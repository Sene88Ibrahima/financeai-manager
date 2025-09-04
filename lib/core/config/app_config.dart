class AppConfig {
  // Configuration Supabase - À remplacer par vos vraies clés
  static const String supabaseUrl = 'https://nrcqiqnundxminikifym.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5yY3FpcW51bmR4bWluaWtpZnltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY5MjU3MTUsImV4cCI6MjA3MjUwMTcxNX0.4Vhp-rIuO0mwwc-af-OrVUr-9KPgHKJiJS_UdJoA8FQ';
  
  // Configuration OpenRouter AI
  static const String openRouterApiKey = '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';
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
