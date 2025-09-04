import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/config/app_config.dart';
import '../../transactions/providers/transaction_provider.dart';

class MonthlySummary extends StatelessWidget {
  const MonthlySummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
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
                  'Résumé du mois',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryItem(
                        'Revenus',
                        revenus,
                        Icons.trending_up,
                        AppTheme.successColor,
                      ),
                    ),
                    Expanded(
                      child: _buildSummaryItem(
                        'Dépenses',
                        depenses,
                        Icons.trending_down,
                        AppTheme.errorColor,
                      ),
                    ),
                    Expanded(
                      child: _buildSummaryItem(
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
      },
    );
  }

  Widget _buildSummaryItem(String label, double montant, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          label,
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
          ).format(montant),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
