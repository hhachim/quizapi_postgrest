#!/bin/bash

# Script pour créer la structure de répertoires SQL core/app
# et organiser les fichiers SQL existants

# Définir les couleurs pour les messages
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Répertoire de base pour les fichiers SQL
BASE_DIR="docker/postgres/init-db"

# Vérifier si le répertoire de base existe
if [ ! -d "$BASE_DIR" ]; then
    echo -e "${RED}Erreur: Le répertoire $BASE_DIR n'existe pas.${NC}"
    echo -e "${YELLOW}Création du répertoire...${NC}"
    mkdir -p "$BASE_DIR"
fi

echo -e "${BLUE}=== Création de la structure core/app pour les fichiers SQL ===${NC}"

# Créer l'arborescence de répertoires
echo -e "${YELLOW}Création des répertoires...${NC}"

# Répertoires principaux
mkdir -p "$BASE_DIR/01-core/01-schema"
mkdir -p "$BASE_DIR/01-core/02-functions"
mkdir -p "$BASE_DIR/01-core/03-permissions"
mkdir -p "$BASE_DIR/02-app/01-schema"
mkdir -p "$BASE_DIR/02-app/02-functions"
mkdir -p "$BASE_DIR/02-app/04-permissions"
mkdir -p "$BASE_DIR/04-data/01-core"
mkdir -p "$BASE_DIR/04-data/02-app"

# Créer les fichiers SQL de base
echo -e "${YELLOW}Création des fichiers SQL...${NC}"

# 00-extensions.sql
cat > "$BASE_DIR/00-extensions.sql" << 'EOF'
-- Extensions nécessaires pour le système
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS pgjwt;
EOF
echo -e "${GREEN}Créé: 00-extensions.sql${NC}"

# 01-core/01-schema/01-users.sql
cat > "$BASE_DIR/01-core/01-schema/01-users.sql" << 'EOF'
-- -----------------------------------------------------
-- TABLE CORE: users
-- Table fondamentale des utilisateurs - peut être référencée par les tables de l'application
-- -----------------------------------------------------

-- Table des utilisateurs
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    last_login_at TIMESTAMP,
    deleted_at TIMESTAMP,
    CONSTRAINT users_email_check CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);
EOF
echo -e "${GREEN}Créé: 01-core/01-schema/01-users.sql${NC}"

# Créer les fichiers vides (placeholder) pour les autres fichiers
touch "$BASE_DIR/01-core/01-schema/02-roles.sql"
touch "$BASE_DIR/01-core/02-functions/01-utility.sql"
touch "$BASE_DIR/01-core/02-functions/02-auth.sql"
touch "$BASE_DIR/01-core/03-permissions/01-roles_def.sql"
touch "$BASE_DIR/01-core/03-permissions/02-core_rls.sql"
touch "$BASE_DIR/02-app/01-schema/01-categories.sql"
touch "$BASE_DIR/02-app/01-schema/02-quizzes.sql"
touch "$BASE_DIR/02-app/01-schema/03-questions.sql"
touch "$BASE_DIR/02-app/01-schema/04-attempts.sql"
touch "$BASE_DIR/02-app/01-schema/05-badges.sql"
touch "$BASE_DIR/02-app/02-functions/01-quiz_management.sql"
touch "$BASE_DIR/02-app/02-functions/02-scoring.sql"
touch "$BASE_DIR/02-app/03-triggers.sql"
touch "$BASE_DIR/02-app/04-permissions/01-app_rls.sql"
touch "$BASE_DIR/03-indexes.sql"
touch "$BASE_DIR/04-data/01-core/01-default-users.sql"
touch "$BASE_DIR/04-data/02-app/01-categories.sql"
touch "$BASE_DIR/04-data/02-app/02-sample-quizzes.sql"
touch "$BASE_DIR/05-views.sql"

echo -e "${GREEN}Structure de répertoires et fichiers créée avec succès!${NC}"
echo -e "${BLUE}=== Vous pouvez maintenant copier le contenu des fichiers SQL dans les fichiers appropriés ===${NC}"

# Fonction pour créer un fichier s'il n'existe pas
create_file_if_not_exists() {
    local file_path="$1"
    local file_content="$2"
    
    if [ ! -f "$file_path" ]; then
        echo "$file_content" > "$file_path"
        echo -e "${GREEN}Créé: $file_path${NC}"
    else
        echo -e "${YELLOW}Le fichier existe déjà: $file_path${NC}"
    fi
}

echo -e "${BLUE}=== Structure complète des répertoires ===${NC}"
find "$BASE_DIR" -type d | sort

echo -e "${BLUE}=== Liste des fichiers SQL créés ===${NC}"
find "$BASE_DIR" -name "*.sql" | sort