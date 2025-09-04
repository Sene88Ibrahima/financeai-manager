# 🚀 Configuration GitHub pour FinanceAI Manager

## 📝 Nom du dépôt suggéré
```
financeai-manager
```

## 🔐 Secrets GitHub à configurer

### Repository Secrets (Settings > Secrets and variables > Actions)

#### 🗄️ Base de données Supabase
```
SUPABASE_URL=https://votre-projet.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### 🤖 API IA
```
OPENROUTER_API_KEY=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
```

#### 📱 Signature Android (optionnel pour CI/CD)
```
ANDROID_KEYSTORE_BASE64=<base64_encoded_keystore>
ANDROID_KEYSTORE_PASSWORD=votre_mot_de_passe
ANDROID_KEY_ALIAS=votre_alias
ANDROID_KEY_PASSWORD=votre_mot_de_passe_cle
```

#### 🍎 Signature iOS (optionnel pour CI/CD)
```
IOS_CERTIFICATE_BASE64=<base64_encoded_certificate>
IOS_CERTIFICATE_PASSWORD=votre_mot_de_passe
IOS_PROVISIONING_PROFILE_BASE64=<base64_encoded_profile>
```

## 📋 Étapes de configuration

### 1. Créer le dépôt GitHub
```bash
# Nom suggéré
financeai-manager
```

### 2. Description suggérée
```
🤖💰 Application Flutter intelligente de gestion financière avec assistant IA - Gérez vos finances avec l'aide de l'intelligence artificielle
```

### 3. Topics suggérés
```
flutter, dart, finance, ai, supabase, mobile-app, personal-finance, fintech, openrouter, deepseek
```

### 4. Initialiser le dépôt local
```bash
git init
git add .
git commit -m "🎉 Initial commit: FinanceAI Manager - Complete Flutter financial app with AI assistant"
git branch -M main
git remote add origin https://github.com/VOTRE-USERNAME/financeai-manager.git
git push -u origin main
```

### 5. Configurer les secrets
1. Aller dans **Settings** > **Secrets and variables** > **Actions**
2. Cliquer sur **New repository secret**
3. Ajouter chaque secret listé ci-dessus

### 6. Créer les variables d'environnement (optionnel)
```
FLUTTER_VERSION=3.16.0
DART_VERSION=3.2.0
```

## 🔒 Sécurité

### ⚠️ Fichiers sensibles déjà exclus par .gitignore
- `.env*` - Variables d'environnement
- `*.key` - Clés privées
- `*.keystore` - Keystores Android
- `secrets.json` - Fichiers de secrets
- `google-services.json` - Config Firebase
- `GoogleService-Info.plist` - Config iOS

### 🛡️ Bonnes pratiques
- ✅ Ne jamais commiter de clés API dans le code
- ✅ Utiliser les GitHub Secrets pour les données sensibles
- ✅ Séparer les environnements (dev/staging/prod)
- ✅ Rotation régulière des clés API

## 🚀 CI/CD (optionnel)

### GitHub Actions workflow suggéré
Créer `.github/workflows/flutter.yml` pour :
- ✅ Tests automatiques
- ✅ Build Android/iOS
- ✅ Déploiement automatique
- ✅ Analyse de code

## 📱 Déploiement

### Android
- Google Play Console
- Firebase App Distribution

### iOS  
- App Store Connect
- TestFlight

### Web
- GitHub Pages
- Netlify
- Vercel

## 🔗 Liens utiles
- [Supabase Dashboard](https://app.supabase.com)
- [OpenRouter Dashboard](https://openrouter.ai)
- [Flutter CI/CD Guide](https://docs.flutter.dev/deployment/cd)
