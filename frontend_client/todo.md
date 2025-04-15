# Feuille de route Next.js adaptée au schéma de BDD Quiz complet

## Architecture globale

L'architecture de l'application sera structurée pour exploiter pleinement le schéma de base de données riche avec:

1. **Couche UI** : Composants React et pages Next.js
2. **Couche Services** : Communication avec l'API PostgREST
3. **Couche État** : Gestion de l'état global avec contextes React et/ou React Query
4. **Couche Utilitaires** : Fonctions d'aide pour la manipulation des données

## Structure de dossiers et fichiers

```
quiz-app/
├── .env.local                   # Variables d'environnement locales
├── .env.production              # Variables d'environnement de production
├── public/                      # Fichiers statiques
│   ├── favicon.ico
│   ├── images/                  # Images statiques pour l'application
│   │   ├── badges/              # Images des badges
│   │   └── default-avatars/     # Avatars par défaut
│   └── locales/                 # Fichiers de traduction (optionnel)
├── src/                         # Code source principal
│   ├── components/              # Composants React réutilisables
│   │   ├── common/              # Composants génériques
│   │   │   ├── Button.jsx       # Bouton personnalisé
│   │   │   ├── Input.jsx        # Input personnalisé
│   │   │   ├── Modal.jsx        # Modal réutilisable
│   │   │   ├── Badge.jsx        # Composant d'affichage des badges
│   │   │   └── ...
│   │   ├── layout/              # Composants de mise en page
│   │   │   ├── Navbar.jsx       # Barre de navigation
│   │   │   ├── Footer.jsx       # Pied de page
│   │   │   ├── Sidebar.jsx      # Barre latérale pour navigation
│   │   │   └── Layout.jsx       # Layout principal
│   │   ├── quiz/                # Composants liés aux quiz
│   │   │   ├── QuizCard.jsx     # Carte aperçu de quiz
│   │   │   ├── QuizList.jsx     # Liste de quiz
│   │   │   ├── QuizFilters.jsx  # Filtres pour les quiz (difficulté, catégorie)
│   │   │   ├── QuizForm.jsx     # Formulaire de création/édition de quiz
│   │   │   └── QuizPrerequisitesForm.jsx # Gestion des prérequis de quiz
│   │   ├── questions/           # Composants liés aux questions
│   │   │   ├── QuestionEditor.jsx   # Éditeur de question
│   │   │   ├── MultipleChoiceQuestion.jsx # Question à choix multiple
│   │   │   ├── TrueFalseQuestion.jsx # Question vrai/faux
│   │   │   ├── ShortAnswerQuestion.jsx # Question réponse courte
│   │   │   ├── LongAnswerQuestion.jsx # Question réponse longue
│   │   │   ├── MatchingQuestion.jsx # Question d'association
│   │   │   ├── OrderingQuestion.jsx # Question d'ordonnancement
│   │   │   └── FillBlanksQuestion.jsx # Question à trous
│   │   ├── attempts/            # Composants liés aux tentatives de quiz
│   │   │   ├── AttemptCard.jsx  # Carte résumé d'une tentative
│   │   │   ├── AttemptList.jsx  # Liste des tentatives
│   │   │   ├── ResultSummary.jsx # Résumé des résultats
│   │   │   └── ResponseReview.jsx # Revue des réponses
│   │   ├── categories/          # Composants liés aux catégories
│   │   │   ├── CategoryTree.jsx # Arborescence des catégories
│   │   │   └── CategorySelector.jsx # Sélecteur de catégorie
│   │   ├── badges/              # Composants liés aux badges
│   │   │   ├── BadgeCard.jsx    # Affichage d'un badge
│   │   │   └── BadgeGrid.jsx    # Grille de badges
│   │   ├── stats/               # Composants liés aux statistiques
│   │   │   ├── UserStats.jsx    # Statistiques utilisateur
│   │   │   ├── QuizStats.jsx    # Statistiques d'un quiz
│   │   │   └── StatChart.jsx    # Graphique de statistiques
│   │   ├── auth/                # Composants d'authentification
│   │   │   ├── LoginForm.jsx    # Formulaire de connexion
│   │   │   ├── RegisterForm.jsx # Formulaire d'inscription
│   │   │   └── ProfileForm.jsx  # Formulaire de profil
│   │   └── admin/               # Composants d'administration
│   │       ├── UserList.jsx     # Liste des utilisateurs
│   │       ├── RoleManager.jsx  # Gestionnaire des rôles
│   │       └── AuditLogViewer.jsx # Affichage des logs d'audit
│   ├── context/                 # Contextes React pour l'état global
│   │   ├── AuthContext.jsx      # Contexte d'authentification
│   │   ├── QuizContext.jsx      # Contexte pour le quiz en cours
│   │   └── ThemeContext.jsx     # Contexte de thème (light/dark)
│   ├── hooks/                   # Hooks React personnalisés
│   │   ├── useAuth.js           # Hook pour l'authentification
│   │   ├── useQuizzes.js        # Hook pour les quiz
│   │   ├── useQuestions.js      # Hook pour les questions
│   │   ├── useCategories.js     # Hook pour les catégories
│   │   ├── useTags.js           # Hook pour les tags
│   │   ├── useAttempts.js       # Hook pour les tentatives
│   │   ├── useBadges.js         # Hook pour les badges
│   │   └── useStats.js          # Hook pour les statistiques
│   ├── lib/                     # Bibliothèques et utilitaires
│   │   ├── postgrest.js         # Configuration client PostgREST
│   │   ├── utils/               # Utilitaires généraux
│   │   │   ├── date.js          # Formatage des dates
│   │   │   ├── validation.js    # Fonctions de validation
│   │   │   ├── formatting.js    # Formatage des données
│   │   │   └── scoring.js       # Calcul des scores
│   │   ├── types/               # Types TypeScript (si utilisé)
│   │   │   ├── quiz.types.ts    # Types pour les quiz
│   │   │   ├── question.types.ts # Types pour les questions
│   │   │   └── ...
│   │   └── queryBuilder.js      # Construction de requêtes PostgREST
│   ├── pages/                   # Pages Next.js
│   │   ├── _app.js              # Composant App personnalisé
│   │   ├── _document.js         # Document HTML personnalisé
│   │   ├── index.js             # Page d'accueil
│   │   ├── api/                 # Routes API Next.js
│   │   │   ├── auth/            # Endpoints d'authentification
│   │   │   │   ├── login.js     # Connexion
│   │   │   │   ├── register.js  # Inscription
│   │   │   │   └── profile.js   # Gestion du profil
│   │   │   ├── quizzes/         # Endpoints pour les quiz
│   │   │   │   ├── index.js     # Liste des quiz
│   │   │   │   ├── [id].js      # Détail d'un quiz
│   │   │   │   ├── [id]/questions.js # Questions d'un quiz
│   │   │   │   └── [id]/attempts.js # Tentatives d'un quiz
│   │   │   ├── questions/       # Endpoints pour les questions
│   │   │   │   ├── index.js     # Liste des questions
│   │   │   │   └── [id].js      # Détail d'une question
│   │   │   ├── attempts/        # Endpoints pour les tentatives
│   │   │   │   ├── index.js     # Liste des tentatives
│   │   │   │   ├── [id].js      # Détail d'une tentative
│   │   │   │   └── [id]/responses.js # Réponses d'une tentative
│   │   │   ├── categories/      # Endpoints pour les catégories
│   │   │   ├── tags/            # Endpoints pour les tags
│   │   │   ├── badges/          # Endpoints pour les badges
│   │   │   └── stats/           # Endpoints pour les statistiques
│   │   ├── auth/                # Pages d'authentification
│   │   │   ├── login.js         # Page de connexion
│   │   │   ├── register.js      # Page d'inscription
│   │   │   └── profile.js       # Page de profil
│   │   ├── quizzes/             # Pages liées aux quiz
│   │   │   ├── index.js         # Liste des quiz
│   │   │   ├── [id].js          # Détail d'un quiz
│   │   │   ├── create.js        # Création d'un quiz
│   │   │   ├── [id]/edit.js     # Modification d'un quiz
│   │   │   ├── [id]/questions/  # Pages liées aux questions d'un quiz
│   │   │   │   ├── index.js     # Liste des questions
│   │   │   │   ├── create.js    # Ajout d'une question
│   │   │   │   └── [questionId].js # Détail/édition d'une question
│   │   │   ├── [id]/take.js     # Page pour passer un quiz
│   │   │   └── [id]/results.js  # Résultats d'un quiz
│   │   ├── questions/           # Pages liées aux questions
│   │   │   ├── index.js         # Banque de questions
│   │   │   ├── create.js        # Création d'une question
│   │   │   └── [id].js          # Détail/édition d'une question
│   │   ├── attempts/            # Pages liées aux tentatives
│   │   │   ├── index.js         # Historique des tentatives
│   │   │   └── [id].js          # Détail d'une tentative
│   │   ├── categories/          # Pages liées aux catégories
│   │   │   ├── index.js         # Liste des catégories
│   │   │   └── [id].js          # Quiz d'une catégorie
│   │   ├── dashboard/           # Pages du tableau de bord
│   │   │   ├── index.js         # Vue principale
│   │   │   ├── my-quizzes.js    # Quiz créés
│   │   │   ├── my-attempts.js   # Tentatives personnelles
│   │   │   ├── badges.js        # Badges obtenus
│   │   │   └── stats.js         # Statistiques personnelles
│   │   └── admin/               # Pages d'administration
│   │       ├── index.js         # Tableau de bord admin
│   │       ├── users/           # Gestion des utilisateurs
│   │       ├── roles/           # Gestion des rôles
│   │       ├── quiz-approval/   # Approbation des quiz
│   │       └── audit-logs/      # Journaux d'audit
│   ├── services/                # Services API
│   │   ├── authService.js       # Service d'authentification
│   │   ├── quizService.js       # Service pour les quiz
│   │   ├── questionService.js   # Service pour les questions
│   │   ├── attemptService.js    # Service pour les tentatives
│   │   ├── categoryService.js   # Service pour les catégories
│   │   ├── tagService.js        # Service pour les tags
│   │   ├── badgeService.js      # Service pour les badges
│   │   ├── statsService.js      # Service pour les statistiques
│   │   └── adminService.js      # Service pour l'administration
│   └── styles/                  # Styles CSS/SCSS
│       ├── globals.css          # Styles globaux
│       ├── components/          # Styles spécifiques aux composants
│       └── pages/               # Styles spécifiques aux pages
├── middleware.js                # Middleware Next.js global
├── next.config.js               # Configuration de Next.js
├── package.json
└── README.md
```

