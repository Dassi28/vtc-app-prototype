import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../config/theme.dart';
import '../../controllers/driver_controller.dart';
import '../../controllers/ride_controller.dart';
import '../../controllers/auth_controller.dart';
import 'widgets/availability_toggle.dart';
import 'widgets/ride_request_dialog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final driverController = Get.put(DriverController());
    final rideController = Get.put(RideController());
    final incomingRequestController = Get.put(IncomingRequestController());
    final authController = Get.find<AuthController>();

    // Listen to incoming requests to show dialog
    ever(incomingRequestController.currentRequest, (request) {
        if (request != null) {
            Get.dialog(
                RideRequestDialog(
                    requestData: request,
                    onAccept: () {
                         Get.back(); // close dialog
                         // Important: Pass ID
                         // We assume request has 'id' and 'ride_id'
                         rideController.acceptRide(request['id'], request['ride_id']);
                         incomingRequestController.clear();
                    },
                    onDecline: () {
                        Get.back();
                        incomingRequestController.clear();
                    },
                ),
                barrierDismissible: false,
            );
        }
    });

    return Scaffold(
      body: Stack(
        children: [
          // MAP
          Obx(() {
            final location = driverController.currentLocation.value;
            return FlutterMap(
                options: MapOptions(
                  initialCenter: location ?? const LatLng(3.8480, 11.5021), // Yaoundé
                  initialZoom: 15.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.yango_driver',
                  ),
                  if (location != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: location,
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.directions_car, color: AppTheme.primaryColor, size: 40),
                        ),
                      ],
                    ),
                ],
            );
          }),

          // Header (Menu + Earnings)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Semantics(
                    label: 'Menu',
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.menu, color: Colors.black),
                        onPressed: () {
                           Get.bottomSheet(_buildMenu(authController));
                        },
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    child: const Text(
                      '0 FCFA', // Placeholder for daily earnings
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Toggle
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Obx(() => AvailabilityToggle(
                isAvailable: driverController.isAvailable.value,
                onChanged: (val) => driverController.toggleAvailability(val),
              )),
            ),
          ),

          // Loading Overlay
          Obx(() => rideController.isLoading.value 
              ? Container(color: Colors.black45, child: const Center(child: CircularProgressIndicator()))
              : const SizedBox.shrink()
          ),
        ],
      ),
    );
  }

  Widget _buildMenu(AuthController auth) {
    return Container(
      color: Colors.white, 
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Déconnexion'),
            onTap: () async {
                await auth.signOut();
                Get.offAllNamed('/login');
            },
          )
        ],
      ),
    );
  }
}
