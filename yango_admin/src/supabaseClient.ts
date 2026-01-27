import { createClient } from "@supabase/supabase-js";

const SUPABASE_URL = "https://iznlnkmorjgiichrjmvo.supabase.co";
const SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml6bmxua21vcmpnaWljaHJqbXZvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjkzNDIyNTIsImV4cCI6MjA4NDkxODI1Mn0.QnJzaHb2THg_PgCPaqiO9Xu7KQiSzsaJBaz5XFab6FQ";

export const supabaseClient = createClient(SUPABASE_URL, SUPABASE_KEY, {
    db: {
        schema: "public",
    },
    auth: {
        persistSession: true,
    },
});
