import 'package:smartpayut_mobile/features/payments/data/models/nfc_payment_payload.dart';
import 'package:smartpayut_mobile/features/payments/data/models/payment_execution_result.dart';
import 'package:smartpayut_mobile/features/payments/data/models/qr_payment_payload.dart';
import 'package:smartpayut_mobile/features/payments/data/repositories/payment_repository.dart';
import 'package:smartpayut_mobile/shared/models/app_user.dart';

class ApiPaymentRepository implements PaymentRepository {
  final String baseUrl;

  const ApiPaymentRepository({
    required this.baseUrl,
  });

  @override
  Future<PaymentExecutionResult> payWithQr({
    required AppUser user,
    required QrPaymentPayload payload,
  }) {
    throw UnsupportedError(
      'ApiPaymentRepository aún no está conectado. '
      'Mantén USE_MOCK_PAYMENTS=true hasta definir el contrato backend real de pagos.',
    );
  }

  @override
  Future<PaymentExecutionResult> payWithNfc({
    required AppUser user,
    required NfcPaymentPayload payload,
  }) {
    throw UnsupportedError(
      'ApiPaymentRepository aún no está conectado. '
      'Mantener USE_MOCK_PAYMENTS=true hasta definir el contrato backend real de pagos.',
    );
  }
}