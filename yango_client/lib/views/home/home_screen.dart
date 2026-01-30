import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../config/theme.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/ride_controller.dart';
import '../../controllers/auth_controller.dart';
import 'widgets/location_search_widget.dart';
import 'widgets/vehicle_selector_widget.dart';
import 'widgets/price_estimate_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final rideController = Get.find<RideController>();
    final authController = Get.find<AuthController>();

    // Yaoundé default
    final defaultCenter = LatLng(3.8480, 11.5021);

    return Scaffold(
      body: Stack(
        children: [
          // Flutter Map (OSM)
          Obx(() => FlutterMap(
                mapController: homeController.mapController,
                options: MapOptions(
                  initialCenter: homeController.currentLocation.value ?? defaultCenter,
                  initialZoom: 15.0,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  PolylineLayer(
                    polylines: homeController.polylines.toList(),
                  ),
                  MarkerLayer(
                    markers: homeController.markers.toList(),
                  ),
                  // Available Drivers
                  MarkerLayer(
                    markers: homeController.driverMarkers.toList(),
                  ),
                  // Current location marker (blue dot)
                  if (homeController.currentLocation.value != null)
                   MarkerLayer(
                     markers: [
                       Marker(
                         point: homeController.currentLocation.value!,
                         width: 20,
                         height: 20,
                         child: Container(
                           decoration: BoxDecoration(
                             color: Colors.blue,
                             shape: BoxShape.circle,
                             border: Border.all(color: Colors.white, width: 2),
                             boxShadow: [
                               BoxShadow(color: Colors.black26, blurRadius: 4),
                             ],
                           ),
                         ),
                       ),
                     ],
                   ),
                ],
              )),

          // Top bar with menu and profile
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Menu button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        _showMenuSheet(context, authController);
                      },
                    ),
                  ),
                  const Spacer(),
                  // My location button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.my_location),
                      onPressed: () async {
                        if (homeController.currentLocation.value != null) {
                           homeController.mapController.move(
                              homeController.currentLocation.value!,
                              15.0,
                           );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom sheet for destination
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.15,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: _buildBottomSheetContent(
                    context,
                    homeController,
                    rideController,
                  ),
                ),
              );
            },
          ),

          // Loading overlay
          Obx(() => homeController.isLoading.value
              ? Container(
                  color: Colors.black26,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildBottomSheetContent(
    BuildContext context,
    HomeController homeController,
    RideController rideController,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Where to button
          Obx(() => homeController.destinationLocation.value == null
              ? GestureDetector(
                  onTap: () {
                    _showLocationSearchSheet(context, homeController);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.search,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Où allez-vous ?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : _buildRideRequestSection(context, homeController, rideController)),
        ],
      ),
    );
  }

  Widget _buildRideRequestSection(
    BuildContext context,
    HomeController homeController,
    RideController rideController,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Locations summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() => Text(
                          homeController.pickupAddress.value,
                          style: const TextStyle(fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(left: 5),
                child: DottedLine(),
              ),
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() => Text(
                          homeController.destinationAddress.value,
                          style: const TextStyle(fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: homeController.clearDestination,
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Vehicle selector
        VehicleSelectorWidget(
          selectedType: homeController.selectedVehicleType,
          onSelect: homeController.selectVehicleType,
          distance: homeController.estimatedDistance,
        ),

        const SizedBox(height: 16),

        // Price estimate
        PriceEstimateWidget(
          price: homeController.estimatedPrice,
          distance: homeController.estimatedDistance,
        ),

        const SizedBox(height: 20),

        // Order button
        Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: rideController.isLoading.value
                    ? null
                    : () async {
                        final success = await rideController.createRide(
                          pickup: homeController.pickupLocation.value!,
                          pickupAddress: homeController.pickupAddress.value,
                          destination: homeController.destinationLocation.value!,
                          destinationAddress: homeController.destinationAddress.value,
                          vehicleType: homeController.selectedVehicleType.value,
                          distanceKm: homeController.estimatedDistance.value,
                        );
                        if (success) {
                          Get.toNamed('/ride-tracking');
                        }
                      },
                child: rideController.isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Commander'),
              ),
            )),
      ],
    );
  }

  void _showLocationSearchSheet(BuildContext context, HomeController homeController) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LocationSearchWidget(
        onDestinationSelected: (address) {
          Navigator.pop(context);
          homeController.setDestinationFromAddress(address);
        },
      ),
    );
  }

  void _showMenuSheet(BuildContext context, AuthController authController) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Profile header
            Obx(() => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryColor,
                    child: Text(
                      authController.userProfile?.fullName.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(authController.userProfile?.fullName ?? 'Utilisateur'),
                  subtitle: Text(authController.userProfile?.phone ?? ''),
                )),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Historique des courses'),
              onTap: () {
                Navigator.pop(context);
                Get.toNamed('/ride-history');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Paramètres'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Aide'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                await authController.signOut();
                Get.offAllNamed('/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DottedLine extends StatelessWidget {
  const DottedLine({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(4, (index) => Container(
          width: 2,
          height: 3,
          color: Colors.grey[400],
        )),
      ),
    );
  }
}
