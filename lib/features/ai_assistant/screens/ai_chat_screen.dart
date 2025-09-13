import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/ai_provider.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../budgets/providers/budget_provider.dart';
import '../../goals/providers/goal_provider.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();

    final aiProvider = Provider.of<AIProvider>(context, listen: false);
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
    final goalProvider = Provider.of<GoalProvider>(context, listen: false);

    await aiProvider.sendMessage(
      message: message,
      transactionProvider: transactionProvider,
      budgetProvider: budgetProvider,
      goalProvider: goalProvider,
    );

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistant IA'),
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final aiProvider = Provider.of<AIProvider>(context, listen: false);
              aiProvider.clearChat();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: Consumer<AIProvider>(
              builder: (context, provider, child) {
                if (provider.messages.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.messages.length,
                  itemBuilder: (context, index) {
                    final message = provider.messages[index];
                    return _buildMessageBubble(message);
                  },
                );
              },
            ),
          ),

          // Zone de saisie
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Consumer<AIProvider>(
              builder: (context, provider, child) {
                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Posez une question sur vos finances...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        maxLines: null,
                        enabled: !provider.isLoading,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FloatingActionButton(
                      mini: true,
                      onPressed: provider.isLoading ? null : _sendMessage,
                      child: provider.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.textLight,
                                ),
                              ),
                            )
                          : const Icon(Icons.send),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Column(
          crossAxisAlignment: message.isUser 
              ? CrossAxisAlignment.end 
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? AppTheme.primaryColor
                    : message.isError
                        ? AppTheme.errorColor.withOpacity(0.1)
                        : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomRight: message.isUser 
                      ? const Radius.circular(4) 
                      : const Radius.circular(16),
                  bottomLeft: message.isUser 
                      ? const Radius.circular(16) 
                      : const Radius.circular(4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!message.isUser)
                    Row(
                      children: [
                        Icon(
                          message.isError ? Icons.error : Icons.smart_toy,
                          size: 16,
                          color: message.isError 
                              ? AppTheme.errorColor 
                              : AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          message.isError ? 'Erreur' : 'Assistant IA',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: message.isError 
                                ? AppTheme.errorColor 
                                : AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  if (!message.isUser) const SizedBox(height: 4),
                  Text(
                    message.content,
                    style: TextStyle(
                      color: message.isUser 
                          ? AppTheme.textLight 
                          : message.isError
                              ? AppTheme.errorColor
                              : AppTheme.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(message.timestamp),
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

// Exemples de questions prédéfinies
class QuickQuestionsWidget extends StatelessWidget {
  final Function(String) onQuestionSelected;

  const QuickQuestionsWidget({
    super.key,
    required this.onQuestionSelected,
  });

  static const List<String> _quickQuestions = [
    'Quel est mon solde actuel ?',
    'Combien ai-je dépensé ce mois-ci ?',
    'Puis-je m\'acheter quelque chose à 50 000 CFA ?',
    'Comment puis-je économiser plus ?',
    'Quels sont mes plus gros postes de dépenses ?',
    'Suis-je en train d\'atteindre mes objectifs ?',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Questions rapides :',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickQuestions.map((question) {
              return ActionChip(
                label: Text(question),
                onPressed: () => onQuestionSelected(question),
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                labelStyle: const TextStyle(
                  color: AppTheme.primaryColor,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
