import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:smartpayut_mobile/app/router/route_paths.dart';
import 'package:smartpayut_mobile/features/payments/data/models/qr_payment_payload.dart';

class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key});

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
  );

  bool _isHandlingScan = false;
  String? _scanError;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _handleDetection(BarcodeCapture capture) async {
    if (_isHandlingScan) {
      return;
    }

    final rawValue = capture.barcodes.isEmpty
        ? null
        : capture.barcodes.first.rawValue?.trim();

    if (rawValue == null || rawValue.isEmpty) {
      _showScanError('No se pudo leer el código QR.');
      return;
    }

    final payload = QrPaymentPayload.tryParse(rawValue);

    if (payload == null) {
      _showScanError('El código QR no es válido para este pago.');
      return;
    }

    _isHandlingScan = true;
    setState(() {
      _scanError = null;
    });

    await _scannerController.stop();

    if (!mounted) {
      return;
    }

    await context.push(RoutePaths.qrConfirm, extra: payload);

    if (!mounted) {
      return;
    }

    _isHandlingScan = false;
    await _scannerController.start();
  }

  void _showScanError(String message) {
    if (_isHandlingScan) {
      return;
    }

    _isHandlingScan = true;

    setState(() {
      _scanError = message;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) {
        return;
      }

      setState(() {
        _scanError = null;
      });

      _isHandlingScan = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear QR del bus'),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _handleDetection,
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: Colors.black.withValues(alpha: 0.28),
                child: Center(
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_scanError != null)
            Positioned(
              top: 20,
              left: 16,
              right: 16,
              child: _ScanMessageBanner(
                message: _scanError!,
                backgroundColor: const Color(0xFFFEF2F2),
                textColor: const Color(0xFFB91C1C),
              ),
            ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ubica el QR fijo de la unidad dentro del recuadro.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'El sistema validará el código y te llevará a la confirmación del pago.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
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

class _ScanMessageBanner extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  final Color textColor;

  const _ScanMessageBanner({
    required this.message,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}