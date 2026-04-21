import 'package:smartpayut_mobile/features/wallet/data/models/transaction_item.dart';

class PaymentExecutionResult {
  final TransactionItem transaction;
  final double updatedBalance;

  const PaymentExecutionResult({
    required this.transaction,
    required this.updatedBalance,
  });
}