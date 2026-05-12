import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smartpayut_mobile/features/wallet/presentation/controllers/wallet_controller.dart';
import 'package:smartpayut_mobile/shared/config/app_seed_data.dart';
import 'package:smartpayut_mobile/shared/theme/app_colors.dart';

class TopUpPage extends ConsumerStatefulWidget {
  const TopUpPage({super.key});

  @override
  ConsumerState<TopUpPage> createState() => _TopUpPageState();
}

class _TopUpPageState extends ConsumerState<TopUpPage> {
  static const _quickAmounts = [1.0, 3.0, 5.0, 10.0];

  final _amountController = TextEditingController();
  double? _selectedAmount = 3.0;

  @override
  void initState() {
  super.initState();

  _amountController.text = _selectedAmount!.toStringAsFixed(2);

  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.read(walletActionControllerProvider.notifier).clearMessages();
  });
}

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submitTopUp() async {
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    final success = await ref
        .read(walletActionControllerProvider.notifier)
        .topUpBalance(amount: amount ?? 0);

    if (!mounted) {
      return;
    }

    final state = ref.read(walletActionControllerProvider);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.successMessage ?? 'Recarga registrada.')),
      );
      context.pop();
      return;
    }

    if (state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(walletActionControllerProvider);
    final balanceAsync = ref.watch(walletBalanceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recargar saldo'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.brandDark, AppColors.brand],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Billetera SmartPayUT',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                balanceAsync.when(
                  data: (balance) => Text(
                    '${AppSeedData.currencySymbol}${balance.toStringAsFixed(2)} USD',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  loading: () => const Text(
                    'Cargando saldo...',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  error: (_, _) => const Text(
                    '--',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.account_balance_wallet_outlined,
                          color: Colors.white),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Flujo mock de recarga listo para conexión futura con Place to Pay.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selecciona un monto',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Escoge una recarga rápida o ingresa un valor personalizado.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _quickAmounts.map((amount) {
                      final isSelected = _selectedAmount == amount;
                      return ChoiceChip(
                        label: Text(
                          '${AppSeedData.currencySymbol}${amount.toStringAsFixed(2)}',
                        ),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            _selectedAmount = amount;
                            _amountController.text = amount.toStringAsFixed(2);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Monto a recargar',
                      hintText: 'Ej. 5.00',
                      prefixText: '${AppSeedData.currencySymbol} ',
                    ),
                    onChanged: (_) {
                      setState(() {
                        _selectedAmount = null;
                      });
                    },
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.brandSoft,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.credit_card_outlined, color: AppColors.brand),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Método simulado: Place to Pay. Luego se reemplaza por integración real con backend.',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (actionState.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    _InlineMessage(
                      message: actionState.errorMessage!,
                      backgroundColor: AppColors.dangerSoft,
                      foregroundColor: AppColors.danger,
                      icon: Icons.error_outline,
                    ),
                  ],
                  if (actionState.successMessage != null) ...[
                    const SizedBox(height: 16),
                    _InlineMessage(
                      message: actionState.successMessage!,
                      backgroundColor: AppColors.successSoft,
                      foregroundColor: AppColors.success,
                      icon: Icons.check_circle_outline,
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: actionState.isProcessing ? null : _submitTopUp,
                      icon: actionState.isProcessing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.add_card_outlined),
                      label: Text(
                        actionState.isProcessing
                            ? 'Procesando recarga...'
                            : 'Confirmar recarga',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineMessage extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;

  const _InlineMessage({
    required this.message,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: foregroundColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: foregroundColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
