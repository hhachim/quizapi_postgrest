# Check-list d'installation des tests API

Utilisez cette check-list pour vérifier que votre environnement de test est correctement configuré.

## 🔧 Configuration Docker

- [ ] Docker est installé et fonctionnel
- [ ] Le réseau `quizapi-network` existe
  ```bash
  docker network ls | grep quizapi-network
  ```
- [ ] Les images nécessaires sont disponibles
  ```bash
  docker pull postman/newman:alpine
  docker pull loadimpact/k6
  ```

## 📁 Structure de fichiers

- [ ] La structure de répertoires est créée
  ```bash
  mkdir -p scripts tests/postman/results tests/load/results docs/api
  ```
- [ ] Les scripts d'exécution sont présents et exécutables
  ```bash
  ls -la scripts/*.sh
  ```
- [ ] Les fichiers de test existent
  ```bash
  ls -la tests/postman/quiz-api-collection.json tests/postman/environment.json tests/load/load-test.js
  ```

## 📋 Scripts

- [ ] Le script d'exécution des tests est fonctionnel
  ```bash
  chmod +x scripts/run-tests.sh
  ./scripts/run-tests.sh --help # Si l'aide est implémentée
  ```
- [ ] Le script de diagnostic fonctionne
  ```bash
  chmod +x scripts/test-diagnostics.sh
  ./scripts/test-diagnostics.sh
  ```

## 🔄 Intégration avec le projet

- [ ] Le fichier `docker-compose.test.yml` est configuré
  ```bash
  docker-compose -f docker-compose.test.yml config
  ```
- [ ] Les commandes de test sont présentes dans le Makefile
  ```bash
  grep "test" Makefile
  ```
- [ ] L'environnement Postman pointe vers la bonne URL API
  ```bash
  grep "apiUrl" tests/postman/environment.json
  ```

## 🧪 Premier test

- [ ] Les services API sont en cours d'exécution
  ```bash
  docker-compose ps
  ```
- [ ] Le test de diagnostic passe
  ```bash
  make test-diagnostics
  ```
- [ ] Un test minimal peut s'exécuter avec succès
  ```bash
  make test
  ```

## 📊 Génération de rapports

- [ ] Les rapports de test sont générés dans le bon répertoire
  ```bash
  ls -la tests/postman/results/
  ```
- [ ] Le format des rapports est exploitable
  ```bash
  # Vérifier qu'au moins un rapport HTML existe
  find tests/postman/results -name "*.html" | wc -l
  ```

## 🔒 Sécurité

- [ ] Les identifiants sensibles utilisent des variables d'environnement
  ```bash
  # Vérifier qu'aucun mot de passe n'apparaît en clair
  grep -r "password" tests/postman/
  ```
- [ ] Les tests respectent les politiques de sécurité (pas d'attaques)
  ```bash
  # À vérifier manuellement dans les collections
  ```

## 🚀 CI/CD

- [ ] Le workflow GitHub Actions est configuré
  ```bash
  cat .github/workflows/api-tests.yml
  ```
- [ ] Les variables d'environnement sensibles sont configurées comme secrets
  ```bash
  # À vérifier dans l'interface GitHub
  ```

## 📝 Documentation

- [ ] Le README contient des instructions pour les tests
  ```bash
  grep -A 10 "Tests" README.md
  ```
- [ ] La documentation des tests est disponible
  ```bash
  ls -la docs/testing.md
  ```

## 🧠 Aide-mémoire des commandes

```bash
# Diagnostics
make test-diagnostics

# Exécuter tous les tests fonctionnels
make test

# Exécuter uniquement les tests API
make test-api

# Exécuter les tests de charge
make test-load

# Générer la documentation
make docs

# Convertir des commandes cURL en collection Postman
make curl-to-postman
```