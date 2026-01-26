import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../config/theme.dart';
import '../../controllers/ride_controller.dart';
import '../../data/models/ride_model.dart';
import '../../core/utils.dart';

class RideTrackingScreen extends StatelessWidget {
  const RideTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rideController = Get.find<RideController>();

    return Scaffold(
      body: Obx(() {
        final ride = rideController.currentRide.value;
        if (ride == null) {
          return const Center(
            child: Text('Aucune course en cours'),
          );
        }

        return Stack(
          children: [
            // Map
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(ride.pickupLatitude, ride.pickupLongitude),
                zoom: 14,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('pickup'),
                  position: LatLng(ride.pickupLatitude, ride.pickupLongitude),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen,
                  ),
                ),
                Marker(
                  markerId: const MarkerId('destination'),
                  position: LatLng(
                    ride.destinationLatitude,
                    ride.destinationLongitude,
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed,
                  ),
                ),
                if (ride.driver?.currentLatitude != null &&
                    ride.driver?.currentLongitude != null)
                  Marker(
                    markerId: const MarkerId('driver'),
                    position: LatLng(
                      ride.driver!.currentLatitude!,
                      ride.driver!.currentLongitude!,
                    ),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueBlue,
                    ),
                  ),
              },
              polylines: {
                Polyline(
                  polylineId: const PolylineId('route'),
                  points: [
                    LatLng(ride.pickupLatitude, ride.pickupLongitude),
                    LatLng(ride.destinationLatitude, ride.destinationLongitude),
                  ],
                  color: AppTheme.primaryColor,
                  width: 4,
                ),
              },
            ),

            // Back button
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Get.back(),
                  ),
                ),
              ),
            ),

            // Bottom sheet with ride info
            DraggableScrollableSheet(
              initialChildSize: 0.35,
              minChildSize: 0.2,
              maxChildSize: 0.6,
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
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: _buildRideInfo(context, ride, rideController),
                  ),
                );
              },
            ),
          ],
        );
      }),
    );
  }

  Widget _buildRideInfo(
    BuildContext context,
    RideModel ride,
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

          // Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(ride.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              ride.statusText,
              style: TextStyle(
                color: _getStatusColor(ride.status),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Driver info (if assigned)
          if (ride.driver != null) ...[
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(
                    ride.driver!.fullName?.substring(0, 1).toUpperCase() ?? 'D',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ride.driver!.fullName ?? 'Chauffeur',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        ride.driver!.vehicleInfo,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(ride.driver!.rating.toStringAsFixed(1)),
                        ],
                      ),
                    ],
                  ),
                ),
                // Call button
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.phone, color: Colors.white),
                    onPressed: () {
                      // TODO: Implement call
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
          ],

          // Locations
          Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 30,
                    color: Colors.grey[300],
                  ),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ride.pickupAddress,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      ride.destinationAddress,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Prix total',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                AppUtils.formatCurrency(ride.totalPrice),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Cancel button (only for pending rides)
          if (ride.status == RideStatus.pending)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  _showCancelDialog(context, rideController);
                },
                child: const Text('Annuler la course'),
              ),
            ),

          // Rating (for completed rides)
          if (ride.status == RideStatus.completed && ride.driverRating == null)
            _buildRatingSection(context, rideController),
        ],
      ),
    );
  }

  Widget _buildRatingSection(
    BuildContext context,
    RideController rideController,
  ) {
    final selectedRating = 0.obs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notez votre chauffeur',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < selectedRating.value
                        ? Icons.star
                        : Icons.star_border,
                    size: 40,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    selectedRating.value = index + 1;
                  },
                );
              }),
            )),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              if (selectedRating.value > 0) {
                await rideController.rateDriver(selectedRating.value);
                Get.offAllNamed('/home');
              }
            },
            child: const Text('Envoyer'),
          ),
        ),
      ],
    );
  }

  void _showCancelDialog(
    BuildContext context,
    RideController rideController,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la course ?'),
        content: const Text(
          'Êtes-vous sûr de vouloir annuler cette course ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await rideController.cancelRide();
              Get.offAllNamed('/home');
            },
            child: const Text(
              'Oui, annuler',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(RideStatus status) {
    switch (status) {
      case RideStatus.pending:
        return Colors.orange;
      case RideStatus.accepted:
      case RideStatus.driverArriving:
        return Colors.blue;
      case RideStatus.inProgress:
        return AppTheme.primaryColor;
      case RideStatus.completed:
        return Colors.green;
      case RideStatus.cancelled:
        return Colors.red;
    }
  }
}
