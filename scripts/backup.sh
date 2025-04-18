#!/bin/bash

# Variables
DATE=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_DIR="./backups"
DB_CONTAINER="postgres"
DB_NAME="quizapi_db"
DB_USER="quizapi_user"
FILENAME="$BACKUP_DIR/quizapi_backup_$DATE.sql"

# Créer le répertoire de sauvegarde s'il n'existe pas
mkdir -p $BACKUP_DIR

# Créer la sauvegarde
echo "Création de la sauvegarde de $DB_NAME dans $FILENAME..."
docker exec $DB_CONTAINER pg_dump -U $DB_USER -d $DB_NAME > $FILENAME

# Compression de la sauvegarde
echo "Compression de la sauvegarde..."
gzip $FILENAME

# Résultat
echo "Sauvegarde terminée: ${FILENAME}.gz"

# Nettoyer les anciennes sauvegardes (garder les 5 plus récentes)
echo "Nettoyage des anciennes sauvegardes..."
ls -tp $BACKUP_DIR/*.gz | grep -v '/$' | tail -n +6 | xargs -I {} rm -- {}

echo "Terminé !"