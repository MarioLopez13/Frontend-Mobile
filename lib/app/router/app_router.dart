import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smartpayut_mobile/app/router/route_names.dart';
import 'package:smartpayut_mobile/app/router/route_paths.dart';
import 'package:smartpayut_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:smartpayut_mobile/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:smartpayut_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:smartpayut_mobile/features/auth/presentation/pages/register_page.dart';
import 'package:smartpayut_mobile/features/auth/presentation/pages/reset_password_page.dart';
import 'package:smartpayut_mobile/features/history/presentation/pages/history_page.dart';
import 'package:smartpayut_mobile/features/home/presentation/pages/home_page.dart';
import 'package:smartpayut_mobile/features/payments/data/models/nfc_payment_payload.dart';
import 'package:smartpayut_mobile/features/payments/data/models/payment_execution_result.dart';
import 'package:smartpayut_mobile/features/payments/data/models/qr_payment_payload.dart';
import 'package:smartpayut_mobile/features/payments/presentation/pages/nfc_payment_confirm_page.dart';
import 'package:smartpayut_mobile/features/payments/presentation/pages/nfc_scan_page.dart';
import 'package:smartpayut_mobile/features/payments/presentation/pages/payment_result_page.dart';
import 'package:smartpayut_mobile/features/payments/presentation/pages/payments_page.dart';
import 'package:smartpayut_mobile/features/payments/presentation/pages/qr_payment_confirm_page.dart';
import 'package:smartpayut_mobile/features/payments/presentation/pages/qr_scan_page.dart';
import 'package:smartpayut_mobile/features/profile/presentation/pages/profile_page.dart';
import 'package:smartpayut_mobile/features/wallet/presentation/pages/top_up_page.dart';
import 'package:smartpayut_mobile/shared/widgets/main_shell_page.dart';
import 'package:smartpayut_mobile/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:smartpayut_mobile/features/profile/presentation/pages/profile_security_page.dart';
import 'package:smartpayut_mobile/features/profile/presentation/pages/profile_support_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: RoutePaths.login,
    redirect: (context, state) {
      final isLoggedIn = authState != null;
      final publicRoutes = {
        RoutePaths.login,
        RoutePaths.register,
        RoutePaths.forgotPassword,
        RoutePaths.resetPassword,
      };
      final isPublicRoute = publicRoutes.contains(state.matchedLocation);

      if (!isLoggedIn && !isPublicRoute) {
        return RoutePaths.login;
      }

      if (isLoggedIn && isPublicRoute) {
        return RoutePaths.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RoutePaths.register,
        name: RouteNames.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        name: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: RoutePaths.resetPassword,
        name: RouteNames.resetPassword,
        builder: (context, state) {
          final token = state.uri.queryParameters['token'];
          final email = state.uri.queryParameters['email'];

          return ResetPasswordPage(
            token: token,
            email: email,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.qrScanner,
        name: RouteNames.qrScanner,
        builder: (context, state) => const QrScanPage(),
      ),
      GoRoute(
        path: RoutePaths.qrConfirm,
        name: RouteNames.qrConfirm,
        builder: (context, state) {
          final payload = state.extra;
          if (payload is! QrPaymentPayload) {
            return const _MissingPaymentDataPage();
          }

          return QrPaymentConfirmPage(payload: payload);
        },
      ),
      GoRoute(
        path: RoutePaths.paymentResult,
        name: RouteNames.paymentResult,
        builder: (context, state) {
          final result = state.extra;
          if (result is! PaymentExecutionResult) {
            return const _MissingPaymentDataPage();
          }

          return PaymentResultPage(result: result);
        },
      ),
      GoRoute(
        path: RoutePaths.nfcReader,
        name: RouteNames.nfcReader,
        builder: (context, state) => const NfcScanPage(),
      ),
      GoRoute(
        path: RoutePaths.nfcConfirm,
        name: RouteNames.nfcConfirm,
        builder: (context, state) {
          final payload = state.extra;
          if (payload is! NfcPaymentPayload) {
            return const _MissingPaymentDataPage();
          }

          return NfcPaymentConfirmPage(payload: payload);
        },
      ),
      GoRoute(
        path: RoutePaths.topUp,
        name: RouteNames.topUp,
        builder: (context, state) => const TopUpPage(),
      ),
      GoRoute(
        path: RoutePaths.editProfile,
        name: RouteNames.editProfile,
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: RoutePaths.profileSecurity,
        name: RouteNames.profileSecurity,
        builder: (context, state) => const ProfileSecurityPage(),
      ),
      GoRoute(
        path: RoutePaths.profileSupport,
        name: RouteNames.profileSupport,
        builder: (context, state) => const ProfileSupportPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShellPage(child: child),
        routes: [
          GoRoute(
            path: RoutePaths.home,
            name: RouteNames.home,
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: RoutePaths.payments,
            name: RouteNames.payments,
            builder: (context, state) => const PaymentsPage(),
          ),
          GoRoute(
            path: RoutePaths.history,
            name: RouteNames.history,
            builder: (context, state) => const HistoryPage(),
          ),
          GoRoute(
            path: RoutePaths.profile,
            name: RouteNames.profile,
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
    ],
  );
});

class _MissingPaymentDataPage extends StatelessWidget {
  const _MissingPaymentDataPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Información incompleta')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No se encontró la información del pago. Regresa y vuelve a intentar.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
