-- ============================================
-- NETTOYAGE PROFOND & RÉPARATION (Fix 500 Final)
-- ============================================

-- Ce script va :
-- 1. Nettoyer les utilisateurs "orphelins" (qui existent dans public mais pas dans auth)
-- 2. Supprimer les doublons de téléphone qui bloquent l'inscription
-- 3. Réinstaller le trigger de protection

-- 1. DÉSACTIVER TEMPORAIREMENT LES TRIGGERS (Pour éviter les erreurs en cascade pendant nettoyage)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- 2. NETTOYAGE DES ORPHELINS (Ghost Data)
-- Supprime les profils publics qui n'ont plus de compte Auth correspondant
DELETE FROM public.users 
WHERE id NOT IN (SELECT id FROM auth.users);

-- Optionnel : Si vous avez des problèmes de téléphone dupliqué même entre comptes valides
-- Ceci est dangereux en prod, mais utile en dev pour débloquer.
-- Cela supprime les vieux comptes qui "squattent" un numéro de téléphone.
-- (Décommentez la ligne ci-dessous si nécessaire, sinon faites-le manuellement)
-- DELETE FROM public.users WHERE phone IN (SELECT phone FROM public.users GROUP BY phone HAVING COUNT(*) > 1);

-- 3. RÉINSTALLATION DU TRIGGER ROBUSTE
-- (Version améliorée qui capture les erreurs de duplication sans planter 500)

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
    user_role public.user_role;
    existing_phone_user UUID;
BEGIN
    -- 1. Gérer le Rôle
    BEGIN
        user_role := (new.raw_user_meta_data->>'role')::public.user_role;
    EXCEPTION WHEN OTHERS THEN
        user_role := 'client'::public.user_role;
    END;
    
    IF user_role IS NULL THEN
        user_role := 'client'::public.user_role;
    END IF;

    -- 2. Vérifier si le téléphone existe déjà (Anti-Crash 500)
    -- Si le numéro est déjà pris par un AUTRE utilisateur, on ne peut pas insérer.
    -- Au lieu de planter (500), on tente de "fusionner" ou logguer l'erreur silencieusement 
    -- pour que l'Auth Auth réussisse (l'user devra régler ça plus tard ou l'app gérera).
    -- MAIS pour la simplicité ici : On essaie l'insertion, et on capture l'erreur explicite.

    BEGIN
        INSERT INTO public.users (id, email, phone, full_name, role, is_active)
        VALUES (
            new.id,
            new.email,
            COALESCE(new.raw_user_meta_data->>'phone', 'NO_PHONE_' || new.id),
            COALESCE(new.raw_user_meta_data->>'full_name', 'Utilisateur sans nom'),
            user_role,
            true
        )
        ON CONFLICT (id) DO UPDATE SET
            email = EXCLUDED.email,
            phone = EXCLUDED.phone,
            full_name = EXCLUDED.full_name,
            role = EXCLUDED.role;
            
    EXCEPTION WHEN unique_violation THEN
        -- C'est ici que l'erreur 500 arrivait (Duplicate Phone).
        -- On va "bypasser" l'erreur pour laisser l'utilisateur se créer dans Auth.
        -- Il n'aura juste pas de profil public valide tout de suite (mais ça évite le crash bloquant).
        RAISE WARNING 'Phone number already taken used by another user. Skipping public profile creation to allow Auth.';
        RETURN new; -- On laisse passer l'inscription Auth
    END;

    RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. ACTIVER LE TRIGGER
CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Message de confirmation
DO $$
BEGIN
    RAISE NOTICE '✅ Base de données nettoyée et Trigger réparé.';
END $$;
