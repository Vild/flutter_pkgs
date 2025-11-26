import 'package:desktop_auth0_flutter/src/auth0_credentials_manager_platform.dart';
import 'package:desktop_auth0_flutter/src/auth0_flutter_web_auth_platform.dart';
import 'package:desktop_auth0_flutter/src/init_options.dart';
import 'package:uri_scheme_registration/uri_scheme_registration.dart';

var _isInitialized = false;

Future<void> initDesktopAuth0Flutter(
  DesktopAuth0FlutterInitOptions options,
) async {
  if (_isInitialized) return;

  // Register our custom platform implementations
  Auth0CredentialsManagerPlatformGeneric.register();
  Auth0FlutterWebAuthPlatformGeneric.register(
    appLinks: options.appLinks,
    waitUrlTimeoutBuilder: options.waitUrlTimeoutBuilder,
  );

  // Register platform-specific URL scheme handlers
  registerScheme(
    bundleName: options.bundleName,
    scheme: options.auth0Scheme,
    categories: options.categories,
    comment: options.comment,
    name: options.name,
    iconAssetPath: options.iconAssetPath,
  );

  _isInitialized = true;
}
