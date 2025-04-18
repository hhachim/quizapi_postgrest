# Liste des TODO pour l'API

## Vitaux (à faire immédiatement)

1. **Corriger les erreurs de réseau dans les tests** - Les rapports de test montrent des erreurs "getaddrinfo ENOTFOUND postgrest" - vérifier le nom du service dans l'environnement de test Postman
2. **Résoudre le conflit UUID vs SERIAL** - Harmoniser le type de clé primaire dans les tables (UUID dans certains scripts, SERIAL dans d'autres)
3. **Finaliser le script d'initialisation pour PostgREST** - Créer un point d'entrée fonctionnel adapté au Docker compose actuel
4. **Corriger la configuration .env** - Terminer la configuration des variables d'environnement pour les services
5. **Configurer correctement les règles RLS** - Les tests semblent indiquer des problèmes d'autorisation, corriger les politiques
6. **Script de suppression des données de test** - pour pouvoir repartir de zéro sur les données (équiv à truncate sur certaines tables)

## Majeurs (importants pour la progression)

1. **Ajouter une route /healthcheck** - Créer une fonction SQL simple renvoyant la version et l'état de la base
2. **Compléter les tests d'authentification REST Client** - Finaliser les tests de login et register avec VS Code REST Client
3. **Réorganiser les scripts SQL** - Déplacer les fichiers des répertoires old_init_db vers la structure en 01-core, 02-app, etc.
4. **Corriger et simplifier le docker-compose.yml** - Supprimer les références aux labels Traefik spécifiques à votre environnement
5. **Améliorer les politiques RLS pour quiz_attempts** - S'assurer que les utilisateurs ne peuvent voir que leurs propres tentatives
6. **Compléter les fonctions d'authentification** - Finaliser register() et login() avec gestion des erreurs plus robuste

## Moyens (amélioration significative)

1. **Ajouter des requêtes REST Client pour les CRUD simples** - Créer des fichiers .http pour categories, tags, etc.
2. **Compléter les vues PostgreSQL** - Décommenter et adapter les vues dans 02-app-06-views-01-views.sql
3. **Créer un script simple de seeding pour tests** - Ajouter quelques données dans 03-data-02-app-02-sample-quizzes.sql
4. **Améliorer le script de test-diagnostics.sh** - Ajouter des vérifications plus précises sur l'état de l'API
5. **Ajouter des index sur les colonnes fréquemment filtrées** - Optimiser les performances des requêtes courantes
6. **Créer quelques fonctions SQL utilitaires** - Ajouter des fonctions pour les opérations courantes comme get_quiz_statistics

## Mineurs (utiles mais non urgents)

1. **Documenter les endpoints principaux** - Ajouter des commentaires dans le swagger.json
2. **Ajouter des tests pour les fonctions scoring** - Créer des tests pour calculate_attempt_score()
3. **Ajouter la gestion de version dans les URLs API** - Préfixer les routes avec /v1 pour permettre des évolutions futures
4. **Créer des exemples de requêtes curl documentées** - Ajouter des exemples complets pour les opérations principales
5. **Améliorer les messages d'erreur des fonctions RPC** - Rendre les messages plus explicites et cohérents
6. **Compléter le fichier README.md** - Ajouter des sections sur l'architecture, les choix techniques
7. **Ajouter des triggers pour audit_logs** - Automatiser la journalisation des modifications importantes

## Nettoyage (refactoring et suppression)

1. **Supprimer les doublons de fichiers SQL** - Nettoyer les old_init_db une fois les scripts reorganisés
2. **Harmoniser les noms de fichiers** - Adopter une convention cohérente pour tous les scripts
3. **Nettoyer les scripts inutilisés** - Supprimer create_db_files_tree.sh s'il n'est plus nécessaire
4. **Supprimer les configurations spécifiques à l'environnement** - Enlever les références à pocs.hachim.fr
5. **Refactoriser les contraintes de clés étrangères** - Utiliser un style cohérent (ON DELETE CASCADE vs RESTRICT)
6. **Nettoyer les fichiers de test** - Supprimer les rapports de test échoués dans tests/postman/results
7. **Simplifier les Dockerfiles** - Optimiser la taille des images et réduire les étapes de build inutiles