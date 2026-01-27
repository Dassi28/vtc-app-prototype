import { AuthBindings } from "@refinedev/core";
import { supabaseClient } from "./supabaseClient";

export const authProvider: AuthBindings = {
    login: async ({ email, password }) => {
        const { data, error } = await supabaseClient.auth.signInWithPassword({
            email,
            password,
        });

        if (error) {
            return {
                success: false,
                error: error,
            };
        }

        if (data.session) {
            // Check if user is admin
            // We assume there's a 'users' table with 'role' column
            const { data: userData, error: userError } = await supabaseClient
                .from("users")
                .select("role")
                .eq("id", data.user.id)
                .single();

            if (userError || userData?.role !== "admin") {
                await supabaseClient.auth.signOut();
                return {
                    success: false,
                    error: {
                        message: "Access Denied",
                        name: "UnlikeAdmin",
                    }
                };
            }

            return {
                success: true,
                redirectTo: "/",
            };
        }

        return {
            success: false,
            error: {
                message: "Login failed",
                name: "LoginError",
            },
        };
    },
    logout: async () => {
        const { error } = await supabaseClient.auth.signOut();

        if (error) {
            return {
                success: false,
                error,
            };
        }

        return {
            success: true,
            redirectTo: "/login",
        };
    },
    onError: async (error) => {
        console.error(error);
        return { error };
    },
    check: async () => {
        const { data } = await supabaseClient.auth.getSession();
        const { session } = data;

        if (!session) {
            return {
                authenticated: false,
                redirectTo: "/login",
            };
        }

        return {
            authenticated: true,
        };
    },
    getPermissions: async () => {
        const user = await supabaseClient.auth.getUser();
        if (user) {
            return user.data.user?.role;
        }
        return null;
    },
    getIdentity: async () => {
        const { data } = await supabaseClient.auth.getUser();

        if (data?.user) {
            const { user } = data;
            return {
                ...user,
                name: user.email,
            };
        }
        return null;
    },
};
