import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/models/transaction.dart';
import 'core/models/budget.dart';
import 'core/models/goal.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/home/screens/main_screen.dart';
import 'features/transactions/providers/transaction_provider.dart';
import 'features/transactions/screens/add_transaction_screen.dart';
import 'features/transactions/screens/transaction_history_screen.dart';
import 'features/budgets/providers/budget_provider.dart';
import 'features/budgets/screens/budget_screen.dart';
import 'features/goals/providers/goal_provider.dart';
import 'features/goals/screens/goals_screen.dart';
import 'features/ai_assistant/providers/ai_provider.dart';
import 'features/ai_assistant/screens/ai_chat_screen.dart';
import 'features/statistics/screens/statistics_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/expense_estimation/providers/expense_estimation_provider.dart';
import 'features/expense_estimation/screens/expense_estimation_screen.dart';
import 'features/expense_estimation/models/expense_pattern.dart';
import 'features/demo/demo_widgets_page.dart';
import 'features/settings/settings_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Charger les variables d'environnement
  await dotenv.load(fileName: ".env");

  // Initialiser Hive
  await Hive.initFlutter();
  
  // Enregistrer les adaptateurs Hive
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(BudgetAdapter());
  Hive.registerAdapter(GoalAdapter());

  // Initialiser Supabase
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  // Initialiser les notifications
  await _initializeNotifications();

  runApp(const AppFinancier());
}

Future<void> _initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  
  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  
  const InitializationSettings initializationSettings =
      InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

class AppFinancier extends StatelessWidget {
  const AppFinancier({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
        ChangeNotifierProvider(create: (_) => GoalProvider()),
        ChangeNotifierProvider(create: (_) => AIProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseEstimationProvider()),
      ],
      child: MaterialApp(
        title: 'FinanceAI Manager',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        locale: const Locale('fr', 'FR'),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.isAuthenticated) {
              return const MainScreen(child: HomeScreen());
            } else {
              return const LoginScreen();
            }
          },
        ),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const MainScreen(child: HomeScreen()),
          '/transactions': (context) => const TransactionHistoryScreen(),
          '/budgets': (context) => const BudgetScreen(),
          '/goals': (context) => const GoalsScreen(),
          '/ai-assistant': (context) => const AIChatScreen(),
          '/statistics': (context) => const StatisticsScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/add-transaction': (context) => const AddTransactionScreen(),
          '/add-revenue': (context) => const AddTransactionScreen(),
          '/add-expense': (context) => const AddTransactionScreen(),
          '/expense-estimation': (context) => const ExpenseEstimationScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/demo': (context) => const DemoWidgetsPage(),
        },
      ),
    );
  }
}
