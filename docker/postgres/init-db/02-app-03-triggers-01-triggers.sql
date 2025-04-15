-- -----------------------------------------------------
-- TRIGGERS APP: Automatisations
-- Triggers pour automatiser certains processus dans l'application
-- -----------------------------------------------------

-- Trigger pour mettre à jour les timestamps des utilisateurs
CREATE TRIGGER update_users_timestamp BEFORE UPDATE ON users 
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();

-- Trigger pour mettre à jour les timestamps des catégories
CREATE TRIGGER update_categories_timestamp BEFORE UPDATE ON categories 
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();

-- Trigger pour mettre à jour les timestamps des quiz
CREATE TRIGGER update_quizzes_timestamp BEFORE UPDATE ON quizzes 
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();

-- Trigger pour mettre à jour les timestamps des questions
CREATE TRIGGER update_questions_timestamp BEFORE UPDATE ON questions 
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();

-- Trigger pour mettre à jour les timestamps des associations quiz-questions
CREATE TRIGGER update_quiz_questions_timestamp BEFORE UPDATE ON quiz_questions 
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();

-- Trigger pour mettre à jour les timestamps des choix de réponses
CREATE TRIGGER update_answer_choices_timestamp BEFORE UPDATE ON answer_choices 
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();

-- Trigger pour mettre à jour les timestamps des tentatives de quiz
CREATE TRIGGER update_quiz_attempts_timestamp BEFORE UPDATE ON quiz_attempts 
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();

-- Trigger pour mettre à jour les timestamps des réponses
CREATE TRIGGER update_attempt_responses_timestamp BEFORE UPDATE ON attempt_responses 
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();

-- Trigger pour mettre à jour les timestamps des statistiques utilisateur
CREATE TRIGGER update_user_statistics_timestamp BEFORE UPDATE ON user_statistics 
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();

-- Trigger pour calculer le temps de réponse automatiquement
CREATE OR REPLACE FUNCTION calculate_response_time()
RETURNS TRIGGER AS $$
BEGIN
    NEW.response_time := EXTRACT(EPOCH FROM (NEW.end_time - NEW.start_time))::INTEGER;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER calculate_attempt_response_time 
    BEFORE UPDATE OF end_time ON attempt_responses
    FOR EACH ROW
    WHEN (NEW.end_time IS NOT NULL AND OLD.end_time IS NULL)
    EXECUTE FUNCTION calculate_response_time();

-- Trigger pour journaliser les modifications importantes
CREATE OR REPLACE FUNCTION log_important_changes()
RETURNS TRIGGER AS $$
DECLARE
    entity_type TEXT;
    entity_id TEXT;
    action_type TEXT;
    details JSONB;
BEGIN
    IF TG_TABLE_NAME = 'quizzes' THEN
        entity_type := 'quiz';
        entity_id := NEW.id::TEXT;
        
        IF TG_OP = 'INSERT' THEN
            action_type := 'create';
            details := jsonb_build_object(
                'title', NEW.title,
                'status', NEW.status,
                'is_public', NEW.is_public
            );
        ELSIF TG_OP = 'UPDATE' THEN
            action_type := 'update';
            IF OLD.status != NEW.status THEN
                details := jsonb_build_object(
                    'status_change', jsonb_build_object('from', OLD.status, 'to', NEW.status)
                );
            ELSIF OLD.is_public != NEW.is_public THEN
                details := jsonb_build_object(
                    'visibility_change', jsonb_build_object('from', OLD.is_public, 'to', NEW.is_public)
                );
            END IF;
        ELSIF TG_OP = 'DELETE' THEN
            action_type := 'delete';
            details := jsonb_build_object('title', OLD.title);
        END IF;
    END IF;
    
    -- N'insérer que si des détails existent
    IF details IS NOT NULL THEN
        INSERT INTO audit_logs (
            user_id,
            action,
            entity_type,
            entity_id,
            details
        ) VALUES (
            CASE 
                WHEN TG_OP = 'DELETE' THEN NULL -- Aucun utilisateur ne peut être identifié pour DELETE
                ELSE NEW.updated_by
            END,
            action_type,
            entity_type,
            entity_id,
            details
        );
    END IF;
    
    -- Pour INSERT et UPDATE, retourner NEW; pour DELETE, retourner OLD
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER log_quiz_changes
    AFTER INSERT OR UPDATE OR DELETE ON quizzes
    FOR EACH ROW
    EXECUTE FUNCTION log_important_changes();