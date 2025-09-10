import 'dart:async';
import 'dart:convert';

import 'package:app_links/app_links.dart';
import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:desktop_auth0_flutter/src/extensions.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:url_launcher/url_launcher.dart';

final class Auth0FlutterWebAuthPlatformGeneric extends Auth0FlutterWebAuthPlatform {
  Auth0FlutterWebAuthPlatformGeneric(this._desktopAppLinks) : super();

  final AppLinks _desktopAppLinks;
  static void register({AppLinks? appLinks}) {
    Auth0FlutterWebAuthPlatform.instance = Auth0FlutterWebAuthPlatformGeneric(appLinks ?? AppLinks());
  }

  /// Waits for a URL callback after launching the browser for authentication.
  Future<String?> _waitUrl(Uri uri, Future<String?>? cancelFuture) async {
    // Helper to clean up URL strings that may have extra quotes
    Uri makeUri(String str) =>
        Uri.parse(str.codeUnitAt(0) == "'".codeUnitAt(0) ? str.substring(1, str.length - 1) : str);

    final tokenComplete = Completer<String>();
    final listener = _desktopAppLinks.stringLinkStream.map(makeUri).listen((uri) {
      tokenComplete.complete(uri.toString());
    });

    // Launch the authorization URL in the system browser
    unawaited(launchUrl(uri));

    // Wait for either the callback or timeout
    final value = await Future.any([tokenComplete.future, if (cancelFuture != null) cancelFuture]);
    await listener.cancel();
    return value;
  }

  @override
  Future<Credentials> login(WebAuthRequest<WebAuthLoginOptions> request) async {
    final options = request.options;
    final parameters = options.parameters;
    final idTokenValidationConfig = options.idTokenValidationConfig;

    // Create OAuth2 authorization grant with Auth0 endpoints
    final grant = oauth2.AuthorizationCodeGrant(
      request.account.clientId,
      Uri.parse('https://${request.account.domain}/authorize'),
      Uri.parse('https://${request.account.domain}/oauth/token'),
    );

    // Build authorization URL with requested scopes and state
    var authUrl = grant.getAuthorizationUrl(
      Uri.parse(options.redirectUrl ?? '${request.options.scheme}://login'),
      scopes: options.scopes,
      state: options.appState != null ? jsonEncode(options.appState) : null,
    );

    // Add Auth0-specific parameters to the authorization URL
    authUrl = authUrl.replace(
      queryParameters: {
        ...authUrl.queryParameters,
        ...parameters,
        // Auth0 specific parameters
        if (options.audience != null) 'audience': options.audience,
        if (options.organizationId != null) 'organization': options.organizationId,
        if (options.invitationUrl != null) 'invitation': options.invitationUrl,
        // ID token validation parameters
        if (idTokenValidationConfig?.leeway != null) 'leeway': idTokenValidationConfig?.leeway.toString(),
        if (idTokenValidationConfig?.issuer != null) 'issuer': idTokenValidationConfig?.issuer,
        if (idTokenValidationConfig?.maxAge != null) 'max_age': idTokenValidationConfig?.maxAge.toString(),
      },
    );

    // Wait for authorization code with timeout
    // TODO: Allow timeout to be configured
    final value = await _waitUrl(authUrl, Future<String?>.delayed(const Duration(minutes: 1), () => null));
    if (value == null) {
      throw TimeoutException('Authorization code not received');
    }

    // Exchange authorization code for tokens
    final client = await grant.handleAuthorizationResponse(Uri.parse(value).queryParameters);
    return client.credentials.toAuth0Credentials();
  }

  @override
  Future<void> logout(WebAuthRequest<WebAuthLogoutOptions> request) async {
    // Build Auth0 logout URL with client ID and return URL
    var logoutUrl = Uri.parse('https://${request.account.domain}/v2/logout');
    logoutUrl = logoutUrl.replace(
      queryParameters: {
        'client_id': request.account.clientId,
        'returnTo': request.options.returnTo ?? '${request.options.scheme}://logout',
      },
    );

    // Launch logout URL and wait for callback
    // TODO: Allow timeout to be configured
    await _waitUrl(logoutUrl, Future<String?>.delayed(const Duration(minutes: 1), () => null));
  }
}
