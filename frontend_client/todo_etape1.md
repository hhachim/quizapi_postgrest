# Étape 1: Configuration et authentification - Sous-étapes et fichiers nécessaires

## 1. Configuration de base de Next.js

### Fichiers nécessaires:
- `package.json` - Définition des dépendances et scripts
- `next.config.js` - Configuration de Next.js, notamment pour les redirections API
- `.env.local` - Variables d'environnement pour le développement
- `.env.production` - Variables d'environnement pour la production
- `tsconfig.json` (si TypeScript) - Configuration TypeScript

### Rôle de chaque fichier:
- `package.json` : Déclare les dépendances (React, Next.js, axios, react-query, etc.)
- `next.config.js` : Configure les redirections d'API vers PostgREST, les optimisations d'image, etc.
- `.env.local` : Stocke l'URL de l'API, les clés JWT et autres variables d'environnement pour le développement
- `.env.production` : Même chose pour l'environnement de production
- `tsconfig.json` : Configuration TypeScript si vous décidez d'utiliser TypeScript (recommandé)

## 2. Configuration de la structure de base

### Fichiers nécessaires:
- `src/pages/_app.js` - Point d'entrée de l'application
- `src/pages/_document.js` - Personnalisation du HTML
- `src/pages/index.js` - Page d'accueil
- `src/styles/globals.css` - Styles globaux
- `public/favicon.ico` - Favicon du site

### Rôle de chaque fichier:
- `_app.js` : Enveloppe toutes les pages, initialise les contextes globaux
- `_document.js` : Personnalise la structure HTML (head, body, etc.)
- `index.js` : Page d'accueil de l'application
- `globals.css` : Styles CSS globaux, reset CSS et variables
- `favicon.ico` : Icône du site affichée dans les onglets du navigateur

## 3. Configuration du client API et services

### Fichiers nécessaires:
- `src/lib/postgrest.js` - Client API pour communiquer avec PostgREST
- `src/services/authService.js` - Service d'authentification

### Rôle de chaque fichier:
- `postgrest.js` : Configure Axios pour communiquer avec l'API PostgREST, gère les headers JWT et l'interception des erreurs
- `authService.js` : Implémente les fonctions login(), register(), logout() et getCurrentUser()

## 4. Système d'authentification

### Fichiers nécessaires:
- `src/context/AuthContext.jsx` - Contexte d'authentification
- `src/hooks/useAuth.js` - Hook personnalisé pour l'authentification

### Rôle de chaque fichier:
- `AuthContext.jsx` : Fournit l'état d'authentification global à l'application, stocke l'utilisateur et le token JWT
- `useAuth.js` : Hook personnalisé qui expose les fonctions d'authentification et l'état utilisateur courant

## 5. Layouts et composants UI principaux

### Fichiers nécessaires:
- `src/components/layout/Layout.jsx` - Layout principal
- `src/components/layout/Navbar.jsx` - Barre de navigation
- `src/components/layout/Footer.jsx` - Pied de page
- `src/components/layout/Sidebar.jsx` - Barre latérale (optionnelle pour cette étape)

### Rôle de chaque fichier:
- `Layout.jsx` : Définit la structure commune à toutes les pages
- `Navbar.jsx` : Affiche la navigation, l'état d'authentification et les liens principaux
- `Footer.jsx` : Affiche les informations de pied de page
- `Sidebar.jsx` : Navigation secondaire (peut être plus simple au début)

## 6. Pages d'authentification

### Fichiers nécessaires:
- `src/pages/auth/login.js` - Page de connexion
- `src/pages/auth/register.js` - Page d'inscription
- `src/pages/auth/profile.js` - Page de profil utilisateur
- `src/components/auth/LoginForm.jsx` - Formulaire de connexion
- `src/components/auth/RegisterForm.jsx` - Formulaire d'inscription
- `src/components/auth/ProfileForm.jsx` - Formulaire de profil

### Rôle de chaque fichier:
- `login.js` : Page de connexion qui intègre le formulaire de connexion
- `register.js` : Page d'inscription qui intègre le formulaire d'inscription
- `profile.js` : Page de profil qui intègre le formulaire de profil
- `LoginForm.jsx` : Composant formulaire avec validation pour la connexion
- `RegisterForm.jsx` : Composant formulaire avec validation pour l'inscription
- `ProfileForm.jsx` : Composant formulaire pour modifier le profil utilisateur

## 7. Middleware d'authentification

### Fichiers nécessaires:
- `src/middleware.js` - Middleware Next.js pour la vérification d'authentification
- `src/lib/utils/validation.js` - Fonctions de validation pour les formulaires

### Rôle de chaque fichier:
- `middleware.js` : Protège les routes nécessitant une authentification
- `validation.js` : Fournit des utilitaires de validation pour les formulaires d'authentification

## 8. Composants communs et UI de base

### Fichiers nécessaires:
- `src/components/common/Button.jsx` - Composant bouton personnalisé
- `src/components/common/Input.jsx` - Composant input personnalisé
- `src/components/common/Modal.jsx` - Composant modal réutilisable
- `src/components/common/Card.jsx` - Composant carte pour afficher des informations

### Rôle de chaque fichier:
- `Button.jsx` : Bouton stylisé avec variantes (primaire, secondaire, etc.)
- `Input.jsx` : Champ de formulaire avec gestion des erreurs intégrée
- `Modal.jsx` : Fenêtre modale réutilisable (utile pour les confirmations)
- `Card.jsx` : Conteneur stylisé pour afficher du contenu

## Notes importantes pour l'Étape 1:

1. **Priorité**: Concentrez-vous d'abord sur la configuration de base, le client API et l'authentification avant d'élaborer les composants UI.

2. **État global**: L'utilisation de Context API pour l'authentification est suffisante à ce stade. Une bibliothèque comme Redux pourrait être ajoutée plus tard si nécessaire.

3. **Dépendances suggérées**:
   - `axios` pour les requêtes HTTP
   - `react-hook-form` pour la gestion de formulaires
   - `zod` ou `yup` pour la validation
   - `js-cookie` pour la gestion des cookies JWT

4. **Tests**: Même si non mentionnés explicitement, pensez à ajouter des tests pour les services d'authentification.