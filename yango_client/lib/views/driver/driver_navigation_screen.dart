import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../config/theme.dart';
import '../../controllers/driver_ride_controller.dart';
import '../../controllers/driver_controller.dart';
import '../../data/models/ride_model.dart';
import '../../core/utils.dart'; // Ensure utils exists or remove formatCurrency

class DriverNavigationScreen extends StatelessWidget {
  const DriverNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rideController = Get.find<DriverRideController>();
    final driverController = Get.find<DriverController>();

    return Scaffold(
      body: Obx(() {
        final ride = rideController.activeRide.value;
        if (ride == null) {
          return const Center(child: Text('Aucune course en cours'));
        }

        final driverLoc = driverController.currentLocation.value;
        final pickup = LatLng(ride.pickupLatitude, ride.pickupLongitude);
        final destination = LatLng(ride.destinationLatitude, ride.destinationLongitude);

        // Determine target based on status
        final isPickingUp = ride.status == RideStatus.accepted || ride.status == RideStatus.driverArriving;
        final targetLoc = isPickingUp ? pickup : destination;
        final targetLabel = isPickingUp ? 'Client' : 'Destination';

        return Stack(
          children: [
            // Map
            FlutterMap(
              options: MapOptions(
                initialCenter: driverLoc ?? pickup,
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                   urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
                   subdomains: const ['a', 'b', 'c'],
                ),
                PolylineLayer(
                  polylines: [
                    if (driverLoc != null)
                      Polyline(
                        points: [driverLoc, targetLoc],
                        strokeWidth: 4,
                        color: Colors.blueAccent,
                      ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    // Pickup
                    Marker(
                      point: pickup,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.person_pin_circle, color: Colors.green, size: 40),
                    ),
                    // Destination
                    Marker(
                      point: destination,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.flag, color: Colors.red, size: 40),
                    ),
                    // Driver
                    if (driverLoc != null)
                      Marker(
                         point: driverLoc,
                         width: 40,
                         height: 40,
                         child: const Icon(Icons.navigation, color: Colors.white, size: 40),
                      ),
                  ],
                ),
              ],
            ),

            // Top Info Panel
            SafeArea(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black26)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Direction : $targetLabel',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isPickingUp ? ride.pickupAddress : ride.destinationAddress,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Action Panel
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Client Info
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: AppTheme.primaryColor,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(
                          ride.client?.fullName ?? 'Client',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        )),
                        Container(
                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                           decoration: BoxDecoration(
                             color: Colors.green.withOpacity(0.1),
                             borderRadius: BorderRadius.circular(20) 
                           ),
                           child: Text(
                             '${ride.totalPrice.toStringAsFixed(0)} FCFA',
                             style: const TextStyle(
                               color: Colors.green, 
                               fontWeight: FontWeight.bold
                             ),
                           ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Main Action Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: rideController.isLoading.value ? null : () {
                           _handleStatusUpdate(ride, rideController);
                        },
                        style: ElevatedButton.styleFrom(
                           backgroundColor: _getActionColor(ride.status),
                           padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(_getActionText(ride.status)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Color _getActionColor(RideStatus status) {
    switch (status) {
      case RideStatus.accepted: return Colors.blue; // I have arrived
      case RideStatus.driverArriving: return AppTheme.primaryColor ; // Start trip
      case RideStatus.inProgress: return Colors.red; // Finish trip
      default: return Colors.grey;
    }
  }

  String _getActionText(RideStatus status) {
    switch (status) {
      case RideStatus.accepted: return 'JE SUIS ARRIVÉ';
      case RideStatus.driverArriving: return 'COMMENCER LA COURSE';
      case RideStatus.inProgress: return 'TERMINER LA COURSE';
      default: return '...';
    }
  }

  void _handleStatusUpdate(RideModel ride, DriverRideController controller) {
    switch (ride.status) {
      case RideStatus.accepted:
        controller.updateStatus(RideStatus.driverArriving);
        break;
      case RideStatus.driverArriving:
        controller.updateStatus(RideStatus.inProgress);
        break;
      case RideStatus.inProgress:
        controller.updateStatus(RideStatus.completed);
        break;
      default:
        break;
    }
  }
}
