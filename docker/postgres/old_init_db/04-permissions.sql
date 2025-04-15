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
    jwt_token := sign( --si l'extension est installée dans un schéma jwt alors faire : jwt.sign, sinon sign directement si dans le schema public
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
    stored_hash TEXT;
BEGIN
    -- Obtenir le hash du mot de passe stocké
    SELECT u.id, u.password_hash INTO user_id, stored_hash
    FROM users u
    WHERE u.email = login.email
      AND u.is_active = true
      AND u.deleted_at IS NULL;
    
    -- Vérifier si l'utilisateur existe
    IF user_id IS NULL THEN
        RETURN 'Invalid email or password';
    END IF;
    
    -- Pour l'utilisateur admin et son hash prédéfini
    IF login.email = 'admin@quizapi.fr' AND stored_hash = '$2a$10$vzOG/7w0vRSzI4QZuAj1OeNL1Y8C3LPGlI/UBUwQQeX1LhqOH0z2W' THEN
        IF login.pass = 'admin_password' THEN -- remplacez par le vrai mot de passe admin
            user_role := 'admin';
            
            -- Mettre à jour la date de dernière connexion
            UPDATE users
            SET last_login_at = CURRENT_TIMESTAMP
            WHERE id = user_id;
            
            -- Générer et retourner le token JWT
            result := generate_jwt(user_id, user_role);
            RETURN result;
        ELSE
            RETURN 'Invalid email or password';
        END IF;
    END IF;
    
    -- Pour les autres utilisateurs, utiliser crypt() pour vérifier
    IF stored_hash = crypt(login.pass, stored_hash) THEN
        user_role := 'authenticated';
        
        -- Mettre à jour la date de dernière connexion
        UPDATE users
        SET last_login_at = CURRENT_TIMESTAMP
        WHERE id = user_id;
        
        -- Générer et retourner le token JWT
        result := generate_jwt(user_id, user_role);
        RETURN result;
    END IF;
    
    RETURN 'Invalid email or password';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Définir la variable de configuration pour le secret JWT
ALTER DATABASE quizapi_db SET app.jwt_secret TO 'votre_secret_jwt_tres_securise_a_changer_en_production';

-- Fonction d'inscription
CREATE OR REPLACE FUNCTION register(
    username TEXT,
    email TEXT,
    pass TEXT,
    first_name TEXT,
    last_name TEXT
) RETURNS TEXT AS $$
DECLARE
    user_id UUID;
    result TEXT;
BEGIN
    -- Vérifier si l'utilisateur existe déjà
    IF EXISTS (SELECT 1 FROM users WHERE users.email = register.email) THEN
        RETURN 'Email already exists';
    END IF;
    
    IF EXISTS (SELECT 1 FROM users WHERE users.username = register.username) THEN
        RETURN 'Username already exists';
    END IF;
    
    -- Créer l'utilisateur avec un mot de passe hashé
    INSERT INTO users (
        username, 
        email, 
        password_hash, 
        first_name, 
        last_name, 
        is_active
    ) VALUES (
        register.username,
        register.email,
        crypt(register.pass, gen_salt('bf')),
        register.first_name,
        register.last_name,
        true
    ) RETURNING id INTO user_id;
    
    -- Générer et retourner le token JWT
    IF user_id IS NOT NULL THEN
        result := generate_jwt(user_id, 'authenticated');
        RETURN result;
    ELSE
        RETURN 'Registration failed';
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Rendre la fonction register accessible via RPC
GRANT EXECUTE ON FUNCTION register TO anon;
-- Rendre la fonction login accessible via RPC
GRANT EXECUTE ON FUNCTION login TO anon;