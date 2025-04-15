-- -----------------------------------------------------
-- DATA APP: Catégories et tags par défaut
-- Données initiales pour les catégories et tags
-- -----------------------------------------------------

-- Insertion de catégories par défaut
INSERT INTO categories (name, description, created_by)
VALUES 
    ('Informatique', 'Tout sur les ordinateurs, la programmation et les technologies', (SELECT id FROM users WHERE username = 'admin')),
    ('Sciences', 'Questions sur la physique, la chimie, la biologie et plus', (SELECT id FROM users WHERE username = 'admin')),
    ('Histoire', 'Événements historiques et personnages importants', (SELECT id FROM users WHERE username = 'admin')),
    ('Littérature', 'Livres, auteurs et mouvements littéraires', (SELECT id FROM users WHERE username = 'admin')),
    ('Géographie', 'Pays, capitales, fleuves et montagnes', (SELECT id FROM users WHERE username = 'admin'))
ON CONFLICT DO NOTHING;

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
     (SELECT id FROM users WHERE username = 'admin'))
ON CONFLICT DO NOTHING;

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
    ('NoSQL', (SELECT id FROM users WHERE username = 'admin'))
ON CONFLICT (name) DO NOTHING;