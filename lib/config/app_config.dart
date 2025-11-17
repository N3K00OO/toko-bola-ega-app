import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kDebugMode, kIsWeb;

class AppConfig {
  const AppConfig._();

  static final String baseUrl = _resolveBaseUrl();

  static String _resolveBaseUrl() {
    const override = String.fromEnvironment('API_BASE_URL');
    if (override.isNotEmpty) return override;

    if (kIsWeb) {
      final host = Uri.base.host;
      if (host == 'localhost' || host == '127.0.0.1') {
        final scheme = Uri.base.scheme.isEmpty ? 'http' : Uri.base.scheme;
        return '$scheme://$host:8000';
      }
    } else if (kDebugMode) {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          return 'http://10.0.2.2:8000';
        case TargetPlatform.iOS:
        case TargetPlatform.macOS:
        case TargetPlatform.windows:
        case TargetPlatform.linux:
          return 'http://127.0.0.1:8000';
        case TargetPlatform.fuchsia:
          break;
      }
    }

    return 'https://gregorius-ega-tokobolaega.pbp.cs.ui.ac.id';
  }

  static String api(String endpoint) {
    if (endpoint.isEmpty) return baseUrl;
    final normalized = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    return '$baseUrl$normalized';
  }

  static const Duration networkTimeout = Duration(seconds: 25);
}
