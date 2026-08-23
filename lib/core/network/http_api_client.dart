import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'api_client.dart';

class HttpApiClient implements ApiClient {
  HttpApiClient({required this.baseUri, http.Client? client})
    : _client = client ?? http.Client();

  final Uri baseUri;
  final http.Client _client;

  @override
  Future<Object?> getJson(String path) async {
    final response = await _client
        .get(_resolve(path), headers: _headers)
        .timeout(AppConfig.requestTimeout);
    return _decode(response);
  }

  @override
  Future<Object?> postJson(String path, {required Object body}) async {
    final response = await _client
        .post(_resolve(path), headers: _headers, body: jsonEncode(body))
        .timeout(AppConfig.requestTimeout);
    return _decode(response);
  }

  Uri _resolve(String path) {
    final normalizedBase = baseUri.toString().endsWith('/')
        ? baseUri.toString().substring(0, baseUri.toString().length - 1)
        : baseUri.toString();
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$normalizedBase$normalizedPath');
  }

  Object? _decode(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        message: _extractErrorMessage(response.body),
        statusCode: response.statusCode,
      );
    }
    if (response.body.trim().isEmpty) {
      return null;
    }
    try {
      return jsonDecode(response.body);
    } on FormatException {
      throw const ApiException(message: '服务端返回了无效 JSON');
    }
  }

  Map<String, String> get _headers => const {
    'Accept': 'application/json',
    'Content-Type': 'application/json; charset=utf-8',
  };

  String _extractErrorMessage(String body) {
    if (body.trim().isEmpty) {
      return '请求失败';
    }
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final message =
            decoded['message'] ?? decoded['error'] ?? decoded['detail'];
        if (message is String && message.isNotEmpty) {
          return message;
        }
      }
    } on FormatException {
      return body;
    }
    return body;
  }
}
