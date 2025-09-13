import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actions rapides',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  context,
                  'Ajouter\nRevenu',
                  Icons.add_circle,
                  AppTheme.successColor,
                  () => Navigator.of(context).pushNamed('/add-revenue'),
                ),
                _buildActionButton(
                  context,
                  'Ajouter\nDépense',
                  Icons.remove_circle,
                  AppTheme.errorColor,
                  () => Navigator.of(context).pushNamed('/add-expense'),
                ),
                _buildActionButton(
                  context,
                  'Voir\nBudgets',
                  Icons.account_balance_wallet,
                  AppTheme.primaryColor,
                  () => Navigator.of(context).pushNamed('/budgets'),
                ),
                _buildActionButton(
                  context,
                  'Assistant\nIA',
                  Icons.smart_toy,
                  AppTheme.warningColor,
                  () => Navigator.of(context).pushNamed('/ai-assistant'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Column(
      children: [
        InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
