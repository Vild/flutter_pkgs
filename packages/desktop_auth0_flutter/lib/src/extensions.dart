// We need UserProfileExtension.fromClaims
// ignore: implementation_imports
import 'package:auth0_flutter/src/web/extensions/user_profile_extension.dart' show UserProfileExtension;
import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:oauth2/oauth2.dart' as oauth2;

extension Oauth2CredentialsExtension on oauth2.Credentials {
  /// Convert oauth2's Credentials to Auth0's Credentials
  Credentials toAuth0Credentials() {
    final idTokenJWT = JWT.decode(idToken!).payload as Map<String, dynamic>;
    return Credentials(
      idToken: idToken!,
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiration!,
      scopes: scopes?.toSet() ?? {},
      user: UserProfileExtension.fromClaims(idTokenJWT),
      tokenType: 'Bearer', // OAuth2 library doesn't support tokenType?, default to Bearer
    );
  }
}

extension CredentialsExtension on Credentials {
  /// Convert Auth0's Credentials to oauth2's Credentials
  oauth2.Credentials toOauth2Credentials({required Uri tokenEndpoint}) => oauth2.Credentials(
        accessToken,
        refreshToken: refreshToken,
        idToken: idToken,
        tokenEndpoint: tokenEndpoint,
        scopes: scopes,
        expiration: expiresAt,
      );
}
