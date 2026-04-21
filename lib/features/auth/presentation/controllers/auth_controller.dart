import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpayut_mobile/features/auth/data/repositories/api_auth_repository.dart';
import 'package:smartpayut_mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:smartpayut_mobile/features/wallet/data/repositories/wallet_repository.dart';
import 'package:smartpayut_mobile/features/wallet/presentation/controllers/wallet_controller.dart';
import 'package:smartpayut_mobile/shared/models/app_user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return ApiAuthRepository();
});

final authControllerProvider =
    NotifierProvider<AuthController, AppUser?>(AuthController.new);

class AuthController extends Notifier<AppUser?> {
  late final AuthRepository _authRepository;
  late final WalletRepository _walletRepository;

  @override
  AppUser? build() {
    _authRepository = ref.read(authRepositoryProvider);
    _walletRepository = ref.read(walletRepositoryProvider);
    return null;
  }

  Future<void> loadSession() async {
    final user = await _authRepository.loadSession();

    if (user != null) {
      await _safeSyncWallet(user);
    }

    state = user;
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    final validationError = _validateLoginFields(
      email: email,
      password: password,
    );

    if (validationError != null) {
      return validationError;
    }

    try {
      final user = await _authRepository.login(
        email: email,
        password: password,
      );

      await _safeSyncWallet(user);
      state = user;
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    String? phone,
  }) async {
    final validationError = _validateRegisterFields(
      name: name,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );

    if (validationError != null) {
      return validationError;
    }

    try {
      await _authRepository.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );

      return 'success';
    } catch (e) {
      return 'No se pudo crear la cuenta.';
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = null;
  }

  Future<void> _safeSyncWallet(AppUser user) async {
    try {
      await _walletRepository.syncBalanceFromBackend(user);
    } catch (_) {}
  }

  String? _validateLoginFields({
    required String email,
    required String password,
  }) {
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();

    if (trimmedEmail.isEmpty || trimmedPassword.isEmpty) {
      return 'Completa el correo y la contraseña.';
    }

    if (!_isValidEmail(trimmedEmail)) {
      return 'Ingresa un correo válido.';
    }

    if (trimmedPassword.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }

    return null;
  }

  String? _validateRegisterFields({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    final trimmedName = name.trim();
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();
    final trimmedConfirmPassword = confirmPassword.trim();

    if (trimmedName.isEmpty ||
        trimmedEmail.isEmpty ||
        trimmedPassword.isEmpty ||
        trimmedConfirmPassword.isEmpty) {
      return 'Completa todos los campos obligatorios.';
    }

    if (trimmedName.length < 3) {
      return 'Ingresa un nombre válido.';
    }

    if (!_isValidEmail(trimmedEmail)) {
      return 'Ingresa un correo válido.';
    }

    if (trimmedPassword.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }

    if (trimmedPassword != trimmedConfirmPassword) {
      return 'Las contraseñas no coinciden.';
    }

    return null;
  }

  bool _isValidEmail(String value) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(value);
  }
}