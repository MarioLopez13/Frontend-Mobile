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
    final cleanValue = rawValue.trim();

    if (cleanValue.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(cleanValue);

    if (uri == null) {
      return null;
    }

    final payloadFromQuery = _fromQueryParameters(
      rawValue: cleanValue,
      queryParameters: uri.queryParameters,
    );

    if (payloadFromQuery != null) {
      return payloadFromQuery;
    }

    final rawQueryLikeValue = Uri.tryParse('smartpayut://pay?$cleanValue');

    if (rawQueryLikeValue == null) {
      return null;
    }

    return _fromQueryParameters(
      rawValue: cleanValue,
      queryParameters: rawQueryLikeValue.queryParameters,
    );
  }

  static QrPaymentPayload? _fromQueryParameters({
    required String rawValue,
    required Map<String, String> queryParameters,
  }) {
    final busCode = (
      queryParameters['bus'] ??
      queryParameters['busCode'] ??
      queryParameters['unit'] ??
      ''
    ).trim();

    final routeName = (
      queryParameters['route'] ??
      queryParameters['routeName'] ??
      queryParameters['line'] ??
      ''
    ).trim();

    final amountText = (
      queryParameters['amount'] ??
      queryParameters['value'] ??
      queryParameters['price'] ??
      ''
    ).trim();

    final amount = double.tryParse(amountText.replaceAll(',', '.'));

    if (busCode.isEmpty) {
      return null;
    }

    if (routeName.isEmpty) {
      return null;
    }

    if (amount == null || amount <= 0) {
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