-- -----------------------------------------------------
-- FONCTIONS APP: Gestion des quiz
-- Fonctions pour la gestion des quiz, questions et catégories
-- -----------------------------------------------------

-- Fonction pour vérifier si un utilisateur peut accéder à un quiz
CREATE OR REPLACE FUNCTION can_access_quiz(quiz_id UUID, user_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    is_allowed BOOLEAN;
BEGIN
    -- Vérifie si le quiz est public et publié
    SELECT EXISTS(
        SELECT 1 FROM quizzes q
        WHERE q.id = quiz_id
          AND q.is_public = TRUE
          AND q.status = 'PUBLISHED'
          AND q.deleted_at IS NULL
    ) OR EXISTS(
        -- Ou si l'utilisateur est le créateur du quiz
        SELECT 1 FROM quizzes q
        WHERE q.id = quiz_id
          AND q.created_by = user_id
          AND q.deleted_at IS NULL
    ) INTO is_allowed;
    
    RETURN is_allowed;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fonction pour vérifier les prérequis d'un quiz
CREATE OR REPLACE FUNCTION check_quiz_prerequisites(quiz_id UUID, user_id UUID)
RETURNS TABLE(
    prerequisite_quiz_id UUID,
    required_score NUMERIC,
    is_satisfied BOOLEAN,
    user_score NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    WITH user_attempts AS (
        SELECT qa.quiz_id, MAX(qa.score) as max_score
        FROM quiz_attempts qa
        WHERE qa.user_id = check_quiz_prerequisites.user_id
          AND qa.is_completed = TRUE
        GROUP BY qa.quiz_id
    )
    SELECT 
        qd.prerequisite_quiz_id,
        qd.required_score,
        CASE 
            WHEN ua.max_score IS NULL THEN FALSE
            WHEN qd.required_score IS NULL THEN TRUE
            WHEN ua.max_score >= qd.required_score THEN TRUE
            ELSE FALSE
        END as is_satisfied,
        COALESCE(ua.max_score, 0) as user_score
    FROM quiz_dependencies qd
    LEFT JOIN user_attempts ua ON ua.quiz_id = qd.prerequisite_quiz_id
    WHERE qd.quiz_id = check_quiz_prerequisites.quiz_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;