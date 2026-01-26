import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/driver_model.dart';
import '../data/services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final Rx<User?> _user = Rx<User?>(null);
  final Rx<DriverModel?> _driverProfile = Rx<DriverModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  User? get user => _user.value;
  DriverModel? get driverProfile => _driverProfile.value;
  bool get isAuthenticated => _user.value != null;

  @override
  void onInit() {
    super.onInit();
    _user.value = _authService.currentUser;
    _authService.authStateChanges.listen((state) {
      _user.value = state.session?.user;
      if (state.session?.user != null) {
        _loadDriverProfile();
      } else {
        _driverProfile.value = null;
      }
    });

    if (isAuthenticated) {
      _loadDriverProfile();
    }
  }

  Future<void> _loadDriverProfile() async {
    _driverProfile.value = await _authService.getCurrentDriverProfile();
  }

  Future<bool> register({
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
      isLoading.value = true;
      errorMessage.value = '';

      await _authService.registerDriver(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        vehicleType: vehicleType,
        vehicleBrand: vehicleBrand,
        vehicleModel: vehicleModel,
        licensePlate: licensePlate,
        driverLicense: driverLicense,
      );

      return true;
    } on AuthException catch (e) {
      errorMessage.value = e.message;
      return false;
    } catch (e) {
      errorMessage.value = 'Registration failed: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      await _authService.signIn(email, password);
      return true;
    } on AuthException catch (e) {
      errorMessage.value = e.message;
      return false;
    } catch (e) {
      errorMessage.value = 'Sign in failed: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
