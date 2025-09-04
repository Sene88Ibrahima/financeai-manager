import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

import '../transactions/providers/transaction_provider.dart';
import '../budgets/providers/budget_provider.dart';
import '../goals/providers/goal_provider.dart';

class ExportService {
  static Future<String> exportTransactionsToCsv(TransactionProvider provider) async {
    final transactions = provider.transactions;
    
    // Préparer les données CSV
    List<List<dynamic>> csvData = [
      ['Date', 'Type', 'Catégorie', 'Montant', 'Description']
    ];
    
    for (var transaction in transactions) {
      csvData.add([
        DateFormat('dd/MM/yyyy').format(transaction.date),
        transaction.type,
        transaction.categorie,
        transaction.montant,
        transaction.description ?? '',
      ]);
    }
    
    // Convertir en CSV
    String csv = const ListToCsvConverter().convert(csvData);
    
    // Sauvegarder le fichier
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/transactions_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv');
    await file.writeAsString(csv);
    
    return file.path;
  }
  
  static Future<String> exportBudgetsToCsv(BudgetProvider provider) async {
    final budgets = provider.budgets;
    
    List<List<dynamic>> csvData = [
      ['Nom', 'Montant Limite', 'Montant Dépensé', 'Catégorie', 'Date Début', 'Date Fin', 'Pourcentage Utilisé']
    ];
    
    for (var budget in budgets) {
      csvData.add([
        budget.nom,
        budget.montantLimite,
        budget.montantDepense,
        budget.categorie ?? 'Global',
        DateFormat('dd/MM/yyyy').format(budget.dateDebut),
        DateFormat('dd/MM/yyyy').format(budget.dateFin),
        '${(budget.pourcentageUtilise * 100).toStringAsFixed(1)}%',
      ]);
    }
    
    String csv = const ListToCsvConverter().convert(csvData);
    
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/budgets_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv');
    await file.writeAsString(csv);
    
    return file.path;
  }
  
  static Future<String> exportGoalsToCsv(GoalProvider provider) async {
    final goals = provider.goals;
    
    List<List<dynamic>> csvData = [
      ['Nom', 'Description', 'Montant Cible', 'Montant Actuel', 'Pourcentage', 'Date Création', 'Date Échéance', 'Statut']
    ];
    
    for (var goal in goals) {
      csvData.add([
        goal.nom,
        goal.description,
        goal.montantCible,
        goal.montantActuel,
        '${(goal.pourcentageProgression * 100).toStringAsFixed(1)}%',
        DateFormat('dd/MM/yyyy').format(goal.dateCreation),
        goal.dateEcheance != null ? DateFormat('dd/MM/yyyy').format(goal.dateEcheance!) : '',
        goal.estAtteint ? 'Atteint' : 'En cours',
      ]);
    }
    
    String csv = const ListToCsvConverter().convert(csvData);
    
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/objectifs_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv');
    await file.writeAsString(csv);
    
    return file.path;
  }
  
  static Future<void> shareFile(String filePath, String subject) async {
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: subject,
    );
  }
  
  static Future<List<String>> exportAllData({
    required TransactionProvider transactionProvider,
    required BudgetProvider budgetProvider,
    required GoalProvider goalProvider,
  }) async {
    final files = <String>[];
    
    // Export des transactions
    final transactionsFile = await exportTransactionsToCsv(transactionProvider);
    files.add(transactionsFile);
    
    // Export des budgets
    final budgetsFile = await exportBudgetsToCsv(budgetProvider);
    files.add(budgetsFile);
    
    // Export des objectifs
    final goalsFile = await exportGoalsToCsv(goalProvider);
    files.add(goalsFile);
    
    return files;
  }
}
