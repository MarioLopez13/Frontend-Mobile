import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartpayut_mobile/features/wallet/data/models/transaction_item.dart';
import 'package:smartpayut_mobile/features/wallet/data/repositories/wallet_repository.dart';
import 'package:smartpayut_mobile/shared/config/app_seed_data.dart';
import 'package:smartpayut_mobile/shared/models/app_user.dart';

class MockWalletRepository implements WalletRepository {
  static const _balancePrefix = 'smartpayut_wallet_balance_';
  static const _transactionsPrefix = 'smartpayut_wallet_transactions_';

  const MockWalletRepository();

  @override
  Future<double> getAvailableBalance(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await _ensureWalletInitialized(prefs, user);

    return prefs.getDouble(_balanceKey(user)) ?? 0.0;
  }

  @override
  Future<List<TransactionItem>> getTransactions(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await _ensureWalletInitialized(prefs, user);

    final rawTransactions = prefs.getString(_transactionsKey(user));

    if (rawTransactions == null || rawTransactions.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(rawTransactions) as List<dynamic>;

    return decoded
        .map(
          (item) => TransactionItem.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  @override
  Future<TransactionItem> registerPayment({
    required AppUser user,
    required String title,
    required String subtitle,
    required double amount,
    required String method,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await _ensureWalletInitialized(prefs, user);

    final currentBalance = prefs.getDouble(_balanceKey(user)) ?? 0.0;

    if (currentBalance < amount) {
      throw StateError('No tienes saldo suficiente para realizar el pago.');
    }

    final transaction = TransactionItem(
      id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      subtitle: subtitle,
      amount: amount,
      date: DateTime.now(),
      method: method,
      status: 'Completado',
    );

    final currentTransactions = await getTransactions(user);
    final updatedTransactions = [transaction, ...currentTransactions];
    final updatedBalance = double.parse(
      (currentBalance - amount).toStringAsFixed(2),
    );

    await prefs.setDouble(_balanceKey(user), updatedBalance);
    await prefs.setString(
      _transactionsKey(user),
      jsonEncode(updatedTransactions.map((item) => item.toJson()).toList()),
    );

    return transaction;
  }

  @override
  Future<void> syncBalanceFromBackend(AppUser user) async {
    final backendBalance = user.backendBalance;

    if (backendBalance == null) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await _ensureTransactionsInitialized(prefs, user);

    await prefs.setDouble(
      _balanceKey(user),
      double.parse(backendBalance.toStringAsFixed(2)),
    );
  }

  Future<void> _ensureWalletInitialized(
    SharedPreferences prefs,
    AppUser user,
  ) async {
    await _ensureTransactionsInitialized(prefs, user);

    final balanceKey = _balanceKey(user);
    final hasBalance = prefs.containsKey(balanceKey);

    if (hasBalance) {
      return;
    }

    final initialBalance = _resolveInitialBalance(user);
    await prefs.setDouble(balanceKey, initialBalance);
  }

  Future<void> _ensureTransactionsInitialized(
    SharedPreferences prefs,
    AppUser user,
  ) async {
    final transactionsKey = _transactionsKey(user);
    final hasTransactions = prefs.containsKey(transactionsKey);

    if (hasTransactions) {
      return;
    }

    final useSeedData = _shouldUseSeedData(user);
    final initialTransactions =
        useSeedData ? _buildSeedTransactions() : <TransactionItem>[];

    await prefs.setString(
      transactionsKey,
      jsonEncode(initialTransactions.map((item) => item.toJson()).toList()),
    );
  }

  double _resolveInitialBalance(AppUser user) {
    if (user.backendBalance != null) {
      return double.parse(user.backendBalance!.toStringAsFixed(2));
    }

    final useSeedData = _shouldUseSeedData(user);
    return useSeedData ? AppSeedData.demoAvailableBalance : 0.0;
  }

  bool _shouldUseSeedData(AppUser user) {
    final email = user.email.trim().toLowerCase();

    return email == 'admin@kynsoft.com' ||
        email == 'operator@kynsoft.com' ||
        email == 'user@kynsoft.com' ||
        email == 'demo@smartpayout.com' ||
        email == 'admin@smartpayout.com' ||
        email == 'operator@smartpayout.com';
  }

  List<TransactionItem> _buildSeedTransactions() {
    return [
      TransactionItem(
        id: 'tx-001',
        title: 'Bus 001',
        subtitle: '12 de Octubre',
        amount: 0.35,
        date: DateTime(2026, 4, 10, 7, 45),
        method: 'QR',
        status: 'Completado',
      ),
      TransactionItem(
        id: 'tx-002',
        title: 'Bus 832',
        subtitle: 'Eloy Alfaro',
        amount: 0.35,
        date: DateTime(2026, 4, 9, 18, 10),
        method: 'NFC',
        status: 'Completado',
      ),
      TransactionItem(
        id: 'tx-003',
        title: 'Bus 145',
        subtitle: 'Corredor Central',
        amount: 0.35,
        date: DateTime(2026, 4, 8, 12, 20),
        method: 'QR',
        status: 'Completado',
      ),
      TransactionItem(
        id: 'tx-004',
        title: 'Bus 204',
        subtitle: 'La Marín',
        amount: 0.35,
        date: DateTime(2026, 4, 7, 8, 05),
        method: 'NFC',
        status: 'Completado',
      ),
      TransactionItem(
        id: 'tx-005',
        title: 'Bus 517',
        subtitle: 'Quitumbe',
        amount: 0.35,
        date: DateTime(2026, 4, 6, 17, 40),
        method: 'QR',
        status: 'Completado',
      ),
    ];
  }

  String _balanceKey(AppUser user) => '$_balancePrefix${_userKey(user)}';

  String _transactionsKey(AppUser user) =>
      '$_transactionsPrefix${_userKey(user)}';

  String _userKey(AppUser user) {
    return user.email
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '_');
  }
}