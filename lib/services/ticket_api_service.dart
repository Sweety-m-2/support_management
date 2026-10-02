import 'dart:async';
import 'dart:convert';

import 'package:assigned_task_quantek/config/api_config.dart';
import 'package:assigned_task_quantek/models/ticket.dart';
import 'package:http/http.dart' as http;

class TicketApiException implements Exception {
  const TicketApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;
}

class TicketApiService {
  TicketApiService({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = (baseUrl ?? ApiConfig.baseUrl).replaceFirst(RegExp(r'/$'), '');

  final http.Client _client;
  final String _baseUrl;

  Future<TicketListResponse> getTickets({
    String? search,
    String? status,
    String? priority,
    String sort = 'newest',
    int page = 1,
    int limit = 10,
  }) async {
    final parameters = <String, String>{
      'sort': sort,
      'page': '$page',
      'limit': '$limit',
    };
    if (search != null && search.trim().isNotEmpty) {
      parameters['search'] = search.trim();
    }
    if (status != null && status.isNotEmpty) {
      parameters['status'] = status;
    }
    if (priority != null && priority.isNotEmpty) {
      parameters['priority'] = priority;
    }

    final uri = Uri.parse('$_baseUrl/api/tickets')
        .replace(queryParameters: parameters);
    final response = await _send(() => _client.get(uri));
    return TicketListResponse.fromJson(_decodeObject(response));
  }

  Future<Ticket> createTicket({
    required String title,
    required String description,
    required String customerEmail,
    required String priority,
  }) async {
    final response = await _send(
      () => _client.post(
        Uri.parse('$_baseUrl/api/tickets'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'description': description,
          'customer_email': customerEmail,
          'priority': priority,
        }),
      ),
    );
    return Ticket.fromJson(_decodeObject(response));
  }

  Future<Ticket> updateTicket({
    required int ticketId,
    required String status,
    required String priority,
  }) async {
    final response = await _send(
      () => _client.patch(
        Uri.parse('$_baseUrl/api/tickets/$ticketId'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({'status': status, 'priority': priority}),
      ),
    );
    return Ticket.fromJson(_decodeObject(response));
  }

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(const Duration(seconds: 12));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      }
      throw TicketApiException(
        _errorMessage(response),
        statusCode: response.statusCode,
      );
    } on TicketApiException {
      rethrow;
    } on TimeoutException {
      throw const TicketApiException(
        'The request timed out. Please try again.',
      );
    } catch (_) {
      throw const TicketApiException(
        'Unable to connect to the ticket service.',
      );
    }
  }

  Map<String, dynamic> _decodeObject(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } on FormatException {
      // Converted below into a safe, user-facing error.
    }
    throw const TicketApiException(
      'The ticket service returned an unexpected response.',
    );
  }

  String _errorMessage(http.Response response) {
    String? detail;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['detail'] is String) {
        detail = decoded['detail'] as String;
      }
    } on FormatException {
      // Fall back to a status-specific message.
    }
    if (detail != null && detail.isNotEmpty) {
      return detail;
    }
    return switch (response.statusCode) {
      400 || 422 => 'Please check the information entered.',
      404 => 'Ticket was not found.',
      >= 500 => 'The ticket service is unavailable. Please try again.',
      _ => 'Unable to complete the request. Please try again.',
    };
  }
}
