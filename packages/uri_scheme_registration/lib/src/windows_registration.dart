import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:uri_scheme_registration/src/common.dart';
import 'package:win32/win32.dart';

const _hive = HKEY_CURRENT_USER;

String _regPrefix(String bundleName) => 'SOFTWARE\\Classes\\$bundleName';

int _regCreateStringKey(int hKey, String key, String valueName, String data) {
  final txtKey = TEXT(key);
  final txtValue = TEXT(valueName);
  final txtData = TEXT(data);
  try {
    // Length calculation: txtData.length * 2 + 2 for Unicode null terminator
    return RegSetKeyValue(hKey, txtKey, txtValue, REG_SZ, txtData, txtData.length * 2 + 2);
  } finally {
    free(txtKey);
    free(txtValue);
    free(txtData);
  }
}

/// For api docs see [registerScheme]
void registerWindowsScheme({required String bundleName, required String scheme}) {
  final cmd = '${Platform.resolvedExecutable} %1';
  final regPrefix = _regPrefix(bundleName);

  _regCreateStringKey(_hive, regPrefix, '', 'URL:$scheme');
  _regCreateStringKey(_hive, regPrefix, 'URL Protocol', '');
  _regCreateStringKey(_hive, '$regPrefix\\shell\\open\\command', '', cmd);
}

/// For api docs see [unregisterScheme]
void unregisterWindowsScheme({required String bundleName}) {
  final regPrefix = _regPrefix(bundleName);
  final txtKey = TEXT(regPrefix);
  try {
    RegDeleteTree(HKEY_CURRENT_USER, txtKey);
  } finally {
    free(txtKey);
  }
}
