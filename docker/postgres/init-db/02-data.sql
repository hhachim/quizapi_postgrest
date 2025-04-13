-- Insertion de catégories par défaut
INSERT INTO categories (name, description, created_by)
VALUES 
    ('Informatique', 'Tout sur les ordinateurs, la programmation et les technologies', (SELECT id FROM users WHERE username = 'admin')),
    ('Sciences', 'Questions sur la physique, la chimie, la biologie et plus', (SELECT id FROM users WHERE username = 'admin')),
    ('Histoire', 'Événements historiques et personnages importants', (SELECT id FROM users WHERE username = 'admin')),
    ('Littérature', 'Livres, auteurs et mouvements littéraires', (SELECT id FROM users WHERE username = 'admin')),
    ('Géographie', 'Pays, capitales, fleuves et montagnes', (SELECT id FROM users WHERE username = 'admin'));

-- Ajout de sous-catégories
INSERT INTO categories (name, description, parent_id, created_by)
VALUES 
    ('Programmation', 'Langages de programmation et algorithmes', 
     (SELECT id FROM categories WHERE name = 'Informatique'), 
     (SELECT id FROM users WHERE username = 'admin')),
    ('Bases de données', 'SQL, NoSQL et conception de BDD', 
     (SELECT id FROM categories WHERE name = 'Informatique'), 
     (SELECT id FROM users WHERE username = 'admin')),
    ('Physique', 'Lois de la physique et découvertes', 
     (SELECT id FROM categories WHERE name = 'Sciences'), 
     (SELECT id FROM users WHERE username = 'admin')),
    ('Biologie', 'Le monde du vivant', 
     (SELECT id FROM categories WHERE name = 'Sciences'), 
     (SELECT id FROM users WHERE username = 'admin'));

-- Insertion de tags courants
INSERT INTO tags (name, created_by)
VALUES 
    ('Débutant', (SELECT id FROM users WHERE username = 'admin')),
    ('Intermédiaire', (SELECT id FROM users WHERE username = 'admin')),
    ('Avancé', (SELECT id FROM users WHERE username = 'admin')),
    ('Web', (SELECT id FROM users WHERE username = 'admin')),
    ('Mobile', (SELECT id FROM users WHERE username = 'admin')),
    ('Backend', (SELECT id FROM users WHERE username = 'admin')),
    ('Frontend', (SELECT id FROM users WHERE username = 'admin')),
    ('DevOps', (SELECT id FROM users WHERE username = 'admin')),
    ('SQL', (SELECT id FROM users WHERE username = 'admin')),
    ('NoSQL', (SELECT id FROM users WHERE username = 'admin'));

-- Insertion de quelques quiz d'exemple
INSERT INTO quizzes (title, description, difficulty_level, time_limit, passing_score, status, is_public, category_id, created_by)
VALUES 
    ('Introduction à SQL', 'Un quiz pour tester vos connaissances sur les bases de SQL', 
     'BEGINNER', 600, 70.00, 'PUBLISHED', TRUE, 
     (SELECT id FROM categories WHERE name = 'Bases de données'), 
     (SELECT id FROM users WHERE username = 'admin')),
    
    ('Concepts avancés de JavaScript', 'Testez vos connaissances sur les closures, promises et async/await', 
     'ADVANCED', 900, 80.00, 'PUBLISHED', TRUE, 
     (SELECT id FROM categories WHERE name = 'Programmation'), 
     (SELECT id FROM users WHERE username = 'admin')),
    
    ('Les fondamentaux de PostgreSQL', 'Un quiz pour maîtriser les concepts de base de PostgreSQL', 
     'MEDIUM', 1200, 75.00, 'DRAFT', FALSE, 
     (SELECT id FROM categories WHERE name = 'Bases de données'), 
     (SELECT id FROM users WHERE username = 'admin'));

-- Association de tags aux quiz
INSERT INTO quiz_tags (quiz_id, tag_id)
VALUES 
    ((SELECT id FROM quizzes WHERE title = 'Introduction à SQL'), 
     (SELECT id FROM tags WHERE name = 'Débutant')),
    
    ((SELECT id FROM quizzes WHERE title = 'Introduction à SQL'), 
     (SELECT id FROM tags WHERE name = 'SQL')),
    
    ((SELECT id FROM quizzes WHERE title = 'Concepts avancés de JavaScript'), 
     (SELECT id FROM tags WHERE name = 'Avancé')),
    
    ((SELECT id FROM quizzes WHERE title = 'Concepts avancés de JavaScript'), 
     (SELECT id FROM tags WHERE name = 'Frontend')),
    
    ((SELECT id FROM quizzes WHERE title = 'Les fondamentaux de PostgreSQL'), 
     (SELECT id FROM tags WHERE name = 'Intermédiaire')),
    
    ((SELECT id FROM quizzes WHERE title = 'Les fondamentaux de PostgreSQL'), 
     (SELECT id FROM tags WHERE name = 'SQL'));