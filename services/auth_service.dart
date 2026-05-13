import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:http/http.dart' as http;

class AuthService {

  final FlutterAppAuth appAuth = FlutterAppAuth();

  final String clientId = 'YOUR_CLIENT_ID';

  final String redirectUrl =
      'msauth://com.arconnect.mobile';

  final String discoveryUrl =
      'https://login.microsoftonline.com/common/v2.0/.well-known/openid-configuration';

  Future<bool> login() async {

    try {

      final AuthorizationTokenResponse result =
          await appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          clientId,
          redirectUrl,
          discoveryUrl: discoveryUrl,
          scopes: [
            'openid',
            'profile',
            'email',
            'User.Read',
          ],
        ),
      );

      // Get Microsoft profile
      final profile = await http.get(
        Uri.parse(
          'https://graph.microsoft.com/v1.0/me',
        ),
        headers: {
          'Authorization':
              'Bearer ${result.accessToken}',
        },
      );

      final userData = jsonDecode(profile.body);

      // Send to PHP backend
      final serverResponse = await http.post(
        Uri.parse(
          'https://YOUR-ZROK-URL.zrok.io/microsoft_login.php',
        ),
        body: {
          'microsoft_id': userData['id'],
          'name': userData['displayName'],
          'email': userData['mail'] ?? '',
        },
      );

      final responseData =
          jsonDecode(serverResponse.body);

      return responseData['success'] == true;

    } catch (e) {

      if (kDebugMode) {
        print(e);
      }

      return false;
    }
  }
}