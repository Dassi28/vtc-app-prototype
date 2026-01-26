import 'dart:ui';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/services/location_service.dart';
import '../data/models/driver_model.dart';

class HomeController extends GetxController {
  final LocationService _locationService = Get.find<LocationService>();

  GoogleMapController? mapController;
  
  final Rx<LatLng?> currentLocation = Rx<LatLng?>(null);
  final Rx<LatLng?> pickupLocation = Rx<LatLng?>(null);
  final Rx<LatLng?> destinationLocation = Rx<LatLng?>(null);
  
  final RxString pickupAddress = ''.obs;
  final RxString destinationAddress = ''.obs;
  
  final RxSet<Marker> markers = <Marker>{}.obs;
  final RxSet<Polyline> polylines = <Polyline>{}.obs;
  
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
      _animateToLocation(currentLocation.value!);
    }
    isLoading.value = false;
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (currentLocation.value != null) {
      _animateToLocation(currentLocation.value!);
    }
  }

  void _animateToLocation(LatLng location) {
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: location, zoom: 15),
      ),
    );
  }

  void _updateMarkers() {
    final newMarkers = <Marker>{};
    
    if (pickupLocation.value != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: pickupLocation.value!,
          infoWindow: InfoWindow(title: 'Départ', snippet: pickupAddress.value),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    }
    
    if (destinationLocation.value != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: destinationLocation.value!,
          infoWindow: InfoWindow(title: 'Destination', snippet: destinationAddress.value),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
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
    
    final bounds = LatLngBounds(
      southwest: LatLng(
        pickupLocation.value!.latitude < destinationLocation.value!.latitude
            ? pickupLocation.value!.latitude
            : destinationLocation.value!.latitude,
        pickupLocation.value!.longitude < destinationLocation.value!.longitude
            ? pickupLocation.value!.longitude
            : destinationLocation.value!.longitude,
      ),
      northeast: LatLng(
        pickupLocation.value!.latitude > destinationLocation.value!.latitude
            ? pickupLocation.value!.latitude
            : destinationLocation.value!.latitude,
        pickupLocation.value!.longitude > destinationLocation.value!.longitude
            ? pickupLocation.value!.longitude
            : destinationLocation.value!.longitude,
      ),
    );
    
    mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  void _calculateRoute() {
    if (pickupLocation.value == null || destinationLocation.value == null) return;
    
    // Calculate distance
    estimatedDistance.value = _locationService.calculateDistance(
      pickupLocation.value!,
      destinationLocation.value!,
    );
    
    // Draw a simple line (for real app, use Directions API)
    polylines.value = {
      Polyline(
        polylineId: const PolylineId('route'),
        points: [pickupLocation.value!, destinationLocation.value!],
        color: const Color(0xFF00B14F),
        width: 5,
      ),
    };
    
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
