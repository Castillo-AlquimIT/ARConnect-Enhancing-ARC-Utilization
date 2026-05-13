class AppConfig {
  AppConfig._();
  static final AppConfig instance = AppConfig._();

  // Change this default to your local fallback
  String baseUrl = "http://localhost"; // Android emulator → localhost

  String url(String app, String endpoint) {
    return "$baseUrl/$app/$endpoint";
  }
}