## Description des rôles des fichiers clés

### Configuration et Structure

- **`.env.local`** : Variables d'environnement pour le développement, incluant l'URL de PostgREST.
- **`middleware.js`** : Middleware Next.js pour la vérification d'authentification, la gestion des rôles et l'audit.
- **`next.config.js`** : Configuration de Next.js, y compris les redirections et les rewrites pour l'API.

### Services API

- **`lib/postgrest.js`** : Client axios configuré pour communiquer avec PostgREST, gérant les headers JWT et l'intercception des erreurs.
- **`lib/queryBuilder.js`** : Utilitaire pour construire des requêtes PostgREST complexes, supportant les jointures, filtres et sélections nécessaires pour le schéma de quiz.
- **`services/authService.js`** : Gère l'authentification, travaillant avec les tables `users`, `roles` et `user_roles`.
- **`services/quizService.js`** : Expose les opérations CRUD pour les quiz, incluant la gestion des relations avec les catégories, tags et questions.
- **`services/questionService.js`** : Gère les questions et leurs choix de réponse, supportant tous les types de questions définis dans `question_types`.
- **`services/attemptService.js`** : Gère les tentatives de quiz et les réponses des utilisateurs, y compris le calcul des scores.

### Contextes et Hooks

- **`context/AuthContext.jsx`** : Gère l'état d'authentification global, incluant le rôle de l'utilisateur et ses permissions.
- **`hooks/useQuizzes.js`** : Hook personnalisé pour récupérer et manipuler les quiz, avec pagination et filtrage.
- **`hooks/useQuestions.js`** : Hook pour gérer les questions, filtré par type de question pour supporter tous les types définis dans votre schéma.
- **`hooks/useAttempts.js`** : Hook pour gérer les tentatives de quiz et les réponses, avec support pour tous les types de réponses.

