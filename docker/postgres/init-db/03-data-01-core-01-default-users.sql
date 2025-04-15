-- -----------------------------------------------------
-- DATA CORE: Utilisateurs par défaut
-- Utilisateurs initiaux pour le système
-- -----------------------------------------------------

-- Insertion de l'utilisateur administrateur par défaut
INSERT INTO users (id, username, email, password_hash, first_name, last_name, is_active)
VALUES (
    uuid_generate_v4(), 
    'admin', 
    'admin@quizapi.fr', 
    '$2a$10$vzOG/7w0vRSzI4QZuAj1OeNL1Y8C3LPGlI/UBUwQQeX1LhqOH0z2W', 
    'Admin', 
    'System', 
    true
) ON CONFLICT (email) DO NOTHING;

-- Insertion des rôles de base
INSERT INTO roles (name, description)
VALUES 
('user', 'Utilisateur standard'),
('moderator', 'Modérateur de contenu'),
('administrator', 'Administrateur système')
ON CONFLICT (name) DO NOTHING;

-- Association du rôle administrateur à l'utilisateur admin
INSERT INTO user_roles (user_id, role_id)
SELECT 
    (SELECT id FROM users WHERE username = 'admin'),
    (SELECT id FROM roles WHERE name = 'administrator')
WHERE NOT EXISTS (
    SELECT 1 FROM user_roles 
    WHERE user_id = (SELECT id FROM users WHERE username = 'admin')
    AND role_id = (SELECT id FROM roles WHERE name = 'administrator')
);