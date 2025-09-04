import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/theme/app_theme.dart';
import '../../transactions/providers/transaction_provider.dart';

class ExpenseChart extends StatelessWidget {
  const ExpenseChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        final depensesParCategorie = provider.depensesParCategorie;

        if (depensesParCategorie.isEmpty) {
          return const SizedBox(
            height: 200,
            child: Center(
              child: Text('Aucune dépense à afficher'),
            ),
          );
        }

        return SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: _buildPieChartSections(depensesParCategorie),
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        );
      },
    );
  }

  List<PieChartSectionData> _buildPieChartSections(Map<String, double> data) {
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

    final total = data.values.fold(0.0, (sum, value) => sum + value);
    int colorIndex = 0;

    return data.entries.map((entry) {
      final percentage = (entry.value / total * 100);
      final color = colors[colorIndex % colors.length];
      colorIndex++;

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}
