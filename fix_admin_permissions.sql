-- ================================================================
-- CORRECTION DES PERMISSIONS ADMIN
-- ================================================================
-- Ce script va :
-- 1. Trouver votre utilisateur via son email.
-- 2. S'assurer qu'il a le rôle 'admin' dans public.users.
-- 3. L'ajouter dans la table public.admins (requis pour voir les données).

-- ⚠️ REMPLACEZ L'EMAIL CI-DESSOUS PAR CELUI QUE VOUS UTILISEZ POUR VOUS CONNECTER ⚠️
DO $$
DECLARE
    target_email TEXT := 'admin@demo.com'; -- << METTEZ VOTRE EMAIL ICI
    user_id UUID;
BEGIN
    -- Récupérer l'ID Auth
    SELECT id INTO user_id FROM auth.users WHERE email = target_email;

    IF user_id IS NOT NULL THEN
        RAISE NOTICE 'Utilisateur trouvé: % (ID: %)', target_email, user_id;

        -- 1. Mise à jour ou insertion dans public.users
        INSERT INTO public.users (id, email, phone, full_name, role, is_active)
        VALUES (
            user_id, 
            target_email, 
            '+0000000000', -- Téléphone fictif si nouveau
            'Super Admin', 
            'admin', 
            true
        )
        ON CONFLICT (id) DO UPDATE 
        SET role = 'admin';
        
        RAISE NOTICE 'Role admin confirmé dans public.users';

        -- 2. Insertion dans public.admins (C'est ÇA qui manquait pour voir les données)
        INSERT INTO public.admins (id, permissions)
        VALUES (user_id, '{"can_manage_users": true, "can_manage_rides": true, "can_view_stats": true}'::jsonb)
        ON CONFLICT (id) DO NOTHING;

        RAISE NOTICE 'Permissions Admin appliquées avec succès !';
    ELSE
        RAISE NOTICE '❌ ERREUR: Utilisateur % introuvable. Avez-vous créé un compte ?', target_email;
    END IF;
END $$;
