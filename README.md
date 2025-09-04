# FinanceAI Manager 💰🤖

Application Flutter intelligente de gestion financière personnelle avec assistant IA intégré.

## 🚀 Fonctionnalités

### 🔐 Authentification & Sécurité
- ✅ Connexion par email/mot de passe
- ✅ Authentification biométrique (empreinte/FaceID)
- ✅ Données locales chiffrées avec Hive

### 🏠 Dashboard Intelligent
- ✅ Affichage du solde en temps réel
- ✅ Graphiques circulaires des dépenses par catégorie
- ✅ Graphiques linéaires revenus/dépenses mensuelles
- ✅ Récapitulatif mensuel automatique

### 💰 Gestion Transactions
- ✅ Ajout rapide revenus/dépenses
- ✅ Catégorisation automatique
- ✅ Historique complet avec filtres
- ✅ Estimation dépenses récurrentes

### 📊 Budgets & Objectifs
- ✅ Budgets globaux et par catégorie
- ✅ Alertes intelligentes (80% du budget)
- ✅ Objectifs financiers avec progression
- ✅ Prévisions basées sur les habitudes

### 🤖 Assistant IA Financier
- ✅ Chat intelligent avec OpenRouter + DeepSeek V3.1
- ✅ Analyse contextuelle de vos finances
- ✅ Conseils personnalisés
- ✅ Prédictions et recommandations

### 📈 Statistiques Avancées
- ✅ Graphiques interactifs (fl_chart)
- ✅ Comparaisons temporelles
- ✅ Export CSV/Excel
- ✅ Synchronisation cloud Supabase

### 🎨 UI/UX Premium
- ✅ Animations fluides et transitions
- ✅ Shimmer effects et spinners élégants
- ✅ Confetti pour célébrations d'objectifs
- ✅ Design moderne avec thème sombre/clair

## 🛠️ Stack Technique

- **Framework**: Flutter (Dart)
- **Backend**: Supabase (PostgreSQL + Auth + RLS)
- **Cache Local**: Hive (chiffré)
- **IA**: OpenRouter API + DeepSeek V3.1
- **Graphiques**: FL Chart
- **Navigation**: Go Router
- **State Management**: Provider
- **Authentification**: Supabase Auth + Local Auth

## 📱 Plateformes Supportées

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🚀 Installation

1. **Cloner le repository**
```bash
git clone https://github.com/votre-username/financeai-manager.git
cd financeai-manager
```

2. **Installer les dépendances**
```bash
flutter pub get
```

3. **Générer les fichiers Hive**
```bash
dart run build_runner build
```

