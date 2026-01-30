import 'driver_model.dart';
import 'user_model.dart';


enum RideStatus {
  pending,
  accepted,
  driverArriving,
  inProgress,
  completed,
  cancelled
}

enum PaymentMethod { cash, mobileMoney, card }

enum PaymentStatus { pending, completed, failed }

class RideModel {
  final String id;
  final String clientId;
  final String? driverId;
  final double pickupLatitude;
  final double pickupLongitude;
  final String pickupAddress;
  final double destinationLatitude;
  final double destinationLongitude;
  final String destinationAddress;
  final RideStatus status;
  final VehicleType vehicleType;
  final double? distanceKm;
  final int? durationMinutes;
  final double basePrice;
  final double totalPrice;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final int? clientRating;
  final int? driverRating;
  final String? clientComment;
  final String? driverComment;
  final DateTime? requestedAt;
  final DateTime? acceptedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Driver info (joined from drivers table)
  final DriverModel? driver;
  // Client info (joined from users table)
  final UserModel? client;

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
    this.status = RideStatus.pending,
    required this.vehicleType,
    this.distanceKm,
    this.durationMinutes,
    required this.basePrice,
    required this.totalPrice,
    this.paymentMethod = PaymentMethod.cash,
    this.paymentStatus = PaymentStatus.pending,
    this.clientRating,
    this.driverRating,
    this.clientComment,
    this.driverComment,
    this.requestedAt,
    this.acceptedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.createdAt,
    this.updatedAt,
    this.driver,
    this.client,
  });

  factory RideModel.fromJson(Map<String, dynamic> json) {
    return RideModel(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      driverId: json['driver_id'] as String?,
      pickupLatitude: (json['pickup_latitude'] as num).toDouble(),
      pickupLongitude: (json['pickup_longitude'] as num).toDouble(),
      pickupAddress: json['pickup_address'] as String,
      destinationLatitude: (json['destination_latitude'] as num).toDouble(),
      destinationLongitude: (json['destination_longitude'] as num).toDouble(),
      destinationAddress: json['destination_address'] as String,
      status: _parseRideStatus(json['status'] as String?),
      vehicleType: VehicleType.values.firstWhere(
        (e) => e.name == json['vehicle_type'],
        orElse: () => VehicleType.standard,
      ),
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      durationMinutes: json['duration_minutes'] as int?,
      basePrice: (json['base_price'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == _snakeToCamel(json['payment_method'] as String? ?? 'cash'),
        orElse: () => PaymentMethod.cash,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == json['payment_status'],
        orElse: () => PaymentStatus.pending,
      ),
      clientRating: json['client_rating'] as int?,
      driverRating: json['driver_rating'] as int?,
      clientComment: json['client_comment'] as String?,
      driverComment: json['driver_comment'] as String?,
      requestedAt: json['requested_at'] != null
          ? DateTime.parse(json['requested_at'] as String)
          : null,
      acceptedAt: json['accepted_at'] != null
          ? DateTime.parse(json['accepted_at'] as String)
          : null,
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
          : null,
      cancellationReason: json['cancellation_reason'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      driver: json['drivers'] != null
          ? DriverModel.fromJson(json['drivers'] as Map<String, dynamic>)
          : null,
      client: json['clients'] != null // Assuming joined as 'clients' referencing users(clients) or direct users join
          ? UserModel.fromJson(json['clients'] as Map<String, dynamic>)
          : (json['client_info'] != null ? UserModel.fromJson(json['client_info']) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'client_id': clientId,
      'driver_id': driverId,
      'pickup_latitude': pickupLatitude,
      'pickup_longitude': pickupLongitude,
      'pickup_address': pickupAddress,
      'destination_latitude': destinationLatitude,
      'destination_longitude': destinationLongitude,
      'destination_address': destinationAddress,
      'status': _rideStatusToString(status),
      'vehicle_type': vehicleType.name,
      'distance_km': distanceKm,
      'duration_minutes': durationMinutes,
      'base_price': basePrice,
      'total_price': totalPrice,
      'payment_method': _paymentMethodToString(paymentMethod),
      'payment_status': paymentStatus.name,
    };
  }

  static RideStatus _parseRideStatus(String? status) {
    switch (status) {
      case 'pending':
        return RideStatus.pending;
      case 'accepted':
        return RideStatus.accepted;
      case 'driver_arriving':
        return RideStatus.driverArriving;
      case 'in_progress':
        return RideStatus.inProgress;
      case 'completed':
        return RideStatus.completed;
      case 'cancelled':
        return RideStatus.cancelled;
      default:
        return RideStatus.pending;
    }
  }

  static String _rideStatusToString(RideStatus status) {
    switch (status) {
      case RideStatus.pending:
        return 'pending';
      case RideStatus.accepted:
        return 'accepted';
      case RideStatus.driverArriving:
        return 'driver_arriving';
      case RideStatus.inProgress:
        return 'in_progress';
      case RideStatus.completed:
        return 'completed';
      case RideStatus.cancelled:
        return 'cancelled';
    }
  }

  static String _paymentMethodToString(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'cash';
      case PaymentMethod.mobileMoney:
        return 'mobile_money';
      case PaymentMethod.card:
        return 'card';
    }
  }

  static String _snakeToCamel(String text) {
    return text.replaceAllMapped(
      RegExp(r'_([a-z])'),
      (match) => match.group(1)!.toUpperCase(),
    );
  }

  String get statusText {
    switch (status) {
      case RideStatus.pending:
        return 'En attente';
      case RideStatus.accepted:
        return 'Acceptée';
      case RideStatus.driverArriving:
        return 'Chauffeur en route';
      case RideStatus.inProgress:
        return 'En cours';
      case RideStatus.completed:
        return 'Terminée';
      case RideStatus.cancelled:
        return 'Annulée';
    }
  }

  RideModel copyWith({
    String? id,
    String? clientId,
    String? driverId,
    double? pickupLatitude,
    double? pickupLongitude,
    String? pickupAddress,
    double? destinationLatitude,
    double? destinationLongitude,
    String? destinationAddress,
    RideStatus? status,
    VehicleType? vehicleType,
    double? distanceKm,
    int? durationMinutes,
    double? basePrice,
    double? totalPrice,
    PaymentMethod? paymentMethod,
    PaymentStatus? paymentStatus,
    int? clientRating,
    int? driverRating,
    String? clientComment,
    String? driverComment,
    DateTime? requestedAt,
    DateTime? acceptedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    DriverModel? driver,
    UserModel? client,
  }) {
    return RideModel(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      driverId: driverId ?? this.driverId,
      pickupLatitude: pickupLatitude ?? this.pickupLatitude,
      pickupLongitude: pickupLongitude ?? this.pickupLongitude,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      destinationLatitude: destinationLatitude ?? this.destinationLatitude,
      destinationLongitude: destinationLongitude ?? this.destinationLongitude,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      status: status ?? this.status,
      vehicleType: vehicleType ?? this.vehicleType,
      distanceKm: distanceKm ?? this.distanceKm,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      basePrice: basePrice ?? this.basePrice,
      totalPrice: totalPrice ?? this.totalPrice,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      clientRating: clientRating ?? this.clientRating,
      driverRating: driverRating ?? this.driverRating,
      clientComment: clientComment ?? this.clientComment,
      driverComment: driverComment ?? this.driverComment,
      requestedAt: requestedAt ?? this.requestedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      driver: driver ?? this.driver,
      client: client ?? this.client,
    );
  }
}
