import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:smartpayut_mobile/app/router/route_paths.dart';
import 'package:smartpayut_mobile/features/payments/data/models/nfc_payment_payload.dart';

class NfcScanPage extends StatefulWidget {
  const NfcScanPage({super.key});

  @override
  State<NfcScanPage> createState() => _NfcScanPageState();
}

class _NfcScanPageState extends State<NfcScanPage> {
  bool _isReading = false;
  String? _errorMessage;
  String _statusMessage = 'Presiona el botón para iniciar la lectura NFC.';

  Future<void> _startReading() async {
    if (_isReading) {
      return;
    }

    final availability = await NfcManager.instance.checkAvailability();

    if (availability != NfcAvailability.enabled) {
      setState(() {
        _errorMessage =
            'NFC no está disponible o está desactivado en este dispositivo.';
        _statusMessage = 'Activa NFC e intenta nuevamente.';
      });
      return;
    }

    setState(() {
      _isReading = true;
      _errorMessage = null;
      _statusMessage = 'Acerca el teléfono a un tag NFC.';
    });

    try {
      await NfcManager.instance.startSession(
        pollingOptions: {NfcPollingOption.iso14443},
        onDiscovered: (tag) async {
          final rawTag = tag.toString().trim();
          final payload = NfcPaymentPayload.tryParse(rawTag);

          await _stopSession();

          if (!mounted) {
            return;
          }

          if (payload == null) {
            setState(() {
              _isReading = false;
              _errorMessage = 'No se pudo interpretar el tag NFC.';
              _statusMessage = 'Intenta nuevamente.';
            });
            return;
          }

          setState(() {
            _isReading = false;
            _errorMessage = null;
            _statusMessage = 'Tag detectado correctamente.';
          });

          await context.push(RoutePaths.nfcConfirm, extra: payload);

          if (!mounted) {
            return;
          }

          setState(() {
            _statusMessage = 'Lectura finalizada. Puedes volver a iniciar.';
          });
        },
        onSessionErrorIos: (error) {
          if (!mounted) {
            return;
          }

          setState(() {
            _isReading = false;
            _errorMessage = 'Falló la lectura NFC. Intenta nuevamente.';
            _statusMessage = 'Presiona el botón para reintentar.';
          });
        },
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isReading = false;
        _errorMessage = 'No se pudo iniciar la sesión NFC.';
        _statusMessage = 'Intenta nuevamente.';
      });
    }
  }

  Future<void> _cancelReading() async {
    await _stopSession();

    if (!mounted) {
      return;
    }

    setState(() {
      _isReading = false;
      _errorMessage = null;
      _statusMessage = 'Lectura cancelada. Puedes volver a iniciar.';
    });
  }

  Future<void> _stopSession() async {
    try {
      await NfcManager.instance.stopSession();
    } catch (_) {}
  }

  @override
  void dispose() {
    _stopSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lectura NFC'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(
            Icons.nfc,
            size: 88,
            color: Color(0xFF9333EA),
          ),
          const SizedBox(height: 16),
          const Text(
            'Pago con NFC',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _statusMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 24),
          if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Color(0xFFB91C1C),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (_errorMessage != null) const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Text(
              'En esta versión controlada, cualquier tag NFC leído se transforma en una unidad demo para completar el flujo de pago.',
              style: TextStyle(
                color: Color(0xFF334155),
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isReading ? null : _startReading,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              _isReading ? 'Esperando tag NFC...' : 'Iniciar lectura NFC',
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _isReading ? _cancelReading : null,
            child: const Text('Cancelar lectura'),
          ),
        ],
      ),
    );
  }
}