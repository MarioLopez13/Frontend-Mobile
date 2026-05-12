import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpayut_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:smartpayut_mobile/shared/theme/app_colors.dart';

class ProfileSecurityPage extends ConsumerStatefulWidget {
  const ProfileSecurityPage({super.key});

  @override
  ConsumerState<ProfileSecurityPage> createState() =>
      _ProfileSecurityPageState();
}

class _ProfileSecurityPageState extends ConsumerState<ProfileSecurityPage> {
  bool _isSending = false;
  bool _sent = false;

  Future<void> _sendRecoveryMock() async {
    setState(() {
      _isSending = true;
      _sent = false;
    });

    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) {
      return;
    }

    setState(() {
      _isSending = false;
      _sent = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Enlace de recuperación generado en modo mock.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider);
    final email = user?.email ?? 'correo@kynsoft.com';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seguridad'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.shield_outlined,
                  color: Colors.white,
                  size: 34,
                ),
                SizedBox(height: 14),
                Text(
                  'Seguridad de cuenta',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Opciones temporales para recuperación y protección de acceso.',
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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recuperación de contraseña',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Se generará un enlace mock de recuperación para $email.',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isSending ? null : _sendRecoveryMock,
                      icon: _isSending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.mark_email_read_outlined),
                      label: Text(
                        _isSending
                            ? 'Generando enlace...'
                            : 'Generar enlace mock',
                      ),
                    ),
                  ),
                  if (_sent) ...[
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.successSoft,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: AppColors.success,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Flujo mock completado. Cuando backend esté listo, aquí se consumirá el endpoint real de recuperación.',
                              style: TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: const [
                  _SecurityItem(
                    icon: Icons.lock_outline,
                    title: 'Contraseña',
                    subtitle: 'Cambio temporal mediante recuperación mock.',
                  ),
                  SizedBox(height: 14),
                  _SecurityItem(
                    icon: Icons.verified_user_outlined,
                    title: 'Sesión activa',
                    subtitle: 'Control básico de sesión local.',
                  ),
                  SizedBox(height: 14),
                  _SecurityItem(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacidad',
                    subtitle: 'Preparado para políticas reales del sistema.',
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

class _SecurityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SecurityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: AppColors.brandSoft,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.brand),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}