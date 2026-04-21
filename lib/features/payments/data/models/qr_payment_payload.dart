class QrPaymentPayload {
  final String rawValue;
  final String busCode;
  final String routeName;
  final double amount;

  const QrPaymentPayload({
    required this.rawValue,
    required this.busCode,
    required this.routeName,
    required this.amount,
  });

  String get title => 'Bus $busCode';

  static QrPaymentPayload? tryParse(String rawValue) {
    final uri = Uri.tryParse(rawValue.trim());

    if (uri == null) {
      return null;
    }

    final scheme = uri.scheme.trim().toLowerCase();
    final action = uri.host.trim().toLowerCase();

    final busCode = (uri.queryParameters['bus'] ?? '').trim();
    final routeName = (uri.queryParameters['route'] ?? '').trim();
    final amount = double.tryParse((uri.queryParameters['amount'] ?? '').trim());

    if (scheme != 'smartpayut' || action != 'pay') {
      return null;
    }

    if (busCode.isEmpty || routeName.isEmpty || amount == null || amount <= 0) {
      return null;
    }

    return QrPaymentPayload(
      rawValue: rawValue,
      busCode: busCode,
      routeName: routeName,
      amount: double.parse(amount.toStringAsFixed(2)),
    );
  }
}