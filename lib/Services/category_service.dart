import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'token_service.dart';

class CategoryService {
  static const String baseUrl = 'http://localhost:4000/api/categories';
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

  // Crear nueva categoría
  Future<Map<String, dynamic>> createCategory({
    required String name,
    required String type,
  }) async {
    final client = _createClient();

    try {
      final token = await _tokenService.getToken();

      final response = await client.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'name': name, 'type': type}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Categoría creada exitosamente',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Error al crear la categoría',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    } finally {
      client.close();
    }
  }

  // Obtener todas las categorías
  Future<Map<String, dynamic>> getCategories() async {
    final client = _createClient();

    try {
      final token = await _tokenService.getToken();

      final response = await client.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Error al obtener las categorías',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    } finally {
      client.close();
    }
  }

  // Obtener categoría por ID
  Future<Map<String, dynamic>> getCategoryById(String id) async {
    final client = _createClient();

    try {
      final token = await _tokenService.getToken();

      final response = await client.get(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Error al obtener la categoría',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    } finally {
      client.close();
    }
  }

  // Actualizar categoría
  Future<Map<String, dynamic>> updateCategory({
    required String id,
    required String name,
    required String type,
  }) async {
    final client = _createClient();

    try {
      final token = await _tokenService.getToken();

      final response = await client.put(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'name': name, 'type': type}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Categoría actualizada exitosamente',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Error al actualizar la categoría',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    } finally {
      client.close();
    }
  }

  // Eliminar categoría
  Future<Map<String, dynamic>> deleteCategory(String id) async {
    final client = _createClient();

    try {
      final token = await _tokenService.getToken();

      final response = await client.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Categoría eliminada exitosamente'};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Error al eliminar la categoría',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    } finally {
      client.close();
    }
  }
}
