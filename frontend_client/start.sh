#!/bin/bash
cd "$(dirname "$0")"

# Vérifier si le réseau Docker pour l'API existe
if ! docker network ls | grep -q quizapi-network; then
    echo "Création du réseau Docker quizapi-network..."
    docker network create quizapi-network
fi

# Vérifier si le réseau Docker pour Traefik existe
if ! docker network ls | grep -q TraefikNetwork_wildcard.pocs.hachim.fr; then
    echo "Création du réseau Docker pour Traefik..."
    docker network create TraefikNetwork_wildcard.pocs.hachim.fr
fi

# Démarrer les conteneurs
#docker compose build --no-cache frontend
docker compose up

echo "Le frontend est disponible sur:"
echo "- http://localhost:3001 (accès direct)"
echo "- https://frontend.pocs.hachim.fr (via Traefik)"