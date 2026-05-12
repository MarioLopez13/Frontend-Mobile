import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smartpayut_mobile/app/router/route_paths.dart';
import 'package:smartpayut_mobile/shared/theme/app_colors.dart';

class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagos'),
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
                Text(
                  'Paga tu viaje de forma rápida',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Selecciona el método de pago que mejor se adapte al escenario de uso del pasajero.',
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
          _PaymentMethodCard(
            icon: Icons.qr_code_2_rounded,
            title: 'Pago con QR',
            description:
                'Escanea el código de la unidad para registrar el pago de manera inmediata.',
            buttonLabel: 'Escanear QR',
            onTap: () => context.push(RoutePaths.qrScanner),
          ),
          const SizedBox(height: 14),
          _PaymentMethodCard(
            icon: Icons.nfc_rounded,
            title: 'Pago con NFC',
            description:
                'Acerca el dispositivo al tag o lector NFC para validar el cobro sin contacto.',
            buttonLabel: 'Abrir lector NFC',
            onTap: () => context.push(RoutePaths.nfcReader),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.brandSoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: AppColors.brand),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'El flujo de recargas se maneja desde Inicio mediante un mock preparado para futura integración con Place to Pay.',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback onTap;

  const _PaymentMethodCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.brandSoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppColors.brand),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onTap,
                icon: Icon(icon),
                label: Text(buttonLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
