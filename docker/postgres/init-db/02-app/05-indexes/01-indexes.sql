-- -----------------------------------------------------
-- INDEXES: Optimisation des performances
-- Index pour améliorer les performances des requêtes fréquentes
-- -----------------------------------------------------

-- Indexes pour les tables catégories et tags
CREATE INDEX idx_categories_name ON categories(name) WHERE deleted_at IS NULL;
CREATE INDEX idx_categories_parent_id ON categories(parent_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_categories_created_by ON categories(created_by) WHERE deleted_at IS NULL;
CREATE INDEX idx_tags_name ON tags(name) WHERE deleted_at IS NULL;
CREATE INDEX idx_tags_created_by ON tags(created_by) WHERE deleted_at IS NULL;

-- Indexes pour la table quizzes
CREATE INDEX idx_quizzes_title ON quizzes(title) WHERE deleted_at IS NULL;
CREATE INDEX idx_quizzes_status ON quizzes(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_quizzes_difficulty ON quizzes(difficulty_level) WHERE deleted_at IS NULL;
CREATE INDEX idx_quizzes_category ON quizzes(category_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_quizzes_created_by ON quizzes(created_by) WHERE deleted_at IS NULL;
CREATE INDEX idx_quizzes_public ON quizzes(is_public) WHERE status = 'PUBLISHED' AND deleted_at IS NULL;
CREATE INDEX idx_quizzes_created_at ON quizzes(created_at) WHERE deleted_at IS NULL;

-- Indexes pour les tables de jointure
CREATE INDEX idx_quiz_tags_quiz_id ON quiz_tags(quiz_id);
CREATE INDEX idx_quiz_tags_tag_id ON quiz_tags(tag_id);
CREATE INDEX idx_quiz_questions_order ON quiz_questions(quiz_id, order_num);
CREATE INDEX idx_quiz_questions_question ON quiz_questions(question_id);

-- Indexes pour les questions et réponses
CREATE INDEX idx_questions_type ON questions(question_type_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_questions_created_by ON questions(created_by) WHERE deleted_at IS NULL;
CREATE INDEX idx_answer_choices_question ON answer_choices(question_id);
CREATE INDEX idx_answer_choices_correct ON answer_choices(is_correct);

-- Indexes pour les tentatives
CREATE INDEX idx_quiz_attempts_user ON quiz_attempts(user_id);
CREATE INDEX idx_quiz_attempts_quiz ON quiz_attempts(quiz_id);
CREATE INDEX idx_quiz_attempts_completed ON quiz_attempts(is_completed);
CREATE INDEX idx_quiz_attempts_status ON quiz_attempts(status);
CREATE INDEX idx_quiz_attempts_date ON quiz_attempts(start_time);

-- Indexes pour les réponses
CREATE INDEX idx_attempt_responses_attempt ON attempt_responses(attempt_id);
CREATE INDEX idx_attempt_responses_question ON attempt_responses(question_id);
CREATE INDEX idx_attempt_responses_correct ON attempt_responses(is_correct);
CREATE INDEX idx_attempt_response_choices_response ON attempt_response_choices(response_id);
CREATE INDEX idx_attempt_response_choices_choice ON attempt_response_choices(choice_id);

-- Indexes pour les badges et statistiques
CREATE INDEX idx_badges_name ON badges(name) WHERE deleted_at IS NULL;
CREATE INDEX idx_user_badges_user ON user_badges(user_id);
CREATE INDEX idx_user_badges_badge ON user_badges(badge_id);
CREATE INDEX idx_user_badges_date ON user_badges(awarded_at);

-- Indexes pour les plugins
CREATE INDEX idx_plugins_enabled ON plugins(enabled);
CREATE INDEX idx_plugins_version ON plugins(version);