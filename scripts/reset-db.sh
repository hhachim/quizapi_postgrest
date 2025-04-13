#!/bin/bash

# Variables
DB_CONTAINER="postgres"
DB_NAME="quizapi_db"
DB_USER="quizapi_user"

# Avertissement
echo "ATTENTION: Cette action va réinitialiser complètement la base de données $DB_NAME."
echo "Toutes les données seront perdues. Cette action est irréversible."
read -p "Êtes-vous sûr de vouloir continuer? (y/n): " confirmation

if [ "$confirmation" != "y" ]; then
    echo "Opération annulée."
    exit 1
fi

# Créer une sauvegarde avant la réinitialisation
echo "Création d'une sauvegarde avant réinitialisation..."
./scripts/backup.sh

# Arrêter les conteneurs
echo "Arrêt des conteneurs..."
docker-compose down

# Supprimer les volumes
echo "Suppression des données persistantes..."
rm -rf ./db_data

# Redémarrer les conteneurs
echo "Redémarrage des conteneurs..."
docker-compose up -d

# Attendre que la base de données soit prête
echo "Attente du démarrage complet de PostgreSQL..."
sleep 10

echo "Base de données réinitialisée avec succès !"
echo "Les conteneurs ont été redémarrés avec une base de données fraîche."