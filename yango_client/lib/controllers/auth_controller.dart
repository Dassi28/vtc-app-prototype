import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/user_model.dart';
import '../data/services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final Rx<User?> _user = Rx<User?>(null);
  final Rx<UserModel?> _userProfile = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  User? get user => _user.value;
  UserModel? get userProfile => _userProfile.value;
  bool get isAuthenticated => _user.value != null;

  @override
  void onInit() {
    super.onInit();
    _user.value = _authService.currentUser;
    
    // Listen to auth state changes
    _authService.authStateChanges.listen((state) {
      _user.value = state.session?.user;
      if (state.session?.user != null) {
        _loadUserProfile();
      } else {
        _userProfile.value = null;
      }
    });

    if (isAuthenticated) {
      _loadUserProfile();
    }
  }

  Future<void> _loadUserProfile() async {
    _userProfile.value = await _authService.getCurrentUserProfile();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );

      return true;
    } on AuthException catch (e) {
      errorMessage.value = e.message;
      return false;
    } catch (e) {
      errorMessage.value = 'Une erreur est survenue. Veuillez réessayer.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _authService.signIn(
        email: email,
        password: password,
      );

      return true;
    } on AuthException catch (e) {
      errorMessage.value = e.message;
      return false;
    } catch (e) {
      errorMessage.value = 'Une erreur est survenue. Veuillez réessayer.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user.value = null;
    _userProfile.value = null;
  }
}
