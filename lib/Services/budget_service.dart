import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'token_service.dart';

class BudgetService {
  static const String baseUrl = 'http://localhost:4000/api/budgets';
  final _tokenService = TokenService();

  http.Client _createClient() {
    if (kIsWeb) {
      final client = BrowserClient();
      client.withCredentials = true;
      return client;
    }
    return http.Client();
  }

  Future<Map<String, dynamic>> getBudgets({String? period}) async {
    final client = _createClient();
    final token = await _tokenService.getToken();

    try {
      var uri = Uri.parse(baseUrl);
      if (period != null) {
        uri = Uri.parse('$baseUrl?period=$period');
      }

      final response = await client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Error al cargar presupuestos'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    } finally {
      client.close();
    }
  }

  Future<Map<String, dynamic>> getBudgetSummary() async {
    final client = _createClient();
    final token = await _tokenService.getToken();

    try {
      final response = await client.get(
        Uri.parse('$baseUrl/summary'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'message': 'Error al cargar resumen'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    } finally {
      client.close();
    }
  }

  Future<Map<String, dynamic>> getBudgetById(String budgetId) async {
    final client = _createClient();
    final token = await _tokenService.getToken();

    try {
      final response = await client.get(
        Uri.parse('$baseUrl/$budgetId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'message': 'Error al cargar presupuesto'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    } finally {
      client.close();
    }
  }

  Future<Map<String, dynamic>> createBudget({
    required String categoryId,
    required double amountLimit,
    required String period,
  }) async {
    final client = _createClient();
    final token = await _tokenService.getToken();

    try {
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

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'],
          'message': 'Presupuesto creado exitosamente',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Error al crear presupuesto',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    } finally {
      client.close();
    }
  }

  Future<Map<String, dynamic>> updateBudget({
    required String budgetId,
    String? categoryId,
    double? amountLimit,
    String? period,
  }) async {
    final client = _createClient();
    final token = await _tokenService.getToken();

    try {
      final body = <String, dynamic>{};
      if (categoryId != null) body['category_id'] = categoryId;
      if (amountLimit != null) body['amount_limit'] = amountLimit;
      if (period != null) body['period'] = period;

      final response = await client.put(
        Uri.parse('$baseUrl/$budgetId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'],
          'message': 'Presupuesto actualizado exitosamente',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Error al actualizar presupuesto',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    } finally {
      client.close();
    }
  }

  Future<Map<String, dynamic>> deleteBudget(String budgetId) async {
    final client = _createClient();
    final token = await _tokenService.getToken();

    try {
      final response = await client.delete(
        Uri.parse('$baseUrl/$budgetId'),
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
          'message': error['message'] ?? 'Error al eliminar presupuesto',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    } finally {
      client.close();
    }
  }
}
