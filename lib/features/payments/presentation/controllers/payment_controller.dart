import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpayut_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:smartpayut_mobile/features/payments/data/models/nfc_payment_payload.dart';
import 'package:smartpayut_mobile/features/payments/data/models/payment_execution_result.dart';
import 'package:smartpayut_mobile/features/payments/data/models/qr_payment_payload.dart';
import 'package:smartpayut_mobile/features/payments/data/repositories/api_payment_repository.dart';
import 'package:smartpayut_mobile/features/payments/data/repositories/mock_payment_repository.dart';
import 'package:smartpayut_mobile/features/payments/data/repositories/payment_repository.dart';
import 'package:smartpayut_mobile/features/wallet/data/repositories/wallet_repository.dart';
import 'package:smartpayut_mobile/features/wallet/presentation/controllers/wallet_controller.dart';
import 'package:smartpayut_mobile/shared/config/app_environment.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  if (AppEnvironment.useMockPayments) {
    final walletRepository = ref.read(walletRepositoryProvider);

    return MockPaymentRepository(
      walletRepository: walletRepository,
    );
  }

  return ApiPaymentRepository(
    baseUrl: AppEnvironment.apiBaseUrl,
  );
});

final paymentControllerProvider =
    NotifierProvider<PaymentController, PaymentControllerState>(
  PaymentController.new,
);

class PaymentControllerState {
  final bool isProcessing;
  final String? errorMessage;
  final String? lastFingerprint;
  final DateTime? lastProcessedAt;

  const PaymentControllerState({
    this.isProcessing = false,
    this.errorMessage,
    this.lastFingerprint,
    this.lastProcessedAt,
  });

  PaymentControllerState copyWith({
    bool? isProcessing,
    String? errorMessage,
    String? lastFingerprint,
    DateTime? lastProcessedAt,
    bool clearError = false,
  }) {
    return PaymentControllerState(
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastFingerprint: lastFingerprint ?? this.lastFingerprint,
      lastProcessedAt: lastProcessedAt ?? this.lastProcessedAt,
    );
  }
}

class PaymentController extends Notifier<PaymentControllerState> {
  late final PaymentRepository _paymentRepository;
  late final WalletRepository _walletRepository;

  @override
  PaymentControllerState build() {
    _paymentRepository = ref.read(paymentRepositoryProvider);
    _walletRepository = ref.read(walletRepositoryProvider);

    return const PaymentControllerState();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<PaymentExecutionResult?> payWithQr({
    required QrPaymentPayload payload,
  }) async {
    if (state.isProcessing) {
      return null;
    }

    final user = ref.read(authControllerProvider);

    if (user == null) {
      _setError('Tu sesión expiró. Vuelve a iniciar sesión.');
      return null;
    }

    final payloadError = _validateQrPayload(payload);
    if (payloadError != null) {
      _setError(payloadError);
      return null;
    }

    final currentBalance = await _walletRepository.getAvailableBalance(user);

    if (currentBalance < payload.amount) {
      _setError('No tienes saldo suficiente para realizar el pago.');
      return null;
    }

    final fingerprint =
        'QR|${payload.busCode}|${payload.routeName}|${payload.amount.toStringAsFixed(2)}';
    final now = DateTime.now();

    if (state.lastFingerprint == fingerprint &&
        state.lastProcessedAt != null &&
        now.difference(state.lastProcessedAt!).inSeconds < 15) {
      _setError('Ya registraste un pago igual hace unos segundos.');
      return null;
    }

    state = state.copyWith(
      isProcessing: true,
      clearError: true,
    );

    try {
      final result = await _paymentRepository.payWithQr(
        user: user,
        payload: payload,
      );

      state = state.copyWith(
        isProcessing: false,
        clearError: true,
        lastFingerprint: fingerprint,
        lastProcessedAt: now,
      );

      ref.invalidate(walletBalanceProvider);
      ref.invalidate(walletTransactionsProvider);

      return result;
    } catch (error) {
      _setError(_mapError(error));
      return null;
    }
  }

  Future<PaymentExecutionResult?> payWithNfc({
    required NfcPaymentPayload payload,
  }) async {
    if (state.isProcessing) {
      return null;
    }

    final user = ref.read(authControllerProvider);

    if (user == null) {
      _setError('Tu sesión expiró. Vuelve a iniciar sesión.');
      return null;
    }

    final payloadError = _validateNfcPayload(payload);
    if (payloadError != null) {
      _setError(payloadError);
      return null;
    }

    final currentBalance = await _walletRepository.getAvailableBalance(user);

    if (currentBalance < payload.amount) {
      _setError('No tienes saldo suficiente para realizar el pago.');
      return null;
    }

    final fingerprint =
        'NFC|${payload.tagReference}|${payload.busCode}|${payload.amount.toStringAsFixed(2)}';
    final now = DateTime.now();

    if (state.lastFingerprint == fingerprint &&
        state.lastProcessedAt != null &&
        now.difference(state.lastProcessedAt!).inSeconds < 15) {
      _setError('Ya registraste un pago NFC igual hace unos segundos.');
      return null;
    }

    state = state.copyWith(
      isProcessing: true,
      clearError: true,
    );

    try {
      final result = await _paymentRepository.payWithNfc(
        user: user,
        payload: payload,
      );

      state = state.copyWith(
        isProcessing: false,
        clearError: true,
        lastFingerprint: fingerprint,
        lastProcessedAt: now,
      );

      ref.invalidate(walletBalanceProvider);
      ref.invalidate(walletTransactionsProvider);

      return result;
    } catch (error) {
      _setError(_mapError(error));
      return null;
    }
  }

  String? _validateQrPayload(QrPaymentPayload payload) {
    if (payload.busCode.trim().isEmpty) {
      return 'No se identificó la unidad del QR.';
    }

    if (payload.routeName.trim().isEmpty) {
      return 'No se identificó la ruta del QR.';
    }

    if (payload.amount <= 0) {
      return 'El monto del pago no es válido.';
    }

    return null;
  }

  String? _validateNfcPayload(NfcPaymentPayload payload) {
    if (payload.tagReference.trim().isEmpty) {
      return 'No se identificó la referencia NFC.';
    }

    if (payload.busCode.trim().isEmpty) {
      return 'No se identificó la unidad del tag NFC.';
    }

    if (payload.routeName.trim().isEmpty) {
      return 'No se identificó la ruta del tag NFC.';
    }

    if (payload.amount <= 0) {
      return 'El monto del pago no es válido.';
    }

    return null;
  }

  void _setError(String message) {
    state = state.copyWith(
      isProcessing: false,
      errorMessage: message,
    );
  }

  String _mapError(Object error) {
    if (error is StateError) {
      final message = error.message;
      if (message.trim().isNotEmpty) {
        return message;
      }
    }

    if (error is UnsupportedError) {
      final message = error.message?.toString().trim() ?? '';
      if (message.isNotEmpty) {
        return message;
      }
    }

    return 'No fue posible procesar el pago. Intenta nuevamente.';
  }
}