/// Generic Auth0 implementation for Flutter desktop platforms.
///
/// This library extends Auth0 support to Linux and Windows desktop applications
/// by providing custom platform implementations for authentication flows,
/// credentials management, and URL scheme handling.
///
/// Should cover everything needed for to use auth0_flutter on Linux and Windows
library;

export 'package:desktop_auth0_flutter/src/init.dart'
    if (dart.library.js_interop) 'package:desktop_auth0_flutter/src/init_stub.dart';

export 'package:desktop_auth0_flutter/src/init_options.dart';
