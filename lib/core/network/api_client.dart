abstract interface class ApiClient {
  Future<Object?> getJson(String path);

  Future<Object?> postJson(String path, {required Object body});
}

class ApiException implements Exception {
  const ApiException({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() {
    final suffix = statusCode == null ? '' : ' (HTTP $statusCode)';
    return 'ApiException: $message$suffix';
  }
}
