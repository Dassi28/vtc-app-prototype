import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ride_model.dart';


class RideService extends GetxService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> acceptRideRequest(String requestId, String rideId, String driverId) async {
    // 1. Transaction-like update:
    // Update ride_requests status to 'accepted'
    // Update rides table: driver_id, status='accepted', accepted_at
    // Update driver availability to false

    // RPC or batch updates would be better, but doing sequential for prototype
    
    // a. Update request
    await _supabase.from('ride_requests').update({
      'status': 'accepted',
      'responded_at': DateTime.now().toIso8601String(),
    }).eq('id', requestId);

    // b. Assign driver to ride
    await _supabase.from('rides').update({
      'driver_id': driverId,
      'status': 'accepted',
      'accepted_at': DateTime.now().toIso8601String(),
    }).eq('id', rideId);

    // c. Make driver busy
    await _supabase.from('drivers').update({
      'is_available': false,
    }).eq('id', driverId);
  }

  Future<void> updateRideStatus(String rideId, RideStatus status) async {
    final updates = {
      'status': _statusToString(status),
    };

    if (status == RideStatus.inProgress) {
      updates['started_at'] = DateTime.now().toIso8601String();
    } else if (status == RideStatus.completed) {
      updates['completed_at'] = DateTime.now().toIso8601String();
    }

    await _supabase.from('rides').update(updates).eq('id', rideId);
    
    // If completed, make driver available again
    if (status == RideStatus.completed) {
      final userId = _supabase.auth.currentUser!.id;
       await _supabase.from('drivers').update({
        'is_available': true,
      }).eq('id', userId);
    }
  }

  // Get active ride for this driver
  Future<RideModel?> getActiveRide(String driverId) async {
    final response = await _supabase
        .from('rides')
        .select('*, clients(*, users(*))') // Fetch client info
        .eq('driver_id', driverId)
        .inFilter('status', ['accepted', 'driver_arriving', 'in_progress'])
        .maybeSingle();

    if (response == null) return null;
    return RideModel.fromJson(response);
  }
  
  Stream<RideModel?> listenToRide(String rideId) {
    return _supabase.from('rides').stream(primaryKey: ['id']).eq('id', rideId).map((event) {
      if (event.isEmpty) return null;
      return RideModel.fromJson(event.first);
    });
  }

  String _statusToString(RideStatus status) {
    switch (status) {
      case RideStatus.pending: return 'pending';
      case RideStatus.accepted: return 'accepted';
      case RideStatus.driverArriving: return 'driver_arriving';
      case RideStatus.inProgress: return 'in_progress';
      case RideStatus.completed: return 'completed';
      case RideStatus.cancelled: return 'cancelled';
    }
  }
}
