import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'token_service.dart';

class DebtService {
  static const String baseUrl = 'http://localhost:4000/api/debts';
  final _tokenService = TokenService();

  http.Client _createClient() {
    if (kIsWeb) {
      final client = BrowserClient();
      client.withCredentials = true;
      return client;
    }
    return http.Client();
  }

  Future<Map<String, dynamic>> getDebts() async {
    final client = _createClient();
    final token = await _tokenService.getToken();

    try {
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
        return {'success': false, 'message': 'Error al cargar deudas'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    } finally {
      client.close();
    }
  }

  Future<Map<String, dynamic>> getDebtSummary() async {
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

  Future<Map<String, dynamic>> getDebtById(String debtId) async {
    final client = _createClient();
    final token = await _tokenService.getToken();

    try {
      final response = await client.get(
        Uri.parse('$baseUrl/$debtId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'message': 'Error al cargar deuda'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    } finally {
      client.close();
    }
  }

  Future<Map<String, dynamic>> createDebt({
    required String name,
    required double totalAmount,
    required double remainingAmount,
    required double interestRate,
    required double minimumPayment,
    required int dueDay,
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
          'name': name,
          'total_amount': totalAmount,
          'remaining_amount': remainingAmount,
          'interest_rate': interestRate,
          'minimum_payment': minimumPayment,
          'due_day': dueDay,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'],
          'message': 'Deuda creada exitosamente',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Error al crear deuda',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    } finally {
      client.close();
    }
  }

  Future<Map<String, dynamic>> updateDebt({
    required String debtId,
    String? name,
    double? totalAmount,
    double? remainingAmount,
    double? interestRate,
    double? minimumPayment,
    int? dueDay,
  }) async {
    final client = _createClient();
    final token = await _tokenService.getToken();

    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (totalAmount != null) body['total_amount'] = totalAmount;
      if (remainingAmount != null) body['remaining_amount'] = remainingAmount;
      if (interestRate != null) body['interest_rate'] = interestRate;
      if (minimumPayment != null) body['minimum_payment'] = minimumPayment;
      if (dueDay != null) body['due_day'] = dueDay;

      final response = await client.put(
        Uri.parse('$baseUrl/$debtId'),
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
          'message': 'Deuda actualizada exitosamente',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Error al actualizar deuda',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    } finally {
      client.close();
    }
  }

  Future<Map<String, dynamic>> deleteDebt(String debtId) async {
    final client = _createClient();
    final token = await _tokenService.getToken();

    try {
      final response = await client.delete(
        Uri.parse('$baseUrl/$debtId'),
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
          'message': error['message'] ?? 'Error al eliminar deuda',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    } finally {
      client.close();
    }
  }

  Future<Map<String, dynamic>> registerPayment({
    required String debtId,
    required double paymentAmount,
  }) async {
    final client = _createClient();
    final token = await _tokenService.getToken();

    try {
      final response = await client.post(
        Uri.parse('$baseUrl/$debtId/payment'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'payment_amount': paymentAmount}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'],
          'message': 'Pago registrado exitosamente',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Error al registrar pago',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    } finally {
      client.close();
    }
  }
}
