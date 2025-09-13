# Documentation des Animations - FinanceAI Manager

## Vue d'ensemble
Cette documentation décrit comment et quand les animations sont déclenchées dans l'application FinanceAI Manager.

## 1. Progress Cards

### CircularProgressCard
- **Déclenchement**: Animation automatique au chargement du widget
- **Interaction**: Tap sur la carte pour augmenter la progression
- **Animation**: 
  - Progression circulaire animée (durée: 1.5s, courbe: easeInOut)
  - Effet de rebond au tap (scale 0.95 → 1.0)

### MiniCircularProgressCard
- **Déclenchement**: Animation automatique au chargement
- **Animation**: Progression circulaire animée similaire à CircularProgressCard

## 2. Confetti & Celebrations

### CelebrationButton
- **Déclenchement**: Au tap sur le bouton
- **Animation**:
  - Scale animation du bouton (0.95 → 1.0)
  - Déclenchement des confettis via ConfettiOverlay
  - Durée des confettis: 3 secondes

### SuccessAnimation
- **Déclenchement**: Via showDialog (ex: après une transaction réussie)
- **Animation**:
  - Checkmark animé (scale et rotation)
  - Confettis automatiques
  - Auto-fermeture après 3 secondes

## 3. Loading Indicators

### PulseLoadingIndicator
- **Déclenchement**: Automatique dès l'affichage
- **Animation**: Rotation continue avec pulsation des points
- **Durée**: Infinie jusqu'à suppression du widget

### DotsLoadingIndicator
- **Déclenchement**: Automatique dès l'affichage
- **Animation**: Points rebondissants avec délai séquentiel
- **Durée**: Infinie (repeat)

### WaveLoadingIndicator
- **Déclenchement**: Automatique dès l'affichage
- **Animation**: Effet de vague sur les barres
- **Durée**: Infinie (repeat)

### ShimmerLoadingCard / ShimmerLoadingList
- **Déclenchement**: Automatique via le package shimmer
- **Animation**: Effet de brillance glissante
- **Usage**: Placeholder pendant le chargement de données

### CircularProgressWithPercentage
- **Déclenchement**: Animation au changement de valeur
- **Animation**: Transition fluide entre les valeurs

## 4. Animated Widgets

### AnimatedGradientContainer
- **Déclenchement**: Automatique après le build (via PostFrameCallback)
- **Animation**: Transition cyclique entre gradients
- **Durée**: 3 secondes par cycle

### PulsatingIcon
- **Déclenchement**: Automatique dès l'affichage
- **Animation**: Pulsation continue (scale 1.0 → 1.2)
- **Durée**: 1.5 secondes, répétition infinie

### BouncingWidget
- **Déclenchement**: Automatique dès l'affichage
- **Animation**: Rebond vertical continu
- **Durée**: 1 seconde, répétition infinie

### FlipCard
- **Déclenchement**: Au tap sur la carte
- **Animation**: Rotation 3D de 180° sur l'axe Y
- **Durée**: 600ms

### AnimatedCounter
- **Déclenchement**: Au changement de valeur
- **Animation**: Transition numérique fluide
- **Durée**: 500ms

### TypewriterText
- **Déclenchement**: Automatique après le build (via PostFrameCallback)
- **Animation**: Affichage caractère par caractère
- **Durée**: 50ms par caractère (par défaut)

### AnimatedProgressBar
- **Déclenchement**: Au changement de valeur de progress
- **Animation**: Transition fluide de la largeur
- **Durée**: 500ms

### AnimatedListItem
- **Déclenchement**: À l'affichage avec délai basé sur l'index
- **Animation**: Slide + fade in
- **Durée**: 500ms + (100ms * index) de délai

### AnimatedFABMenu
- **Déclenchement**: Au tap sur le FAB principal
- **Animation**: Expansion/contraction du menu
- **Durée**: 300ms

## 5. Page Transitions

### SlidePageRoute
- **Déclenchement**: Navigation vers une nouvelle page
- **Animation**: Glissement horizontal (droite → gauche)

### FadePageRoute
- **Déclenchement**: Navigation
- **Animation**: Fondu (opacity 0 → 1)

### ScalePageRoute
- **Déclenchement**: Navigation
- **Animation**: Zoom (scale 0 → 1)

### RotationPageRoute
- **Déclenchement**: Navigation
- **Animation**: Rotation 3D

### MixedPageRoute
- **Déclenchement**: Navigation
- **Animation**: Combinaison scale + fade + rotation

### HeroDialogRoute
- **Déclenchement**: Navigation vers dialog
- **Animation**: Hero animation avec transformation

## Optimisations appliquées

### Prévention des erreurs setState() pendant le build
- Utilisation de `WidgetsBinding.instance.addPostFrameCallback()` pour différer les animations
- Vérification `mounted` avant tout setState()
- Démarrage des animations après la phase de build

### Performance
- Utilisation d'AnimatedBuilder pour isoler les rebuilds
- Controllers disposés correctement pour éviter les fuites mémoire
- Animations conditionnelles basées sur la visibilité

## Usage dans la démo

La page de démo (`/demo`) présente toutes ces animations avec:
- Sections organisées par type d'animation
- Boutons interactifs pour déclencher certaines animations
- Exemples d'utilisation en contexte réel

### Pour tester les animations:
1. Naviguer vers `/demo`
2. Les animations automatiques démarrent immédiatement
3. Interagir avec les éléments pour les animations déclenchées par l'utilisateur
4. Observer les transitions de page via le menu FAB

## Notes importantes

- Toutes les animations respectent les préférences d'accessibilité du système
- Les animations peuvent être désactivées globalement si nécessaire
- La durée et les courbes d'animation sont personnalisables via les paramètres des widgets
