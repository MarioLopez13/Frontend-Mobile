import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartpayut_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:smartpayut_mobile/shared/models/app_user.dart';

class MockAuthRepository implements AuthRepository {
  static const _storageKey = 'smartpayut_mobile_user';

  @override
  Future<AppUser?> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final rawUser = prefs.getString(_storageKey);

    if (rawUser == null || rawUser.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(rawUser) as Map<String, dynamic>;
    return AppUser.fromJson(decoded);
  }

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    final role = _resolveRole(normalizedEmail);

    final user = AppUser(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _resolveNameFromEmail(normalizedEmail),
      email: normalizedEmail,
      role: role,
    );

    await _persistUser(user);
    return user;
  }

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    final user = AppUser(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      email: normalizedEmail,
      role: UserRole.user,
      phone: phone?.trim().isEmpty == true ? null : phone?.trim(),
    );

    await _persistUser(user);
    return user;
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  Future<void> _persistUser(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(user.toJson()));
  }

  UserRole _resolveRole(String email) {
    if (email.contains('admin')) {
      return UserRole.admin;
    }

    if (email.contains('operator') || email.contains('support')) {
      return UserRole.operator;
    }

    return UserRole.user;
  }

  String _resolveNameFromEmail(String email) {
    if (email.contains('admin')) {
      return 'Administrador Demo';
    }

    if (email.contains('operator') || email.contains('support')) {
      return 'Operador Demo';
    }

    return 'Usuario Demo';
  }
}