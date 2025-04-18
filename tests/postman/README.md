# Tests API avec Postman et Newman

Ce répertoire contient les collections Postman et les scripts pour tester l'API Quiz avec Newman dans Docker.

## Prérequis

- Docker installé sur votre machine
- L'API Quiz en cours d'exécution (via docker-compose)
- jq installé pour l'initialisation des données de test (optionnel)

## Structure des fichiers

```
tests/postman/
├── quiz-api-collection.json  # Collection principale de tests Postman
├── environment.json          # Variables d'environnement pour les tests
├── results/                  # Répertoire pour les rapports de test (créé automatiquement)
└── README.md                 # Ce fichier
```

## Exécution des tests

Il y a plusieurs façons d'exécuter les tests :

### 1. Utiliser le script run-tests.sh

Le moyen le plus simple est d'utiliser le script shell fourni :

```bash
# Rendre le script exécutable
chmod +x scripts/run-tests.sh

# Exécuter les tests avec la collection et l'environnement par défaut
./scripts/run-tests.sh

# Ou spécifier une collection et un environnement personnalisés
./scripts/run-tests.sh tests/postman/ma-collection.json tests/postman/mon-env.json
```

### 2. Utiliser docker-compose.test.yml

Pour une intégration CI/CD ou pour exécuter les tests dans un environnement isolé :

```bash
# Initialiser d'abord les données de test (optionnel)
chmod +x scripts/initialize-test-data.sh
./scripts/initialize-test-data.sh http://localhost:3000

# Puis exécuter les tests avec docker-compose
docker-compose -f docker-compose.test.yml up
```

### 3. Exécuter directement avec Docker

Si vous préférez plus de contrôle ou des options personnalisées :

```bash
docker run --rm \
    --network quizapi-network \
    -v "$(pwd)/tests/postman:/etc/newman" \
    postman/newman:alpine \
    run "/etc/newman/quiz-api-collection.json" \
    -e "/etc/newman/environment.json" \
    --reporters cli,htmlextra \
    --reporter-htmlextra-export "/etc/newman/results/report.html"
```

## Visualisation des résultats

Après l'exécution des tests, les rapports sont générés dans le répertoire `tests/postman/results/` :

- Rapport HTML détaillé : `*-report.html`
- Rapport XML JUnit (pour intégration CI/CD) : `*-junit.xml`

Ouvrez le fichier HTML dans un navigateur pour voir les résultats détaillés avec des graphiques.

## Conseils pour les tests

1. **Variables d'environnement** : Utilisez des variables d'environnement pour les valeurs qui peuvent changer (URL de l'API, tokens, IDs).

2. **Tests indépendants** : Assurez-vous que chaque test peut s'exécuter indépendamment des autres.

3. **Nettoyage après les tests** : Les tests qui créent des données devraient également les supprimer à la fin.

4. **Variables globales** : Utilisez les scripts de tests pour définir des variables globales qui seront utilisées par les tests suivants.

5. **Idempotence** : Les tests devraient pouvoir être exécutés plusieurs fois sans effet secondaire.