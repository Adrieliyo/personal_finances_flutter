import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'token_service.dart';

class BudgetService {
  static const String baseUrl = 'http://localhost:4000/api/budgets';
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

  // Crear nuevo presupuesto
  Future<Map<String, dynamic>> createBudget({
    required String categoryId,
    required double amountLimit,
    required String period,
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
        body: jsonEncode({
          'category_id': categoryId,
          'amount_limit': amountLimit,
          'period': period,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Presupuesto creado exitosamente',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Error al crear el presupuesto',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    } finally {
      client.close();
    }
  }

  // Obtener todos los presupuestos
  Future<Map<String, dynamic>> getBudgets() async {
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
          'message': error['message'] ?? 'Error al obtener los presupuestos',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    } finally {
      client.close();
    }
  }

  // Obtener presupuesto por ID
  Future<Map<String, dynamic>> getBudgetById(String id) async {
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
          'message': error['message'] ?? 'Error al obtener el presupuesto',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    } finally {
      client.close();
    }
  }

  // Actualizar presupuesto
  Future<Map<String, dynamic>> updateBudget({
    required String id,
    required String categoryId,
    required double amountLimit,
    required String period,
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
        body: jsonEncode({
          'category_id': categoryId,
          'amount_limit': amountLimit,
          'period': period,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Presupuesto actualizado exitosamente',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Error al actualizar el presupuesto',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    } finally {
      client.close();
    }
  }

  // Eliminar presupuesto
  Future<Map<String, dynamic>> deleteBudget(String id) async {
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
        return {
          'success': true,
          'message': 'Presupuesto eliminado exitosamente',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Error al eliminar el presupuesto',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    } finally {
      client.close();
    }
  }
}
