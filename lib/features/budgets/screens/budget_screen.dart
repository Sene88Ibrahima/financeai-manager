import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/config/app_config.dart';
import '../../../core/models/budget.dart';
import '../providers/budget_provider.dart';
import '../../transactions/providers/transaction_provider.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    
    await budgetProvider.loadBudgets();
    budgetProvider.updateBudgetSpending(transactionProvider);
  }

  void _showAddBudgetDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddBudgetDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
        leading: BackButton(
          color: Colors.white,
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddBudgetDialog,
          ),
        ],
      ),
      body: Consumer<BudgetProvider>(
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
                    onPressed: _loadData,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final budgetsActifs = provider.budgetsActifs;
          final budgetsDepasses = provider.budgetsDepasses;
          final budgetsProchesLimite = provider.budgetsProchesLimite;

          return RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Alertes
                  if (budgetsDepasses.isNotEmpty || budgetsProchesLimite.isNotEmpty)
                    _buildAlertsSection(budgetsDepasses, budgetsProchesLimite),

                  // Budgets actifs
                  if (budgetsActifs.isNotEmpty) ...[
                    const Text(
                      'Budgets actifs',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...budgetsActifs.map((budget) => _buildBudgetCard(budget)),
                  ] else
                    const Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            size: 64,
                            color: AppTheme.textSecondary,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Aucun budget actif',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Créez votre premier budget pour mieux gérer vos dépenses',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBudgetDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAlertsSection(List<Budget> budgetsDepasses, List<Budget> budgetsProchesLimite) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Alertes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Budgets dépassés
        ...budgetsDepasses.map((budget) => Card(
          color: AppTheme.errorColor.withOpacity(0.1),
          child: ListTile(
            leading: const Icon(Icons.warning, color: AppTheme.errorColor),
            title: Text(budget.nom),
            subtitle: Text('Budget dépassé de ${NumberFormat.currency(
              locale: 'fr_FR',
              symbol: AppConfig.currencySymbol,
            ).format(budget.montantDepense - budget.montantLimite)}'),
            trailing: Text(
              '${(budget.pourcentageUtilise * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                color: AppTheme.errorColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        )),

        // Budgets proches de la limite
        ...budgetsProchesLimite.map((budget) => Card(
          color: AppTheme.warningColor.withOpacity(0.1),
          child: ListTile(
            leading: const Icon(Icons.info, color: AppTheme.warningColor),
            title: Text(budget.nom),
            subtitle: Text('Attention, vous approchez de la limite'),
            trailing: Text(
              '${(budget.pourcentageUtilise * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                color: AppTheme.warningColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        )),
        
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildBudgetCard(Budget budget) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        budget.nom,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (budget.categorie != null)
                        Text(
                          budget.categorie!,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Modifier'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: AppTheme.errorColor),
                          SizedBox(width: 8),
                          Text('Supprimer', style: TextStyle(color: AppTheme.errorColor)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) async {
                    if (value == 'delete') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Supprimer le budget'),
                          content: Text('Êtes-vous sûr de vouloir supprimer le budget "${budget.nom}" ?'),
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
                        final provider = Provider.of<BudgetProvider>(context, listen: false);
                        await provider.deleteBudget(budget.id);
                      }
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Barre de progression
            LinearProgressIndicator(
              value: budget.pourcentageUtilise.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                budget.estDepasse
                    ? AppTheme.errorColor
                    : budget.doitAlerter
                        ? AppTheme.warningColor
                        : AppTheme.successColor,
              ),
            ),
            const SizedBox(height: 12),
            
            // Informations financières
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dépensé',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      NumberFormat.currency(
                        locale: 'fr_FR',
                        symbol: AppConfig.currencySymbol,
                      ).format(budget.montantDepense),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Limite',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      NumberFormat.currency(
                        locale: 'fr_FR',
                        symbol: AppConfig.currencySymbol,
                      ).format(budget.montantLimite),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Montant restant
            Text(
              'Restant: ${NumberFormat.currency(
                locale: 'fr_FR',
                symbol: AppConfig.currencySymbol,
              ).format(budget.montantRestant)}',
              style: TextStyle(
                color: budget.montantRestant >= 0 
                    ? AppTheme.successColor 
                    : AppTheme.errorColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            // Période
            const SizedBox(height: 8),
            Text(
              'Du ${DateFormat('dd/MM/yyyy').format(budget.dateDebut)} au ${DateFormat('dd/MM/yyyy').format(budget.dateFin)}',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddBudgetDialog extends StatefulWidget {
  const AddBudgetDialog({super.key});

  @override
  State<AddBudgetDialog> createState() => _AddBudgetDialogState();
}

class _AddBudgetDialogState extends State<AddBudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _montantController = TextEditingController();
  
  String? _categorie;
  DateTime _dateDebut = DateTime.now();
  DateTime _dateFin = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
  bool _alerteActive = true;
  double _seuilAlerte = 0.8;

  @override
  void dispose() {
    _nomController.dispose();
    _montantController.dispose();
    super.dispose();
  }

  Future<void> _selectDateDebut() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateDebut,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _dateDebut = picked;
        if (_dateFin.isBefore(_dateDebut)) {
          _dateFin = DateTime(_dateDebut.year, _dateDebut.month + 1, 0);
        }
      });
    }
  }

  Future<void> _selectDateFin() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateFin,
      firstDate: _dateDebut,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _dateFin = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<BudgetProvider>(context, listen: false);
    final success = await provider.addBudget(
      nom: _nomController.text,
      montantLimite: double.parse(_montantController.text),
      categorie: _categorie,
      dateDebut: _dateDebut,
      dateFin: _dateFin,
      alerteActive: _alerteActive,
      seuilAlerte: _seuilAlerte,
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Budget créé avec succès')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouveau budget'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: 'Nom du budget'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir un nom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _montantController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Montant limite (${AppConfig.currencySymbol})',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir un montant';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Montant invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _categorie,
                decoration: const InputDecoration(labelText: 'Catégorie (optionnel)'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Budget global')),
                  ...AppConfig.defaultExpenseCategories.map(
                    (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                  ),
                ],
                onChanged: (value) => setState(() => _categorie = value),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _selectDateDebut,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Date début'),
                        child: Text(DateFormat('dd/MM/yyyy').format(_dateDebut)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: _selectDateFin,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Date fin'),
                        child: Text(DateFormat('dd/MM/yyyy').format(_dateFin)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Alertes activées'),
                value: _alerteActive,
                onChanged: (value) => setState(() => _alerteActive = value),
              ),
              if (_alerteActive)
                Slider(
                  value: _seuilAlerte,
                  min: 0.5,
                  max: 0.95,
                  divisions: 9,
                  label: '${(_seuilAlerte * 100).round()}%',
                  onChanged: (value) => setState(() => _seuilAlerte = value),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _handleSubmit,
          child: const Text('Créer'),
        ),
      ],
    );
  }
}
