import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../config/theme.dart';
import '../../controllers/ride_controller.dart';
import '../../data/models/ride_model.dart';

class ActiveRideScreen extends StatelessWidget {
  const ActiveRideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rideController = Get.find<RideController>();

    return Scaffold(
      body: Obx(() {
        final ride = rideController.activeRide.value;
        if (ride == null) {
           return const Center(child: CircularProgressIndicator());
        }

        final pickup = LatLng(ride.pickupLatitude, ride.pickupLongitude);
        final dest = LatLng(ride.destinationLatitude, ride.destinationLongitude);

        return Column(
          children: [
            // Map Area
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: pickup, 
                  initialZoom: 14.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.yango_driver',
                  ),
                  PolylineLayer(
                     polylines: [
                       Polyline(points: [pickup, dest], color: AppTheme.primaryColor, strokeWidth: 4),
                     ],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                         point: pickup,
                         child: const Icon(Icons.location_on, color: Colors.green),
                      ),
                      Marker(
                         point: dest,
                         child: const Icon(Icons.location_on, color: Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Info Panel
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Client info
                  Row(
                    children: [
                      const CircleAvatar(radius: 24, child: Icon(Icons.person)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ride.clientName ?? 'Client', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            const Text('Paiement espèces', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {}, // Call
                        icon: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.phone, color: Colors.white)),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  
                  // Address
                  Row(
                    children: [
                       const Icon(Icons.navigation, color: AppTheme.primaryColor),
                       const SizedBox(width: 12),
                       Expanded(child: Text(
                         ride.status == RideStatus.accepted || ride.status == RideStatus.driverArriving 
                          ? ride.pickupAddress 
                          : ride.destinationAddress,
                         style: const TextStyle(fontSize: 16),
                       )),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Action Button
                  ElevatedButton(
                    onPressed: () {
                        if (ride.status == RideStatus.accepted) {
                            rideController.updateStatus(RideStatus.driverArriving);
                        } else if (ride.status == RideStatus.driverArriving) {
                            rideController.updateStatus(RideStatus.inProgress);
                        } else if (ride.status == RideStatus.inProgress) {
                            rideController.updateStatus(RideStatus.completed);
                        }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getButtonColor(ride.status),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    child: Text(_getButtonText(ride.status)),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  String _getButtonText(RideStatus status) {
    switch (status) {
      case RideStatus.accepted: return 'J\'ARRIVE';
      case RideStatus.driverArriving: return 'DÉMARRER LA COURSE';
      case RideStatus.inProgress: return 'TERMINER LA COURSE';
      default: return '...';
    }
  }

  Color _getButtonColor(RideStatus status) {
     if (status == RideStatus.inProgress) return Colors.red;
     return AppTheme.primaryColor;
  }
}
