import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/home/screens/main_screen.dart';
import '../../features/transactions/screens/add_transaction_screen.dart';
import '../../features/transactions/screens/transaction_history_screen.dart';
import '../../features/budgets/screens/budget_screen.dart';
import '../../features/goals/screens/goals_screen.dart';
import '../../features/ai_assistant/screens/ai_chat_screen.dart';
import '../../features/statistics/screens/statistics_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/expense_estimation/screens/expense_estimation_screen.dart';
import '../../features/demo/demo_widgets_page.dart';
import '../../features/settings/settings_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isLoggedIn = authProvider.isAuthenticated;
      
      // Si l'utilisateur n'est pas connecté et n'est pas sur les pages d'auth
      if (!isLoggedIn && !state.fullPath!.startsWith('/login') && !state.fullPath!.startsWith('/register')) {
        return '/login';
      }
      
      // Si l'utilisateur est connecté et sur les pages d'auth
      if (isLoggedIn && (state.fullPath!.startsWith('/login') || state.fullPath!.startsWith('/register'))) {
        return '/home';
      }
      
      return null;
    },
    routes: [
      // Routes d'authentification
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // ShellRoute pour les écrans avec barre de navigation
      ShellRoute(
        builder: (context, state, child) {
          return MainScreen(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
        ],
      ),
      
      // Routes principales
      GoRoute(
        path: '/transactions',
        builder: (context, state) => const TransactionHistoryScreen(),
      ),
      GoRoute(
        path: '/budgets',
        builder: (context, state) => const BudgetScreen(),
      ),
      GoRoute(
        path: '/goals',
        builder: (context, state) => const GoalsScreen(),
      ),
      GoRoute(
        path: '/ai-assistant',
        builder: (context, state) => const AIChatScreen(),
      ),
      GoRoute(
        path: '/statistics',
        builder: (context, state) => const StatisticsScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      
      // Routes modales
      GoRoute(
        path: '/add-transaction',
        builder: (context, state) => const AddTransactionScreen(),
      ),
      GoRoute(
        path: '/add-revenue',
        builder: (context, state) => const AddTransactionScreen(),
      ),
      GoRoute(
        path: '/add-expense',
        builder: (context, state) => const AddTransactionScreen(),
      ),
      GoRoute(
        path: '/expense-estimation',
        builder: (context, state) => const ExpenseEstimationScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/demo',
        builder: (context, state) => const DemoWidgetsPage(),
      ),
    ],
  );
}
