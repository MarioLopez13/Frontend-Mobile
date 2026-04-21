import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpayut_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:smartpayut_mobile/features/wallet/data/models/transaction_item.dart';
import 'package:smartpayut_mobile/features/wallet/data/repositories/mock_wallet_repository.dart';
import 'package:smartpayut_mobile/features/wallet/data/repositories/wallet_repository.dart';

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return const MockWalletRepository();
});

final walletBalanceProvider = FutureProvider<double>((ref) async {
  final repository = ref.read(walletRepositoryProvider);
  final user = ref.watch(authControllerProvider);

  if (user == null) {
    return 0.00;
  }

  return repository.getAvailableBalance(user);
});

final walletTransactionsProvider =
    FutureProvider<List<TransactionItem>>((ref) async {
  final repository = ref.read(walletRepositoryProvider);
  final user = ref.watch(authControllerProvider);

  if (user == null) {
    return [];
  }

  return repository.getTransactions(user);
});