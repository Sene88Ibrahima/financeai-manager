import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/expense_pattern.dart';
import '../../transactions/providers/transaction_provider.dart';

class ExpenseEstimationProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Uuid _uuid = const Uuid();
  
  List<ExpensePattern> _patterns = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ExpensePattern> get patterns => List.unmodifiable(_patterns);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<void> loadPatterns() async {
    try {
      _setLoading(true);
      _setError(null);

      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final response = await _supabase
          .from('expense_patterns')
          .select()
          .eq('user_id', user.id);

      _patterns = response
          .map<ExpensePattern>((data) => ExpensePattern.fromJson(data))
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

  Future<bool> addPattern({
    required String nom,
    required String categorie,
    required double montantJournalier,
    required List<int> joursActifs,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final user = _supabase.auth.currentUser;
      if (user == null) {
        _setError('Utilisateur non connecté');
        return false;
      }

      final pattern = ExpensePattern(
        id: _uuid.v4(),
        nom: nom,
        categorie: categorie,
        montantJournalier: montantJournalier,
        joursActifs: joursActifs,
        userId: user.id,
      );

      await _supabase
          .from('expense_patterns')
          .insert(pattern.toJson());

      _patterns.add(pattern);
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

  Future<bool> updatePattern(ExpensePattern pattern) async {
    try {
      _setLoading(true);
      _setError(null);

      await _supabase
          .from('expense_patterns')
          .update(pattern.toJson())
          .eq('id', pattern.id);

      final index = _patterns.indexWhere((p) => p.id == pattern.id);
      if (index != -1) {
        _patterns[index] = pattern;
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

  Future<bool> deletePattern(String patternId) async {
    try {
      _setLoading(true);
      _setError(null);

      await _supabase
          .from('expense_patterns')
          .delete()
          .eq('id', patternId);

      _patterns.removeWhere((p) => p.id == patternId);
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

  // Calcule l'estimation totale pour le mois courant
  double calculerEstimationMensuelle() {
    final maintenant = DateTime.now();
    double total = 0.0;
    
    for (var pattern in _patterns) {
      if (pattern.estActif) {
        total += pattern.calculerMontantMensuel(maintenant);
      }
    }
    
    return total;
  }

  // Calcule l'estimation par catégorie pour le mois courant
  Map<String, double> calculerEstimationParCategorie() {
    final maintenant = DateTime.now();
    final Map<String, double> estimations = {};
    
    for (var pattern in _patterns) {
      if (pattern.estActif) {
        final montant = pattern.calculerMontantMensuel(maintenant);
        estimations[pattern.categorie] = (estimations[pattern.categorie] ?? 0.0) + montant;
      }
    }
    
    return estimations;
  }

  // Suggère des transactions automatiques basées sur les patterns
  Future<void> suggerTransactionsForToday(TransactionProvider transactionProvider) async {
    final aujourd_hui = DateTime.now();
    final jourSemaine = aujourd_hui.weekday;
    
    for (var pattern in _patterns) {
      if (pattern.estActif && pattern.joursActifs.contains(jourSemaine)) {
        // Vérifier si une transaction similaire n'existe pas déjà aujourd'hui
        final transactionsAujourdhui = transactionProvider.transactions
            .where((t) => 
                t.date.year == aujourd_hui.year &&
                t.date.month == aujourd_hui.month &&
                t.date.day == aujourd_hui.day &&
                t.categorie == pattern.categorie)
            .toList();
        
        if (transactionsAujourdhui.isEmpty) {
          // Suggérer l'ajout de cette transaction
          // Cette logique pourrait être étendue pour afficher des notifications
          debugPrint('Suggestion: ${pattern.nom} - ${pattern.montantJournalier} FCFA');
        }
      }
    }
  }

  Future<void> _saveToLocal() async {
    try {
      final box = await Hive.openBox<ExpensePattern>('expense_patterns');
      await box.clear();
      await box.addAll(_patterns);
    } catch (e) {
      debugPrint('Erreur sauvegarde locale patterns: $e');
    }
  }

  Future<void> _loadFromLocal() async {
    try {
      final box = await Hive.openBox<ExpensePattern>('expense_patterns');
      _patterns = box.values.toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur chargement local patterns: $e');
    }
  }

  void clearError() {
    _setError(null);
  }
}
