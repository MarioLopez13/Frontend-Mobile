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

final walletActionControllerProvider =
    NotifierProvider<WalletActionController, WalletActionState>(
  WalletActionController.new,
);

class WalletActionState {
  final bool isProcessing;
  final String? errorMessage;
  final String? successMessage;

  const WalletActionState({
    this.isProcessing = false,
    this.errorMessage,
    this.successMessage,
  });

  WalletActionState copyWith({
    bool? isProcessing,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return WalletActionState(
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}

class WalletActionController extends Notifier<WalletActionState> {
  late final WalletRepository _walletRepository;

  @override
  WalletActionState build() {
    _walletRepository = ref.read(walletRepositoryProvider);
    return const WalletActionState();
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }

  Future<bool> topUpBalance({
    required double amount,
  }) async {
    if (state.isProcessing) {
      return false;
    }

    final user = ref.read(authControllerProvider);
    if (user == null) {
      state = state.copyWith(
        errorMessage: 'Tu sesión expiró. Vuelve a iniciar sesión.',
      );
      return false;
    }

    if (amount <= 0) {
      state = state.copyWith(
        errorMessage: 'Ingresa un monto de recarga válido.',
      );
      return false;
    }

    state = state.copyWith(
      isProcessing: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      await _walletRepository.topUpBalance(user: user, amount: amount);

      ref.invalidate(walletBalanceProvider);
      ref.invalidate(walletTransactionsProvider);

      state = state.copyWith(
        isProcessing: false,
        successMessage:
            'Recarga registrada correctamente con flujo mock de Place to Pay.',
      );

      return true;
    } catch (error) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: error is StateError
            ? error.message.toString()
            : 'No fue posible procesar la recarga.',
      );
      return false;
    }
  }
}
