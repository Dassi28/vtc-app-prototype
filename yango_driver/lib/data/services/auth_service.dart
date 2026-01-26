import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/driver_model.dart';

class AuthService extends GetxService {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Register a new driver
  /// 1. Create auth user
  /// 2. Insert into 'users'
  /// 3. Insert into 'drivers'
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
    // 1. Auth SignUp
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName, 'phone': phone},
    );

    if (response.user == null) {
      throw const AuthException('Registration failed');
    }

    final userId = response.user!.id;

    // 2. Insert into users (public table)
    await _supabase.from('users').insert({
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
  }

  Future<void> signIn(String email, String password) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<DriverModel?> getCurrentDriverProfile() async {
    if (currentUser == null) return null;

    final response = await _supabase
        .from('drivers')
        .select('*, users!inner(*)') // Join with users
        .eq('id', currentUser!.id)
        .maybeSingle();

    if (response == null) return null;

    return DriverModel.fromJson(response, userJson: response['users']);
  }
}
