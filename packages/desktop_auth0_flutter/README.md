# desktop_auth0_flutter

A generic and simple desktop Auth0 platform implementation for adding desktop platforms (Linux and Windows) support.

## Overview

This package bridges the gap between the official Auth0 Flutter SDK (which supports mobile platforms + macOS) and desktop platforms by implementing custom platform interfaces.
It does this by extending CredentialsManagerPlatform & Auth0FlutterWebAuthPlatform.

For the scheme registration it uses <https://pub.dev/packages/uri_scheme_registration>, and for the actually management/dataflow <https://pub.dev/packages/app_links> is used.
Make sure to follow app_links configuration for Linux and Windows.

## Usage

### Basic Setup

```dart
import 'package:desktop_auth0_flutter/desktop_auth0_flutter.dart';

await initDesktopAuth0Flutter(
  bundleName: 'com.example.myapp',
  auth0Scheme: 'myapp',
  categories: 'Office;Productivity',
  comment: 'My Application',
  name: 'My App',
  iconAssetPath: 'assets/icon.png',
  simpleSecureStoragePrefix: "myapp_",
);

final credentials = await _service
  .webAuthentication(scheme: kAuth0Scheme)
  .login(parameters: parameters, audience: kAuth0Audience, scopes: scopes, useHTTPS: true);

final isLoggedIn =  _service.credentialsManager.hasValidCredentials();
```

## Platform Support

Only for Linux and Windows!
