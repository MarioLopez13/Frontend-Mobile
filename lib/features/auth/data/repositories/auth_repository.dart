import 'package:smartpayut_mobile/shared/models/app_user.dart';

abstract class AuthRepository {
  Future<AppUser?> loadSession();

  Future<AppUser> login({
    required String email,
    required String password,
  });

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  });

  Future<void> logout();
}