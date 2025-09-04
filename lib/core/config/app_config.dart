import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // Configuration Supabase - Chargée depuis le fichier .env
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? 'REMPLACER_PAR_VOTRE_URL';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? 'REMPLACER_PAR_VOTRE_CLE';
  
  // Configuration OpenRouter AI - Chargée depuis le fichier .env
  static String get openRouterApiKey => dotenv.env['OPENROUTER_API_KEY'] ?? 'REMPLACER_PAR_VOTRE_CLE';
  static const String openRouterBaseUrl = 'https://openrouter.ai/api/v1';
  static const String aiModel = 'deepseek/deepseek-chat-v3.1:free';
  
  // Configuration de l'app
  static const String appName = 'FinanceAI Manager';
  static const String appVersion = '1.0.0';
  
  // Catégories par défaut
  static const List<String> defaultExpenseCategories = [
    'Nourriture',
    'Transport',
    'Loyer',
    'Loisirs',
    'Santé',
    'Vêtements',
    'Éducation',
    'Factures',
    'Autres',
  ];
  
  static const List<String> defaultIncomeCategories = [
    'Salaire',
    'Freelance',
    'Investissements',
    'Bonus',
    'Autres',
  ];
  
  // Devise par défaut
  static const String defaultCurrency = 'CFA';
  static const String currencySymbol = 'CFA';
}
