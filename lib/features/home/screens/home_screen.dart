import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/config/app_config.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../budgets/providers/budget_provider.dart';
import '../../goals/providers/goal_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/balance_card.dart';
import '../widgets/expense_chart.dart';
import '../widgets/monthly_summary.dart';
import '../widgets/quick_actions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
    final goalProvider = Provider.of<GoalProvider>(context, listen: false);

    await Future.wait([
      transactionProvider.loadTransactions(),
      budgetProvider.loadBudgets(),
      goalProvider.loadGoals(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Afficher les notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.of(context).pushNamed('/profile'),
          ),
        ],
      ),
      body: const DashboardTab(),
    );
  }
}

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
        await transactionProvider.loadTransactions();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carte de solde
            const BalanceCard(),
            const SizedBox(height: 20),

            // Actions rapides
            const QuickActions(),
            const SizedBox(height: 20),

            // Résumé mensuel
            const MonthlySummary(),
            const SizedBox(height: 20),

            // Graphique des dépenses
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dépenses par catégorie',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const ExpenseChart(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Transactions récentes
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Transactions récentes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pushNamed('/transactions'),
                          child: const Text('Voir tout'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Consumer<TransactionProvider>(
                      builder: (context, provider, child) {
                        final recentTransactions = provider.transactions
                            .take(5)
                            .toList();

                        if (recentTransactions.isEmpty) {
                          return const Center(
                            child: Text('Aucune transaction récente'),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: recentTransactions.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final transaction = recentTransactions[index];
                            return ListTile(
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
                              title: Text(transaction.categorie),
                              subtitle: transaction.description != null
                                  ? Text(transaction.description!)
                                  : null,
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${transaction.isRevenu ? '+' : '-'}${NumberFormat.currency(
                                      locale: 'fr_FR',
                                      symbol: AppConfig.currencySymbol,
                                    ).format(transaction.montant)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: transaction.isRevenu
                                          ? AppTheme.successColor
                                          : AppTheme.errorColor,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('dd/MM').format(transaction.date),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

