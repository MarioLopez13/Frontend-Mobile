import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:smartpayut_mobile/features/payments/data/models/nfc_payment_payload.dart';
import 'package:smartpayut_mobile/features/payments/data/models/payment_execution_result.dart';
import 'package:smartpayut_mobile/features/payments/data/models/qr_payment_payload.dart';
import 'package:smartpayut_mobile/features/payments/data/repositories/payment_repository.dart';
import 'package:smartpayut_mobile/shared/models/app_user.dart';
import 'package:smartpayut_mobile/features/wallet/data/models/transaction_item.dart';

class ApiPaymentRepository implements PaymentRepository {
  final String baseUrl;

  const ApiPaymentRepository({
    required this.baseUrl,
  });

  @override
  Future<PaymentExecutionResult> payWithQr({
    required AppUser user,
    required QrPaymentPayload payload,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mobile-payments/qr'),
        headers: {
          'Content-Type': 'application/json',
          'X-User-ID': user.id ?? '',
        },
        body: jsonEncode({
          'busCode': payload.busCode,
          'routeName': payload.routeName,
          'amount': payload.amount,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final result = data['data'];

        final transaction = TransactionItem(
          id: result['transactionId'],
          title: result['routeName'],
          subtitle: result['busCode'],
          amount: -(result['amount'] as num).toDouble(),
          date: DateTime.now(),
          method: 'QR',
          status: 'Completado',
        );

        return PaymentExecutionResult(
          transaction: transaction,
          updatedBalance: (result['updatedBalance'] as num).toDouble(),
        );
      } else {
        throw Exception(data['message'] ?? 'Error en pago QR');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  @override
  Future<PaymentExecutionResult> payWithNfc({
    required AppUser user,
    required NfcPaymentPayload payload,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mobile-payments/nfc'),
        headers: {
          'Content-Type': 'application/json',
          'X-User-ID': user.id ?? '',
        },
        body: jsonEncode({
          'busCode': payload.busCode,
          'routeName': payload.routeName,
          'amount': payload.amount,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final result = data['data'];

        final transaction = TransactionItem(
          id: result['transactionId'],
          title: result['routeName'],
          subtitle: result['busCode'],
          amount: -(result['amount'] as num).toDouble(),
          date: DateTime.now(),
          method: 'NFC',
          status: 'Completado',
        );

        return PaymentExecutionResult(
        transaction: transaction,
        updatedBalance: (result['updatedBalance'] as num).toDouble(),
        );
      } else {
        throw Exception(data['message'] ?? 'Error en pago NFC');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}