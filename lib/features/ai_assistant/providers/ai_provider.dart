import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../../core/config/app_config.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../budgets/providers/budget_provider.dart';
import '../../goals/providers/goal_provider.dart';

class AIProvider extends ChangeNotifier {
  final Dio _dio = Dio();
  
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AIProvider() {
    _initializeDio();
    _addWelcomeMessage();
  }

  void _initializeDio() {
    _dio.options.baseUrl = AppConfig.openRouterBaseUrl;
    _dio.options.headers = {
      'Authorization': 'Bearer ${AppConfig.openRouterApiKey}',
      'Content-Type': 'application/json',
    };
  }

  void _addWelcomeMessage() {
    _messages.add(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: 'Bonjour ! Je suis votre assistant financier intelligent. Je peux vous aider à analyser vos finances, répondre à vos questions sur vos dépenses, revenus, budgets et objectifs. Comment puis-je vous aider aujourd\'hui ?',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<void> sendMessage({
    required String message,
    required TransactionProvider transactionProvider,
    required BudgetProvider budgetProvider,
    required GoalProvider goalProvider,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      // Ajouter le message de l'utilisateur
      final userMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: message,
        isUser: true,
        timestamp: DateTime.now(),
      );
      _messages.add(userMessage);
      notifyListeners();

      // Préparer le contexte financier
      final financialContext = _buildFinancialContext(
        transactionProvider,
        budgetProvider,
        goalProvider,
      );

      // Préparer les messages pour l'IA
      final aiMessages = [
        {
          'role': 'system',
          'content': '''Vous êtes un assistant financier intelligent et bienveillant. Vous aidez les utilisateurs à gérer leurs finances personnelles en français.

Contexte financier actuel de l'utilisateur:
$financialContext

Instructions:
- Répondez toujours en français
- Soyez précis et utile dans vos conseils
- Utilisez les données financières fournies pour donner des conseils personnalisés
- Proposez des actions concrètes quand c'est pertinent
- Soyez encourageant et positif
- Utilisez le symbole CFA pour les montants
- Formatez les nombres avec des espaces pour les milliers (ex: 150 000 CFA)'''
        },
        ...((_messages.length > 10 
            ? _messages.sublist(_messages.length - 10)
            : _messages)
          .map((msg) => {
            'role': msg.isUser ? 'user' : 'assistant',
            'content': msg.content,
          }).toList()),
      ];

      // Appeler l'API OpenRouter
      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': AppConfig.aiModel,
          'messages': aiMessages,
          'max_tokens': 1000,
          'temperature': 0.7,
        },
      );

      final aiResponse = response.data['choices'][0]['message']['content'] as String;

      // Ajouter la réponse de l'IA
      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: aiResponse,
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(aiMessage);

      notifyListeners();
    } catch (e) {
      _setError('Erreur lors de la communication avec l\'IA: ${e.toString()}');
      
      // Ajouter un message d'erreur
      final errorMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'Désolé, je rencontre des difficultés techniques. Veuillez réessayer dans quelques instants.',
        isUser: false,
        timestamp: DateTime.now(),
        isError: true,
      );
      _messages.add(errorMessage);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  String _buildFinancialContext(
    TransactionProvider transactionProvider,
    BudgetProvider budgetProvider,
    GoalProvider goalProvider,
  ) {
    final solde = transactionProvider.soldeTotal;
    final revenus = transactionProvider.revenusMois;
    final depenses = transactionProvider.depensesMois;
    final epargne = revenus - depenses;

    final depensesParCategorie = transactionProvider.depensesParCategorie;
    final budgetsActifs = budgetProvider.budgetsActifs;
    final budgetsDepasses = budgetProvider.budgetsDepasses;
    final goalsActifs = goalProvider.goalsActifs;

    return '''
SITUATION FINANCIÈRE:
- Solde actuel: ${_formatAmount(solde)} CFA
- Revenus ce mois: ${_formatAmount(revenus)} CFA
- Dépenses ce mois: ${_formatAmount(depenses)} CFA
- Épargne ce mois: ${_formatAmount(epargne)} CFA

DÉPENSES PAR CATÉGORIE CE MOIS:
${depensesParCategorie.entries.map((e) => '- ${e.key}: ${_formatAmount(e.value)} CFA').join('\n')}

BUDGETS:
- Nombre de budgets actifs: ${budgetsActifs.length}
- Budgets dépassés: ${budgetsDepasses.length}
${budgetsActifs.take(3).map((b) => '- ${b.nom}: ${_formatAmount(b.montantDepense)} / ${_formatAmount(b.montantLimite)} CFA (${(b.pourcentageUtilise * 100).toStringAsFixed(1)}%)').join('\n')}

OBJECTIFS FINANCIERS:
- Nombre d'objectifs actifs: ${goalsActifs.length}
${goalsActifs.take(3).map((g) => '- ${g.nom}: ${_formatAmount(g.montantActuel)} / ${_formatAmount(g.montantCible)} CFA (${(g.pourcentageProgression * 100).toStringAsFixed(1)}%)').join('\n')}

TRANSACTIONS RÉCENTES:
${transactionProvider.transactions.take(5).map((t) => '- ${t.categorie}: ${t.isRevenu ? '+' : '-'}${_formatAmount(t.montant)} CFA (${t.date.day}/${t.date.month})').join('\n')}
''';
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
  }

  void clearChat() {
    _messages.clear();
    _addWelcomeMessage();
    notifyListeners();
  }

  void clearError() {
    _setError(null);
  }
}

class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
  });
}
