#!/bin/bash

# Variables
API_URL=${1:-"http://localhost:3000"}
ENV_FILE="tests/postman/environment.json"
TEMP_ENV_FILE="tests/postman/environment.tmp.json"

echo "Initializing test data for Postman tests..."

# Obtenir l'ID du premier quiz public
FIRST_QUIZ_ID=$(curl -s "$API_URL/quizzes?status=eq.PUBLISHED&is_public=eq.true&select=id" | jq -r '.[0].id // empty')

if [ -n "$FIRST_QUIZ_ID" ]; then
    echo "Found first quiz ID: $FIRST_QUIZ_ID"
else
    echo "Warning: No published public quiz found."
fi

# Obtenir l'ID de l'utilisateur admin
ADMIN_ID=$(curl -s "$API_URL/users?username=eq.admin&select=id" | jq -r '.[0].id // empty')

if [ -n "$ADMIN_ID" ]; then
    echo "Found admin user ID: $ADMIN_ID"
else
    echo "Warning: Admin user not found."
fi

# Mise à jour du fichier d'environnement Postman
if [ -f "$ENV_FILE" ]; then
    echo "Updating environment file: $ENV_FILE"
    
    # Utiliser jq pour mettre à jour les valeurs
    jq --arg quizId "$FIRST_QUIZ_ID" --arg adminId "$ADMIN_ID" '
        .values |= map(
            if .key == "firstQuizId" then .value = $quizId else . end
        ) |
        .values |= map(
            if .key == "adminUserId" then .value = $adminId else . end
        )
    ' "$ENV_FILE" > "$TEMP_ENV_FILE"
    
    # Remplacer le fichier d'environnement original
    mv "$TEMP_ENV_FILE" "$ENV_FILE"
    
    echo "Environment file updated successfully!"
else
    echo "Error: Environment file not found: $ENV_FILE"
    exit 1
fi

echo "Test data initialization complete!"