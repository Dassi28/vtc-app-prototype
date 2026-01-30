import 'package:flutter/material.dart';
import '../../../../config/theme.dart';

class RideRequestDialog extends StatelessWidget {
  final Map<String, dynamic> requestData;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const RideRequestDialog({
    super.key,
    required this.requestData,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    // Parse data safely
    final price = (requestData['total_price'] as num?)?.toDouble() ?? 0.0;
    final distance = (requestData['distance_km'] as num?)?.toDouble() ?? 0.0;
    final pickup = requestData['pickup_address'] ?? 'Adresse inconnue';
    final dest = requestData['destination_address'] ?? 'Destination inconnue';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Nouvelle Course !',
              style: TextStyle(
                fontSize: 22, 
                fontWeight: FontWeight.bold, 
                color: AppTheme.primaryColor
              ),
            ),
            const SizedBox(height: 20),
            
            // Price & Distance row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '${price.toStringAsFixed(0)} FCFA',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                    ),
                    const Text('Prix', style: TextStyle(color: Colors.grey)),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '${distance.toStringAsFixed(1)} km',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const Text('Distance', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Addresses
            Row(
              children: [
                const Icon(Icons.my_location, color: Colors.green),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(pickup, style: const TextStyle(fontSize: 16)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(dest, style: const TextStyle(fontSize: 16)),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDecline,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.grey),
                    ),
                    child: const Text('REFUSER', style: TextStyle(color: Colors.grey)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                     style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('ACCEPTER'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
