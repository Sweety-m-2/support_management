class ApiConfig {
  const ApiConfig._();

  /// Override with --dart-define=API_BASE_URL=http://host:8000 when needed.
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );
}
