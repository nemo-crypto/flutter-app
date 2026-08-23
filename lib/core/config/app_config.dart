abstract final class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static const useMockApi = bool.fromEnvironment(
    'USE_MOCK_API',
    defaultValue: true,
  );

  static const skipSplash = bool.fromEnvironment(
    'SKIP_SPLASH',
    defaultValue: false,
  );

  static const requestTimeout = Duration(seconds: 8);
}
