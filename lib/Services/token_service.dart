import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _userKey = 'user_data';

  // Guardar token (solo para móvil o como respaldo en web)
  Future<void> saveToken(String token) async {
    if (!kIsWeb) {
      await _storage.write(key: _tokenKey, value: token);
    }
    // En web, las cookies se manejan automáticamente
  }

  // Obtener token (solo para móvil o respaldo en web)
  Future<String?> getToken() async {
    if (!kIsWeb) {
      return await _storage.read(key: _tokenKey);
    }
    return null; // En web, las cookies se envían automáticamente
  }

  // Guardar información del usuario
  Future<void> saveUserData(String userData) async {
    await _storage.write(key: _userKey, value: userData);
  }

  // Obtener información del usuario
  Future<String?> getUserData() async {
    return await _storage.read(key: _userKey);
  }

  // Eliminar token (logout)
  Future<void> deleteToken() async {
    if (!kIsWeb) {
      await _storage.delete(key: _tokenKey);
    }
    await _storage.delete(key: _userKey);
  }

  // Verificar si el usuario está autenticado
  Future<bool> isAuthenticated() async {
    if (kIsWeb) {
      // En web, verificar si hay datos de usuario guardados
      final userData = await getUserData();
      return userData != null;
    } else {
      final token = await getToken();
      return token != null && token.isNotEmpty;
    }
  }

  // Limpiar todo
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
