enum VehicleType { moto, standard, comfort, van }

class DriverModel {
  final String id;
  final String? fullName;
  final String? avatarUrl;
  final VehicleType vehicleType;
  final String vehicleBrand;
  final String vehicleModel;
  final int? vehicleYear;
  final String licensePlate;
  final String driverLicense;
  final bool isAvailable;
  final bool isVerified;
  final double rating;
  final int totalRides;
  final double totalEarnings;
  final double? currentLatitude;
  final double? currentLongitude;
  final DateTime? lastLocationUpdate;
  final DateTime? createdAt;

  DriverModel({
    required this.id,
    this.fullName,
    this.avatarUrl,
    required this.vehicleType,
    required this.vehicleBrand,
    required this.vehicleModel,
    this.vehicleYear,
    required this.licensePlate,
    required this.driverLicense,
    this.isAvailable = false,
    this.isVerified = false,
    this.rating = 5.0,
    this.totalRides = 0,
    this.totalEarnings = 0.0,
    this.currentLatitude,
    this.currentLongitude,
    this.lastLocationUpdate,
    this.createdAt,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      vehicleType: VehicleType.values.firstWhere(
        (e) => e.name == json['vehicle_type'],
        orElse: () => VehicleType.standard,
      ),
      vehicleBrand: json['vehicle_brand'] as String? ?? '',
      vehicleModel: json['vehicle_model'] as String? ?? '',
      vehicleYear: json['vehicle_year'] as int?,
      licensePlate: json['license_plate'] as String? ?? '',
      driverLicense: json['driver_license'] as String? ?? '',
      isAvailable: json['is_available'] as bool? ?? false,
      isVerified: json['is_verified'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      totalRides: json['total_rides'] as int? ?? 0,
      totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0.0,
      currentLatitude: (json['current_latitude'] as num?)?.toDouble(),
      currentLongitude: (json['current_longitude'] as num?)?.toDouble(),
      lastLocationUpdate: json['last_location_update'] != null
          ? DateTime.parse(json['last_location_update'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_type': vehicleType.name,
      'vehicle_brand': vehicleBrand,
      'vehicle_model': vehicleModel,
      'vehicle_year': vehicleYear,
      'license_plate': licensePlate,
      'driver_license': driverLicense,
      'is_available': isAvailable,
      'is_verified': isVerified,
      'rating': rating,
      'total_rides': totalRides,
      'total_earnings': totalEarnings,
      'current_latitude': currentLatitude,
      'current_longitude': currentLongitude,
    };
  }

  String get vehicleInfo => '$vehicleBrand $vehicleModel';
}
