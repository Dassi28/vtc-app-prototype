import 'dart:async';
import 'package:get/get.dart';
import '../data/models/ride_model.dart';
import '../data/models/ride_request_model.dart';
import '../data/services/ride_service.dart';
import '../data/services/auth_service.dart';
import '../data/services/driver_service.dart';
import 'driver_controller.dart'; // Add this import

class RideController extends GetxController {
  final RideService _rideService = Get.find<RideService>();
  final AuthService _authService = Get.find<AuthService>();
  final DriverService _driverService = Get.find<DriverService>();

  final Rx<RideModel?> activeRide = Rx<RideModel?>(null);
  final RxBool isLoading = false.obs;

  StreamSubscription? _requestsSubscription;
  StreamSubscription? _rideSubscription;

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
     // This logic should ideally be in the View or triggered via a reactive variable
     // For now we will use a global event or similar mechanism. 
     // Let's us an RxVariable for "incomingRequest"
     // But simpler: just emit an event.
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
      Get.toNamed('/active-ride');
      
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible d\'accepter la course: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _listenToActiveRide(String rideId) {
    activeRide.bindStream(_rideService.listenToRide(rideId));
  }

  Future<void> updateStatus(RideStatus status) async {
    if (activeRide.value == null) return;
    
    try {
      isLoading.value = true;
      await _rideService.updateRideStatus(activeRide.value!.id, status);
      
      if (status == RideStatus.completed) {
         Get.offAllNamed('/home');
         activeRide.value = null;
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
