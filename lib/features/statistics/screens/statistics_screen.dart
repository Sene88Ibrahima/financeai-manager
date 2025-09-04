import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/config/app_config.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../budgets/providers/budget_provider.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedPeriod = 0; // 0: Ce mois, 1: 3 mois, 2: 6 mois, 3: 1 an

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Aperçu'),
            Tab(text: 'Graphiques'),
            Tab(text: 'Tendances'),
          ],
        ),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.date_range),
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 0, child: Text('Ce mois')),
              const PopupMenuItem(value: 1, child: Text('3 derniers mois')),
              const PopupMenuItem(value: 2, child: Text('6 derniers mois')),
              const PopupMenuItem(value: 3, child: Text('1 an')),
            ],
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildChartsTab(),
          _buildTrendsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Résumé financier
              _buildFinancialSummary(provider),
              const SizedBox(height: 24),

              // Top catégories de dépenses
              _buildTopExpenseCategories(provider),
              const SizedBox(height: 24),

              // Comparaison mensuelle
              _buildMonthlyComparison(provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChartsTab() {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Graphique en secteurs des dépenses
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Répartition des dépenses',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 300,
                        child: _buildExpensePieChart(provider),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Graphique linéaire des revenus/dépenses
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Évolution revenus/dépenses',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 300,
                        child: _buildIncomeExpenseLineChart(provider),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrendsTab() {
    return Consumer2<TransactionProvider, BudgetProvider>(
      builder: (context, transactionProvider, budgetProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tendances d'épargne
              _buildSavingsTrends(transactionProvider),
              const SizedBox(height: 24),

              // Performance des budgets
              _buildBudgetPerformance(budgetProvider),
              const SizedBox(height: 24),

              // Prévisions
              _buildPredictions(transactionProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFinancialSummary(TransactionProvider provider) {
    final solde = provider.soldeTotal;
    final revenus = provider.revenusMois;
    final depenses = provider.depensesMois;
    final epargne = revenus - depenses;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Résumé financier',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Solde total',
                    solde,
                    Icons.account_balance,
                    solde >= 0 ? AppTheme.successColor : AppTheme.errorColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSummaryCard(
                    'Revenus',
                    revenus,
                    Icons.trending_up,
                    AppTheme.successColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Dépenses',
                    depenses,
                    Icons.trending_down,
                    AppTheme.errorColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSummaryCard(
                    'Épargne du mois',
                    epargne,
                    Icons.savings,
                    epargne >= 0 ? AppTheme.successColor : AppTheme.errorColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            NumberFormat.currency(
              locale: 'fr_FR',
              symbol: AppConfig.currencySymbol,
            ).format(amount),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTopExpenseCategories(TransactionProvider provider) {
    final depensesParCategorie = provider.depensesParCategorie;
    final sortedCategories = depensesParCategorie.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top catégories de dépenses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...sortedCategories.take(5).map((entry) {
              final percentage = depensesParCategorie.values.isNotEmpty
                  ? (entry.value / depensesParCategorie.values.reduce((a, b) => a + b)) * 100
                  : 0.0;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: Colors.grey[300],
                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          NumberFormat.currency(
                            locale: 'fr_FR',
                            symbol: AppConfig.currencySymbol,
                          ).format(entry.value),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyComparison(TransactionProvider provider) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final lastMonth = DateTime(now.year, now.month - 1);

    final currentMonthTransactions = provider.getTransactionsByMonth(currentMonth);
    final lastMonthTransactions = provider.getTransactionsByMonth(lastMonth);

    final currentRevenues = currentMonthTransactions
        .where((t) => t.isRevenu)
        .fold(0.0, (sum, t) => sum + t.montant);
    final currentExpenses = currentMonthTransactions
        .where((t) => t.isDepense)
        .fold(0.0, (sum, t) => sum + t.montant);

    final lastRevenues = lastMonthTransactions
        .where((t) => t.isRevenu)
        .fold(0.0, (sum, t) => sum + t.montant);
    final lastExpenses = lastMonthTransactions
        .where((t) => t.isDepense)
        .fold(0.0, (sum, t) => sum + t.montant);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Comparaison mensuelle',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildComparisonItem(
                    'Revenus',
                    currentRevenues,
                    lastRevenues,
                    AppTheme.successColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildComparisonItem(
                    'Dépenses',
                    currentExpenses,
                    lastExpenses,
                    AppTheme.errorColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonItem(String title, double current, double previous, Color color) {
    final difference = current - previous;
    final percentageChange = previous != 0 ? (difference / previous) * 100 : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          NumberFormat.currency(
            locale: 'fr_FR',
            symbol: AppConfig.currencySymbol,
          ).format(current),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              difference >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
              size: 16,
              color: difference >= 0 ? AppTheme.successColor : AppTheme.errorColor,
            ),
            const SizedBox(width: 4),
            Text(
              '${percentageChange.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 12,
                color: difference >= 0 ? AppTheme.successColor : AppTheme.errorColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExpensePieChart(TransactionProvider provider) {
    final depensesParCategorie = provider.depensesParCategorie;
    
    if (depensesParCategorie.isEmpty) {
      return const Center(child: Text('Aucune donnée à afficher'));
    }

    final colors = [
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
      AppTheme.accentColor,
      AppTheme.warningColor,
      AppTheme.errorColor,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.indigo,
    ];

    final total = depensesParCategorie.values.fold(0.0, (sum, value) => sum + value);
    int colorIndex = 0;
    
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: depensesParCategorie.entries.map((entry) {
                final color = colors[colorIndex % colors.length];
                final percentage = (entry.value / total * 100);
                colorIndex++;
                
                return PieChartSectionData(
                  color: color,
                  value: entry.value,
                  title: percentage >= 5 ? '${percentage.toStringAsFixed(1)}%' : '',
                  radius: 80,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
                  ),
                  badgeWidget: percentage < 5 ? _buildSmallPercentageBadge(percentage) : null,
                  badgePositionPercentageOffset: 1.2,
                );
              }).toList(),
              centerSpaceRadius: 40,
              sectionsSpace: 2,
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  // Pour interactions futures
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildChartLegend(depensesParCategorie, colors),
      ],
    );
  }

  Widget _buildChartLegend(Map<String, double> data, List<Color> colors) {
    final total = data.values.fold(0.0, (sum, value) => sum + value);
    int colorIndex = 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Catégories',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                'Total: ${NumberFormat.currency(
                  locale: 'fr_FR',
                  symbol: AppConfig.currencySymbol,
                ).format(total)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...data.entries.map((entry) {
            final color = colors[colorIndex % colors.length];
            final percentage = (entry.value / total * 100);
            colorIndex++;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Text(
                    NumberFormat.currency(
                      locale: 'fr_FR',
                      symbol: AppConfig.currencySymbol,
                    ).format(entry.value),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 11,
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSmallPercentageBadge(double percentage) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 2,
          ),
        ],
      ),
      child: Text(
        '${percentage.toStringAsFixed(1)}%',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildExpensePieChartOld(TransactionProvider provider) {
    final depensesParCategorie = provider.depensesParCategorie;
    
    if (depensesParCategorie.isEmpty) {
      return const Center(child: Text('Aucune donnée à afficher'));
    }

    final colors = [
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
      AppTheme.accentColor,
      AppTheme.warningColor,
      AppTheme.errorColor,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.indigo,
    ];

    int colorIndex = 0;
    final sections = depensesParCategorie.entries.map((entry) {
      final color = colors[colorIndex % colors.length];
      colorIndex++;
      
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: entry.key,
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }

  Widget _buildIncomeExpenseLineChart(TransactionProvider provider) {
    // Données des 6 derniers mois
    final now = DateTime.now();
    final months = List.generate(6, (index) {
      return DateTime(now.year, now.month - index);
    }).reversed.toList();

    final revenusData = <FlSpot>[];
    final depensesData = <FlSpot>[];

    for (int i = 0; i < months.length; i++) {
      final month = months[i];
      final transactions = provider.getTransactionsByMonth(month);
      
      final revenus = transactions
          .where((t) => t.isRevenu)
          .fold(0.0, (sum, t) => sum + t.montant);
      final depenses = transactions
          .where((t) => t.isDepense)
          .fold(0.0, (sum, t) => sum + t.montant);

      revenusData.add(FlSpot(i.toDouble(), revenus));
      depensesData.add(FlSpot(i.toDouble(), depenses));
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < months.length) {
                  final month = months[value.toInt()];
                  return Text(
                    DateFormat('MMM').format(month),
                    style: const TextStyle(fontSize: 12),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${(value / 1000).toStringAsFixed(0)}k',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: revenusData,
            isCurved: true,
            color: AppTheme.successColor,
            barWidth: 3,
            dotData: const FlDotData(show: true),
          ),
          LineChartBarData(
            spots: depensesData,
            isCurved: true,
            color: AppTheme.errorColor,
            barWidth: 3,
            dotData: const FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsTrends(TransactionProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tendances d\'épargne',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Analyse des tendances d\'épargne en cours de développement...'),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetPerformance(BudgetProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance des budgets',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Analyse de la performance des budgets en cours de développement...'),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictions(TransactionProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Prévisions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Prévisions financières en cours de développement...'),
          ],
        ),
      ),
    );
  }
}
