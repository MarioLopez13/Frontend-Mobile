import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smartpayut_mobile/app/router/route_paths.dart';
import 'package:smartpayut_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:smartpayut_mobile/shared/config/app_seed_data.dart';
import 'package:smartpayut_mobile/shared/models/app_user.dart';
import 'package:smartpayut_mobile/shared/theme/app_colors.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider);

    final displayName =
        (user?.name.trim().isNotEmpty ?? false) ? user!.name : 'Usuario';
    final displayEmail =
        (user?.email.trim().isNotEmpty ?? false)
            ? user!.email
            : AppSeedData.supportEmail;
    final displayPhone =
        (user?.phone?.trim().isNotEmpty ?? false)
            ? user!.phone!
            : 'No registrado';
    final displayDocumentId =
    (user?.documentId?.trim().isNotEmpty ?? false)
        ? user!.documentId!
        : 'No registrado';
    final displayCity =
        (user?.city?.trim().isNotEmpty ?? false)
            ? user!.city!
            : 'Quito';
    final displayRole = user != null ? mapUserRoleLabel(user.role) : 'Usuario';

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
              child: Row(
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          displayRole,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            displayEmail,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
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
                      'Información de cuenta',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _ProfileInfoTile(
                      icon: Icons.person_outline,
                      label: 'Nombre completo',
                      value: displayName,
                    ),
                    const SizedBox(height: 16),
                    _ProfileInfoTile(
                      icon: Icons.mail_outline,
                      label: 'Correo electrónico',
                      value: displayEmail,
                    ),
                    const SizedBox(height: 16),
                    _ProfileInfoTile(
                      icon: Icons.phone_outlined,
                      label: 'Teléfono',
                      value: displayPhone,
                    ),
                    const SizedBox(height: 16),
                    _ProfileInfoTile(
                      icon: Icons.badge_outlined,
                      label: 'Cédula',
                      value: displayDocumentId,
                    ),
                    const SizedBox(height: 16),
                    _ProfileInfoTile(
                      icon: Icons.location_city_outlined,
                      label: 'Ciudad',
                      value: displayCity,
                    ),
                    const SizedBox(height: 16),
                    _ProfileInfoTile(
                      icon: Icons.shield_outlined,
                      label: 'Rol',
                      value: displayRole,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Acciones disponibles',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _ActionRow(
                      title: 'Recargar saldo',
                      subtitle: 'Abrir mock de Place to Pay',
                      onTap: () => context.push(RoutePaths.topUp),
                    ),
                    const SizedBox(height: 10),
                    _ActionRow(
                      title: 'Editar datos personales',
                      subtitle: 'Actualizar información del usuario',
                      onTap: () => context.push(RoutePaths.editProfile),
                    ),
                    const SizedBox(height: 10),
                    _ActionRow(
                      title: 'Seguridad y privacidad',
                      subtitle: 'Recuperación y control de acceso',
                      onTap: () => context.push(RoutePaths.profileSecurity),
                    ),
                    const SizedBox(height: 10),
                    _ActionRow(
                      title: 'Ayuda y soporte',
                      subtitle: 'Información de contacto y preguntas frecuentes',
                      onTap: () => context.push(RoutePaths.profileSupport),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
                onPressed: () async {
                  await ref.read(authControllerProvider.notifier).logout();
                  if (context.mounted) {
                    context.go(RoutePaths.login);
                  }
                },
                child: const Text('Cerrar sesión'),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${AppSeedData.companyName} · App móvil\nVersión 1.0.0 · Sprint 3',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String mapUserRoleLabel(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return 'Administrador';
    case UserRole.operator:
      return 'Operador';
    case UserRole.user:
      return 'Usuario';
  }
}

class _ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.brandSoft,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.brand, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _ActionRow({
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.brandSoft,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.chevron_right_rounded, color: AppColors.brand),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
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
          ),
        ),
      ),
    );
  }
}
