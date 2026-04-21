enum UserRole {
  admin,
  operator,
  user,
}

class AppUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? phone;
  final String? avatarUrl;

  final String? selectedBusinessId;
  final String? selectedBusinessName;
  final double? backendBalance;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.avatarUrl,
    this.selectedBusinessId,
    this.selectedBusinessName,
    this.backendBalance,
  });

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? phone,
    String? avatarUrl,
    String? selectedBusinessId,
    String? selectedBusinessName,
    double? backendBalance,
    bool clearSelectedBusinessId = false,
    bool clearSelectedBusinessName = false,
    bool clearBackendBalance = false,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      selectedBusinessId: clearSelectedBusinessId
          ? null
          : (selectedBusinessId ?? this.selectedBusinessId),
      selectedBusinessName: clearSelectedBusinessName
          ? null
          : (selectedBusinessName ?? this.selectedBusinessName),
      backendBalance: clearBackendBalance
          ? null
          : (backendBalance ?? this.backendBalance),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'selectedBusinessId': selectedBusinessId,
      'selectedBusinessName': selectedBusinessName,
      'backendBalance': backendBalance,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final rawRole = (json['role'] as String?)?.trim().toLowerCase();

    return AppUser(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      role: _mapRole(rawRole),
      phone: json['phone'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      selectedBusinessId: json['selectedBusinessId']?.toString(),
      selectedBusinessName: json['selectedBusinessName']?.toString(),
      backendBalance: _toDouble(json['backendBalance']),
    );
  }

  static UserRole _mapRole(String? rawRole) {
    switch (rawRole) {
      case 'admin':
        return UserRole.admin;
      case 'operator':
        return UserRole.operator;
      case 'user':
      default:
        return UserRole.user;
    }
  }

  static double? _toDouble(Object? value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }
}