-- -----------------------------------------------------
-- FONCTIONS APP: Scoring et évaluation
-- Fonctions pour le calcul des scores et l'évaluation des réponses
-- -----------------------------------------------------

-- Fonction pour calculer le score d'une tentative de quiz
CREATE OR REPLACE FUNCTION calculate_attempt_score(attempt_id UUID)
RETURNS NUMERIC AS $$
DECLARE
    total_points NUMERIC;
    earned_points NUMERIC;
    final_score NUMERIC;
    quiz_passing_score NUMERIC;
    is_passed BOOLEAN;
BEGIN
    -- Récupérer le total des points possibles pour ce quiz
    SELECT SUM(COALESCE(qq.points, q.default_points))
    FROM quiz_attempts qa
    JOIN quiz_questions qq ON qa.quiz_id = qq.quiz_id
    JOIN questions q ON qq.question_id = q.id
    WHERE qa.id = calculate_attempt_score.attempt_id
    INTO total_points;
    
    -- Récupérer les points gagnés
    SELECT SUM(ar.points_earned)
    FROM attempt_responses ar
    WHERE ar.attempt_id = calculate_attempt_score.attempt_id
    INTO earned_points;
    
    -- Calculer le score final (pourcentage)
    IF total_points > 0 THEN
        final_score := (earned_points / total_points) * 100;
    ELSE
        final_score := 0;
    END IF;
    
    -- Récupérer le score minimum pour réussir
    SELECT q.passing_score
    FROM quiz_attempts qa
    JOIN quizzes q ON qa.quiz_id = q.id
    WHERE qa.id = calculate_attempt_score.attempt_id
    INTO quiz_passing_score;
    
    -- Déterminer si l'utilisateur a réussi
    IF quiz_passing_score IS NOT NULL THEN
        is_passed := final_score >= quiz_passing_score;
    ELSE
        is_passed := NULL; -- Pas de score minimum défini
    END IF;
    
    -- Mettre à jour la tentative
    UPDATE quiz_attempts
    SET 
        score = final_score,
        is_passed = is_passed,
        status = CASE
            WHEN is_passed IS TRUE THEN 'COMPLETED'
            WHEN is_passed IS FALSE THEN 'FAILED'
            ELSE 'COMPLETED'
        END,
        is_completed = TRUE,
        end_time = COALESCE(end_time, CURRENT_TIMESTAMP),
        total_time = EXTRACT(EPOCH FROM (COALESCE(end_time, CURRENT_TIMESTAMP) - start_time))::INTEGER,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = calculate_attempt_score.attempt_id;
    
    -- Mettre à jour les statistiques de l'utilisateur
    PERFORM update_user_statistics(
        (SELECT user_id FROM quiz_attempts WHERE id = calculate_attempt_score.attempt_id)
    );
    
    RETURN final_score;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fonction pour mettre à jour les statistiques d'un utilisateur
CREATE OR REPLACE FUNCTION update_user_statistics(user_id UUID)
RETURNS VOID AS $$
DECLARE
    stats_exist BOOLEAN;
BEGIN
    -- Vérifier si des statistiques existent déjà pour cet utilisateur
    SELECT EXISTS(
        SELECT 1 FROM user_statistics WHERE user_id = update_user_statistics.user_id
    ) INTO stats_exist;
    
    IF stats_exist THEN
        -- Mettre à jour les statistiques existantes
        UPDATE user_statistics
        SET
            total_attempts = (SELECT COUNT(*) FROM quiz_attempts WHERE user_id = update_user_statistics.user_id),
            completed_attempts = (SELECT COUNT(*) FROM quiz_attempts WHERE user_id = update_user_statistics.user_id AND is_completed = TRUE),
            passed_attempts = (SELECT COUNT(*) FROM quiz_attempts WHERE user_id = update_user_statistics.user_id AND is_passed = TRUE),
            total_score = (SELECT COALESCE(SUM(score), 0) FROM quiz_attempts WHERE user_id = update_user_statistics.user_id AND is_completed = TRUE),
            average_score = (SELECT COALESCE(AVG(score), 0) FROM quiz_attempts WHERE user_id = update_user_statistics.user_id AND is_completed = TRUE),
            total_time = (SELECT COALESCE(SUM(total_time), 0) FROM quiz_attempts WHERE user_id = update_user_statistics.user_id AND is_completed = TRUE),
            updated_at = CURRENT_TIMESTAMP
        WHERE user_id = update_user_statistics.user_id;
    ELSE
        -- Créer de nouvelles statistiques
        INSERT INTO user_statistics (
            user_id,
            total_attempts,
            completed_attempts,
            passed_attempts,
            total_score,
            average_score,
            total_time
        ) 
        SELECT
            update_user_statistics.user_id,
            COUNT(*),
            COUNT(*) FILTER (WHERE is_completed = TRUE),
            COUNT(*) FILTER (WHERE is_passed = TRUE),
            COALESCE(SUM(score) FILTER (WHERE is_completed = TRUE), 0),
            COALESCE(AVG(score) FILTER (WHERE is_completed = TRUE), 0),
            COALESCE(SUM(total_time) FILTER (WHERE is_completed = TRUE), 0)
        FROM quiz_attempts
        WHERE user_id = update_user_statistics.user_id;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;