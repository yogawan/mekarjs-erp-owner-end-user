// API Configuration
class Api {
  // Base URL untuk API
  static const String baseUrl = "https://mekarjs-erp-core-service.yogawanadityapratama.com";
  
  // API Endpoints
  static const String loginEndpoint = "/api/owner/account/login";
  
  // Full URL helper
  static String get loginUrl => "$baseUrl$loginEndpoint";
}
