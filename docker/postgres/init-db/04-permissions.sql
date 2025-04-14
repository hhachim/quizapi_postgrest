-- Configuration des politiques RLS (Row Level Security)

-- Politique pour la table users
CREATE POLICY users_self_policy ON users 
    FOR ALL 
    TO authenticated 
    USING (id = current_setting('request.jwt.claim.user_id', true)::UUID);

CREATE POLICY users_admin_policy ON users 
    FOR ALL 
    TO admin 
    USING (true);

-- Politique pour la table categories
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

-- Politiques pour la table quiz_tags
CREATE POLICY quiz_tags_read_policy ON quiz_tags 
    FOR SELECT 
    TO anon, authenticated 
    USING (true);

-- Correction pour les politiques d'insertion avec WITH CHECK au lieu de USING
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

CREATE POLICY quiz_tags_admin_policy ON quiz_tags 
    FOR ALL 
    TO admin 
    USING (true);

-- Politiques pour la table tags
CREATE POLICY tags_read_policy ON tags 
    FOR SELECT 
    TO anon, authenticated 
    USING (deleted_at IS NULL);

-- Correction avec WITH CHECK pour INSERT
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

-- Politiques pour la table plugins
CREATE POLICY plugins_read_policy ON plugins 
    FOR SELECT 
    TO anon, authenticated 
    USING (true);

CREATE POLICY plugins_write_policy ON plugins 
    FOR ALL 
    TO admin 
    USING (true);

-- Fonction pour générer des tokens JWT (utilisant pgjwt)
CREATE OR REPLACE FUNCTION generate_jwt(
    user_id UUID,
    role TEXT
) RETURNS TEXT AS $$
DECLARE
    jwt_token TEXT;
    secret TEXT;
BEGIN
    -- Récupérer le secret JWT depuis la configuration
    BEGIN
        secret := current_setting('app.jwt_secret');
    EXCEPTION WHEN OTHERS THEN
        secret := 'votre_secret_jwt_tres_securise_a_changer_en_production';
    END;
    
    -- Création du header et payload du JWT
    jwt_token := jwt.sign(
        json_build_object(
            'role', role,
            'user_id', user_id,
            'exp', extract(epoch from now() + interval '1 day')::integer
        ),
        secret
    );
    
    RETURN jwt_token;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fonction d'authentification
CREATE OR REPLACE FUNCTION login(
    email TEXT,
    pass TEXT
) RETURNS TEXT AS $$
DECLARE
    user_id UUID;
    user_role TEXT;
    result TEXT;
BEGIN
    -- Vérifier si l'utilisateur existe et le mot de passe correspond
    SELECT u.id INTO user_id
    FROM users u
    WHERE u.email = login.email
      AND u.is_active = true
      AND u.deleted_at IS NULL
      AND u.password_hash = crypt(login.pass, u.password_hash);
    
    -- Si l'utilisateur n'existe pas ou le mot de passe est incorrect
    IF user_id IS NULL THEN
        RETURN 'Invalid email or password';
    END IF;
    
    -- Déterminer le rôle (simplifié pour l'exemple)
    user_role := 'authenticated';
    
    -- Mettre à jour la date de dernière connexion
    UPDATE users
    SET last_login_at = CURRENT_TIMESTAMP
    WHERE id = user_id;
    
    -- Générer et retourner le token JWT
    result := generate_jwt(user_id, user_role);
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Définir la variable de configuration pour le secret JWT
ALTER DATABASE quizapi_db SET app.jwt_secret TO 'votre_secret_jwt_tres_securise_a_changer_en_production';