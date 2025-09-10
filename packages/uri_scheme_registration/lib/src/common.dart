import 'dart:io';

import 'package:uri_scheme_registration/src/linux_registration.dart';
import 'package:uri_scheme_registration/src/windows_registration.dart';

/// Register a custom URL scheme handler for the current platform.
/// - [bundleName] is the name of the application.
/// - [scheme] is the scheme to register.
/// - [name] is the name to register. (Linux only)
/// - [comment] is the comment to register. (Linux only)
/// - [categories] is the categories to register. (Linux only)
/// - [iconAssetPath] is the path to the icon to register. (Linux only)
///
/// Example:
/// ```dart
///  await registerScheme(
///    bundleName: 'com.example.myapp',
///    scheme: 'myapp',
///    name: 'My App',
///    categories: 'Office;Productivity',
///    comment: 'My Application',
///    iconAssetPath: 'assets/icon.png',
///  );
/// ```
void registerScheme({
  required String bundleName,
  required String scheme,
  required String name,
  required String categories,
  required String comment,
  required String iconAssetPath,
}) {
  if (Platform.isWindows) {
    registerWindowsScheme(bundleName: bundleName, scheme: scheme);
  } else if (Platform.isLinux) {
    registerLinuxScheme(
      bundleName: bundleName,
      scheme: scheme,
      categories: categories,
      comment: comment,
      name: name,
      iconAssetPath: iconAssetPath,
    );
  }
}

/// Unregister a custom URL scheme handler for the current platform.
/// - [bundleName] is the name of the application.
/// - [scheme] is the scheme to unregister.
///
/// Example:
/// ```dart
///  await unregisterScheme(
///    bundleName: 'com.example.myapp',
///    scheme: 'myapp',
///  );
/// ```
void unregisterScheme({required String bundleName, required String scheme}) {
  if (Platform.isWindows) {
    unregisterWindowsScheme(bundleName: bundleName);
  } else if (Platform.isLinux) {
    unregisterLinuxScheme(bundleName: bundleName, scheme: scheme);
  }
}
