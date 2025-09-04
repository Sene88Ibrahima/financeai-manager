import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Photo de profil et informations
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          backgroundColor: AppTheme.primaryColor,
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: AppTheme.textLight,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user?.userMetadata?['prenom'] ?? 'Utilisateur',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user?.email ?? '',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Options du profil
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.fingerprint),
                        title: const Text('Authentification biométrique'),
                        trailing: Switch(
                          value: authProvider.biometricEnabled,
                          onChanged: (value) async {
                            if (value) {
                              await authProvider.enableBiometric(
                                user?.email ?? '',
                                '', // En production, gérer le mot de passe de façon sécurisée
                              );
                            } else {
                              await authProvider.disableBiometric();
                            }
                          },
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.notifications),
                        title: const Text('Notifications'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // TODO: Implémenter les paramètres de notifications
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.download),
                        title: const Text('Exporter mes données'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // TODO: Implémenter l'export des données
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.help),
                        title: const Text('Aide et support'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // TODO: Implémenter l'aide
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.info),
                        title: const Text('À propos'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          showAboutDialog(
                            context: context,
                            applicationName: 'App Financier',
                            applicationVersion: '1.0.0',
                            applicationIcon: const Icon(
                              Icons.account_balance_wallet,
                              size: 48,
                              color: AppTheme.primaryColor,
                            ),
                            children: const [
                              Text('Application de gestion financière avec assistant IA'),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Bouton de déconnexion
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.logout, color: AppTheme.errorColor),
                    title: const Text(
                      'Se déconnecter',
                      style: TextStyle(color: AppTheme.errorColor),
                    ),
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Déconnexion'),
                          content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Annuler'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.errorColor,
                              ),
                              child: const Text('Se déconnecter'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true && context.mounted) {
                        await authProvider.signOut();
                        context.go('/login');
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