4. **Configurer Supabase**
- Créer un projet sur [Supabase](https://supabase.com)
- Exécuter les scripts SQL fournis
- Configurer les variables d'environnement

5. **Générer les icônes**
```bash
dart run flutter_launcher_icons:main
```

6. **Lancer l'application**
```bash
flutter run
```

## 🔧 Configuration

### Variables d'environnement
Créer un fichier `.env` avec :
```
SUPABASE_URL=votre_url_supabase
SUPABASE_ANON_KEY=votre_cle_anonyme
OPENROUTER_API_KEY=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
```

### Base de données
Exécuter les scripts SQL dans l'ordre :
1. `supabase_expense_patterns_table.sql`
2. `supabase_goals_update.sql`

## 📊 Captures d'écran

[Ajoutez ici vos captures d'écran de l'application]

## 🤝 Contribution

Les contributions sont les bienvenues ! Veuillez :
1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 👨‍💻 Auteur

Développé avec ❤️ pour une gestion financière intelligente.

## 🆘 Support

Pour toute question ou problème :
- Ouvrir une [issue](https://github.com/votre-username/financeai-manager/issues)
- Consulter la [documentation](https://github.com/votre-username/financeai-manager/wiki)

---

**FinanceAI Manager** - Votre assistant financier personnel intelligent 🚀
- **IA**: OpenRouter API avec DeepSeek V3.1
- **Graphiques**: FL Chart
- **Navigation**: Go Router
- **État**: Provider

## 📱 Installation

### Prérequis
- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / Xcode
- Compte Supabase (gratuit)

### Configuration

1. **Cloner le projet**
```bash
git clone <repository-url>
cd app_financier
```

2. **Installer les dépendances**
```bash
flutter pub get
```

3. **Configuration Supabase**
- Créez un projet sur [Supabase](https://supabase.com)
- Créez les tables nécessaires :

```sql
-- Table des transactions
CREATE TABLE transactions (
  id TEXT PRIMARY KEY,
  montant REAL NOT NULL,
  type TEXT NOT NULL,
  categorie TEXT NOT NULL,
  description TEXT,
  date TIMESTAMP NOT NULL,
  date_creation TIMESTAMP DEFAULT NOW(),
  user_id UUID REFERENCES auth.users(id)
);

-- Table des budgets
CREATE TABLE budgets (
  id TEXT PRIMARY KEY,
  nom TEXT NOT NULL,
  montant_limite REAL NOT NULL,
  montant_depense REAL DEFAULT 0,
  categorie TEXT,
  date_debut TIMESTAMP NOT NULL,
  date_fin TIMESTAMP NOT NULL,
  alerte_active BOOLEAN DEFAULT true,
  seuil_alerte REAL DEFAULT 0.8,
  user_id UUID REFERENCES auth.users(id)
);

-- Table des objectifs
CREATE TABLE goals (
  id TEXT PRIMARY KEY,
  nom TEXT NOT NULL,
  description TEXT NOT NULL,
  montant_cible REAL NOT NULL,
  montant_actuel REAL DEFAULT 0,
  date_creation TIMESTAMP DEFAULT NOW(),
  date_echeance TIMESTAMP,
  est_atteint BOOLEAN DEFAULT false,
  user_id UUID REFERENCES auth.users(id)
);
```

4. **Configurer les clés API**
Modifiez le fichier `lib/core/config/app_config.dart` :

```dart
class AppConfig {
  static const String supabaseUrl = 'VOTRE_SUPABASE_URL';
  static const String supabaseAnonKey = 'VOTRE_SUPABASE_ANON_KEY';
  // La clé OpenRouter est déjà configurée
}
```

5. **Générer les adaptateurs Hive**
```bash
flutter packages pub run build_runner build
```

6. **Lancer l'application**
```bash
flutter run
```

## 🎨 Structure du Projet

```
lib/
├── core/
│   ├── config/          # Configuration (API keys, constantes)
│   ├── models/          # Modèles de données (Transaction, Budget, Goal)
│   ├── router/          # Configuration des routes
│   └── theme/           # Thème et styles
├── features/
│   ├── auth/            # Authentification
│   ├── home/            # Dashboard principal
│   ├── transactions/    # Gestion des transactions
│   ├── budgets/         # Gestion des budgets
│   ├── goals/           # Objectifs financiers
│   ├── ai_assistant/    # Assistant IA
│   ├── statistics/      # Statistiques et graphiques
│   └── profile/         # Profil utilisateur
└── main.dart           # Point d'entrée
```

## 🤖 Assistant IA

L'assistant IA utilise le modèle **DeepSeek V3.1** via OpenRouter pour :

- Analyser vos habitudes de dépenses
- Proposer des optimisations budgétaires
- Répondre à des questions comme :
  - "Puis-je m'acheter un téléphone à 200 000 CFA ?"
  - "Combien puis-je économiser en réduisant le fast-food ?"
  - "Quand vais-je atteindre mon objectif d'épargne ?"

## 📊 Exemples d'Usage

### Ajouter une Transaction
```dart
await transactionProvider.addTransaction(
  montant: 50000,
  type: 'depense',
  categorie: 'Nourriture',
  description: 'Courses du mois',
);
```

### Créer un Budget
```dart
await budgetProvider.addBudget(
  nom: 'Budget Nourriture',
  montantLimite: 100000,
  categorie: 'Nourriture',
  dateDebut: DateTime.now(),
  dateFin: DateTime(2024, 12, 31),
);
```

### Définir un Objectif
```dart
await goalProvider.addGoal(
  nom: 'Nouveau PC',
  description: 'Économiser pour un ordinateur portable',
  montantCible: 400000,
  dateEcheance: DateTime(2024, 6, 30),
);
```

## 🔧 Personnalisation

### Ajouter des Catégories
Modifiez `AppConfig.defaultExpenseCategories` et `AppConfig.defaultIncomeCategories`.

### Changer la Devise
Modifiez `AppConfig.defaultCurrency` et `AppConfig.currencySymbol`.

### Personnaliser l'IA
Ajustez le prompt système dans `AIProvider._buildFinancialContext()`.

## 🚀 Déploiement

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à :

1. Fork le projet
2. Créer une branche feature
3. Commit vos changements
4. Push vers la branche
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 🆘 Support

Pour toute question ou problème :
- Ouvrez une issue sur GitHub
- Consultez la documentation Supabase
- Vérifiez la documentation Flutter

---

**Développé avec ❤️ en Flutter**
