import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'token_service.dart';

class TransactionService {
  static const String baseUrl = 'http://localhost:4000/api/transactions';
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

  // Crear nueva transacción
  Future<Map<String, dynamic>> createTransaction({
    required String accountId,
    required String categoryId,
    required double amount,
    required String date,
    required String description,
    required String type,
    bool isRecurring = false,
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
          'account_id': accountId,
          'category_id': categoryId,
          'amount': amount,
          'date': date,
          'description': description,
          'type': type,
          'is_recurring': isRecurring,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Transacción creada exitosamente',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Error al crear la transacción',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    } finally {
      client.close();
    }
  }

  // Obtener todas las transacciones con filtros
  Future<Map<String, dynamic>> getTransactions({
    String? type,
    String? accountId,
    String? categoryId,
    String? startDate,
    String? endDate,
    bool? isRecurring,
  }) async {
    final client = _createClient();

    try {
      final token = await _tokenService.getToken();

      // Construir query parameters
      final queryParams = <String, String>{};
      if (type != null) queryParams['type'] = type;
      if (accountId != null) queryParams['account_id'] = accountId;
      if (categoryId != null) queryParams['category_id'] = categoryId;
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;
      if (isRecurring != null)
        queryParams['is_recurring'] = isRecurring.toString();

      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

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
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Error al obtener las transacciones',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    } finally {
      client.close();
    }
  }

  // Obtener resumen de transacciones
  Future<Map<String, dynamic>> getTransactionsSummary({
    String? startDate,
    String? endDate,
  }) async {
    final client = _createClient();

    try {
      final token = await _tokenService.getToken();

      // Construir query parameters
      final queryParams = <String, String>{};
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final uri = Uri.parse(
        '$baseUrl/summary',
      ).replace(queryParameters: queryParams);

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
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Error al obtener el resumen',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    } finally {
      client.close();
    }
  }

  // Obtener transacciones agrupadas por categoría
  Future<Map<String, dynamic>> getTransactionsByCategory() async {
    final client = _createClient();

    try {
      final token = await _tokenService.getToken();

      final response = await client.get(
        Uri.parse('$baseUrl/by-category'),
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
          'message':
              error['message'] ??
              'Error al obtener las transacciones por categoría',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    } finally {
      client.close();
    }
  }

  // Obtener transacciones recurrentes
  Future<Map<String, dynamic>> getRecurringTransactions() async {
    final client = _createClient();

    try {
      final token = await _tokenService.getToken();

      final response = await client.get(
        Uri.parse('$baseUrl/recurring'),
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
          'message':
              error['message'] ??
              'Error al obtener las transacciones recurrentes',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    } finally {
      client.close();
    }
  }

  // Obtener reporte mensual
  Future<Map<String, dynamic>> getMonthlyReport(int year, int month) async {
    final client = _createClient();

    try {
      final token = await _tokenService.getToken();

      final response = await client.get(
        Uri.parse('$baseUrl/report/$year/$month'),
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
          'message': error['message'] ?? 'Error al obtener el reporte mensual',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    } finally {
      client.close();
    }
  }

  // Obtener transacción por ID
  Future<Map<String, dynamic>> getTransactionById(String id) async {
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
          'message': error['message'] ?? 'Error al obtener la transacción',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    } finally {
      client.close();
    }
  }

  // Actualizar transacción
  Future<Map<String, dynamic>> updateTransaction({
    required String id,
    required String accountId,
    required String categoryId,
    required double amount,
    required String date,
    required String description,
    required String type,
    bool isRecurring = false,
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
          'account_id': accountId,
          'category_id': categoryId,
          'amount': amount,
          'date': date,
          'description': description,
          'type': type,
          'is_recurring': isRecurring,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Transacción actualizada exitosamente',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Error al actualizar la transacción',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    } finally {
      client.close();
    }
  }

  // Eliminar transacción
  Future<Map<String, dynamic>> deleteTransaction(String id) async {
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
          'message': 'Transacción eliminada exitosamente',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Error al eliminar la transacción',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    } finally {
      client.close();
    }
  }
}