### Pages et Composants

- **`pages/api/quizzes/[id].js`** : API Route servant de proxy entre le client et PostgREST pour les opérations sur un quiz, gérant les relations complexes.
- **`pages/quizzes/[id]/take.js`** : Interface pour passer un quiz, gère les différents types de questions définies dans votre schéma.
- **`pages/dashboard/stats.js`** : Affiche les statistiques de l'utilisateur à partir de la table `user_statistics`.
- **`components/questions/MatchingQuestion.jsx`** : Composant pour afficher et répondre à une question d'association, compatible avec la structure de données de votre schéma.
- **`components/questions/QuestionEditor.jsx`** : Éditeur de question qui s'adapte au type de question sélectionné, gérant tous les types définis dans `question_types`.

## Gestion des types de questions spécifiques

Votre schéma inclut plusieurs types de questions (QCM, vrai/faux, réponse courte, etc.). Chaque type nécessite un traitement spécifique:

1. **`components/questions/MultipleChoiceQuestion.jsx`** : 
   - Affiche une question à choix multiple avec ses options
   - Gère la sélection unique ou multiple selon les paramètres
   - Connecté aux tables `questions`, `answer_choices`, et `attempt_response_choices`

2. **`components/questions/MatchingQuestion.jsx`** : 
   - Interface glisser-déposer pour associer des éléments
   - Gère la table `matching_responses` pour stocker les associations

