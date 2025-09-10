import 'dart:convert';
import 'dart:math';

import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:desktop_auth0_flutter/src/extensions.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:synchronized/synchronized.dart' show Lock;

final class Auth0CredentialsManagerPlatformGeneric extends CredentialsManagerPlatform {
  static const _key = 'auth0_credentials';
  final _lock = Lock();

  final storage = const FlutterSecureStorage();

  static void register() {
    CredentialsManagerPlatform.instance = Auth0CredentialsManagerPlatformGeneric();
  }

  Future<Credentials> _refreshCredentials({
    required Credentials credentials,
    required String clientId,
    required String domain,
  }) async {
    final oauth2Cred = credentials.toOauth2Credentials(tokenEndpoint: Uri.parse('https://$domain/oauth/token'));
    final newOauth2Cred = await oauth2Cred.refresh(identifier: clientId);
    final newCredentials = newOauth2Cred.toAuth0Credentials();
    await storage.write(key: _key, value: jsonEncode(newCredentials.toMap()));
    return newCredentials;
  }

  @override
  Future<Credentials> getCredentials(CredentialsManagerRequest<GetCredentialsOptions> request) async =>
      _lock.synchronized(() async {
        if (!(await storage.containsKey(key: _key))) {
          throw Exception('No credentials key found');
        }
        final data = await storage.read(key: _key);
        if (data == null) {
          throw Exception('No data in credentials key');
        }
        final credentials = Credentials.fromMap(jsonDecode(data) as Map<String, dynamic>);
        final minTtlDuration = Duration(seconds: max(request.options?.minTtl ?? 0, 60));
        if (credentials.expiresAt.isAfter(DateTime.now().add(minTtlDuration))) {
          return credentials;
        }

        return _refreshCredentials(
          credentials: credentials,
          clientId: request.account.clientId,
          domain: request.account.domain,
        );
      });

  @override
  Future<Credentials> renewCredentials(CredentialsManagerRequest<RenewCredentialsOptions> request) async =>
      _lock.synchronized(() async {
        if (!(await storage.containsKey(key: _key))) {
          throw Exception('No credentials key found');
        }
        final data = await storage.read(key: _key);
        if (data == null) {
          throw Exception('No data in credentials key');
        }
        final credentials = Credentials.fromMap(jsonDecode(data) as Map<String, dynamic>);

        return _refreshCredentials(
          credentials: credentials,
          clientId: request.account.clientId,
          domain: request.account.domain,
        );
      });

  @override
  Future<bool> clearCredentials(CredentialsManagerRequest request) async => _lock.synchronized(() async {
        try {
          if (await storage.containsKey(key: _key)) {
            await storage.delete(key: _key);
          }
          return true;
        } on Exception {
          return false;
        }
      });

  @override
  Future<bool> saveCredentials(CredentialsManagerRequest<SaveCredentialsOptions> request) async =>
      _lock.synchronized(() async {
        try {
          await storage.write(key: _key, value: jsonEncode(request.options?.credentials.toMap()));
          return true;
        } on Exception {
          return false;
        }
      });

  @override
  Future<bool> hasValidCredentials(CredentialsManagerRequest<HasValidCredentialsOptions> request) async =>
      _lock.synchronized(() async {
        if (!(await storage.containsKey(key: _key))) {
          return false;
        }
        final data = await storage.read(key: _key);
        if (data == null) {
          return false;
        }
        final credentials = Credentials.fromMap(jsonDecode(data) as Map<String, dynamic>);
        final minTtlDuration = Duration(seconds: max(request.options?.minTtl ?? 0, 60));
        if (credentials.expiresAt.isAfter(DateTime.now().add(minTtlDuration))) {
          return true;
        }
        return false;
      });
}
