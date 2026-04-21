abstract final class AppEnvironment {
  static const String _apiBaseUrlFromDefine = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static const bool useMockPayments = bool.fromEnvironment(
    'USE_MOCK_PAYMENTS',
    defaultValue: true,
  );

  static const String fallbackApiBaseUrl = 'http://192.168.1.17:9909/api';

  static String get apiBaseUrl {
    final value = _apiBaseUrlFromDefine.trim();

    if (value.isEmpty) {
      return fallbackApiBaseUrl;
    }

    return _normalizeBaseUrl(value);
  }

  static String _normalizeBaseUrl(String value) {
    final trimmed = value.trim();

    if (trimmed.endsWith('/')) {
      return trimmed.substring(0, trimmed.length - 1);
    }

    return trimmed;
  }
}