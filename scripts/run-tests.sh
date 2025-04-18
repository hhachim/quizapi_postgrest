#!/bin/bash

# Variables
COLLECTION_FILE=${1:-"tests/postman/quiz-api-collection.json"}
ENVIRONMENT_FILE=${2:-"tests/postman/environment.json"}
OUTPUT_DIR="tests/postman/results"
TEST_NAME=$(basename "$COLLECTION_FILE" .json)
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
REPORT_NAME="${TEST_NAME}_${TIMESTAMP}"
NETWORK_NAME="quizapi-network"

# Vérifier si les fichiers existent
if [ ! -f "$COLLECTION_FILE" ]; then
    echo "Collection file not found: $COLLECTION_FILE"
    exit 1
fi

# Créer le répertoire de sortie s'il n'existe pas
mkdir -p "$OUTPUT_DIR"

echo "Running Postman tests with Newman..."
echo "Collection: $COLLECTION_FILE"
if [ -f "$ENVIRONMENT_FILE" ]; then
    echo "Environment: $ENVIRONMENT_FILE"
    ENV_PARAM="-e $ENVIRONMENT_FILE"
else
    ENV_PARAM=""
fi

# Vérifier si le réseau Docker existe, le créer si nécessaire
if ! docker network ls | grep -q $NETWORK_NAME; then
    echo "Creating Docker network: $NETWORK_NAME"
    docker network create $NETWORK_NAME
fi

# S'assurer que le conteneur PostgREST est connecté au réseau
if docker ps -q --filter "name=postgrest" | grep -q .; then
    # Le conteneur postgrest existe et tourne
    if ! docker network inspect $NETWORK_NAME | grep -q "\"postgrest\""; then
        echo "Connecting postgrest container to $NETWORK_NAME network..."
        docker network connect $NETWORK_NAME postgrest
    else
        echo "postgrest container is already connected to $NETWORK_NAME network"
    fi
else
    echo "Warning: PostgREST container not found or not running"
    echo "Make sure your PostgREST service is running before executing tests"
    echo "You can start it with: docker-compose up -d"
fi

# Exécuter Newman dans le même réseau Docker que PostgREST
echo "Executing tests in the $NETWORK_NAME network..."
docker run --rm \
    --network $NETWORK_NAME \
    -v "$(pwd):/etc/newman" \
    postman/newman:alpine \
    run "/etc/newman/$COLLECTION_FILE" \
    $ENV_PARAM \
    --reporters cli,htmlextra,junit \
    --reporter-htmlextra-export "/etc/newman/$OUTPUT_DIR/${REPORT_NAME}-report.html" \
    --reporter-junit-export "/etc/newman/$OUTPUT_DIR/${REPORT_NAME}-junit.xml"

# Vérifier le code de sortie
if [ $? -eq 0 ]; then
    echo "Tests completed successfully!"
    echo "Reports saved to $OUTPUT_DIR/${REPORT_NAME}-report.html"
else
    echo "Tests failed!"
    echo "Check reports in $OUTPUT_DIR for details"
    exit 1
fi