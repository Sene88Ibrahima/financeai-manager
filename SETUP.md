# Guide de Configuration - FinanceAI Manager

## 🚀 Démarrage Rapide

### 1. Prérequis
- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio ou Xcode
- Compte Supabase (gratuit)

### 2. Installation

```bash
# Cloner le projet
git clone <repository-url>
cd financeai_manager

# Installer les dépendances
flutter pub get

# Générer les adaptateurs Hive
flutter packages pub run build_runner build
```

### 3. Configuration Supabase

#### Créer un projet Supabase
1. Allez sur [supabase.com](https://supabase.com)
2. Créez un nouveau projet
3. Notez votre URL et clé anonyme

#### Créer les tables
Exécutez ces requêtes SQL dans l'éditeur Supabase :

```sql
-- Table des transactions
CREATE TABLE transactions (
  id TEXT PRIMARY KEY,
  montant REAL NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('revenu', 'depense')),
  categorie TEXT NOT NULL,
  description TEXT,
  date TIMESTAMP NOT NULL,
  date_creation TIMESTAMP DEFAULT NOW(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Index pour améliorer les performances
CREATE INDEX idx_transactions_user_id ON transactions(user_id);
CREATE INDEX idx_transactions_date ON transactions(date);
CREATE INDEX idx_transactions_type ON transactions(type);

-- Table des budgets
CREATE TABLE budgets (
  id TEXT PRIMARY KEY,
  nom TEXT NOT NULL,
  montant_limite REAL NOT NULL CHECK (montant_limite > 0),
  montant_depense REAL DEFAULT 0 CHECK (montant_depense >= 0),
  categorie TEXT,
  date_debut TIMESTAMP NOT NULL,
  date_fin TIMESTAMP NOT NULL,
  alerte_active BOOLEAN DEFAULT true,
  seuil_alerte REAL DEFAULT 0.8 CHECK (seuil_alerte BETWEEN 0 AND 1),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  CONSTRAINT valid_date_range CHECK (date_fin > date_debut)
);

-- Index pour les budgets
CREATE INDEX idx_budgets_user_id ON budgets(user_id);
CREATE INDEX idx_budgets_dates ON budgets(date_debut, date_fin);

-- Table des objectifs
CREATE TABLE goals (
  id TEXT PRIMARY KEY,
  nom TEXT NOT NULL,
  description TEXT NOT NULL,
  montant_cible REAL NOT NULL CHECK (montant_cible > 0),
  montant_actuel REAL DEFAULT 0 CHECK (montant_actuel >= 0),
  date_creation TIMESTAMP DEFAULT NOW(),
  date_echeance TIMESTAMP,
  est_atteint BOOLEAN DEFAULT false,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Index pour les objectifs
CREATE INDEX idx_goals_user_id ON goals(user_id);
CREATE INDEX idx_goals_status ON goals(est_atteint);

-- Activer RLS (Row Level Security)
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE budgets ENABLE ROW LEVEL SECURITY;
ALTER TABLE goals ENABLE ROW LEVEL SECURITY;

-- Politiques de sécurité pour les transactions
CREATE POLICY "Users can view own transactions" ON transactions
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own transactions" ON transactions
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own transactions" ON transactions
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own transactions" ON transactions
  FOR DELETE USING (auth.uid() = user_id);

-- Politiques de sécurité pour les budgets
CREATE POLICY "Users can view own budgets" ON budgets
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own budgets" ON budgets
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own budgets" ON budgets
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own budgets" ON budgets
  FOR DELETE USING (auth.uid() = user_id);

-- Politiques de sécurité pour les objectifs
CREATE POLICY "Users can view own goals" ON goals
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own goals" ON goals
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own goals" ON goals
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own goals" ON goals
  FOR DELETE USING (auth.uid() = user_id);
```

### 4. Configuration de l'application

Modifiez `lib/core/config/app_config.dart` :

```dart
class AppConfig {
  // Remplacez par vos vraies clés Supabase
  static const String supabaseUrl = 'VOTRE_SUPABASE_URL';
  static const String supabaseAnonKey = 'VOTRE_SUPABASE_ANON_KEY';
  
  // La clé OpenRouter est déjà configurée
  static const String openRouterApiKey = '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';
  // ... reste de la configuration
}
```

### 5. Lancement

```bash
# Vérifier que tout est configuré
flutter doctor

# Lancer l'application
flutter run
```

## 🔧 Configuration Avancée

### Authentification Biométrique

#### Android
Ajoutez dans `android/app/src/main/AndroidManifest.xml` :
```xml
<uses-permission android:name="android.permission.USE_FINGERPRINT" />
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
```

#### iOS
Ajoutez dans `ios/Runner/Info.plist` :
```xml
<key>NSFaceIDUsageDescription</key>
<string>Cette application utilise Face ID pour une connexion sécurisée.</string>
```

### Notifications

#### Android
Les permissions sont déjà configurées dans le manifest.

#### iOS
Les permissions sont demandées automatiquement au premier lancement.

## 🎯 Fonctionnalités Principales

### Dashboard
- Solde en temps réel
- Graphiques des dépenses
- Résumé mensuel
- Actions rapides

### Transactions
- Ajout/modification/suppression
- Catégorisation automatique
- Historique avec filtres
- Export CSV

### Budgets
- Budgets globaux et par catégorie
- Alertes automatiques (80% par défaut)
- Suivi en temps réel
- Notifications push

### Objectifs Financiers
- Définition d'objectifs d'épargne
- Suivi automatique de progression
- Échéances et rappels
- Célébration des réussites

### Assistant IA
- Chat intelligent avec DeepSeek V3.1
- Analyse personnalisée des finances
- Conseils contextuels
- Questions prédéfinies

### Statistiques
- Graphiques interactifs
- Comparaisons temporelles
- Tendances d'épargne
- Export des données

## 🛠️ Développement

### Structure du Projet
```
lib/
├── core/              # Configuration, modèles, thème
├── features/          # Fonctionnalités par domaine
│   ├── auth/         # Authentification
│   ├── home/         # Dashboard
│   ├── transactions/ # Gestion des transactions
│   ├── budgets/      # Gestion des budgets
│   ├── goals/        # Objectifs financiers
│   ├── ai_assistant/ # Assistant IA
│   └── statistics/   # Statistiques
└── main.dart         # Point d'entrée
```

### Commandes Utiles

```bash
# Générer les adaptateurs Hive
flutter packages pub run build_runner build

# Nettoyer et régénérer
flutter packages pub run build_runner build --delete-conflicting-outputs

# Build pour production
flutter build apk --release  # Android
flutter build ios --release  # iOS

# Analyser le code
flutter analyze

# Tests
flutter test
```

### Variables d'Environnement

Pour la production, créez un fichier `.env` :
```
SUPABASE_URL=votre_url_supabase
SUPABASE_ANON_KEY=votre_cle_anonyme
OPENROUTER_API_KEY=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
```

## 🚨 Dépannage

### Erreurs Communes

#### "Supabase not initialized"
- Vérifiez que les clés Supabase sont correctes
- Assurez-vous que `Supabase.initialize()` est appelé avant `runApp()`

#### "Hive box not found"
- Exécutez `flutter packages pub run build_runner build`
- Vérifiez que les adaptateurs sont enregistrés dans `main.dart`

#### Erreurs de build Android
- Vérifiez que `minSdkVersion` est au moins 21
- Nettoyez avec `flutter clean` puis `flutter pub get`

#### Problèmes d'authentification biométrique
- Testez sur un appareil physique (pas l'émulateur)
- Vérifiez que l'appareil a la biométrie configurée

### Logs et Debug

```bash
# Logs détaillés
flutter run --verbose

# Logs en temps réel
flutter logs

# Profiling des performances
flutter run --profile
```

## 📱 Déploiement

### Android (Google Play)
1. Configurez le signing dans `android/app/build.gradle`
2. Générez l'APK : `flutter build apk --release`
3. Testez l'APK sur différents appareils
4. Uploadez sur Google Play Console

### iOS (App Store)
1. Configurez les certificats dans Xcode
2. Build : `flutter build ios --release`
3. Archivez et uploadez via Xcode
4. Soumettez pour review

## 🔒 Sécurité

### Bonnes Pratiques
- Ne jamais commiter les clés API
- Utiliser les variables d'environnement
- Activer RLS sur Supabase
- Chiffrer les données sensibles localement
- Valider toutes les entrées utilisateur

### Audit de Sécurité
```bash
# Analyser les dépendances
flutter pub deps

# Vérifier les vulnérabilités
flutter pub audit
```

## 📞 Support

### Ressources
- [Documentation Flutter](https://flutter.dev/docs)
- [Documentation Supabase](https://supabase.com/docs)
- [OpenRouter API](https://openrouter.ai/docs)

### Contact
- Issues GitHub : [Lien vers votre repo]
- Email : votre-email@exemple.com

---

**Développé avec ❤️ en Flutter**
