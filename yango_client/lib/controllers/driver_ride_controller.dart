import 'dart:async';
import 'package:get/get.dart';
import '../data/models/ride_model.dart';
import '../data/services/ride_service.dart';
import '../data/services/auth_service.dart';
import '../data/services/driver_service.dart';
import '../data/services/location_service.dart';
import 'driver_controller.dart';

class DriverRideController extends GetxController {
  final RideService _rideService = Get.find<RideService>();
  final AuthService _authService = Get.find<AuthService>();
  final DriverService _driverService = Get.find<DriverService>();
  final LocationService _locationService = Get.find<LocationService>();


  final Rx<RideModel?> activeRide = Rx<RideModel?>(null);
  final RxBool isLoading = false.obs;

  StreamSubscription? _requestsSubscription;
  StreamSubscription? _rideSubscription; 
  StreamSubscription? _locationSubscription;

  @override
  void onInit() {
    super.onInit();
    // Listen for requests when logged in
    ever(Get.find<DriverController>().isAvailable, (available) {
      if (available) {
        _listenToRequests();
      } else {
        _requestsSubscription?.cancel();
      }
    });

    _checkActiveRide();
  }
  
  void _checkActiveRide() async {
    if (_authService.currentUser == null) return;
    final ride = await _rideService.getActiveRide(_authService.currentUser!.id);
    if (ride != null) {
        activeRide.value = ride;
        _listenToActiveRide(ride.id);
    }
  }

  void _listenToRequests() {
    if (_authService.currentUser == null) return;
    
    _requestsSubscription = _driverService.listenToMyRequests(_authService.currentUser!.id).listen((payloads) {
      if (payloads.isNotEmpty) {
        // Handle new request - show dialog
        // For prototype, we just verify data
        // We need to fetch Ride details for the first request
        final request = payloads.first;
        _showRequestDialog(request);
      }
    });
  }

  void _showRequestDialog(Map<String, dynamic> requestData) {
     // Trigger UI Dialog via Get.dialog or call View method
     Get.find<IncomingRequestController>().newRequest(requestData);
  }

  Future<void> acceptRide(String requestId, String rideId) async {
    if (_authService.currentUser == null) return;

    try {
      isLoading.value = true;
      await _rideService.acceptRideRequest(requestId, rideId, _authService.currentUser!.id);
      
      // Stop listening to requests as we are busy
      _requestsSubscription?.cancel();
      
      // Start listening to the ride
      _listenToActiveRide(rideId);
      
      // Navigate to active ride screen
      Get.toNamed('/driver/active-ride'); // Changed route
      
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible d\'accepter la course: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _listenToActiveRide(String rideId) {
    activeRide.bindStream(_rideService.listenToRide(rideId));
    
    // Start tracking location for the ride
    _startLocationTracking();
  }

  void _startLocationTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = _locationService.getPositionStream().listen((position) {
       _driverService.updateLocation(
         _authService.currentUser!.id, 
         position.latitude, 
         position.longitude
       );
    });
  }

  void _stopLocationTracking() {
    _locationSubscription?.cancel();
  }

  Future<void> updateStatus(RideStatus status) async {
    if (activeRide.value == null) return;
    
    try {
      isLoading.value = true;
      await _rideService.updateRideStatus(activeRide.value!.id, status);
      
      if (status == RideStatus.completed) {
         Get.offAllNamed('/driver-home');
         activeRide.value = null;
         _stopLocationTracking();
      }
    } catch (e) {
       Get.snackbar('Erreur', 'Mise à jour échouée');
    } finally {
      isLoading.value = false;
    }
  }
}

// Helper controller for incoming requests
class IncomingRequestController extends GetxController {
    final Rx<Map<String, dynamic>?> currentRequest = Rx<Map<String, dynamic>?>(null);
    
    void newRequest(Map<String, dynamic> request) {
        currentRequest.value = request;
    }
    
    void clear() {
        currentRequest.value = null;
    }
}
