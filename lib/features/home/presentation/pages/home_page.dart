import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smartpayut_mobile/app/router/route_paths.dart';
import 'package:smartpayut_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:smartpayut_mobile/features/wallet/data/models/transaction_item.dart';
import 'package:smartpayut_mobile/features/wallet/presentation/controllers/wallet_controller.dart';
import 'package:smartpayut_mobile/shared/config/app_seed_data.dart';
import 'package:smartpayut_mobile/shared/theme/app_colors.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider);
    final balanceAsync = ref.watch(walletBalanceProvider);
    final transactionsAsync = ref.watch(walletTransactionsProvider);

    final displayName =
        (user?.name.trim().isNotEmpty ?? false) ? user!.name : 'Usuario';
    final displayEmail =
        (user?.email.trim().isNotEmpty ?? false)
            ? user!.email
            : AppSeedData.supportEmail;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.brandDark, AppColors.brand],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Image.asset('assets/images/kynsoft_logo.png'),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'KynSoft · SmartPayUT',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Hola, $displayName',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Saldo disponible',
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
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    error: (_, _) => const Text(
                      '--',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.mail_outline,
                          color: Colors.white70,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            displayEmail,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
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
                      'Acciones principales',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Accede rápido a pago por QR, pago por NFC y recarga de saldo.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 18),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isMobile = constraints.maxWidth < 600;

                        final actions = [
                          _ActionCard(
                            icon: Icons.qr_code_2_rounded,
                            title: 'Pagar QR',
                            subtitle: 'Escanear',
                            onTap: () => context.push(RoutePaths.qrScanner),
                          ),
                          _ActionCard(
                            icon: Icons.nfc_rounded,
                            title: 'Pagar NFC',
                            subtitle: 'NFC',
                            onTap: () => context.push(RoutePaths.nfcReader),
                          ),
                          _ActionCard(
                            icon: Icons.add_card_rounded,
                            title: 'Recargar',
                            subtitle: 'Saldo',
                            onTap: () => context.push(RoutePaths.topUp),
                          ),
                        ];

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: actions.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: isMobile ? 8 : 12,
                            mainAxisSpacing: isMobile ? 8 : 12,
                            mainAxisExtent: isMobile ? 136 : 132,
                          ),
                          itemBuilder: (context, index) => actions[index],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: transactionsAsync.when(
                  data: (transactions) {
                    final recent = transactions.take(4).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Actividad reciente',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.go(RoutePaths.history),
                              child: const Text('Ver todo'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Visualiza tus últimos movimientos y el estado de cada operación.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 18),
                        if (recent.isEmpty)
                          const _EmptyState(
                            icon: Icons.receipt_long_outlined,
                            title: 'Aún no tienes movimientos.',
                            subtitle:
                                'Cuando realices pagos o recargas, aparecerán aquí.',
                          )
                        else
                          Column(
                            children: [
                              for (int i = 0; i < recent.length; i++) ...[
                                _TransactionTile(item: recent[i]),
                                if (i < recent.length - 1)
                                  const SizedBox(height: 12),
                              ],
                            ],
                          ),
                      ],
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, _) => const _EmptyState(
                    icon: Icons.error_outline,
                    title: 'No fue posible cargar el historial.',
                    subtitle: 'Intenta nuevamente en unos segundos.',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.brandSoft,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.brand,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionItem item;

  const _TransactionTile({required this.item});

  bool get _isTopUp => item.method.toUpperCase() == 'RECARGA';

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: AppSeedData.currencySymbol);
    final formatter = DateFormat('dd MMM · HH:mm', 'es');
    final accentColor = _isTopUp ? AppColors.success : AppColors.brand;
    final backgroundColor = _isTopUp ? AppColors.successSoft : AppColors.brandSoft;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _isTopUp ? Icons.add_card_rounded : Icons.directions_bus_filled_rounded,
              color: accentColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${item.subtitle} · ${formatter.format(item.date)}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_isTopUp ? '+' : '-'}${currency.format(item.amount)}',
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.method,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.brandSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.brand, size: 32),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
