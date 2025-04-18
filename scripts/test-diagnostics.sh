#!/bin/bash

# Variables
API_URL=${1:-"http://localhost:3000"}
COLLECTION_FILE=${2:-"tests/postman/quiz-api-collection.json"}
ENVIRONMENT_FILE=${3:-"tests/postman/environment.json"}

# Couleurs
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
NC="\033[0m" # No Color

echo "=== Diagnostic des tests API ==="
echo "URL de l'API: $API_URL"
echo "Collection: $COLLECTION_FILE"
echo "Environnement: $ENVIRONMENT_FILE"
echo ""

# Vérifier si les fichiers existent
echo "=== Vérification des fichiers ==="
if [ -f "$COLLECTION_FILE" ]; then
    echo -e "${GREEN}✓${NC} Collection trouvée"
else
    echo -e "${RED}✗${NC} Collection non trouvée: $COLLECTION_FILE"
fi

if [ -f "$ENVIRONMENT_FILE" ]; then
    echo -e "${GREEN}✓${NC} Environnement trouvé"
else
    echo -e "${RED}✗${NC} Environnement non trouvé: $ENVIRONMENT_FILE"
fi
echo ""

# Vérifier l'état des conteneurs Docker
echo "=== État des conteneurs Docker ==="
CONTAINERS=("postgres" "postgrest" "swagger" "pgadmin")
for container in "${CONTAINERS[@]}"; do
    if docker ps | grep -q $container; then
        echo -e "${GREEN}✓${NC} $container est en cours d'exécution"
    else
        echo -e "${RED}✗${NC} $container n'est pas en cours d'exécution"
    fi
done
echo ""

# Vérifier l'accès à l'API
echo "=== Test de connexion à l'API ==="
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" $API_URL)
if [ "$HTTP_CODE" -eq 200 ]; then
    echo -e "${GREEN}✓${NC} API accessible (code HTTP $HTTP_CODE)"
else
    echo -e "${RED}✗${NC} API non accessible (code HTTP $HTTP_CODE)"
fi
echo ""

# Vérifier la validité de la collection Postman
echo "=== Validation de la collection Postman ==="
if [ -f "$COLLECTION_FILE" ]; then
    if jq -e . "$COLLECTION_FILE" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Collection JSON valide"
        
        # Extraire des informations de base
        NAME=$(jq -r '.info.name // "Non spécifié"' "$COLLECTION_FILE")
        VERSION=$(jq -r '.info.version // "Non spécifié"' "$COLLECTION_FILE")
        ITEM_COUNT=$(jq '.item | length' "$COLLECTION_FILE")
        
        echo "   Nom: $NAME"
        echo "   Version: $VERSION"
        echo "   Nombre d'items: $ITEM_COUNT"
    else
        echo -e "${RED}✗${NC} Collection JSON invalide"
    fi
fi
echo ""

# Vérifier la validité de l'environnement Postman
echo "=== Validation de l'environnement Postman ==="
if [ -f "$ENVIRONMENT_FILE" ]; then
    if jq -e . "$ENVIRONMENT_FILE" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Environnement JSON valide"
        
        # Extraire des informations de base
        ENV_NAME=$(jq -r '.name // "Non spécifié"' "$ENVIRONMENT_FILE")
        VAR_COUNT=$(jq '.values | length' "$ENVIRONMENT_FILE")
        
        echo "   Nom: $ENV_NAME"
        echo "   Nombre de variables: $VAR_COUNT"
        
        # Vérifier l'URL de l'API dans l'environnement
        API_URL_ENV=$(jq -r '.values[] | select(.key=="apiUrl") | .value' "$ENVIRONMENT_FILE")
        if [ -n "$API_URL_ENV" ]; then
            echo "   URL API configurée: $API_URL_ENV"
            
            # Tester si l'URL dans l'environnement est accessible
            HTTP_CODE_ENV=$(curl -s -o /dev/null -w "%{http_code}" $API_URL_ENV 2>/dev/null || echo "erreur")
            if [ "$HTTP_CODE_ENV" == "erreur" ]; then
                echo -e "${YELLOW}⚠${NC} Impossible de tester l'URL de l'environnement (probablement une URL interne au réseau Docker)"
            elif [ "$HTTP_CODE_ENV" -eq 200 ]; then
                echo -e "${GREEN}✓${NC} URL de l'environnement accessible (code HTTP $HTTP_CODE_ENV)"
            else
                echo -e "${RED}✗${NC} URL de l'environnement non accessible (code HTTP $HTTP_CODE_ENV)"
            fi
        else
            echo -e "${YELLOW}⚠${NC} Variable apiUrl non trouvée dans l'environnement"
        fi
    else
        echo -e "${RED}✗${NC} Environnement JSON invalide"
    fi
fi
echo ""

# Tester si Newman est accessible via Docker
echo "=== Test de Newman avec Docker ==="
if docker run --rm postman/newman:alpine --version > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Newman accessible via Docker"
    NEWMAN_VERSION=$(docker run --rm postman/newman:alpine --version)
    echo "   Version: $NEWMAN_VERSION"
else
    echo -e "${RED}✗${NC} Newman non accessible via Docker"
fi
echo ""

# Vérifier la connectivité réseau entre conteneurs
echo "=== Test de connectivité réseau Docker ==="
if docker network ls | grep -q quizapi-network; then
    echo -e "${GREEN}✓${NC} Réseau quizapi-network trouvé"
    
    # Liste des conteneurs dans le réseau
    CONNECTED_CONTAINERS=$(docker network inspect quizapi-network -f '{{range .Containers}}{{.Name}} {{end}}')
    echo "   Conteneurs connectés: $CONNECTED_CONTAINERS"
else
    echo -e "${RED}✗${NC} Réseau quizapi-network non trouvé"
fi
echo ""

echo "=== Diagnostic terminé ==="