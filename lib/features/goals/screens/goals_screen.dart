import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/config/app_config.dart';
import '../../../core/models/goal.dart';
import '../providers/goal_provider.dart';
import '../../transactions/providers/transaction_provider.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final goalProvider = Provider.of<GoalProvider>(context, listen: false);
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    
    await goalProvider.loadGoals();
    goalProvider.updateGoalsProgress(transactionProvider);
  }

  void _showAddGoalDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddGoalDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Objectifs financiers'),
        leading: BackButton(
          color: Colors.white,
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddGoalDialog,
          ),
        ],
      ),
      body: Consumer<GoalProvider>(
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

          final goalsActifs = provider.goalsActifs;
          final goalsCompletes = provider.goalsCompletes;

          return RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statistiques rapides
                  _buildStatsCards(provider),
                  const SizedBox(height: 24),

                  // Objectifs actifs
                  if (goalsActifs.isNotEmpty) ...[
                    const Text(
                      'Objectifs en cours',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...goalsActifs.map((goal) => _buildGoalCard(goal, false)),
                    const SizedBox(height: 24),
                  ],

                  // Objectifs complétés
                  if (goalsCompletes.isNotEmpty) ...[
                    const Text(
                      'Objectifs atteints',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...goalsCompletes.map((goal) => _buildGoalCard(goal, true)),
                  ],

                  // Message si aucun objectif
                  if (goalsActifs.isEmpty && goalsCompletes.isEmpty)
                    const Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.flag,
                            size: 64,
                            color: AppTheme.textSecondary,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Aucun objectif défini',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Créez votre premier objectif financier pour vous motiver',
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
        onPressed: _showAddGoalDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatsCards(GoalProvider provider) {
    final totalGoals = provider.goals.length;
    final completedGoals = provider.goalsCompletes.length;
    final activeGoals = provider.goalsActifs.length;

    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.flag, color: AppTheme.primaryColor, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    '$totalGoals',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text('Total'),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.trending_up, color: AppTheme.warningColor, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    '$activeGoals',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text('En cours'),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.check_circle, color: AppTheme.successColor, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    '$completedGoals',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text('Atteints'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalCard(Goal goal, bool isCompleted) {
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
                      Row(
                        children: [
                          if (isCompleted)
                            const Icon(
                              Icons.check_circle,
                              color: AppTheme.successColor,
                              size: 20,
                            ),
                          if (isCompleted) const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              goal.nom,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                decoration: isCompleted ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        goal.description,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    if (!isCompleted)
                      const PopupMenuItem(
                        value: 'progress',
                        child: Row(
                          children: [
                            Icon(Icons.add),
                            SizedBox(width: 8),
                            Text('Ajouter progrès'),
                          ],
                        ),
                      ),
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
                    if (value == 'progress') {
                      _showAddProgressDialog(goal);
                    } else if (value == 'delete') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Supprimer l\'objectif'),
                          content: Text('Êtes-vous sûr de vouloir supprimer l\'objectif "${goal.nom}" ?'),
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
                        final provider = Provider.of<GoalProvider>(context, listen: false);
                        await provider.deleteGoal(goal.id);
                      }
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Barre de progression
            LinearProgressIndicator(
              value: goal.pourcentageProgression.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                isCompleted ? AppTheme.successColor : AppTheme.primaryColor,
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
                      'Progression',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      NumberFormat.currency(
                        locale: 'fr_FR',
                        symbol: AppConfig.currencySymbol,
                      ).format(goal.montantActuel),
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
                      'Objectif',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      NumberFormat.currency(
                        locale: 'fr_FR',
                        symbol: AppConfig.currencySymbol,
                      ).format(goal.montantCible),
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
            
            // Pourcentage et montant restant
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(goal.pourcentageProgression * 100).toStringAsFixed(1)}% atteint',
                  style: TextStyle(
                    color: isCompleted ? AppTheme.successColor : AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (!isCompleted)
                  Text(
                    'Restant: ${NumberFormat.currency(
                      locale: 'fr_FR',
                      symbol: AppConfig.currencySymbol,
                    ).format(goal.montantRestant)}',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
            
            // Échéance
            if (goal.dateEcheance != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: goal.joursRestants != null && goal.joursRestants! <= 30
                        ? AppTheme.warningColor
                        : AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    goal.joursRestants != null && goal.joursRestants! > 0
                        ? 'Échéance dans ${goal.joursRestants} jours (${DateFormat('dd/MM/yyyy').format(goal.dateEcheance!)})'
                        : 'Échéance: ${DateFormat('dd/MM/yyyy').format(goal.dateEcheance!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: goal.joursRestants != null && goal.joursRestants! <= 30
                          ? AppTheme.warningColor
                          : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddProgressDialog(Goal goal) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ajouter progrès - ${goal.nom}'),
        content: TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Montant (${AppConfig.currencySymbol})',
            hintText: 'Ex: 50000',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final montant = double.tryParse(controller.text);
              if (montant != null && montant > 0) {
                final provider = Provider.of<GoalProvider>(context, listen: false);
                final success = await provider.addProgressToGoal(goal.id, montant);
                
                if (success && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Progrès ajouté avec succès')),
                  );
                }
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }
}

class AddGoalDialog extends StatefulWidget {
  const AddGoalDialog({super.key});

  @override
  State<AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<AddGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _montantController = TextEditingController();
  
  DateTime? _dateEcheance;

  @override
  void dispose() {
    _nomController.dispose();
    _descriptionController.dispose();
    _montantController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)), // 10 ans
    );
    if (picked != null) {
      setState(() {
        _dateEcheance = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<GoalProvider>(context, listen: false);
    final success = await provider.addGoal(
      nom: _nomController.text,
      description: _descriptionController.text,
      montantCible: double.parse(_montantController.text),
      dateEcheance: _dateEcheance,
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Objectif créé avec succès')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouvel objectif'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: 'Nom de l\'objectif'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir un nom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir une description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _montantController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Montant cible (${AppConfig.currencySymbol})',
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
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date d\'échéance (optionnel)',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _dateEcheance != null
                        ? DateFormat('dd/MM/yyyy').format(_dateEcheance!)
                        : 'Aucune échéance',
                  ),
                ),
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
