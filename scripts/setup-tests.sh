#!/bin/bash

# Script d'installation rapide pour les tests API avec Newman et Docker, avec des fichiers vides
# Exécutez ce script à la racine de votre projet.

# Couleurs pour une meilleure lisibilité
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
NC="\033[0m" # No Color

echo -e "${GREEN}=== Installation des tests API avec Newman et Docker ===${NC}"

# Vérifier si Docker est installé
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker n'est pas installé. Veuillez l'installer avant de continuer.${NC}"
    exit 1
fi

# Vérifier si nous sommes à la racine du projet
if [ ! -f "docker-compose.yml" ]; then
    echo -e "${RED}Erreur: Ce script doit être exécuté à la racine du projet (où se trouve docker-compose.yml).${NC}"
    exit 1
fi

# Créer la structure de répertoires
echo -e "${YELLOW}Création des répertoires...${NC}"
mkdir -p scripts tests/postman/results tests/load/results docs/api

# Vérifier si le réseau Docker existe
if ! docker network ls | grep -q quizapi-network; then
    echo -e "${YELLOW}Création du réseau Docker quizapi-network...${NC}"
    docker network create quizapi-network
fi

# Télécharger tous les scripts
echo -e "${YELLOW}Téléchargement des scripts...${NC}"

# Liste des scripts à télécharger
SCRIPTS=(
    "run-tests.sh"
    "initialize-test-data.sh"
    "test-diagnostics.sh"
    "curl-to-postman.sh"
    "run-load-tests.sh"
    "generate-api-docs.sh"
)

# URL de base pour les scripts (à remplacer par votre dépôt Git ou un autre système de stockage)
BASE_URL="https://raw.githubusercontent.com/votre-organisation/quiz-api-tests/main/scripts"

for script in "${SCRIPTS[@]}"; do
    # Simuler le téléchargement (dans un vrai scénario, vous utiliseriez curl ou wget)
    echo "#!/bin/bash" > scripts/$script
    echo "# Script $script pour les tests API" >> scripts/$script
    echo "echo \"Ce script doit être remplacé par le vrai contenu\"" >> scripts/$script
    
    chmod +x scripts/$script
    echo -e "${GREEN}✓${NC} Script $script créé"
done

# Créer une collection Postman de base
echo -e "${YELLOW}Création d'une collection Postman initiale...${NC}"
cat > tests/postman/quiz-api-collection.json << 'EOF'
{
  "info": {
    "_postman_id": "8a7b4e9c-6d5f-4e3c-8c2a-1f2a3b4c5d6e",
    "name": "Quiz API Tests",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json",
    "description": "Tests automatisés pour l'API Quiz"
  },
  "item": [
    {
      "name": "Sanity Check",
      "item": [
        {
          "name": "API Root",
          "event": [
            {
              "listen": "test",
              "script": {
                "exec": [
                  "pm.test(\"Status code is 200\", function() {",
                  "    pm.response.to.have.status(200);",
                  "});"
                ],
                "type": "text/javascript"
              }
            }
          ],
          "request": {
            "method": "GET",
            "header": [],
            "url": {
              "raw": "{{apiUrl}}/",
              "host": ["{{apiUrl}}"],
              "path": [""]
            }
          }
        }
      ]
    }
  ]
}
EOF
echo -e "${GREEN}✓${NC} Collection Postman créée"

# Créer un environnement Postman de base
echo -e "${YELLOW}Création d'un environnement Postman...${NC}"
cat > tests/postman/environment.json << 'EOF'
{
  "id": "7d6e5f4c-3b2a-1c9d-8e7f-6a5b4c3d2e1f",
  "name": "Quiz API Environment",
  "values": [
    {
      "key": "apiUrl",
      "value": "http://postgrest:3000",
      "type": "default",
      "enabled": true
    }
  ],
  "_postman_variable_scope": "environment"
}
EOF
echo -e "${GREEN}✓${NC} Environnement Postman créé"

# Créer un script de test de charge de base
echo -e "${YELLOW}Création d'un script de test de charge...${NC}"
cat > tests/load/load-test.js << 'EOF'
import http from 'k6/http';
import { sleep, check } from 'k6';

export const options = {
  vus: 10,
  duration: '30s',
};

export default function() {
  const res = http.get('http://postgrest:3000/');
  check(res, { 'status was 200': (r) => r.status === 200 });
  sleep(1);
}
EOF
echo -e "${GREEN}✓${NC} Script de test de charge créé"

# Créer un docker-compose pour les tests
echo -e "${YELLOW}Création de docker-compose.test.yml...${NC}"
cat > docker-compose.test.yml << 'EOF'
version: '3'

services:
  newman:
    image: postman/newman:alpine
    container_name: newman
    volumes:
      - ./tests/postman:/etc/newman
      - ./tests/postman/results:/etc/newman/results
    command: >
      run "/etc/newman/quiz-api-collection.json"
      -e "/etc/newman/environment.json"
      --reporters cli,htmlextra,junit
      --reporter-htmlextra-export "/etc/newman/results/report.html"
      --reporter-junit-export "/etc/newman/results/junit-report.xml"
    networks:
      - quizapi-network
    depends_on:
      - postgrest

networks:
  quizapi-network:
    external: true
EOF
echo -e "${GREEN}✓${NC} docker-compose.test.yml créé"

