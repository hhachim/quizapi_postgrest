-- -----------------------------------------------------
-- TABLE APP: badges et statistiques
-- Système de badges et statistiques utilisateur
-- -----------------------------------------------------

-- Table des badges
CREATE TABLE badges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    image_url VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by UUID,
    deleted_at TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Table d'attribution des badges aux utilisateurs
CREATE TABLE user_badges (
    user_id UUID NOT NULL,
    badge_id UUID NOT NULL,
    awarded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    awarded_by UUID,
    PRIMARY KEY (user_id, badge_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (badge_id) REFERENCES badges(id) ON DELETE CASCADE,
    FOREIGN KEY (awarded_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Table de statistiques utilisateur (agrégées)
CREATE TABLE user_statistics (
    user_id UUID PRIMARY KEY,
    total_attempts INTEGER DEFAULT 0,
    completed_attempts INTEGER DEFAULT 0,
    passed_attempts INTEGER DEFAULT 0,
    total_score NUMERIC(10,2) DEFAULT 0,
    average_score NUMERIC(5,2) DEFAULT 0,
    total_time INTEGER DEFAULT 0, -- Temps total en secondes
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);