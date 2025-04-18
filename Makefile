.PHONY: help start stop test test-api test-init test-report test-load test-diagnostics docs clean backup reset

# Couleurs pour une meilleure lisibilité
GREEN=\033[0;32m
YELLOW=\033[0;33m
RED=\033[0;31m
NC=\033[0m # No Color

# Aide
help: ## Affiche cette aide
	@echo "${YELLOW}Makefile pour l'API Quiz${NC}"
	@echo ""
	@echo "${GREEN}Usage:${NC}"
	@echo "  make ${YELLOW}<target>${NC}"
	@echo ""
	@echo "${GREEN}Targets:${NC}"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  ${YELLOW}%-15s${NC} %s\n", $$1, $$2}'

# Démarrage de l'application
start: ## Démarre les services de l'API Quiz
	@echo "${GREEN}Démarrage des services...${NC}"
	docker-compose up -d
	@echo "${GREEN}Services démarrés !${NC}"

# Arrêt de l'application
stop: ## Arrête les services de l'API Quiz
	@echo "${YELLOW}Arrêt des services...${NC}"
	docker-compose down
	@echo "${GREEN}Services arrêtés !${NC}"

# Tests fonctionnels
test: test-init test-api ## Exécute tous les tests fonctionnels

test-api: ## Exécute les tests Postman/Newman
	@echo "${GREEN}Exécution des tests API...${NC}"
	@chmod +x scripts/run-tests.sh
	@./scripts/run-tests.sh
	@echo "${GREEN}Tests API terminés !${NC}"

test-init: ## Initialise les données de test
	@echo "${GREEN}Initialisation des données de test...${NC}"
	@chmod +x scripts/initialize-test-data.sh
	@./scripts/initialize-test-data.sh http://localhost:3000
	@echo "${GREEN}Données de test initialisées !${NC}"

test-report: ## Ouvre le dernier rapport de test dans le navigateur par défaut
	@echo "${GREEN}Ouverture du rapport de test...${NC}"
	@latest_report=$$(find tests/postman/results -name "*.html" -type f -printf "%T@ %p\n" | sort -n | tail -1 | cut -f2- -d" "); \
	if [ -n "$$latest_report" ]; then \
		echo "Ouverture de $$latest_report"; \
		open "$$latest_report" 2>/dev/null || xdg-open "$$latest_report" 2>/dev/null || echo "${RED}Impossible d'ouvrir le rapport automatiquement${NC}"; \
	else \
		echo "${RED}Aucun rapport trouvé !${NC}"; \
	fi

# Tests de charge
test-load: ## Exécute les tests de charge avec k6
	@echo "${GREEN}Exécution des tests de charge...${NC}"
	@chmod +x scripts/run-load-tests.sh
	@./scripts/run-load-tests.sh http://localhost:3000
	@echo "${GREEN}Tests de charge terminés !${NC}"

# Diagnostics
test-diagnostics: ## Exécute les diagnostics des tests
	@echo "${GREEN}Exécution des diagnostics...${NC}"
	@chmod +x scripts/test-diagnostics.sh
	@./scripts/test-diagnostics.sh http://localhost:3000
	@echo "${GREEN}Diagnostics terminés !${NC}"

# Documentation
docs: ## Génère la documentation API
	@echo "${GREEN}Génération de la documentation API...${NC}"
	@chmod +x scripts/generate-api-docs.sh
	@./scripts/generate-api-docs.sh
	@echo "${GREEN}Documentation générée !${NC}"

curl-to-postman: ## Convertit les commandes cURL en collection Postman
	@echo "${GREEN}Conversion des commandes cURL en collection Postman...${NC}"
	@chmod +x scripts/curl-to-postman.sh
	@./scripts/curl-to-postman.sh CurlTests.md
	@echo "${GREEN}Conversion terminée !${NC}"

# Maintenance
backup: ## Crée une sauvegarde de la base de données
	@echo "${GREEN}Création d'une sauvegarde...${NC}"
	@chmod +x scripts/backup.sh
	@./scripts/backup.sh
	@echo "${GREEN}Sauvegarde terminée !${NC}"

reset: ## Réinitialise la base de données (ATTENTION: toutes les données seront perdues)
	@echo "${RED}ATTENTION: Cette action va réinitialiser complètement la base de données !${NC}"
	@echo "${RED}Toutes les données seront perdues. Cette action est irréversible.${NC}"
	@read -p "Êtes-vous sûr de vouloir continuer? (y/n): " confirm; \
	if [ "$$confirm" = "y" ]; then \
		chmod +x scripts/reset-db.sh; \
		./scripts/reset-db.sh; \
	else \
		echo "${YELLOW}Opération annulée.${NC}"; \
	fi

clean: ## Nettoie les rapports de test
	@echo "${YELLOW}Nettoyage des rapports de test...${NC}"
	@rm -rf tests/postman/results/*
	@rm -rf tests/load/results/*
	@echo "${GREEN}Nettoyage terminé !${NC}"

# Développement
dev-env: ## Prépare l'environnement de développement
	@echo "${GREEN}Préparation de l'environnement de développement...${NC}"
	@mkdir -p tests/postman/results
	@mkdir -p tests/load/results
	@mkdir -p docs/api
	@chmod +x scripts/*.sh
	@echo "${GREEN}Environnement prêt !${NC}"