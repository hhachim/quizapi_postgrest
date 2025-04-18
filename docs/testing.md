# Guide complet des tests pour l'API Quiz

Ce document décrit l'ensemble des outils et processus de test mis en place pour garantir la qualité de l'API Quiz.

## Table des matières

1. [Tests fonctionnels avec Postman/Newman](#tests-fonctionnels-avec-postman-newman)
2. [Tests de charge avec k6](#tests-de-charge-avec-k6)
3. [Intégration CI/CD](#intégration-ci-cd)
4. [Diagnostics et dépannage](#diagnostics-et-dépannage)
5. [Génération de documentation d'API](#génération-de-documentation-dapi)
6. [Conversion automatique de cURL](#conversion-automatique-de-curl)
7. [Meilleures pratiques](#meilleures-pratiques)

## Tests fonctionnels avec Postman/Newman

### Présentation

Les tests fonctionnels vérifient que l'API fonctionne conformément aux spécifications. Ils utilisent Postman pour définir les requêtes et Newman pour automatiser leur exécution.

### Structure des fichiers

```
tests/postman/
├── quiz-api-collection.json  # Collection principale de tests
├── environment.json          # Variables d'environnement
└── results/                  # Rapports de tests générés
```

### Commandes disponibles

```bash
# Exécuter tous les tests fonctionnels
make test

# Exécuter uniquement les tests API
make test-api

# Initialiser les données de test
make test-init

# Afficher le rapport de test
make test-report
```

### Création de nouveaux tests

Pour ajouter de nouveaux tests fonctionnels:

1. Ouvrez votre client Postman et importez la collection existante
2. Ajoutez vos nouvelles requêtes et tests
3. Exportez la collection mise à jour dans `tests/postman/quiz-api-collection.json`
4. Exécutez les tests avec `make test-api` pour vérifier qu'ils fonctionnent

### Exemple de test dans Postman

```javascript
// Exemple de script de test pour une requête GET /categories
pm.test("Status code is 200", function() {
    pm.response.to.have.status(200);
});

pm.test("Response is an array", function() {
    var jsonData = pm.response.json();
    pm.expect(jsonData).to.be.an('array');
});

pm.test("Categories contain required fields", function() {
    var jsonData = pm.response.json();
    if (jsonData.length > 0) {
        pm.expect(jsonData[0]).to.have.property('id');
        pm.expect(jsonData[0]).to.have.property('name');
    }
});
```

## Tests de charge avec k6

### Présentation

Les tests de charge vérifient la performance et la stabilité de l'API sous différentes conditions de charge. Ils utilisent k6, un outil moderne de test de charge.

### Structure des fichiers

```
tests/load/
├── load-test.js             # Script principal de test de charge
└── results/                 # Rapports de tests générés
```

### Commandes disponibles

```bash
# Exécuter les tests de charge
make test-load
```

### Types de tests de charge inclus

1. **Test de charge constante**: Vérifie le comportement sous un nombre fixe d'utilisateurs simultanés
2. **Test de montée en charge**: Vérifie la capacité à s'adapter à une augmentation progressive du trafic
3. **Test de pic de charge**: Vérifie la robustesse face à des pics soudains de trafic

### Personnalisation des tests de charge

Modifiez le fichier `tests/load/load-test.js` pour ajuster les paramètres suivants:

- **Nombre d'utilisateurs virtuels**: Modifiez les valeurs `vus` dans les scénarios
- **Durée des tests**: Modifiez les valeurs `duration` dans les scénarios
- **Critères de performance**: Modifiez les seuils dans la section `thresholds`
- **Endpoints testés**: Ajoutez ou modifiez les requêtes dans la fonction principale

### Exemple de configuration de seuils

```javascript
// Seuils de performance acceptables
thresholds: {
  'http_req_duration': ['p(95)<500'], // 95% des requêtes doivent s'exécuter en moins de 500ms
  'http_req_failed': ['rate<0.01'],   // Moins de 1% d'erreurs
  'category_response_time': ['avg<300'], // Temps de réponse moyen pour /categories < 300ms
}
```

## Intégration CI/CD

### Configuration pour GitHub Actions

Le fichier `.github/workflows/api-tests.yml` configure l'exécution automatique des tests lors des opérations de push et pull request.

### Processus

1. Chaque push sur les branches `main` et `develop` déclenche les tests
2. Les services sont démarrés dans l'environnement CI
3. Les tests fonctionnels et de charge sont exécutés
4. Les rapports de test sont générés et attachés comme artefacts
5. Un résumé des résultats est affiché dans l'interface CI

### Extension à d'autres plateformes CI/CD

Pour utiliser GitLab CI, Travis CI ou Jenkins, adaptez les commandes du workflow GitHub Actions. Les scripts principaux restent les mêmes, seule la configuration spécifique à la plateforme change.

## Diagnostics et dépannage

### Outil de diagnostic

Le script `scripts/test-diagnostics.sh` vérifie l'environnement de test et aide à identifier les problèmes potentiels.

```bash
# Exécuter les diagnostics
make test-diagnostics
```

### Problèmes courants et solutions

1. **Erreur "Network quizapi-network not found"**
   - Solution: `docker network create quizapi-network`

2. **Erreur "Connection refused" lors des tests**
   - Vérifiez que les services sont démarrés: `docker-compose ps`
   - Vérifiez les logs: `docker-compose logs postgrest`

3. **Erreur "404 Not Found" dans les tests Postman**
   - Vérifiez les URL dans la collection et l'environnement Postman
   - Vérifiez que les données de test ont été initialisées: `make test-init`

## Génération de documentation d'API

### À propos

La documentation d'API est générée automatiquement à partir des collections Postman, fournissant une référence pour les développeurs frontend.

### Commande

```bash
# Générer la documentation
make docs
```

### Structure de la documentation

```
docs/api/
├── index.html              # Documentation interactive
├── openapi.yaml            # Spécification OpenAPI (si générée)
└── examples/               # Exemples de requêtes et réponses
```

## Conversion automatique de cURL

### Présentation

Pour faciliter la création de tests, un script convertit automatiquement les commandes cURL en collection Postman.

### Utilisation

```bash
# Convertir les commandes cURL du fichier CurlTests.md
make curl-to-postman
```

### Processus

1. Le script extrait les commandes cURL du fichier Markdown
2. Les commandes sont converties en format Postman
3. Une nouvelle collection est générée dans `tests/postman/`
4. Cette collection peut être importée et modifiée dans Postman

## Meilleures pratiques

### Conception des tests

1. **Tests indépendants**: Chaque test doit pouvoir s'exécuter indépendamment
2. **Nettoyage après test**: Les tests créant des données doivent les supprimer à la fin
3. **Assertions claires**: Utilisez des messages d'assertion explicites
4. **Vérification complète**: Testez les cas normaux, limites et d'erreur

### Organisation des collections Postman

1. **Groupement logique**: Organisez les requêtes par fonctionnalité ou entité
2. **Variables d'environnement**: Utilisez des variables pour les valeurs qui changent
3. **Scripts de pré-requête**: Utilisez-les pour préparer les données nécessaires
4. **Automatisation**: Incluez des tests pour chaque requête

### Test en production

Pour tester une API en production sans risque:

1. Utilisez un jeu de données de test isolé
2. Exécutez uniquement les tests en lecture (GET)
3. Désactivez les tests de charge ou réduisez leurs paramètres
4. Utilisez un environnement Postman spécifique pour la production

```bash
# Exemple de test en production (lecture seule)
./scripts/run-tests.sh tests/postman/read-only-collection.json tests/postman/production-env.json
```

---

Ce guide vous donne tous les outils nécessaires pour maintenir et améliorer la qualité de l'API Quiz à travers des tests automatisés complets. Pour toute question ou suggestion, n'hésitez pas à contacter l'équipe de développement.