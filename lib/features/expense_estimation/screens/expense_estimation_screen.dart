import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/config/app_config.dart';
import '../models/expense_pattern.dart';
import '../providers/expense_estimation_provider.dart';

class ExpenseEstimationScreen extends StatefulWidget {
  const ExpenseEstimationScreen({super.key});

  @override
  State<ExpenseEstimationScreen> createState() => _ExpenseEstimationScreenState();
}

class _ExpenseEstimationScreenState extends State<ExpenseEstimationScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<ExpenseEstimationProvider>(context, listen: false);
    await provider.loadPatterns();
  }

  void _showAddPatternDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddPatternDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estimation des dépenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddPatternDialog,
          ),
        ],
      ),
      body: Consumer<ExpenseEstimationProvider>(
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

          return RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Résumé des estimations
                  _buildEstimationSummary(provider),
                  const SizedBox(height: 24),

                  // Liste des patterns
                  const Text(
                    'Patterns de dépenses',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (provider.patterns.isEmpty)
                    const Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.pattern,
                            size: 64,
                            color: AppTheme.textSecondary,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Aucun pattern défini',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Créez des patterns pour estimer vos dépenses récurrentes',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...provider.patterns.map((pattern) => _buildPatternCard(pattern)),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPatternDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEstimationSummary(ExpenseEstimationProvider provider) {
    final estimationTotale = provider.calculerEstimationMensuelle();
    final estimationsParCategorie = provider.calculerEstimationParCategorie();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estimation mensuelle',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Total
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total estimé',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    NumberFormat.currency(
                      locale: 'fr_FR',
                      symbol: AppConfig.currencySymbol,
                    ).format(estimationTotale),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            
            // Par catégorie
            if (estimationsParCategorie.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Par catégorie',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              ...estimationsParCategorie.entries.map((entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key),
                    Text(
                      NumberFormat.currency(
                        locale: 'fr_FR',
                        symbol: AppConfig.currencySymbol,
                      ).format(entry.value),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPatternCard(ExpensePattern pattern) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                        pattern.nom,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pattern.categorie,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: pattern.estActif,
                  onChanged: (value) async {
                    pattern.estActif = value;
                    final provider = Provider.of<ExpenseEstimationProvider>(context, listen: false);
                    await provider.updatePattern(pattern);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Montant journalier',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      NumberFormat.currency(
                        locale: 'fr_FR',
                        symbol: AppConfig.currencySymbol,
                      ).format(pattern.montantJournalier),
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
                      'Estimation mensuelle',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      NumberFormat.currency(
                        locale: 'fr_FR',
                        symbol: AppConfig.currencySymbol,
                      ).format(pattern.calculerMontantMensuel(DateTime.now())),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            Text(
              'Jours: ${pattern.joursActifsTexte}',
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

class AddPatternDialog extends StatefulWidget {
  const AddPatternDialog({super.key});

  @override
  State<AddPatternDialog> createState() => _AddPatternDialogState();
}

class _AddPatternDialogState extends State<AddPatternDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _categorieController = TextEditingController();
  final _montantController = TextEditingController();
  
  final List<bool> _joursSelectionnes = List.filled(7, false);
  final List<String> _nomsJours = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

  @override
  void dispose() {
    _nomController.dispose();
    _categorieController.dispose();
    _montantController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final joursActifs = <int>[];
    for (int i = 0; i < _joursSelectionnes.length; i++) {
      if (_joursSelectionnes[i]) {
        joursActifs.add(i + 1); // 1=lundi, 7=dimanche
      }
    }
    
    if (joursActifs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner au moins un jour')),
      );
      return;
    }

    final provider = Provider.of<ExpenseEstimationProvider>(context, listen: false);
    final success = await provider.addPattern(
      nom: _nomController.text,
      categorie: _categorieController.text,
      montantJournalier: double.parse(_montantController.text),
      joursActifs: joursActifs,
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pattern créé avec succès')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouveau pattern'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: 'Nom du pattern'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir un nom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categorieController,
                decoration: const InputDecoration(labelText: 'Catégorie'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir une catégorie';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _montantController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Montant journalier (${AppConfig.currencySymbol})',
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
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Jours de la semaine',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: List.generate(7, (index) {
                  return FilterChip(
                    label: Text(_nomsJours[index]),
                    selected: _joursSelectionnes[index],
                    onSelected: (selected) {
                      setState(() {
                        _joursSelectionnes[index] = selected;
                      });
                    },
                  );
                }),
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
