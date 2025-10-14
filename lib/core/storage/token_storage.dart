import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _kaccess = 'access_token';
  static const _krefresh = 'refresh_token';

  final _storage = const FlutterSecureStorage();

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: _kaccess, value: accessToken);
    await _storage.write(key: _krefresh, value: refreshToken);
  }

  Future<String?> readAccess() => _storage.read(key: _kaccess);
  Future<String?> readRefresh() => _storage.read(key: _krefresh);

  Future<void> clear() async => _storage.deleteAll();
}
