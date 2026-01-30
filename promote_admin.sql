-- ============================================
-- PROMOTION ADMIN RAPIDE
-- ============================================

-- Remplacez 'votre_email@exemple.com' par l'email que vous utilisez pour vous connecter au Dashboard Admin.
-- Ensuite, exécutez ce script dans l'éditeur SQL de Supabase.

DO $$
DECLARE
    target_email TEXT := 'admin@demo.com'; -- << METTEZ VOTRE EMAIL ICI
    user_id UUID;
BEGIN
    -- 1. Trouver l'utilisateur
    SELECT id INTO user_id FROM auth.users WHERE email = target_email;

    IF user_id IS NOT NULL THEN
        -- 2. Mettre à jour le rôle dans public.users
        UPDATE public.users 
        SET role = 'admin' 
        WHERE id = user_id;

        -- 3. Créer l'entrée dans la table admins (indispensable pour les permissions RLS)
        INSERT INTO public.admins (id, permissions)
        VALUES (user_id, '{"can_manage_all": true}'::jsonb)
        ON CONFLICT (id) DO NOTHING;

        RAISE NOTICE '✅ Succès : L''utilisateur % est maintenant ADMIN.', target_email;
    ELSE
        RAISE NOTICE '❌ Erreur : Aucun utilisateur trouvé avec l''email %. Vérifiez l''orthographe.', target_email;
    END IF;
END $$;
