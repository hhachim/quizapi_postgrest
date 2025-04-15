-- -----------------------------------------------------
-- DATA APP: Quiz et questions d'exemple
-- Données initiales pour les quiz et questions
-- -----------------------------------------------------

-- Insertion de quelques quiz d'exemple
INSERT INTO quizzes (title, description, difficulty_level, time_limit, passing_score, status, is_public, category_id, created_by)
VALUES 
    ('Introduction à SQL', 'Un quiz pour tester vos connaissances sur les bases de SQL', 
     'BEGINNER', 600, 70.00, 'PUBLISHED', TRUE, 
     (SELECT id FROM categories WHERE name = 'Bases de données'), 
     (SELECT id FROM users WHERE username = 'admin')),
    
    ('Concepts avancés de JavaScript', 'Testez vos connaissances sur les closures, promises et async/await', 
     'HARD', 900, 80.00, 'PUBLISHED', TRUE, 
     (SELECT id FROM categories WHERE name = 'Programmation'), 
     (SELECT id FROM users WHERE username = 'admin')),
    
    ('Les fondamentaux de PostgreSQL', 'Un quiz pour maîtriser les concepts de base de PostgreSQL', 
     'MEDIUM', 1200, 75.00, 'DRAFT', FALSE, 
     (SELECT id FROM categories WHERE name = 'Bases de données'), 
     (SELECT id FROM users WHERE username = 'admin'))
ON CONFLICT DO NOTHING;

-- Association de tags aux quiz
INSERT INTO quiz_tags (quiz_id, tag_id)
SELECT 
    (SELECT id FROM quizzes WHERE title = 'Introduction à SQL'),
    (SELECT id FROM tags WHERE name = 'Débutant')
WHERE NOT EXISTS (
    SELECT 1 FROM quiz_tags 
    WHERE quiz_id = (SELECT id FROM quizzes WHERE title = 'Introduction à SQL')
    AND tag_id = (SELECT id FROM tags WHERE name = 'Débutant')
);

INSERT INTO quiz_tags (quiz_id, tag_id)
SELECT 
    (SELECT id FROM quizzes WHERE title = 'Introduction à SQL'),
    (SELECT id FROM tags WHERE name = 'SQL')
WHERE NOT EXISTS (
    SELECT 1 FROM quiz_tags 
    WHERE quiz_id = (SELECT id FROM quizzes WHERE title = 'Introduction à SQL')
    AND tag_id = (SELECT id FROM tags WHERE name = 'SQL')
);

INSERT INTO quiz_tags (quiz_id, tag_id)
SELECT 
    (SELECT id FROM quizzes WHERE title = 'Concepts avancés de JavaScript'),
    (SELECT id FROM tags WHERE name = 'Avancé')
WHERE NOT EXISTS (
    SELECT 1 FROM quiz_tags 
    WHERE quiz_id = (SELECT id FROM quizzes WHERE title = 'Concepts avancés de JavaScript')
    AND tag_id = (SELECT id FROM tags WHERE name = 'Avancé')
);

INSERT INTO quiz_tags (quiz_id, tag_id)
SELECT 
    (SELECT id FROM quizzes WHERE title = 'Concepts avancés de JavaScript'),
    (SELECT id FROM tags WHERE name = 'Frontend')
WHERE NOT EXISTS (
    SELECT 1 FROM quiz_tags 
    WHERE quiz_id = (SELECT id FROM quizzes WHERE title = 'Concepts avancés de JavaScript')
    AND tag_id = (SELECT id FROM tags WHERE name = 'Frontend')
);

INSERT INTO quiz_tags (quiz_id, tag_id)
SELECT 
    (SELECT id FROM quizzes WHERE title = 'Les fondamentaux de PostgreSQL'),
    (SELECT id FROM tags WHERE name = 'Intermédiaire')
WHERE NOT EXISTS (
    SELECT 1 FROM quiz_tags 
    WHERE quiz_id = (SELECT id FROM quizzes WHERE title = 'Les fondamentaux de PostgreSQL')
    AND tag_id = (SELECT id FROM tags WHERE name = 'Intermédiaire')
);