3. **`components/questions/OrderingQuestion.jsx`** : 
   - Interface pour réordonner des éléments
   - Utilise la table `ordering_responses` pour stocker l'ordre des éléments

4. **`components/questions/FillBlanksQuestion.jsx`** : 
   - Interface de texte à trous
   - Stocke les réponses sous forme structurée dans `response_data` (JSONB)

## Flux de données pour les principales fonctionnalités

### Création d'un quiz

1. L'utilisateur remplit le formulaire dans `pages/quizzes/create.js`
2. Les données sont envoyées via `quizService.create()` à l'API
3. L'API Next.js transforme et valide les données avant de les envoyer à PostgREST
4. PostgREST insère les données dans `quizzes`, puis gère les relations avec `categories` et `tags`
5. L'utilisateur est redirigé vers la page de gestion des questions pour ce quiz

### Passage d'un quiz

1. L'utilisateur accède à `pages/quizzes/[id]/take.js`
2. Le système vérifie les prérequis dans `quiz_dependencies`
3. Une nouvelle entrée est créée dans `quiz_attempts`
4. Pour chaque question:
   - Le composant approprié est rendu selon `question_type_id`
   - La réponse est stockée temporairement
5. À la fin du quiz:
   - Toutes les réponses sont envoyées via `attemptService.submitResponses()`
   - Les réponses sont insérées dans `attempt_responses`
   - Pour les QCM, les choix sont enregistrés dans `attempt_response_choices`
   - Pour les questions d'ordre, les positions sont enregistrées dans `ordering_responses`
   - Pour les questions d'association, les paires sont enregistrées dans `matching_responses`
6. Le score est calculé et mis à jour dans `quiz_attempts`
7. Les statistiques utilisateur sont mises à jour dans `user_statistics`
8. L'utilisateur est redirigé vers la page de résultats

### Tableau de bord des statistiques

1. L'utilisateur accède à `pages/dashboard/stats.js`
2. Les données sont chargées depuis `user_statistics` via `statsService.getUserStats()`
3. Les tentatives récentes sont récupérées de `quiz_attempts`
4. Les badges sont chargés depuis `user_badges` et `badges`
5. Les données sont affichées sous forme de graphiques et tableaux

## Considérations particulières pour ce schéma

1. **Système de permissions basé sur les rôles**:
   - Le middleware vérifie les permissions de l'utilisateur en utilisant `roles` et `permissions`
   - Les composants d'UI s'adaptent aux permissions de l'utilisateur

2. **Types de questions dynamiques**:
   - Utilisation de `React.lazy()` pour charger conditionnellement les composants selon le type de question
   - Factory pattern pour créer les bons composants d'édition selon `question_type_id`

3. **Stockage flexible des réponses**:
   - Utilisation de la colonne JSONB `response_data` pour les types de réponses complexes
   - Parser/serializer pour convertir entre le format UI et le format de stockage

4. **Prérequisits de quiz**:
   - Interface dans `QuizPrerequisitesForm.jsx` pour définir les conditions préalables
   - Vérification des prérequis avant de permettre l'accès à un quiz

5. **Journalisation d'audit**:
   - Intercepteur dans `postgrest.js` pour enregistrer les actions importantes
   - Page d'administration pour consulter les logs d'audit

## Étapes de développement

### Étape 1: Configuration et authentification
- Mise en place de Next.js avec les environnements
- Implémentation de l'authentification avec rôles et permissions
- Création des layouts principaux

### Étape 2: Gestion des quiz
- Liste et détail des quiz publics
- Interface de création et modification de quiz
- Gestion des catégories et tags

### Étape 3: Système de questions
- Création de l'éditeur de questions
- Implémentation des différents types de questions
- Système d'association question-quiz

### Étape 4: Système de tentatives
- Interface pour passer un quiz
- Système de scoring et d'évaluation
- Affichage des résultats et commentaires

### Étape 5: Tableau de bord et statistiques
- Vue générale du tableau de bord
- Visualisation des statistiques
- Système de badges

### Étape 6: Administration et optimisations
- Interface d'administration
- Optimisations de performances
- Tests et déploiement