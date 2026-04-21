import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartpayut_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:smartpayut_mobile/shared/config/app_environment.dart';
import 'package:smartpayut_mobile/shared/models/app_user.dart';
import 'package:smartpayut_mobile/shared/storage/app_session_storage.dart';

class ApiAuthRepository implements AuthRepository {
  final String baseUrl;

  ApiAuthRepository({
    String? baseUrl,
  }) : baseUrl = baseUrl ?? AppEnvironment.apiBaseUrl;

  @override
  Future<AppUser?> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final rawUser = prefs.getString(AppSessionStorage.userKey);

    if (rawUser == null || rawUser.isEmpty) {
      return null;
    }

    final cachedUser =
        AppUser.fromJson(jsonDecode(rawUser) as Map<String, dynamic>);

    final token = prefs.getString(AppSessionStorage.tokenKey);

    if (token == null || token.isEmpty) {
      return cachedUser;
    }

    try {
      final freshUser = await _getUserFromBackend(token, cachedUser.email);
      await _persistSession(user: freshUser, token: token);
      return freshUser;
    } catch (_) {
      return cachedUser;
    }
  }

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    final res = await http.post(
      Uri.parse('$baseUrl/auth/authenticate'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': normalizedEmail,
        'password': password,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Login failed [${res.statusCode}]: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final token = data['access_token'] as String?;

    if (token == null || token.isEmpty) {
      throw Exception('No se recibió access_token');
    }

    final user = await _getUserFromBackend(token, normalizedEmail);
    await _persistSession(user: user, token: token);

    return user;
  }

  Future<AppUser> _getUserFromBackend(
    String token,
    String fallbackEmail,
  ) async {
    final res = await http.get(
      Uri.parse('$baseUrl/users/me'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode != 200) {
      return AppUser(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: fallbackEmail.split('@').first,
        email: fallbackEmail,
        role: _resolveRoleFromEmail(fallbackEmail),
      );
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final userData = data['data'] as Map<String, dynamic>?;

    if (userData == null) {
      return AppUser(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: fallbackEmail.split('@').first,
        email: fallbackEmail,
        role: _resolveRoleFromEmail(fallbackEmail),
      );
    }

    final email = (userData['email'] ?? fallbackEmail).toString();
    final fullName =
        '${userData['name'] ?? ''} ${userData['lastName'] ?? ''}'.trim();

    final selectedBusinessId = userData['selectedBusiness']?.toString();

    final rawBusinesses = (userData['businesses'] as List<dynamic>? ?? const []);
    final businesses = rawBusinesses
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();

    Map<String, dynamic>? selectedBusiness;

    if (selectedBusinessId != null && selectedBusinessId.isNotEmpty) {
      for (final business in businesses) {
        if (business['businessId']?.toString() == selectedBusinessId) {
          selectedBusiness = business;
          break;
        }
      }
    }

    selectedBusiness ??= businesses.isNotEmpty ? businesses.first : null;

    final backendBalance = _toDouble(selectedBusiness?['balance']);
    final selectedBusinessName = selectedBusiness?['name']?.toString();

    return AppUser(
      id: (userData['userId'] ?? userData['id'] ?? '').toString(),
      name: fullName.isEmpty ? fallbackEmail.split('@').first : fullName,
      email: email,
      role: _resolveRoleFromEmail(email),
      avatarUrl: userData['image']?.toString(),
      selectedBusinessId: selectedBusiness?['businessId']?.toString(),
      selectedBusinessName: selectedBusinessName,
      backendBalance: backendBalance,
    );
  }

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final parts = name.trim().split(RegExp(r'\s+'));
    final firstName = parts.isNotEmpty ? parts.first : '';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'userName': normalizedEmail,
        'email': normalizedEmail,
        'name': firstName,
        'lastName': lastName,
        'password': password,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Error al registrar usuario');
    }

    return AppUser(
      id: '',
      name: name,
      email: normalizedEmail,
      role: UserRole.user,
    );
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppSessionStorage.userKey);
    await prefs.remove(AppSessionStorage.tokenKey);
  }

  Future<void> _persistSession({
    required AppUser user,
    required String token,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppSessionStorage.userKey,
      jsonEncode(user.toJson()),
    );
    await prefs.setString(AppSessionStorage.tokenKey, token);
  }

  UserRole _resolveRoleFromEmail(String email) {
    final normalized = email.toLowerCase();

    if (normalized.contains('admin')) {
      return UserRole.admin;
    }

    if (normalized.contains('operator') || normalized.contains('support')) {
      return UserRole.operator;
    }

    return UserRole.user;
  }

  double? _toDouble(Object? value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }
}