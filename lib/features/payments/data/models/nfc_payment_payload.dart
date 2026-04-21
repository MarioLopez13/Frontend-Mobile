class NfcPaymentPayload {
  final String rawData;
  final String tagReference;
  final String busCode;
  final String routeName;
  final double amount;

  const NfcPaymentPayload({
    required this.rawData,
    required this.tagReference,
    required this.busCode,
    required this.routeName,
    required this.amount,
  });

  String get title => 'Bus $busCode';

  static const List<String> _demoRoutes = [
    '12 de Octubre',
    'Eloy Alfaro',
    'Corredor Central',
    'La Marín',
    'Quitumbe',
  ];

  static NfcPaymentPayload? tryParse(String rawData) {
    final normalized = rawData.trim();
    if (normalized.isEmpty) {
      return null;
    }

    final hash = normalized.hashCode.abs();
    final busCode = ((hash % 900) + 100).toString();
    final routeName = _demoRoutes[hash % _demoRoutes.length];

    return NfcPaymentPayload(
      rawData: normalized,
      tagReference: 'TAG-$busCode',
      busCode: busCode,
      routeName: routeName,
      amount: 0.35,
    );
  }
}