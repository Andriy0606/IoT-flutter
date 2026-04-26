import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

final class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const Map<String, String> _defaultHeaders = <String, String>{
    'Accept': 'application/json',
    // Some public mock APIs block unknown clients; this avoids 403s.
    'User-Agent': 'Mozilla/5.0 (Flutter; Dart)',
  };

  Map<String, String> _mergeHeaders(Map<String, String>? headers) {
    if (headers == null || headers.isEmpty) return _defaultHeaders;
    return <String, String>{..._defaultHeaders, ...headers};
  }

  Future<Map<String, Object?>> getJsonObject(
    Uri url, {
    Map<String, String>? headers,
  }) async {
    final res = await _client
        .get(url, headers: _mergeHeaders(headers))
        .timeout(const Duration(seconds: 10));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException('HTTP ${res.statusCode}');
    }

    final dynamic decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw const ApiException('Expected JSON object');
    }
    return decoded.cast<String, Object?>();
  }

  Future<List<Object?>> getJsonList(
    Uri url, {
    Map<String, String>? headers,
  }) async {
    final res = await _client
        .get(url, headers: _mergeHeaders(headers))
        .timeout(const Duration(seconds: 10));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException('HTTP ${res.statusCode}');
    }

    final dynamic decoded = jsonDecode(res.body);
    if (decoded is! List<dynamic>) {
      throw const ApiException('Expected JSON list');
    }
    return decoded.cast<Object?>();
  }
}

final class ApiException implements Exception {
  const ApiException(this.message);
  final String message;

  @override
  String toString() => 'ApiException($message)';
}
