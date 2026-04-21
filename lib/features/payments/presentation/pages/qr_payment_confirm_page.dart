import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smartpayut_mobile/app/router/route_paths.dart';
import 'package:smartpayut_mobile/features/payments/data/models/qr_payment_payload.dart';
import 'package:smartpayut_mobile/features/payments/presentation/controllers/payment_controller.dart';
import 'package:smartpayut_mobile/features/wallet/presentation/controllers/wallet_controller.dart';
import 'package:smartpayut_mobile/shared/config/app_seed_data.dart';

class QrPaymentConfirmPage extends ConsumerStatefulWidget {
  final QrPaymentPayload payload;

  const QrPaymentConfirmPage({
    super.key,
    required this.payload,
  });

  @override
  ConsumerState<QrPaymentConfirmPage> createState() =>
      _QrPaymentConfirmPageState();
}

class _QrPaymentConfirmPageState extends ConsumerState<QrPaymentConfirmPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(paymentControllerProvider.notifier).clearError();
    });
  }

  Future<void> _handleConfirmPayment() async {
    final result = await ref
        .read(paymentControllerProvider.notifier)
        .payWithQr(payload: widget.payload);

    if (!mounted || result == null) {
      return;
    }

    context.go(RoutePaths.paymentResult, extra: result);
  }

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentControllerProvider);
    final balanceAsync = ref.watch(walletBalanceProvider);

    final balance = balanceAsync.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );

    final isBalanceLoading = balanceAsync.isLoading;
    final hasBalanceError = balanceAsync.hasError;
    final hasEnoughBalance = balance != null && balance >= widget.payload.amount;
    final projectedBalance = hasEnoughBalance ? balance - widget.payload.amount : 0.0;

    final isConfirmDisabled = paymentState.isProcessing ||
        isBalanceLoading ||
        hasBalanceError ||
        !hasEnoughBalance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar pago QR'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Revisa la información antes de confirmar la transacción.',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resumen del pago',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _SummaryRow(
                    label: 'Unidad',
                    value: 'Bus ${widget.payload.busCode}',
                  ),
                  const SizedBox(height: 12),
                  _SummaryRow(
                    label: 'Ruta',
                    value: widget.payload.routeName,
                  ),
                  const SizedBox(height: 12),
                  const _SummaryRow(
                    label: 'Método',
                    value: 'QR',
                  ),
                  const SizedBox(height: 12),
                  _SummaryRow(
                    label: 'Monto',
                    value:
                        '${AppSeedData.currencySymbol}${widget.payload.amount.toStringAsFixed(2)}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: balanceAsync.when(
                data: (resolvedBalance) {
                  final resolvedProjectedBalance =
                      resolvedBalance >= widget.payload.amount
                          ? resolvedBalance - widget.payload.amount
                          : 0.0;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Validación de saldo',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _SummaryRow(
                        label: 'Saldo actual',
                        value:
                            '${AppSeedData.currencySymbol}${resolvedBalance.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 12),
                      _SummaryRow(
                        label: 'Saldo proyectado',
                        value:
                            '${AppSeedData.currencySymbol}${resolvedProjectedBalance.toStringAsFixed(2)}',
                      ),
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, _) => const Text(
                  'No fue posible consultar el saldo.',
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (isBalanceLoading)
            const _ValidationBanner(
              message: 'Validando saldo disponible...',
              backgroundColor: Color(0xFFEFF6FF),
              textColor: Color(0xFF1D4ED8),
            )
          else if (hasBalanceError)
            const _ValidationBanner(
              message: 'No se pudo validar el saldo. Intenta nuevamente.',
              backgroundColor: Color(0xFFFEF2F2),
              textColor: Color(0xFFB91C1C),
            )
          else if (hasEnoughBalance)
            _ValidationBanner(
              message:
                  'Saldo suficiente. Después del pago te quedarán ${AppSeedData.currencySymbol}${projectedBalance.toStringAsFixed(2)}.',
              backgroundColor: const Color(0xFFF0FDF4),
              textColor: const Color(0xFF166534),
            )
          else
            _ValidationBanner(
              message:
                  'Saldo insuficiente. Necesitas ${AppSeedData.currencySymbol}${widget.payload.amount.toStringAsFixed(2)} para continuar.',
              backgroundColor: const Color(0xFFFEF2F2),
              textColor: const Color(0xFFB91C1C),
            ),
          if (paymentState.errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                paymentState.errorMessage!,
                style: const TextStyle(
                  color: Color(0xFFB91C1C),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isConfirmDisabled ? null : _handleConfirmPayment,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                paymentState.isProcessing
                    ? 'Procesando pago...'
                    : isBalanceLoading
                        ? 'Validando saldo...'
                        : hasBalanceError
                            ? 'Saldo no disponible'
                            : !hasEnoughBalance
                                ? 'Saldo insuficiente'
                                : 'Confirmar pago',
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: paymentState.isProcessing ? null : () => context.pop(),
              child: const Text('Cancelar'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
        Text(
          value,
          textAlign: TextAlign.end,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class _ValidationBanner extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  final Color textColor;

  const _ValidationBanner({
    required this.message,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}