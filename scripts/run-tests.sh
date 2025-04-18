#!/bin/bash

# Variables
COLLECTION_FILE=${1:-"tests/postman/quiz-api-collection.json"}
ENVIRONMENT_FILE=${2:-"tests/postman/environment.json"}
OUTPUT_DIR="tests/postman/results"
TEST_NAME=$(basename "$COLLECTION_FILE" .json)
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
REPORT_NAME="${TEST_NAME}_${TIMESTAMP}"

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

# Exécuter Newman avec l'image personnalisée
docker run --rm \
    --network quizapi-network \
    -v "$(pwd):/etc/newman" \
    newman-with-htmlextra \
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