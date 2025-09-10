# app_links_scheme_registrations

Helpers for registering URI schemes.
On Window it is registers in the registry, and on Linux by following the XDG spec.
Other targets are no-ops.

See lib/src/common.dart for main documentation

## Example

```dart
await registerScheme(
  bundleName: 'com.example.myapp',
  scheme: 'myapp',
  name: 'My App',
  categories: 'Office;Productivity',
  comment: 'My Application',
  iconAssetPath: 'assets/icon.png',
);

await unregisterScheme(
  bundleName: 'com.example.myapp',
  scheme: 'myapp',
);
```
