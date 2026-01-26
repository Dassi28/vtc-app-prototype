import 'dart:async';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ride_model.dart';
import '../models/driver_model.dart';

class RideService extends GetxService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Price per km for each vehicle type (in FCFA)
  static const Map<VehicleType, double> basePrices = {
    VehicleType.moto: 100,
    VehicleType.standard: 200,
    VehicleType.comfort: 350,
    VehicleType.van: 500,
  };

  static const Map<VehicleType, double> pricePerKm = {
    VehicleType.moto: 150,
    VehicleType.standard: 250,
    VehicleType.comfort: 400,
    VehicleType.van: 600,
  };

  double calculatePrice(VehicleType vehicleType, double distanceKm) {
    final base = basePrices[vehicleType] ?? 200;
    final perKm = pricePerKm[vehicleType] ?? 250;
    return base + (perKm * distanceKm);
  }

  Future<RideModel> createRide({
    required String clientId,
    required double pickupLatitude,
    required double pickupLongitude,
    required String pickupAddress,
    required double destinationLatitude,
    required double destinationLongitude,
    required String destinationAddress,
    required VehicleType vehicleType,
    required double distanceKm,
    int? durationMinutes,
  }) async {
    final basePrice = calculatePrice(vehicleType, distanceKm);
    final totalPrice = basePrice; // Could add surge pricing here

    final rideData = {
      'client_id': clientId,
      'pickup_latitude': pickupLatitude,
      'pickup_longitude': pickupLongitude,
      'pickup_address': pickupAddress,
      'destination_latitude': destinationLatitude,
      'destination_longitude': destinationLongitude,
      'destination_address': destinationAddress,
      'vehicle_type': vehicleType.name,
      'distance_km': distanceKm,
      'duration_minutes': durationMinutes,
      'base_price': basePrice,
      'total_price': totalPrice,
      'status': 'pending',
      'payment_method': 'cash',
      'payment_status': 'pending',
    };

    final response = await _supabase
        .from('rides')
        .insert(rideData)
        .select()
        .single();

    return RideModel.fromJson(response);
  }

  Future<RideModel?> getRide(String rideId) async {
    final response = await _supabase
        .from('rides')
        .select('*, drivers(*)')
        .eq('id', rideId)
        .maybeSingle();

    if (response == null) return null;
    return RideModel.fromJson(response);
  }

  Future<List<RideModel>> getClientRides(String clientId) async {
    final response = await _supabase
        .from('rides')
        .select('*, drivers(*)')
        .eq('client_id', clientId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => RideModel.fromJson(json))
        .toList();
  }

  Future<void> cancelRide(String rideId, {String? reason}) async {
    await _supabase.from('rides').update({
      'status': 'cancelled',
      'cancelled_at': DateTime.now().toIso8601String(),
      'cancellation_reason': reason,
    }).eq('id', rideId);
  }

  Future<void> rateDriver(String rideId, int rating, {String? comment}) async {
    await _supabase.from('rides').update({
      'driver_rating': rating,
      'driver_comment': comment,
    }).eq('id', rideId);
  }

  Stream<RideModel?> listenToRide(String rideId) {
    return _supabase
        .from('rides')
        .stream(primaryKey: ['id'])
        .eq('id', rideId)
        .map((data) {
          if (data.isEmpty) return null;
          return RideModel.fromJson(data.first);
        });
  }

  Future<RideModel?> getActiveRide(String clientId) async {
    final response = await _supabase
        .from('rides')
        .select('*, drivers(*)')
        .eq('client_id', clientId)
        .inFilter('status', ['pending', 'accepted', 'driver_arriving', 'in_progress'])
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) return null;
    return RideModel.fromJson(response);
  }
}