INSERT INTO quiz_tags (quiz_id, tag_id)
SELECT 
    (SELECT id FROM quizzes WHERE title = 'Les fondamentaux de PostgreSQL'),
    (SELECT id FROM tags WHERE name = 'SQL')
WHERE NOT EXISTS (
    SELECT 1 FROM quiz_tags 
    WHERE quiz_id = (SELECT id FROM quizzes WHERE title = 'Les fondamentaux de PostgreSQL')
    AND tag_id = (SELECT id FROM tags WHERE name = 'SQL')
);

-- Création de quelques questions pour le quiz "Introduction à SQL"
DO $$
DECLARE
    quiz_id UUID;
    question_id UUID;
    admin_id UUID;
BEGIN
    SELECT id INTO quiz_id FROM quizzes WHERE title = 'Introduction à SQL';
    SELECT id INTO admin_id FROM users WHERE username = 'admin';
    
    -- Question 1: QCM
    INSERT INTO questions (content, explanation, question_type_id, default_points, created_by)
    VALUES (
        'Que signifie SQL ?',
        'SQL signifie "Structured Query Language". C''est un langage standardisé utilisé pour communiquer avec les bases de données relationnelles.',
        (SELECT id FROM question_types WHERE name = 'MULTIPLE_CHOICE'),
        1.0,
        admin_id
    )
    RETURNING id INTO question_id;
    
    -- Choix pour la question 1
    INSERT INTO answer_choices (question_id, content, is_correct)
    VALUES 
        (question_id, 'Structured Query Language', TRUE),
        (question_id, 'Simple Query Language', FALSE),
        (question_id, 'Standard Query Language', FALSE),
        (question_id, 'Sequential Query Language', FALSE);
    
    -- Lier la question au quiz
    INSERT INTO quiz_questions (quiz_id, question_id, order_num)
    VALUES (quiz_id, question_id, 1);
    
    -- Question 2: Vrai/Faux
    INSERT INTO questions (content, explanation, question_type_id, default_points, created_by)
    VALUES (
        'SQL est un langage de programmation orienté objet.',
        'Faux. SQL est un langage déclaratif conçu spécifiquement pour gérer des données dans des systèmes de gestion de bases de données relationnelles, et non un langage de programmation orienté objet.',
        (SELECT id FROM question_types WHERE name = 'TRUE_FALSE'),
        1.0,
        admin_id
    )
    RETURNING id INTO question_id;
    
    -- Choix pour la question 2
    INSERT INTO answer_choices (question_id, content, is_correct)
    VALUES 
        (question_id, 'Vrai', FALSE),
        (question_id, 'Faux', TRUE);
    
    -- Lier la question au quiz
    INSERT INTO quiz_questions (quiz_id, question_id, order_num)
    VALUES (quiz_id, question_id, 2);
    
    -- Question 3: QCM multiple
    INSERT INTO questions (content, explanation, question_type_id, default_points, created_by)
    VALUES (
        'Quelles commandes font partie du langage de manipulation de données (DML) ? (Sélectionnez toutes les réponses correctes)',
        'Les commandes DML sont celles qui permettent de manipuler les données dans les tables: SELECT (pour lire), INSERT (pour ajouter), UPDATE (pour modifier) et DELETE (pour supprimer).',
        (SELECT id FROM question_types WHERE name = 'MULTIPLE_CHOICE'),
        2.0,
        admin_id
    )
    RETURNING id INTO question_id;
    
    -- Choix pour la question 3
    INSERT INTO answer_choices (question_id, content, is_correct)
    VALUES 
        (question_id, 'SELECT', TRUE),
        (question_id, 'INSERT', TRUE),
        (question_id, 'UPDATE', TRUE),
        (question_id, 'DELETE', TRUE),
        (question_id, 'CREATE', FALSE),
        (question_id, 'ALTER', FALSE),
        (question_id, 'DROP', FALSE);
    
    -- Lier la question au quiz
    INSERT INTO quiz_questions (quiz_id, question_id, order_num)
    VALUES (quiz_id, question_id, 3);
END $$;