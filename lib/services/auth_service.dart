import 'dart:convert';

import 'package:pbp_django_auth/pbp_django_auth.dart';

import '../config/app_config.dart';
import '../models/session_user.dart';

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

class AuthService {
  AuthService(this.request);

  final CookieRequest request;

  Future<String> _prepareCsrfToken() async {
    final response = await request
        .get(AppConfig.api('/api/auth/csrf/'))
        .timeout(AppConfig.networkTimeout);
    if (response is Map && response['csrfToken'] is String) {
      final token = response['csrfToken'] as String;
      if (token.isNotEmpty) return token;
    }
    throw const AuthException(
        'Gagal mengambil token keamanan. Coba beberapa saat lagi.');
  }

  Future<T> _withCsrf<T>(Future<T> Function() action) async {
    final csrfToken = await _prepareCsrfToken();
    final previousToken = request.headers['X-CSRFToken'];
    final previousReferer = request.headers['Referer'];
    request.headers['X-CSRFToken'] = csrfToken;
    request.headers['Referer'] = AppConfig.baseUrl;
    try {
      return await action();
    } finally {
      if (previousToken == null) {
        request.headers.remove('X-CSRFToken');
      } else {
        request.headers['X-CSRFToken'] = previousToken;
      }
      if (previousReferer == null) {
        request.headers.remove('Referer');
      } else {
        request.headers['Referer'] = previousReferer;
      }
    }
  }

  Future<SessionUser> login({
    required String username,
    required String password,
  }) async {
    final response = await _withCsrf(() async {
      return request.login(
        AppConfig.api('/api/auth/login/'),
        {'username': username, 'password': password},
      );
    });

    if (!request.loggedIn) {
      final errors = response['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final description = errors.values.first;
        if (description is List && description.isNotEmpty) {
          throw AuthException(description.first.toString());
        }
      }
      throw const AuthException('Username atau kata sandi salah.');
    }

    return SessionUser.fromJson(
      response['user'] as Map<String, dynamic>?,
      lastLogin: response['last_login'] as String?,
    );
  }

  Future<SessionUser> register({
    required String username,
    required String password,
    required String passwordConfirmation,
    String? firstName,
    String? lastName,
    String? email,
  }) async {
    final response = await _withCsrf(() async {
      return request.postJson(
        AppConfig.api('/api/auth/register/'),
        jsonEncode({
          'username': username,
          'password1': password,
          'password2': passwordConfirmation,
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
        }),
      );
    });

    if (response is! Map || response['ok'] != true) {
      final errors = response['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final buffer = StringBuffer();
        for (final entry in errors.entries) {
          buffer.writeln('${entry.key}: ${entry.value}');
        }
        throw AuthException(buffer.toString().trim());
      }
      throw const AuthException(
          'Registrasi gagal. Pastikan seluruh data valid.');
    }

    // Set status logged in for CookieRequest by performing a real login.
    await login(username: username, password: password);

    return SessionUser.fromJson(
      response['user'] as Map<String, dynamic>?,
      lastLogin: response['last_login'] as String?,
    );
  }

  Future<void> logout() async {
    if (!request.loggedIn) return;
    await _withCsrf(() async {
      await request.logout(AppConfig.api('/api/auth/logout/'));
    });
  }

  void dispose() {}
}
