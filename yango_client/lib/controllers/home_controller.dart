import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../data/data.dart';
import '../data/services/location_service.dart';
import '../data/models/driver_model.dart';
import '../core/utils.dart';


class HomeController extends GetxController {
  final LocationService _locationService = Get.find<LocationService>();

  final MapController mapController = MapController();
  
  final Rx<LatLng?> currentLocation = Rx<LatLng?>(null);
  final Rx<LatLng?> pickupLocation = Rx<LatLng?>(null);
  final Rx<LatLng?> destinationLocation = Rx<LatLng?>(null);
  
  final RxString pickupAddress = ''.obs;
  final RxString destinationAddress = ''.obs;
  
  final RxList<Marker> markers = <Marker>[].obs;
  final RxList<Polyline> polylines = <Polyline>[].obs;
  
  final RxBool isLoading = false.obs;
  final Rx<VehicleType> selectedVehicleType = VehicleType.standard.obs;
  final RxDouble estimatedDistance = 0.0.obs;
  final RxDouble estimatedPrice = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _initCurrentLocation();
  }

  Future<void> _initCurrentLocation() async {
    isLoading.value = true;
    final position = await _locationService.getCurrentPosition();
    if (position != null) {
      currentLocation.value = LatLng(position.latitude, position.longitude);
      pickupLocation.value = currentLocation.value;
      
      // Get address for current location
      final address = await _locationService.getAddressFromLatLng(
        position.latitude,
        position.longitude,
      );
      if (address != null) {
        pickupAddress.value = address;
      }
      
      _updateMarkers();
      // Need to wait for map to differ rendering before moving
      // Or just set initial center in view
    }
    isLoading.value = false;
  }

  void _moveToLocation(LatLng location) {
    mapController.move(location, 15.0);
  }

  void _updateMarkers() {
    final newMarkers = <Marker>[];
    
    if (pickupLocation.value != null) {
      newMarkers.add(
        Marker(
          point: pickupLocation.value!,
          width: 40,
          height: 40,
          child: const Icon(Icons.location_on, color: Colors.green, size: 40),
        ),
      );
    }
    
    if (destinationLocation.value != null) {
      newMarkers.add(
        Marker(
          point: destinationLocation.value!,
          width: 40,
          height: 40,
          child: const Icon(Icons.location_on, color: Colors.red, size: 40),
        ),
      );
    }
    
    markers.value = newMarkers;
  }

  Future<void> setPickupLocation(LatLng location) async {
    pickupLocation.value = location;
    final address = await _locationService.getAddressFromLatLng(
      location.latitude,
      location.longitude,
    );
    if (address != null) {
      pickupAddress.value = address;
    }
    _updateMarkers();
    _calculateRoute();
  }

  Future<void> setDestinationLocation(LatLng location) async {
    destinationLocation.value = location;
    final address = await _locationService.getAddressFromLatLng(
      location.latitude,
      location.longitude,
    );
    if (address != null) {
      destinationAddress.value = address;
    }
    _updateMarkers();
    _calculateRoute();
  }

  Future<void> setDestinationFromAddress(String address) async {
    isLoading.value = true;
    final location = await _locationService.getLatLngFromAddress(address);
    if (location != null) {
      destinationLocation.value = location;
      destinationAddress.value = address;
      _updateMarkers();
      _calculateRoute();
      
      // Zoom to show both markers
      if (pickupLocation.value != null) {
        _fitBounds();
      }
    }
    isLoading.value = false;
  }

  void _fitBounds() {
    if (pickupLocation.value == null || destinationLocation.value == null) return;
    
    final bounds = LatLngBounds(pickupLocation.value!, destinationLocation.value!);
    mapController.fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)));
  }

  void _calculateRoute() {
    if (pickupLocation.value == null || destinationLocation.value == null) return;
    
    // Calculate distance
    estimatedDistance.value = _locationService.calculateDistance(
      pickupLocation.value!,
      destinationLocation.value!,
    );
    
    // Draw a simple line 
    polylines.value = [
      Polyline(
        points: [pickupLocation.value!, destinationLocation.value!],
        color: const Color(0xFF00B14F),
        strokeWidth: 5,
      ),
    ];
    
    _calculatePrice();
  }

  void _calculatePrice() {
    // Simple price calculation - in real app, use RideService
    const basePrices = {
      VehicleType.moto: 100.0,
      VehicleType.standard: 200.0,
      VehicleType.comfort: 350.0,
      VehicleType.van: 500.0,
    };
    
    const pricePerKm = {
      VehicleType.moto: 150.0,
      VehicleType.standard: 250.0,
      VehicleType.comfort: 400.0,
      VehicleType.van: 600.0,
    };
    
    final base = basePrices[selectedVehicleType.value] ?? 200.0;
    final perKm = pricePerKm[selectedVehicleType.value] ?? 250.0;
    estimatedPrice.value = base + (perKm * estimatedDistance.value);
  }

  void selectVehicleType(VehicleType type) {
    selectedVehicleType.value = type;
    _calculatePrice();
  }

  void clearDestination() {
    destinationLocation.value = null;
    destinationAddress.value = '';
    polylines.clear();
    estimatedDistance.value = 0.0;
    estimatedPrice.value = 0.0;
    _updateMarkers();
  }
}
