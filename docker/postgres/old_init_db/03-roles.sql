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

-- Droits pour le rôle anonyme (lecture seule pour les éléments publics)
GRANT SELECT ON 
    categories, 
    quizzes,
    tags,
    quiz_tags,
    plugins
TO anon;

-- Restrictions pour anon: limiter aux quiz publiés et publics
CREATE POLICY quizzes_anon_policy ON quizzes 
    FOR SELECT 
    TO anon 
    USING (status = 'PUBLISHED' AND is_public = TRUE AND deleted_at IS NULL);

-- Droits pour les utilisateurs authentifiés
GRANT SELECT ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT INSERT, UPDATE, DELETE ON 
    quiz_tags,
    tags
TO authenticated;

-- Restreindre l'accès aux utilisateurs authentifiés pour qu'ils ne voient que leurs propres données ou les données publiques
CREATE POLICY quizzes_authenticated_policy ON quizzes 
    FOR ALL 
    TO authenticated 
    USING (
        (status = 'PUBLISHED' AND is_public = TRUE) OR 
        (created_by = current_setting('request.jwt.claim.user_id', true)::UUID)
    );

-- Droits pour les administrateurs (accès complet)
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO admin;

-- S'assurer que les permissions s'appliquent aussi aux futures tables
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON SEQUENCES TO admin;

-- Activer Row Level Security sur toutes les tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE quizzes ENABLE ROW LEVEL SECURITY;
ALTER TABLE tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE plugins ENABLE ROW LEVEL SECURITY;