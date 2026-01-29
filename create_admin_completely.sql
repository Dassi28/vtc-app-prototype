-- ================================================================
-- CRÉATION D'UN COMPTE ADMIN (SANS HASH DE MOT DE PASSE)
-- ================================================================

-- Comme nous ne pouvons pas générer le hash de mot de passe sécurisé (bcrypt) depuis ce script SQL simple 
-- sans connaître la configuration exacte de votre serveur Supabase (salt), 
-- la méthode la plus fiable est la suivante :

-- 1. Autoriser l'inscription temporaire
-- 2. Vous vous inscrivez via la page de login que je viens de créer
-- 3. Ce script vous promeut immédiatement ADMIN

-- ÉTAPE 1 : Exécutez ce script pour préparer le terrain
DO $$
BEGIN
    -- On s'assure que public.users accepte les nouveaux inscrits (normalement géré par trigger, mais on force si besoin)
    -- Pas d'action requise ici si les triggers sont en place.
    
    RAISE NOTICE 'Prêt pour inscription.';
END $$;

-- ÉTAPE 2 : Inscription
-- Allez sur http://localhost:5173/register
-- Créez un compte avec l'email : admin@demo.com (ou un autre de votre choix)
-- Mot de passe : password123 (ou ce que vous voulez)

-- ÉTAPE 3 : Une fois inscrit, revenez ici et lancez la commande suivante :
-- (Remplacez l'email si vous avez choisi autre chose)

DO $$
DECLARE
    target_email TEXT := 'admin@demo.com'; -- << VOTRE EMAIL ICI
    user_id UUID;
BEGIN
    -- Chercher l'ID de l'utilisateur fraîchement créé
    SELECT id INTO user_id FROM auth.users WHERE email = target_email;

    IF user_id IS NOT NULL THEN
        -- 1. Forcer le rôle dans public.users
        UPDATE public.users 
        SET role = 'admin', is_active = true, full_name = 'Admin Principal'
        WHERE id = user_id;

        -- Si l'utilisateur n'existait pas encore dans public.users (retard trigger), on l'insère
        IF NOT FOUND THEN
            INSERT INTO public.users (id, email, phone, full_name, role, is_active)
            VALUES (user_id, target_email, '+0000000000', 'Admin Principal', 'admin', true);
        END IF;

        -- 2. Donner les permissions explicites (Table public.admins)
        INSERT INTO public.admins (id, permissions)
        VALUES (user_id, '{"allbox_access": true}'::jsonb)
        ON CONFLICT (id) DO NOTHING;

        RAISE NOTICE '✅ SUCCÈS : % est maintenant ADMIN avec tous les droits !', target_email;
    ELSE
        RAISE NOTICE '⏳ ATTENTE : L''utilisateur % n''existe pas encore. Allez vous inscrire sur la page /register d''abord !', target_email;
    END IF;
END $$;
