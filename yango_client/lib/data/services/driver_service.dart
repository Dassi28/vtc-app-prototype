import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DriverService extends GetxService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> updateLocation(String driverId, double lat, double lng) async {
    await _supabase.from('drivers').update({
      'current_latitude': lat,
      'current_longitude': lng,
      'last_location_update': DateTime.now().toIso8601String(),
    }).eq('id', driverId);
  }

  Future<void> toggleAvailability(String driverId, bool isAvailable) async {
    await _supabase.from('drivers').update({
      'is_available': isAvailable,
    }).eq('id', driverId);
  }

  // Find requests targeted at this driver
  Stream<List<Map<String, dynamic>>> listenToMyRequests(String driverId) {
    return _supabase
        .from('ride_requests')
        .stream(primaryKey: ['id'])
        .map((event) => event.where((e) => e['driver_id'] == driverId && e['status'] == 'pending').toList());
  }
}
