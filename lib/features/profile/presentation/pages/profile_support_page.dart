import 'package:flutter/material.dart';
import 'package:smartpayut_mobile/shared/config/app_seed_data.dart';
import 'package:smartpayut_mobile/shared/theme/app_colors.dart';

class ProfileSupportPage extends StatelessWidget {
  const ProfileSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayuda y soporte'),
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
                  Icons.support_agent_outlined,
                  color: Colors.white,
                  size: 34,
                ),
                SizedBox(height: 14),
                Text(
                  'Soporte SmartPayUT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Información temporal de asistencia para el usuario final.',
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
                children: const [
                  _SupportTile(
                    icon: Icons.mail_outline,
                    title: 'Correo de soporte',
                    value: AppSeedData.supportEmail,
                  ),
                  SizedBox(height: 16),
                  _SupportTile(
                    icon: Icons.phone_outlined,
                    title: 'Teléfono',
                    value: '+593 99 999 9999',
                  ),
                  SizedBox(height: 16),
                  _SupportTile(
                    icon: Icons.schedule_outlined,
                    title: 'Horario',
                    value: 'Lunes a viernes · 09:00 - 18:00',
                  ),
                  SizedBox(height: 16),
                  _SupportTile(
                    icon: Icons.location_on_outlined,
                    title: 'Ubicación',
                    value: 'Quito, Ecuador',
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
                children: const [
                  Text(
                    'Preguntas frecuentes',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 16),
                  _FaqItem(
                    question: '¿Cómo recargo saldo?',
                    answer:
                        'Desde Inicio, selecciona Recargar y confirma el monto. Actualmente funciona en modo mock.',
                  ),
                  _FaqItem(
                    question: '¿Cómo pago con QR?',
                    answer:
                        'Selecciona Pagar QR y escanea el código fijo de la unidad de transporte.',
                  ),
                  _FaqItem(
                    question: '¿Cómo pago con NFC?',
                    answer:
                        'Selecciona Pagar NFC y acerca el dispositivo al lector o tag compatible.',
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

class _SupportTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _SupportTile({
    required this.icon,
    required this.title,
    required this.value,
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
              Text(title, style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqItem({
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              answer,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
          ),
        ),
      ],
    );
  }
}