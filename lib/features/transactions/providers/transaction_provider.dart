import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../core/models/transaction.dart';
import '../../../core/config/app_config.dart';

class TransactionProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Uuid _uuid = const Uuid();
  
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Transaction> get transactions => List.unmodifiable(_transactions);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Calculs financiers
  double get soldeTotal {
    double revenus = 0;
    double depenses = 0;
    
    for (var transaction in _transactions) {
      if (transaction.isRevenu) {
        revenus += transaction.montant;
      } else {
        depenses += transaction.montant;
      }
    }
    
    return revenus - depenses;
  }

  double get revenusMois {
    final now = DateTime.now();
    final debutMois = DateTime(now.year, now.month, 1);
    final finMois = DateTime(now.year, now.month + 1, 0);

    return _transactions
        .where((t) => t.isRevenu && 
                     t.date.isAfter(debutMois.subtract(const Duration(days: 1))) &&
                     t.date.isBefore(finMois.add(const Duration(days: 1))))
        .fold(0.0, (sum, t) => sum + t.montant);
  }

  double get depensesMois {
    final now = DateTime.now();
    final debutMois = DateTime(now.year, now.month, 1);
    final finMois = DateTime(now.year, now.month + 1, 0);

    return _transactions
        .where((t) => t.isDepense && 
                     t.date.isAfter(debutMois.subtract(const Duration(days: 1))) &&
                     t.date.isBefore(finMois.add(const Duration(days: 1))))
        .fold(0.0, (sum, t) => sum + t.montant);
  }

  Map<String, double> get depensesParCategorie {
    final Map<String, double> result = {};
    
    for (var transaction in _transactions) {
      if (transaction.isDepense) {
        result[transaction.categorie] = 
            (result[transaction.categorie] ?? 0) + transaction.montant;
      }
    }
    
    return result;
  }

  List<Transaction> getTransactionsByMonth(DateTime month) {
    final debutMois = DateTime(month.year, month.month, 1);
    final finMois = DateTime(month.year, month.month + 1, 0);

    return _transactions
        .where((t) => t.date.isAfter(debutMois.subtract(const Duration(days: 1))) &&
                     t.date.isBefore(finMois.add(const Duration(days: 1))))
        .toList();
  }

  List<Transaction> getTransactionsByCategory(String category) {
    return _transactions
        .where((t) => t.categorie == category)
        .toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<void> loadTransactions() async {
    try {
      _setLoading(true);
      _setError(null);

      final user = _supabase.auth.currentUser;
      if (user == null) return;

      // Charger depuis Supabase
      final response = await _supabase
          .from('transactions')
          .select()
          .eq('user_id', user.id)
          .order('date', ascending: false);

      _transactions = response
          .map<Transaction>((data) => Transaction.fromJson(data))
          .toList();

      // Sauvegarder en local avec Hive
      await _saveToLocal();

      notifyListeners();
    } catch (e) {
      _setError('Erreur lors du chargement: ${e.toString()}');
      // Charger depuis le cache local en cas d'erreur
      await _loadFromLocal();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addTransaction({
    required double montant,
    required String type,
    required String categorie,
    String? description,
    DateTime? date,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final user = _supabase.auth.currentUser;
      if (user == null) {
        _setError('Utilisateur non connecté');
        return false;
      }

      final transaction = Transaction(
        id: _uuid.v4(),
        montant: montant,
        type: type,
        categorie: categorie,
        description: description,
        date: date ?? DateTime.now(),
        dateCreation: DateTime.now(),
        userId: user.id,
      );

      // Sauvegarder sur Supabase
      await _supabase
          .from('transactions')
          .insert(transaction.toJson());

      // Ajouter à la liste locale
      _transactions.insert(0, transaction);
      
      // Sauvegarder en local
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

  Future<bool> updateTransaction(Transaction transaction) async {
    try {
      _setLoading(true);
      _setError(null);

      // Mettre à jour sur Supabase
      await _supabase
          .from('transactions')
          .update(transaction.toJson())
          .eq('id', transaction.id);

      // Mettre à jour dans la liste locale
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
      }

      // Sauvegarder en local
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

  Future<bool> deleteTransaction(String transactionId) async {
    try {
      _setLoading(true);
      _setError(null);

      // Supprimer de Supabase
      await _supabase
          .from('transactions')
          .delete()
          .eq('id', transactionId);

      // Supprimer de la liste locale
      _transactions.removeWhere((t) => t.id == transactionId);

      // Sauvegarder en local
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

  Future<void> _saveToLocal() async {
    try {
      final box = await Hive.openBox<Transaction>('transactions');
      await box.clear();
      await box.addAll(_transactions);
    } catch (e) {
      debugPrint('Erreur sauvegarde locale: $e');
    }
  }

  Future<void> _loadFromLocal() async {
    try {
      final box = await Hive.openBox<Transaction>('transactions');
      _transactions = box.values.toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur chargement local: $e');
    }
  }

  void clearError() {
    _setError(null);
  }

  // Export des données
  List<Map<String, dynamic>> exportToCsv() {
    return _transactions.map((t) => {
      'Date': t.date.toIso8601String(),
      'Type': t.type,
      'Catégorie': t.categorie,
      'Montant': t.montant,
      'Description': t.description ?? '',
    }).toList();
  }
}
