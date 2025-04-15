-- -----------------------------------------------------
-- PERMISSIONS APP: Row Level Security pour les tables applicatives
-- Politiques de sécurité au niveau des lignes pour les tables de l'application
-- -----------------------------------------------------

-- Activer Row Level Security sur toutes les tables de l'application
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE quizzes ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_dependencies ENABLE ROW LEVEL SECURITY;
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE answer_choices ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE attempt_responses ENABLE ROW LEVEL SECURITY;
ALTER TABLE badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_statistics ENABLE ROW LEVEL SECURITY;
ALTER TABLE plugins ENABLE ROW LEVEL SECURITY;

-- Droits pour le rôle anonyme (lecture seule pour les éléments publics)
GRANT SELECT ON 
    categories, 
    quizzes,
    tags,
    quiz_tags,
    plugins
TO anon;

-- Politique pour les catégories
CREATE POLICY categories_read_policy ON categories 
    FOR SELECT 
    TO anon, authenticated 
    USING (deleted_at IS NULL);

CREATE POLICY categories_write_policy ON categories 
    FOR ALL 
    TO authenticated 
    USING (
        created_by = current_setting('request.jwt.claim.user_id', true)::UUID OR
        current_setting('request.jwt.claim.role', true) = 'admin'
    );

CREATE POLICY categories_admin_policy ON categories 
    FOR ALL 
    TO admin 
    USING (true);

-- Politique pour les quiz
CREATE POLICY quizzes_anon_policy ON quizzes 
    FOR SELECT 
    TO anon 
    USING (status = 'PUBLISHED' AND is_public = TRUE AND deleted_at IS NULL);

CREATE POLICY quizzes_authenticated_policy ON quizzes 
    FOR ALL 
    TO authenticated 
    USING (
        (status = 'PUBLISHED' AND is_public = TRUE) OR 
        (created_by = current_setting('request.jwt.claim.user_id', true)::UUID)
    );

CREATE POLICY quizzes_admin_policy ON quizzes 
    FOR ALL 
    TO admin 
    USING (true);

-- Politiques pour les tags
CREATE POLICY tags_read_policy ON tags 
    FOR SELECT 
    TO anon, authenticated 
    USING (deleted_at IS NULL);

CREATE POLICY tags_insert_policy ON tags 
    FOR INSERT 
    TO authenticated 
    WITH CHECK (
        created_by = current_setting('request.jwt.claim.user_id', true)::UUID OR
        current_setting('request.jwt.claim.role', true) = 'admin'
    );

CREATE POLICY tags_update_policy ON tags 
    FOR UPDATE 
    TO authenticated 
    USING (
        created_by = current_setting('request.jwt.claim.user_id', true)::UUID OR
        current_setting('request.jwt.claim.role', true) = 'admin'
    );

CREATE POLICY tags_delete_policy ON tags 
    FOR DELETE 
    TO authenticated 
    USING (
        created_by = current_setting('request.jwt.claim.user_id', true)::UUID OR
        current_setting('request.jwt.claim.role', true) = 'admin'
    );

CREATE POLICY tags_admin_policy ON tags 
    FOR ALL 
    TO admin 
    USING (true);

-- Politiques pour les associations quiz-tags
CREATE POLICY quiz_tags_read_policy ON quiz_tags 
    FOR SELECT 
    TO anon, authenticated 
    USING (true);

CREATE POLICY quiz_tags_insert_policy ON quiz_tags 
    FOR INSERT 
    TO authenticated 
    WITH CHECK (
        quiz_id IN (
            SELECT id FROM quizzes 
            WHERE created_by = current_setting('request.jwt.claim.user_id', true)::UUID
        ) OR
        current_setting('request.jwt.claim.role', true) = 'admin'
    );

CREATE POLICY quiz_tags_update_policy ON quiz_tags 
    FOR UPDATE 
    TO authenticated 
    USING (
        quiz_id IN (
            SELECT id FROM quizzes 
            WHERE created_by = current_setting('request.jwt.claim.user_id', true)::UUID
        ) OR
        current_setting('request.jwt.claim.role', true) = 'admin'
    );

