import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smartpayut_mobile/app/router/route_paths.dart';
import 'package:smartpayut_mobile/features/payments/data/models/payment_execution_result.dart';
import 'package:smartpayut_mobile/shared/config/app_seed_data.dart';

class PaymentResultPage extends StatelessWidget {
  final PaymentExecutionResult result;

  const PaymentResultPage({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final transaction = result.transaction;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Pago completado'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 8),
          const Icon(
            Icons.check_circle_rounded,
            size: 88,
            color: Color(0xFF16A34A),
          ),
          const SizedBox(height: 16),
          const Text(
            'Pago realizado con éxito',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'La transacción fue registrada correctamente en tu historial.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detalle de la transacción',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _ResultRow(
                    label: 'Referencia',
                    value: transaction.id,
                  ),
                  const SizedBox(height: 12),
                  _ResultRow(
                    label: 'Unidad',
                    value: transaction.title,
                  ),
                  const SizedBox(height: 12),
                  _ResultRow(
                    label: 'Ruta',
                    value: transaction.subtitle,
                  ),
                  const SizedBox(height: 12),
                  _ResultRow(
                    label: 'Método',
                    value: transaction.method,
                  ),
                  const SizedBox(height: 12),
                  _ResultRow(
                    label: 'Estado',
                    value: transaction.status,
                  ),
                  const SizedBox(height: 12),
                  _ResultRow(
                    label: 'Monto',
                    value:
                        '${AppSeedData.currencySymbol}${transaction.amount.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 12),
                  _ResultRow(
                    label: 'Fecha',
                    value: DateFormat('dd/MM/yyyy · HH:mm').format(transaction.date),
                  ),
                  const SizedBox(height: 12),
                  _ResultRow(
                    label: 'Saldo actual',
                    value:
                        '${AppSeedData.currencySymbol}${result.updatedBalance.toStringAsFixed(2)}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => context.go(RoutePaths.history),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Ver historial'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.go(RoutePaths.home),
              child: const Text('Volver al inicio'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;

  const _ResultRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 15,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}