enum RideStatus {
  pending,
  accepted,
  driverArriving,
  inProgress,
  completed,
  cancelled
}

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

class RideModel {
  final String id;
  final String clientId;
  final String? driverId;
  
  // Locations
  final double pickupLatitude;
  final double pickupLongitude;
  final String pickupAddress;
  final double destinationLatitude;
  final double destinationLongitude;
  final String destinationAddress;
  
  final RideStatus status;
  final double totalPrice;
  final double distanceKm;
  
  // Client info (joined)
  final String? clientName;
  final String? clientPhone;

  RideModel({
    required this.id,
    required this.clientId,
    this.driverId,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.pickupAddress,
    required this.destinationLatitude,
    required this.destinationLongitude,
    required this.destinationAddress,
    required this.status,
    required this.totalPrice,
    required this.distanceKm,
    this.clientName,
    this.clientPhone,
  });

  factory RideModel.fromJson(Map<String, dynamic> json) {
    return RideModel(
      id: json['id'],
      clientId: json['client_id'],
      driverId: json['driver_id'],
      pickupLatitude: (json['pickup_latitude'] as num).toDouble(),
      pickupLongitude: (json['pickup_longitude'] as num).toDouble(),
      pickupAddress: json['pickup_address'],
      destinationLatitude: (json['destination_latitude'] as num).toDouble(),
      destinationLongitude: (json['destination_longitude'] as num).toDouble(),
      destinationAddress: json['destination_address'],
      status: _parseStatus(json['status']),
      totalPrice: (json['total_price'] as num).toDouble(),
      distanceKm: (json['distance_km'] as num).toDouble(),
      clientName: json['clients']?['users']?['full_name'],
      clientPhone: json['clients']?['users']?['phone'],
    );
  }

  static RideStatus _parseStatus(String status) {
    switch (status) {
      case 'pending': return RideStatus.pending;
      case 'accepted': return RideStatus.accepted;
      case 'driver_arriving': return RideStatus.driverArriving;
      case 'in_progress': return RideStatus.inProgress;
      case 'completed': return RideStatus.completed;
      case 'cancelled': return RideStatus.cancelled;
      default: return RideStatus.pending;
    }
  }

  String get statusString {
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