CREATE POLICY quiz_tags_delete_policy ON quiz_tags 
    FOR DELETE 
    TO authenticated 
    USING (
        quiz_id IN (
            SELECT id FROM quizzes 
            WHERE created_by = current_setting('request.jwt.claim.user_id', true)::UUID
        ) OR
        current_setting('request.jwt.claim.role', true) = 'admin'
    );

-- Politiques pour les questions
CREATE POLICY questions_read_policy ON questions 
    FOR SELECT 
    TO authenticated 
    USING (
        deleted_at IS NULL OR 
        created_by = current_setting('request.jwt.claim.user_id', true)::UUID
    );

CREATE POLICY questions_write_policy ON questions 
    FOR ALL 
    TO authenticated 
    USING (
        created_by = current_setting('request.jwt.claim.user_id', true)::UUID OR
        current_setting('request.jwt.claim.role', true) = 'admin'
    );

-- Politiques pour les tentatives de quiz
CREATE POLICY quiz_attempts_read_self_policy ON quiz_attempts 
    FOR SELECT 
    TO authenticated 
    USING (user_id = current_setting('request.jwt.claim.user_id', true)::UUID);

CREATE POLICY quiz_attempts_read_creator_policy ON quiz_attempts 
    FOR SELECT 
    TO authenticated 
    USING (
        quiz_id IN (
            SELECT id FROM quizzes 
            WHERE created_by = current_setting('request.jwt.claim.user_id', true)::UUID
        )
    );

CREATE POLICY quiz_attempts_insert_policy ON quiz_attempts 
    FOR INSERT 
    TO authenticated 
    WITH CHECK (user_id = current_setting('request.jwt.claim.user_id', true)::UUID);

CREATE POLICY quiz_attempts_update_self_policy ON quiz_attempts 
    FOR UPDATE 
    TO authenticated 
    USING (user_id = current_setting('request.jwt.claim.user_id', true)::UUID);

-- Politiques pour les réponses des tentatives
CREATE POLICY attempt_responses_read_self_policy ON attempt_responses 
    FOR SELECT 
    TO authenticated 
    USING (
        attempt_id IN (
            SELECT id FROM quiz_attempts 
            WHERE user_id = current_setting('request.jwt.claim.user_id', true)::UUID
        )
    );

CREATE POLICY attempt_responses_read_creator_policy ON attempt_responses 
    FOR SELECT 
    TO authenticated 
    USING (
        attempt_id IN (
            SELECT qa.id FROM quiz_attempts qa
            JOIN quizzes q ON qa.quiz_id = q.id
            WHERE q.created_by = current_setting('request.jwt.claim.user_id', true)::UUID
        )
    );

CREATE POLICY attempt_responses_write_policy ON attempt_responses 
    FOR ALL 
    TO authenticated 
    USING (
        attempt_id IN (
            SELECT id FROM quiz_attempts 
            WHERE user_id = current_setting('request.jwt.claim.user_id', true)::UUID
        )
    );

-- Politiques pour les badges
CREATE POLICY badges_read_policy ON badges 
    FOR SELECT 
    TO anon, authenticated 
    USING (deleted_at IS NULL);

CREATE POLICY badges_write_policy ON badges 
    FOR ALL 
    TO admin 
    USING (true);

-- Politiques pour les statistiques utilisateur
CREATE POLICY user_statistics_read_self_policy ON user_statistics 
    FOR SELECT 
    TO authenticated 
    USING (user_id = current_setting('request.jwt.claim.user_id', true)::UUID);

CREATE POLICY user_statistics_read_admin_policy ON user_statistics 
    FOR ALL 
    TO admin 
    USING (true);

-- Politiques pour les plugins
CREATE POLICY plugins_read_policy ON plugins 
    FOR SELECT 
    TO anon, authenticated 
    USING (true);

CREATE POLICY plugins_write_policy ON plugins 
    FOR ALL 
    TO admin 
    USING (true);

-- Droits pour les utilisateurs authentifiés
GRANT SELECT ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT INSERT, UPDATE, DELETE ON 
    quiz_tags,
    tags,
    categories,
    quizzes,
    questions,
    answer_choices,
    quiz_questions,
    quiz_attempts,
    attempt_responses,
    attempt_response_choices,
    ordering_responses,
    matching_responses
TO authenticated;

-- Droits pour les administrateurs (accès complet)
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO admin;

-- S'assurer que les permissions s'appliquent aussi aux futures tables
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON SEQUENCES TO admin;