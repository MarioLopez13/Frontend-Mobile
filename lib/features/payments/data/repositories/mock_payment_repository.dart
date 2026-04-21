import 'package:smartpayut_mobile/features/payments/data/models/payment_execution_result.dart';
import 'package:smartpayut_mobile/features/payments/data/models/qr_payment_payload.dart';
import 'package:smartpayut_mobile/features/payments/data/repositories/payment_repository.dart';
import 'package:smartpayut_mobile/features/wallet/data/repositories/wallet_repository.dart';
import 'package:smartpayut_mobile/shared/models/app_user.dart';
import 'package:smartpayut_mobile/features/payments/data/models/nfc_payment_payload.dart';

class MockPaymentRepository implements PaymentRepository {
  final WalletRepository walletRepository;

  const MockPaymentRepository({
    required this.walletRepository,
  });

  @override
  Future<PaymentExecutionResult> payWithQr({
    required AppUser user,
    required QrPaymentPayload payload,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    final transaction = await walletRepository.registerPayment(
      user: user,
      title: payload.title,
      subtitle: payload.routeName,
      amount: payload.amount,
      method: 'QR',
    );

    final updatedBalance = await walletRepository.getAvailableBalance(user);

    return PaymentExecutionResult(
      transaction: transaction,
      updatedBalance: updatedBalance,
    );
  }
  @override
Future<PaymentExecutionResult> payWithNfc({
  required AppUser user,
  required NfcPaymentPayload payload,
}) async {
  await Future.delayed(const Duration(seconds: 1));

  final transaction = await walletRepository.registerPayment(
    user: user,
    title: payload.title,
    subtitle: payload.routeName,
    amount: payload.amount,
    method: 'NFC',
  );

  final updatedBalance = await walletRepository.getAvailableBalance(user);

  return PaymentExecutionResult(
    transaction: transaction,
    updatedBalance: updatedBalance,
  );
}
}