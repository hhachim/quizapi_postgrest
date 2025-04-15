-- -----------------------------------------------------
-- TABLE APP: tentatives et réponses
-- Système de gestion des tentatives de quiz et des réponses utilisateur
-- -----------------------------------------------------

-- Table des tentatives de quiz
CREATE TABLE quiz_attempts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    quiz_id UUID NOT NULL,
    start_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP,
    total_time INTEGER, -- Temps total en secondes (calculé)
    score NUMERIC(5,2), -- Score final
    is_completed BOOLEAN DEFAULT FALSE,
    is_passed BOOLEAN, -- NULL = non évalué, TRUE/FALSE = résultat
    status VARCHAR(20) DEFAULT 'IN_PROGRESS' CHECK (status IN ('IN_PROGRESS', 'COMPLETED', 'FAILED')), -- Ajout du statut explicite
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (quiz_id) REFERENCES quizzes(id) ON DELETE CASCADE
);

-- Table des réponses des utilisateurs
CREATE TABLE attempt_responses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    attempt_id UUID NOT NULL,
    question_id UUID NOT NULL,
    start_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP,
    response_time INTEGER, -- Temps de réponse en secondes (calculé)
    text_response TEXT, -- Pour les réponses textuelles simples
    response_data JSONB, -- Pour stocker des réponses complexes (ordonnancement, association, etc.)
    is_correct BOOLEAN, -- NULL = non évalué, TRUE/FALSE = résultat
    points_earned NUMERIC(5,2), -- Points gagnés
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (attempt_id) REFERENCES quiz_attempts(id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE,
    CONSTRAINT unique_attempt_question UNIQUE (attempt_id, question_id)
);

-- Table des choix sélectionnés pour les QCM et autres types similaires
CREATE TABLE attempt_response_choices (
    response_id UUID NOT NULL,
    choice_id UUID NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (response_id, choice_id),
    FOREIGN KEY (response_id) REFERENCES attempt_responses(id) ON DELETE CASCADE,
    FOREIGN KEY (choice_id) REFERENCES answer_choices(id) ON DELETE CASCADE
);

-- Table des réponses d'ordonnancement
CREATE TABLE ordering_responses (
    id SERIAL PRIMARY KEY,
    attempt_response_id UUID NOT NULL,
    item_id UUID NOT NULL,
    position INTEGER NOT NULL,
    FOREIGN KEY (attempt_response_id) REFERENCES attempt_responses(id) ON DELETE CASCADE
);

-- Table des réponses d'association
CREATE TABLE matching_responses (
    id SERIAL PRIMARY KEY,
    attempt_response_id UUID NOT NULL,
    source_id UUID NOT NULL,
    target_id UUID NOT NULL,
    FOREIGN KEY (attempt_response_id) REFERENCES attempt_responses(id) ON DELETE CASCADE
);