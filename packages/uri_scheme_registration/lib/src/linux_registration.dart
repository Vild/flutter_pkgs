import 'dart:io';

import 'package:uri_scheme_registration/src/common.dart';

/// Create the MIME type association line for Linux protocol handlers.
String _schemeLine(String bundleName, String scheme) => 'x-scheme-handler/$scheme=$bundleName.desktop';

/// Registers a custom URL scheme handler for Linux desktop environments.
/// For api docs see [registerScheme]
void registerLinuxScheme({
  required String bundleName,
  required String scheme,
  required String name,
  required String comment,
  required String categories,
  required String iconAssetPath,
}) {
  // Create and register the application launcher file (.desktop)
  {
    final executable = Platform.resolvedExecutable;
    final icon = '${File(executable).parent.path}/data/flutter_assets/$iconAssetPath';

    final desktopPath = '${Platform.environment['HOME']}/.local/share/applications/$bundleName.desktop';

    // Create desktop entry file with proper metadata and MIME type association
    File(desktopPath).writeAsStringSync('''
[Desktop Entry]
Categories=$categories
Comment=$comment
Exec=$executable %u
Icon=$icon
MimeType=x-scheme-handler/$scheme;
Name=$name
NoDisplay=false
StartupNotify=true
Terminal=false
Type=Application
''', flush: true);

    // Register the desktop file with the system MIME database
    Process.runSync('xdg-mime', ['install', desktopPath]);
    // Associate the URL scheme with this application using gio
    Process.runSync('gio', ['mime', 'x-scheme-handler/$scheme', '$bundleName.desktop']);
  }

  // Register the scheme in the user's MIME applications list
  {
    final mimeappsPath = '${Platform.environment['HOME']}/.config/mimeapps.list';
    final mimeapps = File(mimeappsPath);
    String prevData;
    final line = _schemeLine(bundleName, scheme);
    var shouldWrite = true;

    // Read existing mimeapps.list or create default structure
    if (mimeapps.existsSync()) {
      prevData = mimeapps.readAsStringSync();
      shouldWrite = !prevData.contains(line);
    } else {
      prevData = '[Default Applications]\n';
    }

    // Add our protocol handler association if not already present
    if (shouldWrite) {
      if (!prevData.endsWith('\n')) prevData += '\n';
      prevData += '$line\n';
      mimeapps.writeAsStringSync(prevData, flush: true);
    }
  }
}

/// Unregisters a custom URL scheme handler from Linux desktop environments.
void unregisterLinuxScheme({required String bundleName, required String scheme}) {
  // Remove scheme registration from mimeapps.list
  {
    final mimeappsPath = '${Platform.environment['HOME']}/.config/mimeapps.list';
    final mimeapps = File(mimeappsPath);
    if (mimeapps.existsSync()) {
      var prevData = mimeapps.readAsStringSync();
      final line = '${_schemeLine(bundleName, scheme)}\n';
      prevData = prevData.replaceAll(line, '');
      mimeapps.writeAsStringSync(prevData, flush: true);
    }
  }
  // Remove application launcher and unregister from MIME database
  {
    final desktopPath = '${Platform.environment['HOME']}/.local/share/applications/$bundleName.desktop';
    final desktop = File(desktopPath);
    if (desktop.existsSync()) {
      // Unregister from system MIME database
      Process.runSync('xdg-mime', ['uninstall', desktopPath]);
      // Delete the desktop launcher file
      desktop.deleteSync();
    }
  }
}
