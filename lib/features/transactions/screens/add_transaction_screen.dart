import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/config/app_config.dart';
import '../providers/transaction_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _montantController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _type = 'depense';
  String? _categorie;
  DateTime _selectedDate = DateTime.now();
  bool _routeParsed = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_routeParsed) return;
    
    // Déterminer le type selon la route
    final routeName = ModalRoute.of(context)?.settings.name;
    if (routeName != null) {
      if (routeName.contains('/add-revenue')) {
        setState(() {
          _type = 'revenu';
        });
      } else if (routeName.contains('/add-expense')) {
        setState(() {
          _type = 'depense';
        });
      }
    }
    
    _routeParsed = true;
  }

  @override
  void dispose() {
    _montantController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  List<String> get _categories {
    return _type == 'revenu' 
        ? AppConfig.defaultIncomeCategories
        : AppConfig.defaultExpenseCategories;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categorie == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une catégorie')),
      );
      return;
    }

    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final success = await provider.addTransaction(
      montant: double.parse(_montantController.text),
      type: _type,
      categorie: _categorie!,
      description: _descriptionController.text.isEmpty 
          ? null 
          : _descriptionController.text,
      date: _selectedDate,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction ajoutée avec succès')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter ${_type == 'revenu' ? 'un revenu' : 'une dépense'}'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // Simplifié: retour direct à l'accueil
            Navigator.of(context).pushReplacementNamed('/home');
          },
        ),
        actions: _type == 'depense' ? [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => Navigator.of(context).pushNamed('/expense-estimation'),
            tooltip: 'Estimation des dépenses',
          ),
        ] : null,
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Sélecteur de type
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Type de transaction',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: RadioListTile<String>(
                                  title: const Text('Revenu'),
                                  value: 'revenu',
                                  groupValue: _type,
                                  onChanged: (value) {
                                    setState(() {
                                      _type = value!;
                                      _categorie = null;
                                    });
                                  },
                                  activeColor: AppTheme.successColor,
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<String>(
                                  title: const Text('Dépense'),
                                  value: 'depense',
                                  groupValue: _type,
                                  onChanged: (value) {
                                    setState(() {
                                      _type = value!;
                                      _categorie = null;
                                    });
                                  },
                                  activeColor: AppTheme.errorColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Montant
                  TextFormField(
                    controller: _montantController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Montant (${AppConfig.currencySymbol})',
                      prefixIcon: Icon(
                        Icons.attach_money,
                        color: _type == 'revenu' 
                            ? AppTheme.successColor 
                            : AppTheme.errorColor,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez saisir un montant';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Montant invalide';
                      }
                      if (double.parse(value) <= 0) {
                        return 'Le montant doit être positif';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Catégorie
                  DropdownButtonFormField<String>(
                    value: _categorie,
                    decoration: const InputDecoration(
                      labelText: 'Catégorie',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _categorie = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Veuillez sélectionner une catégorie';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Date
                  InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        DateFormat('dd/MM/yyyy').format(_selectedDate),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (optionnel)',
                      prefixIcon: Icon(Icons.notes),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),

                  // Message d'erreur
                  if (provider.errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.errorColor),
                      ),
                      child: Text(
                        provider.errorMessage!,
                        style: const TextStyle(color: AppTheme.errorColor),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Bouton d'ajout
                  ElevatedButton(
                    onPressed: provider.isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _type == 'revenu' 
                          ? AppTheme.successColor 
                          : AppTheme.errorColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: provider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.textLight,
                              ),
                            ),
                          )
                        : Text(
                            'Ajouter ${_type == 'revenu' ? 'le revenu' : 'la dépense'}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
