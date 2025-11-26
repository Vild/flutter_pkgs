import 'package:app_links/app_links.dart';

enum WaitUrlTimeoutType {
  login,
  logout,
}

/// Builder callback that is used to build a [Future<String?>] that will be used by the "wait for a url" logic.
///
/// If the builder returns null, no timeout will be used.
///
/// Otherwise the [Future] will be `Future.any(` awaited on.
/// If the [Future] returns *before* we get the schema callback, we will use its return value, instead of the schema callback.
typedef WaitUrlTimeoutBuilder = Future<String?>? Function(WaitUrlTimeoutType type);

Future<String?> defaultWaitUrlTimeoutBuilder(WaitUrlTimeoutType type) =>
    Future<String?>.delayed(const Duration(minutes: 1), () => null);

class DesktopAuth0FlutterInitOptions {
  const DesktopAuth0FlutterInitOptions({
    required this.bundleName,
    required this.auth0Scheme,
    required this.categories,
    required this.comment,
    required this.name,
    required this.iconAssetPath,
    this.appLinks,
    this.waitUrlTimeoutBuilder = defaultWaitUrlTimeoutBuilder,
  });

  final String bundleName;
  final String auth0Scheme;
  final String categories;
  final String comment;
  final String name;
  final String iconAssetPath;
  final AppLinks? appLinks;
  final WaitUrlTimeoutBuilder waitUrlTimeoutBuilder;
}
