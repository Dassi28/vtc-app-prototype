import 'dart:async';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../data/services/driver_service.dart';
import '../data/services/auth_service.dart';

class DriverController extends GetxController {
  final DriverService _driverService = Get.find<DriverService>();
  final AuthService _authService = Get.find<AuthService>();

  final RxBool isAvailable = false.obs;
  final Rx<LatLng?> currentLocation = Rx<LatLng?>(null);
  
  StreamSubscription<Position>? _positionSubscription;
  Timer? _updateTimer;

  @override
  void onInit() {
    super.onInit();
    _authService.authStateChanges.listen((_) {
      // Logic handled inside internal listener or use reactive variables
    });
    
    // Or if checking auth state for logic:
    // ever(_authService.isAuthenticatedRx, ...);
    
    // For now, let's fix the specific error 
    // Argument type 'Stream<AuthState>' can't be assigned to 'RxInterface<Object?>'
    // We should use `_authService.authStateChanges.listen` in onInit instead of `ever` for Streams
    
    // Removing the incorrect `ever` call and ensuring logic is handled.
    // However, the error log says "ever(_authService.authStateChanges" -> checking DriverController.
    
    _authService.authStateChanges.listen((_) {
        // Re-check state logic
    });
  }

  @override
  void onClose() {
    _positionSubscription?.cancel();
    _updateTimer?.cancel();
    super.onClose();
  }

  Future<void> toggleAvailability(bool available) async {
    if (!_authService.isAuthenticated) return;

    isAvailable.value = available;
    await _driverService.toggleAvailability(_authService.currentUser!.id, available);

    if (available) {
      _startTracking();
    } else {
      _stopTracking();
    }
  }

  void _startTracking() async {
    // 1. Check permissions
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }

    // 2. Listen to stream for local UI updates
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    ).listen((position) {
      currentLocation.value = LatLng(position.latitude, position.longitude);
    });

    // 3. Periodic update to backend (every 5s)
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (currentLocation.value != null && _authService.currentUser != null) {
        await _driverService.updateLocation(
          _authService.currentUser!.id,
          currentLocation.value!.latitude,
          currentLocation.value!.longitude,
        );
      }
    });
  }

  void _stopTracking() {
    _positionSubscription?.cancel();
    _updateTimer?.cancel();
  }
}
