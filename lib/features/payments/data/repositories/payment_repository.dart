import 'package:smartpayut_mobile/features/payments/data/models/payment_execution_result.dart';
import 'package:smartpayut_mobile/features/payments/data/models/qr_payment_payload.dart';
import 'package:smartpayut_mobile/shared/models/app_user.dart';
import 'package:smartpayut_mobile/features/payments/data/models/nfc_payment_payload.dart';
abstract class PaymentRepository {
  Future<PaymentExecutionResult> payWithQr({
    required AppUser user,
    required QrPaymentPayload payload,
  });
  Future<PaymentExecutionResult> payWithNfc({
    required AppUser user,
    required NfcPaymentPayload payload,
  });
}