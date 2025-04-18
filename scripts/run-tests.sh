#!/bin/bash

# Variables
COLLECTION_FILE=${1:-"tests/postman/quiz-api-collection.json"}
ENVIRONMENT_FILE=${2:-"tests/postman/environment.json"}
OUTPUT_DIR="tests/postman/results"
TEST_NAME=$(basename "$COLLECTION_FILE" .json)
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
REPORT_NAME="${TEST_NAME}_${TIMESTAMP}"
NEWMAN_IMAGE="newman-with-htmlextra"

# Paramètre d'exclusion de tests via variable d'environnement
IGNORE_TESTS=${IGNORE_TESTS:-""}

# Vérifier si les fichiers existent
if [ ! -f "$COLLECTION_FILE" ]; then
    echo "Collection file not found: $COLLECTION_FILE"
    exit 1
fi

# Créer le répertoire de sortie s'il n'existe pas
mkdir -p "$OUTPUT_DIR"

# Vérifier si l'image newman-with-htmlextra existe, sinon la créer
if ! docker image inspect $NEWMAN_IMAGE >/dev/null 2>&1; then
    echo "Image $NEWMAN_IMAGE n'existe pas. Construction en cours..."
    if [ -d "docker/newman" ] && [ -f "docker/newman/Dockerfile" ]; then
        docker build -t $NEWMAN_IMAGE docker/newman
        echo "Image $NEWMAN_IMAGE construite avec succès!"
    # else
    #     echo "Dossier docker/newman ou fichier Dockerfile manquant!"
    #     echo "Création d'une image temporaire..."
    #     # Créer Dockerfile temporaire et construire l'image
    #     mkdir -p docker/newman
    #     echo "FROM postman/newman:alpine" > docker/newman/Dockerfile
    #     echo "RUN npm install -g newman-reporter-htmlextra" >> docker/newman/Dockerfile
    #     docker build -t $NEWMAN_IMAGE docker/newman
    #     echo "Image temporaire $NEWMAN_IMAGE construite avec succès!"
    fi
fi

echo "Running Postman tests with Newman..."
echo "Collection: $COLLECTION_FILE"
if [ -f "$ENVIRONMENT_FILE" ]; then
    echo "Environment: $ENVIRONMENT_FILE"
    ENV_PARAM="-e $ENVIRONMENT_FILE"
else
    ENV_PARAM=""
fi

# Afficher quels tests sont ignorés
if [ ! -z "$IGNORE_TESTS" ]; then
    echo "Skipping tests: $IGNORE_TESTS"
fi

# Exécuter Newman avec l'image personnalisée
docker run --rm \
    --network quizapi-network \
    -v "$(pwd):/etc/newman" \
    $NEWMAN_IMAGE \
    run "/etc/newman/$COLLECTION_FILE" \
    $ENV_PARAM \
    $IGNORE_TESTS \
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