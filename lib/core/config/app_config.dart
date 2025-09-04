class AppConfig {
  // Configuration Supabase - Utilise les variables d'environnement ou GitHub Secrets
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: 'REMPLACER_PAR_VOTRE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'REMPLACER_PAR_VOTRE_CLE');
  
  // Configuration OpenRouter AI - Utilise les variables d'environnement ou GitHub Secrets
  static const String openRouterApiKey = String.fromEnvironment('OPENROUTER_API_KEY', defaultValue: 'REMPLACER_PAR_VOTRE_CLE');
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
