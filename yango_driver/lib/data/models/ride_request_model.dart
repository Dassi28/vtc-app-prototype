// Enum is now imported from ride_model.dart if needed, or handled as string in JSON
// Avoiding duplicate definition.


class RideRequestModel {
  final String id;
  final String rideId;
  final double pickupLat;
  final double pickupLng;
  final String pickupAddress;
  final double destLat;
  final double destLng;
  final String destAddress;
  final double price;
  final double distanceKm;
  final DateTime expiresAt;

  RideRequestModel({
    required this.id,
    required this.rideId,
    required this.pickupLat,
    required this.pickupLng,
    required this.pickupAddress,
    required this.destLat,
    required this.destLng,
    required this.destAddress,
    required this.price,
    required this.distanceKm,
    required this.expiresAt,
  });

  factory RideRequestModel.fromJson(Map<String, dynamic> json, Map<String, dynamic> rideJson) {
    return RideRequestModel(
      id: json['id'],
      rideId: rideJson['id'],
      pickupLat: (rideJson['pickup_latitude'] as num).toDouble(),
      pickupLng: (rideJson['pickup_longitude'] as num).toDouble(),
      pickupAddress: rideJson['pickup_address'],
      destLat: (rideJson['destination_latitude'] as num).toDouble(),
      destLng: (rideJson['destination_longitude'] as num).toDouble(),
      destAddress: rideJson['destination_address'],
      price: (rideJson['total_price'] as num).toDouble(),
      distanceKm: (rideJson['distance_km'] as num).toDouble(),
      expiresAt: DateTime.parse(json['expires_at']),
    );
  }
}
