-- -----------------------------------------------------
-- TABLE APP: quizzes et relations
-- Définition des quiz et leurs relations avec catégories et tags
-- -----------------------------------------------------

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

-- Table d'association quiz-tags
CREATE TABLE quiz_tags (
    quiz_id UUID NOT NULL,
    tag_id UUID NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (quiz_id, tag_id),
    FOREIGN KEY (quiz_id) REFERENCES quizzes(id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
);

-- Table des dépendances entre quiz
CREATE TABLE quiz_dependencies (
    id SERIAL PRIMARY KEY,
    quiz_id UUID NOT NULL,
    prerequisite_quiz_id UUID NOT NULL,
    required_score NUMERIC(5,2), -- NULL = juste participation, sinon score minimum requis
    conditions JSONB, -- Conditions additionnelles de réussite en format flexible
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by UUID,
    FOREIGN KEY (quiz_id) REFERENCES quizzes(id) ON DELETE CASCADE,
    FOREIGN KEY (prerequisite_quiz_id) REFERENCES quizzes(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
    CHECK (quiz_id != prerequisite_quiz_id) -- Empêcher l'auto-référence
);

-- Table détaillée des conditions de dépendance
CREATE TABLE quiz_dependency_conditions (
    id SERIAL PRIMARY KEY,
    quiz_dependency_id INTEGER NOT NULL,
    condition_type VARCHAR(50) NOT NULL, -- ex: 'MIN_SCORE', 'COMPLETION_TIME'
    condition_value VARCHAR(255) NOT NULL,
    FOREIGN KEY (quiz_dependency_id) REFERENCES quiz_dependencies(id) ON DELETE CASCADE
);