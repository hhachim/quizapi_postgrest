#!/bin/bash

# Variables
INPUT_FILE=${1:-"CurlTests.md"}
OUTPUT_DIR="tests/postman"
COLLECTION_NAME="quiz-api-collection"
TIMESTAMP=$(date +%Y%m%d%H%M%S)
OUTPUT_FILE="$OUTPUT_DIR/${COLLECTION_NAME}_${TIMESTAMP}.json"

# Vérifier si le fichier d'entrée existe
if [ ! -f "$INPUT_FILE" ]; then
    echo "Fichier d'entrée non trouvé: $INPUT_FILE"
    exit 1
fi

# Créer le répertoire de sortie s'il n'existe pas
mkdir -p "$OUTPUT_DIR"

echo "Conversion des commandes cURL en collection Postman..."

# Utiliser Docker pour convertir les commandes cURL en collection Postman
docker run --rm -v "$(pwd)/$INPUT_FILE:/input.md" -v "$(pwd)/$OUTPUT_DIR:/output" \
    postman/newman:alpine sh -c '
    # Installer le convertisseur curl-to-postman
    apk add --no-cache nodejs npm
    npm install -g postman-collection-transformer

    # Extraire les commandes cURL du fichier Markdown
    grep -A 1 "```bash" /input.md | grep -v "```bash" | grep "curl" > /tmp/curl_commands.txt

    # Initialiser la collection Postman
    echo "{
      \"info\": {
        \"_postman_id\": \"$(cat /dev/urandom | tr -dc \"a-z0-9\" | fold -w 24 | head -n 1)\",
        \"name\": \"Generated from cURL\",
        \"schema\": \"https://schema.getpostman.com/json/collection/v2.1.0/collection.json\"
      },
      \"item\": []
    }" > /tmp/collection.json

    # Pour chaque commande cURL
    while IFS= read -r cmd; do
        # Extraire le nom de la requête en utilisant un commentaire ou l URL
        name=$(echo "$cmd" | grep -o "# [^\"]*" | sed "s/# //")
        if [ -z "$name" ]; then
            name=$(echo "$cmd" | grep -o -E "\"http[s]?://[^\"]*\"" | sed "s/\"//g" | xargs basename)
        fi
        if [ -z "$name" ]; then
            name="Requête $(date +%s)"
        fi

        # Convertir la commande cURL en format Postman
        request="{
          \"name\": \"$name\",
          \"request\": {
            \"method\": \"$(echo "$cmd" | grep -o -E "\\-X [A-Z]+" | sed "s/-X //g" || echo "GET")\",
            \"header\": [
              $(echo "$cmd" | grep -o -E "\\-H \"[^\"]*\"" | sed "s/-H \"//g" | sed "s/\"//g" | while read header; do
                key=$(echo "$header" | cut -d: -f1)
                value=$(echo "$header" | cut -d: -f2- | sed "s/^ //")
                echo "{\"key\": \"$key\", \"value\": \"$value\"},"
              done | sed \"s/,$//\")
            ],
            \"url\": {
              \"raw\": \"$(echo "$cmd" | grep -o -E "\"http[s]?://[^\"]*\"" | sed "s/\"//g")\",
              \"host\": [\"{{apiUrl}}\"],
              \"path\": [\"$(echo "$cmd" | grep -o -E "\"http[s]?://[^\"]*\"" | sed "s/\"//g" | sed "s/http[s]\\?:\\/\\/[^\\/]*\\///g")\"]
            }
          }
        }"

        # Ajouter la requête à la collection
        temp=$(mktemp)
        jq ".item += [$request]" /tmp/collection.json > "$temp"
        mv "$temp" /tmp/collection.json
    done < /tmp/curl_commands.txt

    # Sauvegarder la collection
    jq "." /tmp/collection.json > /output/$(basename '"$COLLECTION_NAME"'_'"$TIMESTAMP"').json
    echo "Collection générée: /output/$(basename '"$COLLECTION_NAME"'_'"$TIMESTAMP"').json"
    '

echo "Conversion terminée. Collection Postman générée: $OUTPUT_FILE"
echo "Note: Cette collection est basique et peut nécessiter des ajustements manuels pour les tests."