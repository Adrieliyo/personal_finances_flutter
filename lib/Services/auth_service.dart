import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'token_service.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:4000/api/auth';
  final _tokenService = TokenService();

  // Crear cliente HTTP que incluye credenciales para web
  http.Client _createClient() {
    if (kIsWeb) {
      final client = BrowserClient();
      client.withCredentials = true;
      return client;
    }
    return http.Client();
  }

  // Método de registro
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String fullName,
    required String password,
    String currency = 'MXN',
  }) async {
    final client = _createClient();

    try {
      final response = await client.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'full_name': fullName,
          'password': password,
          'currency': currency,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // Guardar token si viene en la respuesta
        if (data['token'] != null) {
          await _tokenService.saveToken(data['token']);
        }

        return {
          'success': true,
          'data': data,
          'message': 'Usuario registrado exitosamente',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Error al registrar usuario',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    } finally {
      client.close();
    }
  }

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final client = _createClient();

    try {
      final response = await client.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'emailOrUsername': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Guardar token
        if (data['token'] != null) {
          await _tokenService.saveToken(data['token']);
        }

        return {
          'success': true,
          'data': data,
          'message': 'Inicio de sesión exitoso',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Error al iniciar sesión',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    } finally {
      client.close();
    }
  }

  Future<Map<String, dynamic>> logout() async {
    final client = _createClient();

    try {
      final token = await _tokenService.getToken();

      final response = await client.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      // Eliminar token local
      await _tokenService.deleteToken();

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Sesión cerrada correctamente'};
      } else {
        return {'success': true, 'message': 'Sesión cerrada localmente'};
      }
    } catch (e) {
      await _tokenService.deleteToken();
      return {'success': true, 'message': 'Sesión cerrada localmente'};
    } finally {
      client.close();
    }
  }

  Future<bool> isAuthenticated() async {
    return await _tokenService.isAuthenticated();
  }

  Future<String?> getToken() async {
    return await _tokenService.getToken();
  }

  Future<http.Response> authenticatedRequest(
    String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    final client = _createClient();
    final token = await getToken();

    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final uri = Uri.parse('$baseUrl$endpoint');

    try {
      switch (method.toUpperCase()) {
        case 'POST':
          return await client.post(
            uri,
            headers: headers,
            body: jsonEncode(body),
          );
        case 'PUT':
          return await client.put(
            uri,
            headers: headers,
            body: jsonEncode(body),
          );
        case 'DELETE':
          return await client.delete(uri, headers: headers);
        default:
          return await client.get(uri, headers: headers);
      }
    } finally {
      client.close();
    }
  }
}
