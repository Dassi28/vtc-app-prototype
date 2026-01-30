import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/driver_model.dart';


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
        'role': 'client', // Critical for triggers
      },
    );

    if (response.user != null) {
      // Create user profile in public.users table (Use upsert to avoid trigger conflicts)
      await _supabase.from('users').upsert({
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
  Future<void> registerDriver({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required VehicleType vehicleType,
    required String vehicleBrand,
    required String vehicleModel,
    required String licensePlate,
    required String driverLicense,
  }) async {
    try {
      // 1. Auth SignUp
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName, 
          'phone': phone,
          'role': 'driver',
        },
      );

      if (response.user == null) {
        throw const AuthException('Registration failed: No user returned');
      }

      final userId = response.user!.id;

      // 2. Insert into users (public table)
      // Note: If permissions are fixed by policy, this should work.
      await _supabase.from('users').upsert({
        'id': userId,
        'email': email,
        'phone': phone,
        'full_name': fullName,
        'role': 'driver',
      });

      // 3. Insert into drivers
      await _supabase.from('drivers').insert({
        'id': userId,
        'vehicle_type': vehicleType.name,
        'vehicle_brand': vehicleBrand,
        'vehicle_model': vehicleModel,
        'license_plate': licensePlate,
        'driver_license': driverLicense,
        'is_available': false,
        'is_verified': false, // Requires admin approval
      });
    } on AuthException catch (e) {
      // Re-throw Supabase Auth exceptions directly
      print('Auth Error: ${e.message}');
      rethrow;
    } catch (e) {
      print('Registration Error: $e');
      throw AuthException('Erreur d\'inscription: $e');
    }
  }
}

