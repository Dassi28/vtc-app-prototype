-- ============================================
-- FIX AUTH TRIGGER (Erreur 500)
-- ============================================

-- Ce script remplace le déclencheur (trigger) automatique qui crée l'utilisateur
-- dans la table `public.users` lors de l'inscription.
-- L'erreur 500 est souvent causée par un conflit ou une mauvaise gestion des métadonnées dans ce trigger.

-- 1. Supprimer l'ancien trigger et la fonction s'ils existent
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- 2. Créer une fonction robuste pour gérer la création d'utilisateur
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
    user_role public.user_role;
BEGIN
    -- Tentative de récupération du rôle depuis les métadonnées
    -- Si absent ou invalide, on force 'client' par défaut
    BEGIN
        user_role := (new.raw_user_meta_data->>'role')::public.user_role;
    EXCEPTION WHEN OTHERS THEN
        user_role := 'client'::public.user_role;
    END;

    -- Si le rôle est NULL après le cast, mettre 'client'
    IF user_role IS NULL THEN
        user_role := 'client'::public.user_role;
    END IF;

    -- Insertion sécurisée dans public.users
    INSERT INTO public.users (
        id, 
        email, 
        phone, 
        full_name, 
        role,
        is_active
    )
    VALUES (
        new.id,
        new.email,
        -- On utilise COALESCE pour éviter les erreurs NULL, mais phone est UNIQUE/NOT NULL
        -- Si pas de téléphone, on met un placeholder temporaire (ne devrait pas arriver avec l'app)
        COALESCE(new.raw_user_meta_data->>'phone', 'WAITING_FOR_PHONE_' || new.id),
        COALESCE(new.raw_user_meta_data->>'full_name', 'Utilisateur sans nom'),
        user_role,
        true
    )
    ON CONFLICT (id) DO UPDATE SET
        -- Si l'utilisateur existe déjà, on met à jour les infos
        email = EXCLUDED.email,
        phone = EXCLUDED.phone,
        full_name = EXCLUDED.full_name,
        role = EXCLUDED.role;

    RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER; -- SECURITY DEFINER = s'exécute avec les droits admin

-- 3. Recréer le trigger
CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 4. Nettoyage des doublons/erreurs (Optionnel mais utile)
-- S'assure que les utilisateurs existants dans auth mais pas dans public sont créés (si possible)
-- INSERT INTO public.users (id, email, phone, full_name, role)
-- SELECT 
--     id, 
--     email, 
--     COALESCE(raw_user_meta_data->>'phone', 'MISSING_' || id),
--     COALESCE(raw_user_meta_data->>'full_name', 'Inconnu'),
--     'client' 
-- FROM auth.users 
-- WHERE id NOT IN (SELECT id FROM public.users)
-- ON CONFLICT DO NOTHING;
