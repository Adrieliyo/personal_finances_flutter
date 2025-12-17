// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'token_service.dart';

// class AuthService {
//   static const String baseUrl = 'http://localhost:4000/api/auth';
//   final _tokenService = TokenService();

//   Future<Map<String, dynamic>> login(String email, String password) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/login'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'emailOrUsername': email, 'password': password}),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         // Guardar token y datos del usuario
//         if (data['token'] != null) {
//           await _tokenService.saveToken(data['token']);
//         }

//         if (data['user'] != null) {
//           await _tokenService.saveUserData(jsonEncode(data['user']));
//         }

//         return {'success': true, 'data': data};
//       } else {
//         final error = jsonDecode(response.body);
//         return {
//           'success': false,
//           'message': error['message'] ?? 'Error al iniciar sesión',
//         };
//       }
//     } catch (e) {
//       return {'success': false, 'message': 'Error de conexión: $e'};
//     }
//   }

//   // Logout con llamada al backend
//   Future<Map<String, dynamic>> logout() async {
//     try {
//       final token = await _tokenService.getToken();

//       if (token != null) {
//         final response = await http.post(
//           Uri.parse('$baseUrl/logout'),
//           headers: {
//             'Content-Type': 'application/json',
//             'Authorization': 'Bearer $token',
//           },
//         );

//         // Eliminar token local independientemente de la respuesta del servidor
//         await _tokenService.deleteToken();

//         if (response.statusCode == 200) {
//           return {'success': true, 'message': 'Sesión cerrada correctamente'};
//         } else {
//           // Aunque falle el backend, ya eliminamos el token local
//           return {'success': true, 'message': 'Sesión cerrada localmente'};
//         }
//       } else {
//         // No hay token, solo limpiar datos locales
//         await _tokenService.deleteToken();
//         return {'success': true, 'message': 'Sesión cerrada'};
//       }
//     } catch (e) {
//       // En caso de error de conexión, eliminar token local de todas formas
//       await _tokenService.deleteToken();
//       return {'success': true, 'message': 'Sesión cerrada localmente'};
//     }
//   }

//   // Verificar autenticación
//   Future<bool> isAuthenticated() async {
//     return await _tokenService.isAuthenticated();
//   }

//   // Obtener token para hacer peticiones autenticadas
//   Future<String?> getToken() async {
//     return await _tokenService.getToken();
//   }

//   // Hacer peticiones autenticadas
//   Future<http.Response> authenticatedRequest(
//     String endpoint, {
//     String method = 'GET',
//     Map<String, dynamic>? body,
//   }) async {
//     final token = await getToken();

//     final headers = {
//       'Content-Type': 'application/json',
//       if (token != null) 'Authorization': 'Bearer $token',
//     };

//     final uri = Uri.parse('$baseUrl$endpoint');

//     switch (method.toUpperCase()) {
//       case 'POST':
//         return await http.post(uri, headers: headers, body: jsonEncode(body));
//       case 'PUT':
//         return await http.put(uri, headers: headers, body: jsonEncode(body));
//       case 'DELETE':
//         return await http.delete(uri, headers: headers);
//       default:
//         return await http.get(uri, headers: headers);
//     }
//   }
// }
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

  Future<Map<String, dynamic>> login(String email, String password) async {
    final client = _createClient();

    try {
      final response = await client.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'emailOrUsername': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Guardar token si viene en el body (respaldo)
        if (data['token'] != null) {
          await _tokenService.saveToken(data['token']);
        }

        if (data['user'] != null) {
          await _tokenService.saveUserData(jsonEncode(data['user']));
        }

        return {'success': true, 'data': data};
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
