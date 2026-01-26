class UserModel {
  final String id;
  final String? email;
  final String phone;
  final String fullName;
  final String role;
  final String? avatarUrl;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    this.email,
    required this.phone,
    required this.fullName,
    required this.role,
    this.avatarUrl,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String,
      fullName: json['full_name'] as String,
      role: json['role'] as String,
      avatarUrl: json['avatar_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'full_name': fullName,
      'role': role,
      'avatar_url': avatarUrl,
      'is_active': isActive,
    };
  }
}

class ClientModel {
  final String id;
  final String? address;
  final List<dynamic> favoriteLocations;
  final int totalRides;
  final DateTime? createdAt;

  ClientModel({
    required this.id,
    this.address,
    this.favoriteLocations = const [],
    this.totalRides = 0,
    this.createdAt,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'] as String,
      address: json['address'] as String?,
      favoriteLocations: json['favorite_locations'] as List<dynamic>? ?? [],
      totalRides: json['total_rides'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'favorite_locations': favoriteLocations,
      'total_rides': totalRides,
    };
  }
}