# Ajouter les commandes au Makefile
echo -e "${YELLOW}Mise à jour du Makefile...${NC}"
if [ -f "Makefile" ]; then
    # Vérifier si les commandes de test existent déjà
    if ! grep -q "test-api:" Makefile; then
        # Ajouter les commandes de test
        cat >> Makefile << 'EOF'

# Commandes de test
test: test-init test-api ## Exécute tous les tests fonctionnels

test-api: ## Exécute les tests Postman/Newman
	@echo "Exécution des tests API..."
	@chmod +x scripts/run-tests.sh
	@./scripts/run-tests.sh

test-init: ## Initialise les données de test
	@echo "Initialisation des données de test..."
	@chmod +x scripts/initialize-test-data.sh
	@./scripts/initialize-test-data.sh http://localhost:3000

test-load: ## Exécute les tests de charge
	@echo "Exécution des tests de charge..."
	@chmod +x scripts/run-load-tests.sh
	@./scripts/run-load-tests.sh

test-diagnostics: ## Exécute les diagnostics de test
	@echo "Exécution des diagnostics..."
	@chmod +x scripts/test-diagnostics.sh
	@./scripts/test-diagnostics.sh
EOF
        echo -e "${GREEN}✓${NC} Commandes de test ajoutées au Makefile"
    else
        echo -e "${YELLOW}Les commandes de test sont déjà présentes dans le Makefile.${NC}"
    fi
else
    # Créer un nouveau Makefile
    cat > Makefile << 'EOF'
.PHONY: help start stop test test-api test-init test-load test-diagnostics

# Couleurs pour une meilleure lisibilité
GREEN=\033[0;32m
YELLOW=\033[0;33m
RED=\033[0;31m
NC=\033[0m # No Color

# Aide
help: ## Affiche cette aide
	@echo "$(YELLOW)Makefile pour l'API Quiz$(NC)"
	@echo ""
	@echo "$(GREEN)Usage:$(NC)"
	@echo "  make $(YELLOW)<target>$(NC)"
	@echo ""
	@echo "$(GREEN)Targets:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-15s$(NC) %s\n", $$1, $$2}'

# Démarrage de l'application
start: ## Démarre les services de l'API Quiz
	@echo "$(GREEN)Démarrage des services...$(NC)"
	docker-compose up -d
	@echo "$(GREEN)Services démarrés !$(NC)"

# Arrêt de l'application
stop: ## Arrête les services de l'API Quiz
	@echo "$(YELLOW)Arrêt des services...$(NC)"
	docker-compose down
	@echo "$(GREEN)Services arrêtés !$(NC)"

# Tests fonctionnels
test: test-init test-api ## Exécute tous les tests fonctionnels

test-api: ## Exécute les tests Postman/Newman
	@echo "$(GREEN)Exécution des tests API...$(NC)"
	@chmod +x scripts/run-tests.sh
	@./scripts/run-tests.sh
	@echo "$(GREEN)Tests API terminés !$(NC)"

test-init: ## Initialise les données de test
	@echo "$(GREEN)Initialisation des données de test...$(NC)"
	@chmod +x scripts/initialize-test-data.sh
	@./scripts/initialize-test-data.sh http://localhost:3000
	@echo "$(GREEN)Données de test initialisées !$(NC)"

test-load: ## Exécute les tests de charge
	@echo "$(GREEN)Exécution des tests de charge...$(NC)"
	@chmod +x scripts/run-load-tests.sh
	@./scripts/run-load-tests.sh
	@echo "$(GREEN)Tests de charge terminés !$(NC)"

test-diagnostics: ## Exécute les diagnostics
	@echo "$(GREEN)Exécution des diagnostics...$(NC)"
	@chmod +x scripts/test-diagnostics.sh
	@./scripts/test-diagnostics.sh
	@echo "$(GREEN)Diagnostics terminés !$(NC)"
EOF
    echo -e "${GREEN}✓${NC} Nouveau Makefile créé"
fi

# Créer un workflow GitHub Actions de base
echo -e "${YELLOW}Création du workflow GitHub Actions...${NC}"
mkdir -p .github/workflows
cat > .github/workflows/api-tests.yml << 'EOF'
name: API Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  api-tests:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3
      
      - name: Set up environment
        run: |
          mkdir -p tests/postman/results
      
      - name: Start services
        run: docker-compose up -d
      
      - name: Run API tests
        run: |
          chmod +x scripts/run-tests.sh
          ./scripts/run-tests.sh
      
      - name: Upload test results
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: newman-test-results
          path: tests/postman/results/
EOF
echo -e "${GREEN}✓${NC} Workflow GitHub Actions créé"

# Instructions finales
echo -e "${GREEN}=== Installation terminée avec succès ===${NC}"
echo -e "${YELLOW}Prochaines étapes:${NC}"
echo "1. Remplacez les scripts générés par les scripts réels"
echo "2. Personnalisez la collection Postman selon vos besoins"
echo "3. Adaptez les tests de charge à votre API"
echo "4. Essayez de lancer un premier test avec: make test-diagnostics"
echo ""
echo -e "${YELLOW}Note importante:${NC} Ce script a créé des fichiers avec du contenu minimal."
echo "Vous devrez remplacer le contenu des scripts par les véritables scripts de test."
echo ""
echo -e "${GREEN}Bon testing !${NC}"