#!/bin/bash

# Variables
API_URL=${1:-"http://localhost:3000"}
SCRIPT_PATH=${2:-"tests/load/load-test.js"}
OUTPUT_DIR="tests/load/results"
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
REPORT_NAME="load-test-report-${TIMESTAMP}"

# Créer le répertoire de sortie s'il n'existe pas
mkdir -p "$OUTPUT_DIR"

echo "=== Exécution des tests de charge sur $API_URL ==="
echo "Script: $SCRIPT_PATH"
echo "Résultats dans: $OUTPUT_DIR/${REPORT_NAME}.html"

# Test si l'API est accessible
echo "Vérification de l'accès à l'API..."
if curl -s -f -o /dev/null "$API_URL"; then
    echo "✅ API accessible"
else
    echo "❌ API non accessible à l'URL: $API_URL"
    echo "Veuillez vérifier que votre API est en cours d'exécution."
    exit 1
fi

# Exécution des tests de charge avec k6 dans Docker
echo "Démarrage des tests de charge..."
docker run --rm \
    -v "$(pwd)/$SCRIPT_PATH:/script.js" \
    -v "$(pwd)/$OUTPUT_DIR:/results" \
    -e API_URL="$API_URL" \
    --network="host" \
    loadimpact/k6 run \
    --out json=/results/${REPORT_NAME}.json \
    /script.js

if [ $? -eq 0 ]; then
    echo "✅ Tests de charge terminés avec succès"
    
    # Génération d'un rapport HTML si pas déjà généré par le script k6
    if [ ! -f "$OUTPUT_DIR/${REPORT_NAME}.html" ]; then
        echo "Génération d'un rapport HTML..."
        docker run --rm \
            -v "$(pwd)/$OUTPUT_DIR:/results" \
            --entrypoint sh \
            loadimpact/k6 -c "
            apk add --no-cache nodejs npm &&
            npm install -g k6-html-reporter &&
            k6-html-reporter -s /results/${REPORT_NAME}.json -o /results/${REPORT_NAME}.html
            "
    fi
    
    echo "📊 Rapport disponible: $OUTPUT_DIR/${REPORT_NAME}.html"
    
    # Afficher un résumé des résultats
    echo "=== Résumé des résultats ==="
    docker run --rm \
        -v "$(pwd)/$OUTPUT_DIR:/results" \
        --entrypoint sh \
        loadimpact/k6 -c "
        cat /results/${REPORT_NAME}.json | 
        grep -E '\"http_req_duration\":|\"{\"avg\":|\"med\":|\"p95\":' |
        head -10
        "
    
    echo "=== Fin des tests de charge ==="
else
    echo "❌ Erreur lors de l'exécution des tests de charge"
    exit 1
fi

# Proposer d'ouvrir le rapport
if [ -f "$OUTPUT_DIR/${REPORT_NAME}.html" ]; then
    echo "Voulez-vous ouvrir le rapport dans votre navigateur? (y/n)"
    read -r answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        if command -v xdg-open &> /dev/null; then
            xdg-open "$OUTPUT_DIR/${REPORT_NAME}.html"
        elif command -v open &> /dev/null; then
            open "$OUTPUT_DIR/${REPORT_NAME}.html"
        else
            echo "Impossible d'ouvrir automatiquement le rapport."
            echo "Veuillez l'ouvrir manuellement: $OUTPUT_DIR/${REPORT_NAME}.html"
        fi
    fi
fi