import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../core/models/budget.dart';
import '../../transactions/providers/transaction_provider.dart';

class BudgetProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Uuid _uuid = const Uuid();
  
  List<Budget> _budgets = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Budget> get budgets => List.unmodifiable(_budgets);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Budget> get budgetsActifs {
    final now = DateTime.now();
    return _budgets.where((b) => 
        b.dateDebut.isBefore(now.add(const Duration(days: 1))) &&
        b.dateFin.isAfter(now.subtract(const Duration(days: 1)))
    ).toList();
  }

  List<Budget> get budgetsDepasses {
    return budgetsActifs.where((b) => b.estDepasse).toList();
  }

  List<Budget> get budgetsProchesLimite {
    return budgetsActifs.where((b) => b.doitAlerter && !b.estDepasse).toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<void> loadBudgets() async {
    try {
      _setLoading(true);
      _setError(null);

      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final response = await _supabase
          .from('budgets')
          .select()
          .eq('user_id', user.id)
          .order('date_debut', ascending: false);

      _budgets = response
          .map<Budget>((data) => Budget.fromJson(data))
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

  Future<bool> addBudget({
    required String nom,
    required double montantLimite,
    String? categorie,
    required DateTime dateDebut,
    required DateTime dateFin,
    bool alerteActive = true,
    double seuilAlerte = 0.8,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final user = _supabase.auth.currentUser;
      if (user == null) {
        _setError('Utilisateur non connecté');
        return false;
      }

      final budget = Budget(
        id: _uuid.v4(),
        nom: nom,
        montantLimite: montantLimite,
        categorie: categorie,
        dateDebut: dateDebut,
        dateFin: dateFin,
        alerteActive: alerteActive,
        seuilAlerte: seuilAlerte,
        userId: user.id,
      );

      await _supabase
          .from('budgets')
          .insert(budget.toJson());

      _budgets.insert(0, budget);
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

  Future<bool> updateBudget(Budget budget) async {
    try {
      _setLoading(true);
      _setError(null);

      await _supabase
          .from('budgets')
          .update(budget.toJson())
          .eq('id', budget.id);

      final index = _budgets.indexWhere((b) => b.id == budget.id);
      if (index != -1) {
        _budgets[index] = budget;
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

  Future<bool> deleteBudget(String budgetId) async {
    try {
      _setLoading(true);
      _setError(null);

      await _supabase
          .from('budgets')
          .delete()
          .eq('id', budgetId);

      _budgets.removeWhere((b) => b.id == budgetId);
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

  void updateBudgetSpending(TransactionProvider transactionProvider) {
    for (var budget in _budgets) {
      double totalDepenses = 0;

      if (budget.estGlobal) {
        // Budget global : toutes les dépenses
        totalDepenses = transactionProvider.transactions
            .where((t) => 
                t.isDepense &&
                t.date.isAfter(budget.dateDebut.subtract(const Duration(days: 1))) &&
                t.date.isBefore(budget.dateFin.add(const Duration(days: 1))))
            .fold(0.0, (sum, t) => sum + t.montant);
      } else {
        // Budget par catégorie
        totalDepenses = transactionProvider.transactions
            .where((t) => 
                t.isDepense &&
                t.categorie == budget.categorie &&
                t.date.isAfter(budget.dateDebut.subtract(const Duration(days: 1))) &&
                t.date.isBefore(budget.dateFin.add(const Duration(days: 1))))
            .fold(0.0, (sum, t) => sum + t.montant);
      }

      if (budget.montantDepense != totalDepenses) {
        budget.montantDepense = totalDepenses;
      }
    }
    notifyListeners();
  }

  Budget? getBudgetForCategory(String category) {
    final now = DateTime.now();
    return _budgets
        .where((b) => 
            b.categorie == category &&
            b.dateDebut.isBefore(now.add(const Duration(days: 1))) &&
            b.dateFin.isAfter(now.subtract(const Duration(days: 1))))
        .firstOrNull;
  }

  Budget? getGlobalBudget() {
    final now = DateTime.now();
    return _budgets
        .where((b) => 
            b.estGlobal &&
            b.dateDebut.isBefore(now.add(const Duration(days: 1))) &&
            b.dateFin.isAfter(now.subtract(const Duration(days: 1))))
        .firstOrNull;
  }

  Future<void> _saveToLocal() async {
    try {
      final box = await Hive.openBox<Budget>('budgets');
      await box.clear();
      await box.addAll(_budgets);
    } catch (e) {
      debugPrint('Erreur sauvegarde locale budgets: $e');
    }
  }

  Future<void> _loadFromLocal() async {
    try {
      final box = await Hive.openBox<Budget>('budgets');
      _budgets = box.values.toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur chargement local budgets: $e');
    }
  }

  void clearError() {
    _setError(null);
  }
}
