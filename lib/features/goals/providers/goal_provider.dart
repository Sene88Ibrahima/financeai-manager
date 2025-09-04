import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../core/models/goal.dart';
import '../../transactions/providers/transaction_provider.dart';

class GoalProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Uuid _uuid = const Uuid();
  
  List<Goal> _goals = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Goal> get goals => List.unmodifiable(_goals);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Goal> get goalsActifs => _goals.where((g) => !g.estAtteint).toList();
  List<Goal> get goalsCompletes => _goals.where((g) => g.estAtteint).toList();
  
  List<Goal> get goalsProchesEcheance {
    final now = DateTime.now();
    return goalsActifs.where((g) => 
        g.dateEcheance != null && 
        g.dateEcheance!.difference(now).inDays <= 30 &&
        g.dateEcheance!.isAfter(now)
    ).toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<void> loadGoals() async {
    try {
      _setLoading(true);
      _setError(null);

      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final response = await _supabase
          .from('goals')
          .select()
          .eq('user_id', user.id)
          .order('date_creation', ascending: false);

      _goals = response
          .map<Goal>((data) => Goal.fromJson(data))
          .toList();

      await _saveToLocal();
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors du chargement: ${e.toString()}');
      await _loadFromLocal();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addGoal({
    required String nom,
    required String description,
    required double montantCible,
    DateTime? dateEcheance,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final user = _supabase.auth.currentUser;
      if (user == null) {
        _setError('Utilisateur non connecté');
        return false;
      }

      final goal = Goal(
        id: _uuid.v4(),
        nom: nom,
        description: description,
        montantCible: montantCible,
        dateCreation: DateTime.now(),
        dateEcheance: dateEcheance,
        userId: user.id,
      );

      await _supabase
          .from('goals')
          .insert(goal.toJson());

      _goals.insert(0, goal);
      await _saveToLocal();

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Erreur lors de l\'ajout: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateGoal(Goal goal) async {
    try {
      _setLoading(true);
      _setError(null);

      await _supabase
          .from('goals')
          .update(goal.toJson())
          .eq('id', goal.id);

      final index = _goals.indexWhere((g) => g.id == goal.id);
      if (index != -1) {
        _goals[index] = goal;
      }

      await _saveToLocal();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Erreur lors de la mise à jour: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteGoal(String goalId) async {
    try {
      _setLoading(true);
      _setError(null);

      await _supabase
          .from('goals')
          .delete()
          .eq('id', goalId);

      _goals.removeWhere((g) => g.id == goalId);
      await _saveToLocal();

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Erreur lors de la suppression: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addProgressToGoal(String goalId, double montant) async {
    try {
      final goalIndex = _goals.indexWhere((g) => g.id == goalId);
      if (goalIndex == -1) return false;

      final goal = _goals[goalIndex];
      goal.montantActuel += montant;
      
      // Vérifier si l'objectif est atteint
      if (goal.montantActuel >= goal.montantCible && !goal.estAtteint) {
        goal.estAtteint = true;
      }

      return await updateGoal(goal);
    } catch (e) {
      _setError('Erreur lors de la mise à jour du progrès: ${e.toString()}');
      return false;
    }
  }

  void updateGoalsProgress(TransactionProvider transactionProvider) {
    // Calculer automatiquement le progrès basé sur l'épargne du mois
    final epargneMois = transactionProvider.revenusMois - transactionProvider.depensesMois;
    final moisCourant = "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}";
    
    for (var goal in _goals) {
      if (!goal.estAtteint && epargneMois > 0) {
        // Incrémenter une seule fois par mois
        if (goal.dernierMoisApplique != moisCourant) {
          final increment = epargneMois * 0.1; // 10% de l'épargne du mois
          goal.montantActuel += increment;
          goal.montantActuel = goal.montantActuel.clamp(0.0, goal.montantCible);
          goal.dernierMoisApplique = moisCourant;
          
          if (goal.montantActuel >= goal.montantCible && !goal.estAtteint) {
            goal.estAtteint = true;
          }
          
          // Persister les changements
          updateGoal(goal);
        }
      }
    }
    notifyListeners();
  }

  int calculateDaysToGoal(Goal goal, double monthlyEpargne) {
    if (monthlyEpargne <= 0) return -1;
    
    final montantRestant = goal.montantRestant;
    if (montantRestant <= 0) return 0;
    
    final moisNecessaires = (montantRestant / monthlyEpargne).ceil();
    return moisNecessaires * 30; // Approximation en jours
  }

  Future<void> _saveToLocal() async {
    try {
      final box = await Hive.openBox<Goal>('goals');
      await box.clear();
      await box.addAll(_goals);
    } catch (e) {
      debugPrint('Erreur sauvegarde locale goals: $e');
    }
  }

  Future<void> _loadFromLocal() async {
    try {
      final box = await Hive.openBox<Goal>('goals');
      _goals = box.values.toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur chargement local goals: $e');
    }
  }

  void clearError() {
    _setError(null);
  }
}
