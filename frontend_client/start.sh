#!/bin/bash
cd "$(dirname "$0")"

# Vérifier si le réseau Docker existe
if ! docker network ls | grep -q quizapi-network; then
    echo "Création du réseau Docker quizapi-network..."
    docker network create quizapi-network
fi

# Démarrer les conteneurs
docker-compose up -d

echo "Le frontend est disponible sur http://localhost:3001"
