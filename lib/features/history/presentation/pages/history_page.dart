import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:smartpayut_mobile/features/wallet/data/models/transaction_item.dart';
import 'package:smartpayut_mobile/features/wallet/presentation/controllers/wallet_controller.dart';
import 'package:smartpayut_mobile/shared/config/app_seed_data.dart';
import 'package:smartpayut_mobile/shared/theme/app_colors.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(walletTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
      ),
      body: SafeArea(
        child: transactionsAsync.when(
          data: (transactions) => _HistoryContent(transactions: transactions),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('No fue posible cargar tu historial.'),
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryContent extends StatelessWidget {
  final List<TransactionItem> transactions;

  const _HistoryContent({required this.transactions});

  @override
  Widget build(BuildContext context) {
    final payments = transactions
        .where((item) => item.method.toUpperCase() != 'RECARGA')
        .fold<double>(0, (sum, item) => sum + item.amount);
    final topUps = transactions
        .where((item) => item.method.toUpperCase() == 'RECARGA')
        .fold<double>(0, (sum, item) => sum + item.amount);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Pagos',
                value: '${AppSeedData.currencySymbol}${payments.toStringAsFixed(2)}',
                caption: 'Transporte',
                icon: Icons.directions_bus_filled_rounded,
                backgroundColor: AppColors.brandSoft,
                iconColor: AppColors.brand,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                title: 'Recargas',
                value: '${AppSeedData.currencySymbol}${topUps.toStringAsFixed(2)}',
                caption: 'Saldo agregado',
                icon: Icons.add_card_rounded,
                backgroundColor: AppColors.successSoft,
                iconColor: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const Text(
          'Todos los movimientos',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Consulta pagos y recargas registrados en tu billetera.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 18),
        if (transactions.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.brandSoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              children: [
                Icon(Icons.receipt_long_outlined, color: AppColors.brand, size: 32),
                SizedBox(height: 10),
                Text(
                  'Aún no tienes movimientos registrados.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          )
        else
          Column(
            children: [
              for (int i = 0; i < transactions.length; i++) ...[
                _HistoryTile(item: transactions[i]),
                if (i < transactions.length - 1) const SizedBox(height: 12),
              ],
            ],
          ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String caption;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.caption,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            caption,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final TransactionItem item;

  const _HistoryTile({required this.item});

  bool get _isTopUp => item.method.toUpperCase() == 'RECARGA';

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd MMM yyyy · HH:mm', 'es');
    final currency = NumberFormat.currency(symbol: AppSeedData.currencySymbol);
    final accent = _isTopUp ? AppColors.success : AppColors.brand;
    final soft = _isTopUp ? AppColors.successSoft : AppColors.brandSoft;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: soft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _isTopUp ? Icons.add_card_rounded : Icons.directions_bus_rounded,
              color: accent,
            ),
          ),
          const SizedBox(width: 14),
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
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatter.format(item.date),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_isTopUp ? '+' : '-'}${currency.format(item.amount)}',
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: soft,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  item.method,
                  style: TextStyle(
                    color: accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
