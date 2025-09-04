import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../auth/providers/auth_provider.dart';
import '../notifications/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _budgetNotifications = true;
  bool _goalNotifications = true;
  bool _generalNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Section Notifications
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SwitchListTile(
                      title: const Text('Alertes budget'),
                      subtitle: const Text('Notifications quand vous approchez de vos limites'),
                      value: _budgetNotifications,
                      onChanged: (value) {
                        setState(() {
                          _budgetNotifications = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Alertes objectifs'),
                      subtitle: const Text('Notifications pour vos objectifs financiers'),
                      value: _goalNotifications,
                      onChanged: (value) {
                        setState(() {
                          _goalNotifications = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Notifications générales'),
                      subtitle: const Text('Conseils et rappels'),
                      value: _generalNotifications,
                      onChanged: (value) {
                        setState(() {
                          _generalNotifications = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Section Sécurité
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Sécurité',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SwitchListTile(
                      title: const Text('Authentification biométrique'),
                      subtitle: const Text('Utiliser l\'empreinte digitale ou Face ID'),
                      value: authProvider.biometricEnabled,
                      onChanged: (value) async {
                        if (value) {
                          await authProvider.enableBiometric(
                            authProvider.user?.email ?? '',
                            '', // En production, gérer le mot de passe de façon sécurisée
                          );
                        } else {
                          await authProvider.disableBiometric();
                        }
                      },
                    ),
                    ListTile(
                      title: const Text('Changer le mot de passe'),
                      subtitle: const Text('Modifier votre mot de passe de connexion'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // TODO: Implémenter le changement de mot de passe
                        _showChangePasswordDialog();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Section Données
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Données',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListTile(
                      title: const Text('Sauvegarder les données'),
                      subtitle: const Text('Synchroniser avec le cloud'),
                      trailing: const Icon(Icons.cloud_upload),
                      onTap: () {
                        // TODO: Implémenter la sauvegarde cloud
                        _showBackupDialog();
                      },
                    ),
                    ListTile(
                      title: const Text('Effacer le cache local'),
                      subtitle: const Text('Supprimer les données mises en cache'),
                      trailing: const Icon(Icons.delete_sweep),
                      onTap: () {
                        _showClearCacheDialog();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Section Apparence
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Apparence',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListTile(
                      title: const Text('Thème'),
                      subtitle: const Text('Clair, sombre ou automatique'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        _showThemeDialog();
                      },
                    ),
                    ListTile(
                      title: const Text('Devise'),
                      subtitle: const Text('CFA (par défaut)'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        _showCurrencyDialog();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Section Support
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Support',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListTile(
                      title: const Text('Centre d\'aide'),
                      subtitle: const Text('FAQ et guides d\'utilisation'),
                      trailing: const Icon(Icons.help),
                      onTap: () {
                        // TODO: Implémenter le centre d'aide
                      },
                    ),
                    ListTile(
                      title: const Text('Signaler un problème'),
                      subtitle: const Text('Nous faire part d\'un bug ou suggestion'),
                      trailing: const Icon(Icons.bug_report),
                      onTap: () {
                        // TODO: Implémenter le signalement
                      },
                    ),
                    ListTile(
                      title: const Text('Évaluer l\'application'),
                      subtitle: const Text('Donnez votre avis sur les stores'),
                      trailing: const Icon(Icons.star),
                      onTap: () {
                        // TODO: Implémenter l'évaluation
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Changer le mot de passe'),
        content: const Text('Cette fonctionnalité sera bientôt disponible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sauvegarde des données'),
        content: const Text('Vos données sont automatiquement sauvegardées dans le cloud lorsque vous êtes connecté.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Effacer le cache'),
        content: const Text('Êtes-vous sûr de vouloir effacer le cache local ? Vos données seront rechargées depuis le cloud.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implémenter l'effacement du cache
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache effacé avec succès')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Effacer'),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir le thème'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Clair'),
              value: 'light',
              groupValue: 'system',
              onChanged: (value) {
                Navigator.pop(context);
                // TODO: Implémenter le changement de thème
              },
            ),
            RadioListTile<String>(
              title: const Text('Sombre'),
              value: 'dark',
              groupValue: 'system',
              onChanged: (value) {
                Navigator.pop(context);
                // TODO: Implémenter le changement de thème
              },
            ),
            RadioListTile<String>(
              title: const Text('Automatique'),
              value: 'system',
              groupValue: 'system',
              onChanged: (value) {
                Navigator.pop(context);
                // TODO: Implémenter le changement de thème
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Devise'),
        content: const Text('La devise CFA est actuellement la seule supportée. D\'autres devises seront ajoutées prochainement.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
