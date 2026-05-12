import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smartpayut_mobile/app/router/route_paths.dart';
import 'package:smartpayut_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:smartpayut_mobile/shared/theme/app_colors.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? errorMessage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await ref.read(authControllerProvider.notifier).loadSession();
      final user = ref.read(authControllerProvider);
      if (user != null && mounted) {
        context.go(RoutePaths.home);
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final error = await ref.read(authControllerProvider.notifier).login(
          email: _emailController.text,
          password: _passwordController.text,
        );

    if (!mounted) {
      return;
    }

    setState(() {
      isLoading = false;
      errorMessage = error;
    });

    if (error == null) {
      context.go(RoutePaths.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.brandDark, AppColors.brand],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Image.asset('assets/images/kynsoft_logo.png'),
                        ),
                        const SizedBox(height: 22),
                        const Text(
                          'Bienvenido a SmartPayUT',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 30,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Ingresa con tu cuenta para pagar transporte, revisar tu saldo y administrar tus movimientos.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Iniciar sesión',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Usa tus credenciales para acceder al entorno móvil.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Correo electrónico',
                              hintText: 'correo@dominio.com',
                              prefixIcon: Icon(Icons.mail_outline),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _handleLogin(),
                            decoration: const InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: isLoading
                                  ? null
                                  : () => context.go(RoutePaths.forgotPassword),
                              child: const Text('¿Olvidaste tu contraseña?'),
                            ),
                          ),
                          if (errorMessage != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.dangerSoft,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                errorMessage!,
                                style: const TextStyle(
                                  color: AppColors.danger,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: isLoading ? null : _handleLogin,
                              child: Text(
                                isLoading ? 'Ingresando...' : 'Ingresar',
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: isLoading
                                  ? null
                                  : () => context.go(RoutePaths.register),
                              child: const Text('Crear cuenta'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
