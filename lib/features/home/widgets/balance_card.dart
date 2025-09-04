import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/config/app_config.dart';
import '../../transactions/providers/transaction_provider.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        final solde = provider.soldeTotal;
        final revenus = provider.revenusMois;
        final depenses = provider.depensesMois;

        return Card(
          elevation: 4,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Solde actuel',
                  style: TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  NumberFormat.currency(
                    locale: 'fr_FR',
                    symbol: AppConfig.currencySymbol,
                  ).format(solde),
                  style: const TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.arrow_upward,
                                color: AppTheme.textLight,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Revenus',
                                style: TextStyle(
                                  color: AppTheme.textLight,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            NumberFormat.currency(
                              locale: 'fr_FR',
                              symbol: AppConfig.currencySymbol,
                            ).format(revenus),
                            style: const TextStyle(
                              color: AppTheme.textLight,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.arrow_downward,
                                color: AppTheme.textLight,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Dépenses',
                                style: TextStyle(
                                  color: AppTheme.textLight,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            NumberFormat.currency(
                              locale: 'fr_FR',
                              symbol: AppConfig.currencySymbol,
                            ).format(depenses),
                            style: const TextStyle(
                              color: AppTheme.textLight,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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
}
