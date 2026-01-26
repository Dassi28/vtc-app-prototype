import 'dart:async';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/models/ride_model.dart';
import '../data/models/driver_model.dart';
import '../data/services/ride_service.dart';
import '../data/services/auth_service.dart';

class RideController extends GetxController {
  final RideService _rideService = Get.find<RideService>();
  final AuthService _authService = Get.find<AuthService>();

  final Rx<RideModel?> currentRide = Rx<RideModel?>(null);
  final RxList<RideModel> rideHistory = <RideModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  
  StreamSubscription? _rideSubscription;

  @override
  void onInit() {
    super.onInit();
    _checkActiveRide();
  }

  @override
  void onClose() {
    _rideSubscription?.cancel();
    super.onClose();
  }

  Future<void> _checkActiveRide() async {
    if (_authService.currentUser == null) return;
    
    final activeRide = await _rideService.getActiveRide(_authService.currentUser!.id);
    if (activeRide != null) {
      currentRide.value = activeRide;
      _startListeningToRide(activeRide.id);
    }
  }

  Future<bool> createRide({
    required LatLng pickup,
    required String pickupAddress,
    required LatLng destination,
    required String destinationAddress,
    required VehicleType vehicleType,
    required double distanceKm,
  }) async {
    if (_authService.currentUser == null) {
      errorMessage.value = 'Vous devez être connecté pour commander une course.';
      return false;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final ride = await _rideService.createRide(
        clientId: _authService.currentUser!.id,
        pickupLatitude: pickup.latitude,
        pickupLongitude: pickup.longitude,
        pickupAddress: pickupAddress,
        destinationLatitude: destination.latitude,
        destinationLongitude: destination.longitude,
        destinationAddress: destinationAddress,
        vehicleType: vehicleType,
        distanceKm: distanceKm,
      );

      currentRide.value = ride;
      _startListeningToRide(ride.id);
      return true;
    } catch (e) {
      errorMessage.value = 'Erreur lors de la création de la course.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void _startListeningToRide(String rideId) {
    _rideSubscription?.cancel();
    _rideSubscription = _rideService.listenToRide(rideId).listen((ride) {
      if (ride != null) {
        currentRide.value = ride;
        
        // If ride is completed or cancelled, stop listening
        if (ride.status == RideStatus.completed || ride.status == RideStatus.cancelled) {
          _rideSubscription?.cancel();
        }
      }
    });
  }

  Future<void> cancelRide({String? reason}) async {
    if (currentRide.value == null) return;
    
    try {
      isLoading.value = true;
      await _rideService.cancelRide(currentRide.value!.id, reason: reason);
      currentRide.value = null;
      _rideSubscription?.cancel();
    } catch (e) {
      errorMessage.value = 'Erreur lors de l\'annulation de la course.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> rateDriver(int rating, {String? comment}) async {
    if (currentRide.value == null) return;
    
    try {
      isLoading.value = true;
      await _rideService.rateDriver(currentRide.value!.id, rating, comment: comment);
      currentRide.value = null;
    } catch (e) {
      errorMessage.value = 'Erreur lors de la notation.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadRideHistory() async {
    if (_authService.currentUser == null) return;
    
    try {
      isLoading.value = true;
      final rides = await _rideService.getClientRides(_authService.currentUser!.id);
      rideHistory.value = rides;
    } catch (e) {
      errorMessage.value = 'Erreur lors du chargement de l\'historique.';
    } finally {
      isLoading.value = false;
    }
  }

  double getEstimatedPrice(VehicleType vehicleType, double distanceKm) {
    return _rideService.calculatePrice(vehicleType, distanceKm);
  }
}
