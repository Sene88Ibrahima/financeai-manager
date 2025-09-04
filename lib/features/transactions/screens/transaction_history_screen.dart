import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/config/app_config.dart';
import '../../../core/models/transaction.dart';
import '../providers/transaction_provider.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String _filterType = 'tous';
  String? _filterCategory;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    await provider.loadTransactions();
  }

  List<Transaction> _getFilteredTransactions(List<Transaction> transactions) {
    List<Transaction> filtered = transactions;

    // Filtrer par type
    if (_filterType != 'tous') {
      filtered = filtered.where((t) => t.type == _filterType).toList();
    }

    // Filtrer par catégorie
    if (_filterCategory != null) {
      filtered = filtered.where((t) => t.categorie == _filterCategory).toList();
    }

    // Filtrer par date
    if (_startDate != null) {
      filtered = filtered.where((t) => t.date.isAfter(_startDate!.subtract(const Duration(days: 1)))).toList();
    }
    if (_endDate != null) {
      filtered = filtered.where((t) => t.date.isBefore(_endDate!.add(const Duration(days: 1)))).toList();
    }

    return filtered;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtres'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: _filterType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [
                    DropdownMenuItem(value: 'tous', child: Text('Tous')),
                    DropdownMenuItem(value: 'revenu', child: Text('Revenus')),
                    DropdownMenuItem(value: 'depense', child: Text('Dépenses')),
                  ],
                  onChanged: (value) => setState(() => _filterType = value!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _filterCategory,
                  decoration: const InputDecoration(labelText: 'Catégorie'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Toutes')),
                    ...AppConfig.defaultExpenseCategories.map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    ),
                    ...AppConfig.defaultIncomeCategories.map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    ),
                  ],
                  onChanged: (value) => setState(() => _filterCategory = value),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _filterType = 'tous';
                _filterCategory = null;
                _startDate = null;
                _endDate = null;
              });
              Navigator.pop(context);
            },
            child: const Text('Réinitialiser'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Appliquer'),
          ),
        ],
      ),
    );
  }

  double _calculateBalanceAfterTransaction(Transaction transaction) {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final transactions = provider.transactions;
    
    // Trier les transactions par date
    final sortedTransactions = List<Transaction>.from(transactions)
      ..sort((a, b) => a.date.compareTo(b.date));
    
    double balance = 0.0;
    for (var t in sortedTransactions) {
      if (t.isRevenu) {
        balance += t.montant;
      } else {
        balance -= t.montant;
      }
      
      // Si c'est la transaction recherchée, retourner le solde à ce moment
      if (t.id == transaction.id) {
        return balance;
      }
    }
    
    return balance;
  }

  void _showTransactionDetails(Transaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: transaction.isRevenu
                          ? AppTheme.successColor.withOpacity(0.2)
                          : AppTheme.errorColor.withOpacity(0.2),
                      child: Icon(
                        transaction.isRevenu
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color: transaction.isRevenu
                            ? AppTheme.successColor
                            : AppTheme.errorColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.categorie,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            transaction.type.toUpperCase(),
                            style: TextStyle(
                              color: transaction.isRevenu
                                  ? AppTheme.successColor
                                  : AppTheme.errorColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${transaction.isRevenu ? '+' : '-'}${NumberFormat.currency(
                        locale: 'fr_FR',
                        symbol: AppConfig.currencySymbol,
                      ).format(transaction.montant)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: transaction.isRevenu
                            ? AppTheme.successColor
                            : AppTheme.errorColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildDetailRow('Date', DateFormat('dd/MM/yyyy à HH:mm').format(transaction.date)),
                if (transaction.description != null)
                  _buildDetailRow('Description', transaction.description!),
                _buildDetailRow('Créé le', DateFormat('dd/MM/yyyy à HH:mm').format(transaction.dateCreation)),
                _buildDetailRow('Solde après transaction', 
                  NumberFormat.currency(
                    locale: 'fr_FR',
                    symbol: AppConfig.currencySymbol,
                  ).format(_calculateBalanceAfterTransaction(transaction))),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          // TODO: Implémenter la modification
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Modifier'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Supprimer la transaction'),
                              content: const Text('Êtes-vous sûr de vouloir supprimer cette transaction ?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Annuler'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.errorColor,
                                  ),
                                  child: const Text('Supprimer'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true && mounted) {
                            final provider = Provider.of<TransactionProvider>(context, listen: false);
                            final success = await provider.deleteTransaction(transaction.id);
                            
                            if (success && mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Transaction supprimée')),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.errorColor,
                        ),
                        icon: const Icon(Icons.delete),
                        label: const Text('Supprimer'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // TODO: Implémenter l'export
            },
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadTransactions,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final filteredTransactions = _getFilteredTransactions(provider.transactions);

          if (filteredTransactions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 64,
                    color: AppTheme.textSecondary,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Aucune transaction trouvée',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadTransactions,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filteredTransactions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final transaction = filteredTransactions[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: transaction.isRevenu
                          ? AppTheme.successColor.withOpacity(0.2)
                          : AppTheme.errorColor.withOpacity(0.2),
                      child: Icon(
                        transaction.isRevenu
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color: transaction.isRevenu
                            ? AppTheme.successColor
                            : AppTheme.errorColor,
                      ),
                    ),
                    title: Text(
                      transaction.categorie,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (transaction.description != null)
                          Text(transaction.description!),
                        Text(
                          DateFormat('dd/MM/yyyy à HH:mm').format(transaction.date),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    trailing: Text(
                      '${transaction.isRevenu ? '+' : '-'}${NumberFormat.currency(
                        locale: 'fr_FR',
                        symbol: AppConfig.currencySymbol,
                      ).format(transaction.montant)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: transaction.isRevenu
                            ? AppTheme.successColor
                            : AppTheme.errorColor,
                      ),
                    ),
                    onTap: () => _showTransactionDetails(transaction),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/add-expense'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
