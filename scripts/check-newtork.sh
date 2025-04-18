#!/bin/bash

# Variables
NETWORK_NAME="quizapi-network"
API_CONTAINER="postgrest"
API_PORT="3000"

# Couleurs pour l'affichage
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
NC="\033[0m" # No Color

echo -e "${YELLOW}=== Test de connectivité Docker pour PostgREST ===${NC}"

# Vérifier si le réseau existe
if ! docker network ls | grep -q $NETWORK_NAME; then
    echo -e "${RED}Le réseau $NETWORK_NAME n'existe pas${NC}"
    echo -e "Création du réseau..."
    docker network create $NETWORK_NAME
    echo -e "${GREEN}Réseau $NETWORK_NAME créé${NC}"
else
    echo -e "${GREEN}Réseau $NETWORK_NAME existe${NC}"
fi

# Vérifier si le conteneur de l'API existe et tourne
if ! docker ps | grep -q $API_CONTAINER; then
    echo -e "${RED}Le conteneur $API_CONTAINER n'est pas en cours d'exécution${NC}"
    echo -e "Veuillez démarrer vos services avec 'docker-compose up -d'"
    exit 1
else
    echo -e "${GREEN}Conteneur $API_CONTAINER est en cours d'exécution${NC}"
fi

# Vérifier si le conteneur est connecté au réseau
if ! docker network inspect $NETWORK_NAME | grep -q "\"$API_CONTAINER\""; then
    echo -e "${RED}Le conteneur $API_CONTAINER n'est pas connecté au réseau $NETWORK_NAME${NC}"
    echo -e "Connexion du conteneur au réseau..."
    docker network connect $NETWORK_NAME $API_CONTAINER
    echo -e "${GREEN}Conteneur connecté au réseau${NC}"
else
    echo -e "${GREEN}Conteneur $API_CONTAINER est déjà connecté au réseau $NETWORK_NAME${NC}"
fi

# Tester la connectivité depuis un conteneur temporaire sur le même réseau
echo -e "${YELLOW}Test de connectivité à l'API depuis le réseau Docker...${NC}"
RESULT=$(docker run --rm --network $NETWORK_NAME appropriate/curl -s -o /dev/null -w "%{http_code}" http://$API_CONTAINER:$API_PORT 2>/dev/null || echo "ERROR")

if [ "$RESULT" = "ERROR" ]; then
    echo -e "${RED}Impossible de se connecter à http://$API_CONTAINER:$API_PORT${NC}"
    # Vérifier si le conteneur écoute bien sur le port attendu
    LISTENING=$(docker exec $API_CONTAINER netstat -tulpn 2>/dev/null | grep $API_PORT || echo "")
    if [ -z "$LISTENING" ]; then
        echo -e "${RED}Le conteneur $API_CONTAINER ne semble pas écouter sur le port $API_PORT${NC}"
        echo -e "Vérifiez la configuration de PostgREST et assurez-vous qu'il est configuré pour écouter sur 0.0.0.0:$API_PORT"
    fi
else
    echo -e "${GREEN}Connexion réussie ! Code HTTP: $RESULT${NC}"
    echo -e "Le conteneur Newman pourra accéder à l'API via http://$API_CONTAINER:$API_PORT"
fi

# Tester la résolution DNS
echo -e "${YELLOW}Test de résolution DNS du conteneur $API_CONTAINER...${NC}"
DNS_RESULT=$(docker run --rm --network $NETWORK_NAME appropriate/curl -s getent hosts $API_CONTAINER || echo "ERROR")

if [ "$DNS_RESULT" = "ERROR" ]; then
    echo -e "${RED}Impossible de résoudre le nom d'hôte $API_CONTAINER dans le réseau Docker${NC}"
else
    echo -e "${GREEN}Résolution DNS réussie:${NC}"
    echo -e "$DNS_RESULT"
fi

echo -e "\n${YELLOW}Conclusion:${NC}"
if [ "$RESULT" != "ERROR" ] && [ "$DNS_RESULT" != "ERROR" ]; then
    echo -e "${GREEN}✅ La configuration réseau est correcte${NC}"
    echo -e "Les tests Newman pourront accéder à l'API via http://$API_CONTAINER:$API_PORT"
    echo -e "Vous pouvez maintenant exécuter vos tests avec ./scripts/run-tests.sh"
else
    echo -e "${RED}❌ Des problèmes de connectivité ont été détectés${NC}"
    echo -e "Veuillez corriger les problèmes ci-dessus avant d'exécuter les tests"
fi