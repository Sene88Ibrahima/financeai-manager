import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  final Widget child;

  const MainScreen({
    super.key,
    required this.child,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _calculateSelectedIndex(BuildContext context) {
    final String? routeName = ModalRoute.of(context)?.settings.name;
    if (routeName != null) {
      if (routeName.contains('/transactions')) {
        return 1;
      }
      if (routeName.contains('/budgets')) {
        return 2;
      }
      if (routeName.contains('/goals')) {
        return 3;
      }
      if (routeName.contains('/ai-assistant')) {
        return 4;
      }
    }
    return 0; // home par défaut
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/home');
        break;
      case 1:
        Navigator.of(context).pushNamed('/transactions');
        break;
      case 2:
        Navigator.of(context).pushNamed('/budgets');
        break;
      case 3:
        Navigator.of(context).pushNamed('/goals');
        break;
      case 4:
        Navigator.of(context).pushNamed('/ai-assistant');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Budgets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag),
            label: 'Objectifs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy),
            label: 'Assistant IA',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed('/add-transaction'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
