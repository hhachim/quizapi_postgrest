-- -----------------------------------------------------
-- TABLE APP: questions et choix de réponses
-- Système de gestion des questions et des options de réponse
-- -----------------------------------------------------

-- Table des types de questions
CREATE TABLE question_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Insertion des types de questions de base
INSERT INTO question_types (name, description) VALUES
('MULTIPLE_CHOICE', 'Question à choix multiple avec une ou plusieurs réponses correctes'),
('TRUE_FALSE', 'Question vrai ou faux'),
('SHORT_ANSWER', 'Question à réponse courte'),
('LONG_ANSWER', 'Question à réponse longue/rédaction'),
('MATCHING', 'Question d''association entre éléments'),
('ORDERING', 'Question d''ordonnancement d''éléments'),
('FILL_BLANKS', 'Texte à trous');

-- Table des questions
CREATE TABLE questions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    content TEXT NOT NULL,
    explanation TEXT, -- Explication de la réponse correcte
    question_type_id INTEGER NOT NULL,
    default_time_limit INTEGER, -- Temps par défaut en secondes, NULL = pas de limite
    default_points NUMERIC(5,2) DEFAULT 1.0, -- Points par défaut
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    created_by UUID NOT NULL,
    updated_by UUID,
    deleted_at TIMESTAMP,
    additional_settings JSONB, -- Paramètres spécifiques au type de question (pour plus de flexibilité)
    FOREIGN KEY (question_type_id) REFERENCES question_types(id) ON DELETE RESTRICT,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE RESTRICT,
    FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Table d'association quiz-questions
CREATE TABLE quiz_questions (
    quiz_id UUID NOT NULL,
    question_id UUID NOT NULL,
    order_num INTEGER NOT NULL, -- Ordre de la question dans le quiz
    is_required BOOLEAN DEFAULT TRUE,
    time_limit INTEGER, -- Temps spécifique pour cette question dans ce quiz, NULL = utiliser la valeur par défaut
    points NUMERIC(5,2), -- Points spécifiques pour cette question dans ce quiz, NULL = utiliser la valeur par défaut
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    PRIMARY KEY (quiz_id, question_id),
    FOREIGN KEY (quiz_id) REFERENCES quizzes(id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE
);

-- Table des choix pour les questions à choix multiples et d'association
CREATE TABLE answer_choices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    question_id UUID NOT NULL,
    content TEXT NOT NULL,
    match_content TEXT, -- Pour les questions d'association, le contenu correspondant
    is_correct BOOLEAN DEFAULT FALSE, -- Pour les QCM et vrai/faux
    order_num INTEGER, -- Pour l'ordre dans les questions d'ordonnancement
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE
);

-- Table des paramètres de questions
CREATE TABLE question_parameters (
    id SERIAL PRIMARY KEY,
    question_id UUID NOT NULL,
    parameter_name VARCHAR(50) NOT NULL,
    parameter_value TEXT NOT NULL,
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE,
    UNIQUE (question_id, parameter_name)
);