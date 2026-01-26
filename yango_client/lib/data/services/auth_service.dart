import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService extends GetxService {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'phone': phone,
      },
    );

    if (response.user != null) {
      // Create user profile in public.users table
      await _supabase.from('users').insert({
        'id': response.user!.id,
        'email': email,
        'phone': phone,
        'full_name': fullName,
        'role': 'client',
      });

      // Create client entry
      await _supabase.from('clients').insert({
        'id': response.user!.id,
      });
    }

    return response;
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<UserModel?> getCurrentUserProfile() async {
    if (currentUser == null) return null;

    final response = await _supabase
        .from('users')
        .select()
        .eq('id', currentUser!.id)
        .single();

    return UserModel.fromJson(response);
  }

  Future<void> updateUserProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    if (currentUser == null) return;

    final updates = <String, dynamic>{};
    if (fullName != null) updates['full_name'] = fullName;
    if (phone != null) updates['phone'] = phone;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

    if (updates.isNotEmpty) {
      await _supabase
          .from('users')
          .update(updates)
          .eq('id', currentUser!.id);
    }
  }
}
