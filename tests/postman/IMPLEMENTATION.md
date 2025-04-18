# Guide d'implémentation des tests API avec Docker

Ce document explique comment intégrer et utiliser les nouvelles fonctionnalités de test dans votre projet Quiz API basé sur PostgREST.

## Fichiers ajoutés

### Scripts principaux
- `scripts/run-tests.sh` - Exécute les tests Postman avec Newman via Docker
- `scripts/initialize-test-data.sh` - Prépare les données pour les tests
- `scripts/test-diagnostics.sh` - Diagnostic de l'environnement de test
- `scripts/curl-to-postman.sh` - Convertit les commandes cURL en collection Postman
- `scripts/run-load-tests.sh` - Exécute les tests de charge avec k6
- `scripts/generate-api-docs.sh` - Génère la documentation de l'API

### Collections et environnements Postman
- `tests/postman/quiz-api-collection.json` - Collection principale de tests
- `tests/postman/environment.json` - Variables d'environnement pour les tests

### Tests de charge
- `tests/load/load-test.js` - Script de test de charge avec k6

### Configuration CI/CD
- `.github/workflows/api-tests.yml` - Configuration GitHub Actions

### Documentation
- `docs/testing.md` - Guide complet des tests
- `docs/frontend-testing-integration.md` - Guide d'intégration avec le frontend

## Étapes d'installation

1. **Créer la structure de répertoires**
   ```bash
   mkdir -p scripts tests/postman/results tests/load/results docs/api
   ```

2. **Copier les scripts dans le répertoire scripts/**
   ```bash
   # S'assurer que tous les scripts sont exécutables
   chmod +x scripts/*.sh
   ```

3. **Ajouter les commandes au Makefile**
   ```bash
   # Si vous n'avez pas de Makefile, en créer un
   cp Makefile-updated Makefile
   ```

4. **Créer un premier test à partir des commandes cURL existantes**
   ```bash
   ./scripts/curl-to-postman.sh CurlTests.md
   ```

## Utilisation quotidienne

### Exécuter les tests API

```bash
# Exécuter tous les tests fonctionnels
make test

# Ou avec le script directement
./scripts/run-tests.sh
```

### Tester les performances

```bash
# Exécuter les tests de charge
make test-load
```

### Générer la documentation

```bash
# Créer une documentation interactive
make docs
```

### Diagnostiquer les problèmes

```bash
# Vérifier l'environnement de test
make test-diagnostics
```

## Intégration avec votre workflow de développement

### Développement local

1. **Avant de commencer à développer**
   ```bash
   # Démarrer les services
   make start
   
   # Vérifier que tout fonctionne
   make test-diagnostics
   ```

2. **Après des modifications de l'API**
   ```bash
   # Exécuter les tests
   make test
   
   # Vérifier les performances
   make test-load
   ```

3. **Pour partager la documentation avec l'équipe frontend**
   ```bash
   # Générer la documentation
   make docs
   
   # La documentation est disponible dans docs/api/
   ```

### Intégration continue

Le fichier `.github/workflows/api-tests.yml` configure GitHub Actions pour:

1. Exécuter automatiquement les tests à chaque push
2. Générer des rapports de tests
3. Alerter en cas d'échec

## Personnalisation

### Ajouter de nouveaux tests

1. **Éditer la collection directement**
   - Modifier `tests/postman/quiz-api-collection.json` avec un éditeur de texte
   
2. **Utiliser Postman (recommandé)**
   - Importer la collection dans Postman
   - Ajouter vos nouveaux tests
   - Exporter et remplacer le fichier de collection

3. **Convertir d'autres commandes cURL**
   ```bash
   ./scripts/curl-to-postman.sh votre-fichier.md
   ```

### Modifier les tests de charge

Modifiez `tests/load/load-test.js` pour :
- Changer le nombre d'utilisateurs virtuels
- Modifier les seuils de performance
- Ajouter de nouveaux scénarios de test

## Conseils pour la maintenance

1. **Mettre à jour régulièrement les collections**
   - Chaque nouveau endpoint devrait avoir des tests
   - Les modifications d'API doivent être reflétées dans les tests

2. **Vérifier les performances après chaque changement significatif**
   ```bash
   make test-load
   ```

3. **Conserver un historique des rapports de performance**
   - Les rapports sont datés dans `tests/load/results/`
   - Suivez l'évolution des performances au fil du temps

4. **Utiliser les tests comme documentation vivante**
   - La collection Postman documente les endpoints disponibles
   - Les assertions documentent le comportement attendu

## Résolution des problèmes courants

### Les tests échouent avec "Connection refused"

```bash
# Vérifier que les services sont en cours d'exécution
docker-compose ps

# Vérifier l'état du réseau Docker
docker network inspect quizapi-network

# Exécuter les diagnostics
make test-diagnostics
```

### Les tests de charge consomment trop de ressources

Modifiez `tests/load/load-test.js` pour réduire:
- Le nombre d'utilisateurs virtuels (`vus`)
- La durée des tests (`duration`)
- Le nombre de requêtes par seconde (`rate`)

### Erreur "network quizapi-network not found"

```bash
# Créer le réseau Docker
docker network create quizapi-network
```

## Prochaines étapes suggérées

1. **Enrichir la collection Postman**
   - Ajouter des tests pour tous les endpoints
   - Ajouter des tests pour les cas d'erreur

2. **Configurer le monitoring continu**
   - Ajouter des tests de supervision (heartbeat)
   - Mettre en place des alertes automatiques

3. **Élargir les tests de charge**
   - Tester des scénarios utilisateur complets
   - Établir des benchmarks de référence

4. **Intégrer avec le frontend**
   - Utiliser la même collection pour les tests E2E
   - Créer des mocks basés sur les exemples Postman