-- V2__core_schema.sql
-- Tables fondamentales pour le Core utilisant des UUIDs comme clés primaires

-- Extension pour les UUIDs (déjà créée dans V1)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

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

-- Table des catégories
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    parent_id UUID,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    created_by UUID,
    updated_by UUID,
    deleted_at TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE SET NULL,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Table des quiz
CREATE TABLE quizzes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    difficulty_level VARCHAR(20) CHECK (difficulty_level IN ('BEGINNER', 'EASY', 'MEDIUM', 'HARD', 'EXPERT')),
    time_limit INTEGER, -- Durée en secondes, NULL = pas de limite
    passing_score NUMERIC(5,2), -- Score minimum pour réussir (pourcentage)
    status VARCHAR(20) NOT NULL DEFAULT 'DRAFT' CHECK (status IN ('DRAFT', 'PUBLISHED', 'ARCHIVED', 'REVIEWING')),
    is_public BOOLEAN DEFAULT FALSE,
    category_id UUID,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    created_by UUID NOT NULL,
    updated_by UUID,
    deleted_at TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE RESTRICT,
    FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Table des tags
CREATE TABLE tags (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) NOT NULL UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by UUID,
    deleted_at TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Table d'association quiz-tags
CREATE TABLE quiz_tags (
    quiz_id UUID NOT NULL,
    tag_id UUID NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (quiz_id, tag_id),
    FOREIGN KEY (quiz_id) REFERENCES quizzes(id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
);

CREATE TABLE plugins (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    version TEXT NOT NULL,
    description TEXT,
    enabled BOOLEAN NOT NULL DEFAULT false,
    config JSONB DEFAULT '{}'::jsonb,
    installed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_enabled_at TIMESTAMPTZ,
    last_disabled_at TIMESTAMPTZ
);

-- Fonction pour mettre à jour les timestamps des enregistrements modifiés
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = CURRENT_TIMESTAMP;
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers pour mettre à jour les timestamps automatiquement
CREATE TRIGGER update_users_timestamp BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_timestamp();
CREATE TRIGGER update_categories_timestamp BEFORE UPDATE ON categories FOR EACH ROW EXECUTE FUNCTION update_timestamp();
CREATE TRIGGER update_quizzes_timestamp BEFORE UPDATE ON quizzes FOR EACH ROW EXECUTE FUNCTION update_timestamp();

-- Indexes pour améliorer les performances
-- Optimisés pour la recherche, le tri et les jointures
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_is_active ON users(is_active) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_last_login ON users(last_login_at) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_name ON users(first_name, last_name) WHERE deleted_at IS NULL;

CREATE INDEX idx_categories_name ON categories(name) WHERE deleted_at IS NULL;
CREATE INDEX idx_categories_parent_id ON categories(parent_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_categories_created_by ON categories(created_by) WHERE deleted_at IS NULL;

CREATE INDEX idx_quizzes_title ON quizzes(title) WHERE deleted_at IS NULL;
CREATE INDEX idx_quizzes_status ON quizzes(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_quizzes_difficulty ON quizzes(difficulty_level) WHERE deleted_at IS NULL;
CREATE INDEX idx_quizzes_category ON quizzes(category_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_quizzes_created_by ON quizzes(created_by) WHERE deleted_at IS NULL;
CREATE INDEX idx_quizzes_public ON quizzes(is_public) WHERE status = 'PUBLISHED' AND deleted_at IS NULL;
CREATE INDEX idx_quizzes_created_at ON quizzes(created_at) WHERE deleted_at IS NULL;

CREATE INDEX idx_tags_name ON tags(name) WHERE deleted_at IS NULL;
CREATE INDEX idx_tags_created_by ON tags(created_by) WHERE deleted_at IS NULL;

-- Index pour la table de jointure
CREATE INDEX idx_quiz_tags_quiz_id ON quiz_tags(quiz_id);
CREATE INDEX idx_quiz_tags_tag_id ON quiz_tags(tag_id);

-- Insertion de données initiales (utilisateur administrateur par défaut)
INSERT INTO users (id, username, email, password_hash, first_name, last_name, is_active)
VALUES (
    uuid_generate_v4(), 
    'admin', 
    'admin@quizapi.fr', 
    '$2a$10$vzOG/7w0vRSzI4QZuAj1OeNL1Y8C3LPGlI/UBUwQQeX1LhqOH0z2W', 
    'Admin', 
    'System', 
    true
);