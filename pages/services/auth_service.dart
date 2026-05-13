import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Added
import 'package:http/http.dart' as http;

class AuthService {
  final FlutterAppAuth appAuth = const FlutterAppAuth();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  final String clientId = 'YOUR_CLIENT_ID';
  // Note: Ensure this EXACT string is in your Azure Redirect URIs
  final String redirectUrl = 'msauth://com.arconnect.mobile'; 
  final String discoveryUrl = 'https://login.microsoftonline.com/common/v2.0/.well-known/openid-configuration';

  Future<bool> login() async {
    try {
      final AuthorizationTokenResponse result = await appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          clientId,
          redirectUrl,
          discoveryUrl: discoveryUrl,
          scopes: ['openid', 'profile', 'email', 'User.Read', 'offline_access'], // Added offline_access for refresh tokens
          promptValues: ['login'],
        ),
      );

      if (result.accessToken == null) return false;

      // Save tokens securely immediately
      await secureStorage.write(key: 'access_token', value: result.accessToken);

      // 1. Get Microsoft profile
      final profileResponse = await http.get(
        Uri.parse('https://graph.microsoft.com/v1.0/me'),
        headers: {'Authorization': 'Bearer ${result.accessToken}'},
      );
      
      if (profileResponse.statusCode != 200) return false;
      final userData = jsonDecode(profileResponse.body);

      // 2. Send to PHP backend via zrok
      // TIP: Use jsonEncode for the body and set Content-Type header
      final serverResponse = await http.post(
        Uri.parse('https://YOUR-ZROK-URL.zrok.io/microsoft_login.php'),
        headers: {'Content-Type': 'application/json'}, 
        body: jsonEncode({
          'microsoft_id': userData['id'],
          'name': userData['displayName'],
          'email': userData['mail'] ?? userData['userPrincipalName'], // Fallback for email
        }),
      );

      final responseData = jsonDecode(serverResponse.body);
      return responseData['success'] == true;

    } catch (e) {
      if (kDebugMode) {
        print("Auth Error: $e");
      }
      return false;
    }
  }
}