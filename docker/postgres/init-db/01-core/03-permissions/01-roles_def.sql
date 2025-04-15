-- -----------------------------------------------------
-- PERMISSIONS CORE: Définition des rôles
-- Création et configuration des rôles du système
-- -----------------------------------------------------

-- Ne pas créer l'utilisateur s'il existe déjà (il est créé par Docker lors du démarrage)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT FROM pg_catalog.pg_roles
        WHERE rolname = 'quizapi_user'
    ) THEN
        CREATE USER quizapi_user WITH LOGIN PASSWORD 'quizapi_password';
    END IF;
END
$$;

-- Création du rôle administrateur
CREATE ROLE admin NOLOGIN;

-- Création du rôle pour les utilisateurs anonymes
CREATE ROLE anon NOLOGIN;

-- Création du rôle pour les utilisateurs authentifiés
CREATE ROLE authenticated NOLOGIN;

-- Attribution des privilèges
GRANT anon TO quizapi_user;
GRANT authenticated TO quizapi_user;
GRANT admin TO quizapi_user;

-- Droits sur le schéma
GRANT USAGE ON SCHEMA public TO anon, authenticated, admin;

-- Droits pour les fonctions d'authentification
GRANT EXECUTE ON FUNCTION register TO anon;
GRANT EXECUTE ON FUNCTION login TO anon;