import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'token_service.dart';

class DebtService {
  static const String baseUrl = 'http://localhost:4000/api/debts';
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

  // Crear nueva deuda
  Future<Map<String, dynamic>> createDebt({
    required String name,
    required double totalAmount,
    required double remainingAmount,
    required double interestRate,
    required double minimumPayment,
    required int dueDay,
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
          'name': name,
          'total_amount': totalAmount,
          'remaining_amount': remainingAmount,
          'interest_rate': interestRate,
          'minimum_payment': minimumPayment,
          'due_day': dueDay,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Deuda creada exitosamente',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Error al crear la deuda',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    } finally {
      client.close();
    }
  }

  // Obtener todas las deudas
  Future<Map<String, dynamic>> getDebts() async {
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
          'message': error['message'] ?? 'Error al obtener las deudas',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    } finally {
      client.close();
    }
  }

  // Obtener resumen de deudas
  Future<Map<String, dynamic>> getDebtsSummary() async {
    final client = _createClient();

    try {
      final token = await _tokenService.getToken();

      final response = await client.get(
        Uri.parse('$baseUrl/summary'),
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
              error['message'] ?? 'Error al obtener el resumen de deudas',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    } finally {
      client.close();
    }
  }

  // Obtener deuda por ID
  Future<Map<String, dynamic>> getDebtById(String id) async {
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
          'message': error['message'] ?? 'Error al obtener la deuda',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    } finally {
      client.close();
    }
  }

  // Actualizar deuda
  Future<Map<String, dynamic>> updateDebt({
    required String id,
    required String name,
    required double totalAmount,
    required double remainingAmount,
    required double interestRate,
    required double minimumPayment,
    required int dueDay,
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
          'name': name,
          'total_amount': totalAmount,
          'remaining_amount': remainingAmount,
          'interest_rate': interestRate,
          'minimum_payment': minimumPayment,
          'due_day': dueDay,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Deuda actualizada exitosamente',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Error al actualizar la deuda',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    } finally {
      client.close();
    }
  }

  // Eliminar deuda
  Future<Map<String, dynamic>> deleteDebt(String id) async {
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
        return {'success': true, 'message': 'Deuda eliminada exitosamente'};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Error al eliminar la deuda',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    } finally {
      client.close();
    }
  }

  // Registrar pago de deuda
  Future<Map<String, dynamic>> registerPayment({
    required String debtId,
    required double paymentAmount,
  }) async {
    final client = _createClient();

    try {
      final token = await _tokenService.getToken();

      final response = await client.post(
        Uri.parse('$baseUrl/$debtId/payment'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'payment_amount': paymentAmount}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Pago registrado exitosamente',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Error al registrar el pago',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    } finally {
      client.close();
    }
  }
}
