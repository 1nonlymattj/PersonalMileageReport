import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class ApiService {
  final http.Client _client;
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<http.Response> _sendFollowRedirects(String method, Uri uri,
      {Map<String, String>? headers, Map<String, String>? body}) async {
    final req = http.Request(method, uri)
      ..followRedirects = true
      ..maxRedirects = 5;

    if (headers != null) req.headers.addAll(headers);
    if (body != null) req.bodyFields = body;

    final streamed = await _client.send(req);
    return http.Response.fromStream(streamed);
  }

  Future<Map<String, dynamic>> fetchDashboard(
      {String? start, String? end}) async {
    final uri = Uri.parse(kScriptBaseUrl).replace(queryParameters: {
      'action': 'dashboard',
      if (start != null && start.isNotEmpty) 'start': start,
      if (end != null && end.isNotEmpty) 'end': end,
    });

    final res = await _sendFollowRedirects('GET', uri);

    if (res.statusCode < 200 || res.statusCode >= 400) {
      throw Exception('Dashboard fetch failed: ${res.statusCode}\n${res.body}');
    }

    // If you were redirected to an HTML login page, JSON decode will fail.
    try {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception(
        'Dashboard returned non-JSON. Likely redirect/login issue.\n'
        'Status: ${res.statusCode}\nBody starts with: ${res.body.substring(0, res.body.length > 120 ? 120 : res.body.length)}',
      );
    }
  }

  Future<void> submitMileage({
    required String date,
    required int startMileage,
    required int endMileage,
    required int miles,
    required double amountMade,
  }) async {
    final res = await _sendFollowRedirects(
      'POST',
      Uri.parse(kScriptBaseUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'date': date,
        'startMileage': '$startMileage',
        'endMileage': '$endMileage',
        'mileage': '$miles',
        'amountMade': amountMade.toStringAsFixed(2),
      },
    );

    if (res.statusCode < 200 || res.statusCode >= 400) {
      throw Exception('Mileage submit failed: ${res.statusCode}\n${res.body}');
    }
  }

  Future<void> submitMaintenance({
    required String date,
    required String type,
    required double cost,
  }) async {
    final res = await _sendFollowRedirects(
      'POST',
      Uri.parse(kScriptBaseUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'date': date,
        'type': type.toUpperCase(),
        'cost': cost.toStringAsFixed(2),
      },
    );

    if (res.statusCode < 200 || res.statusCode >= 400) {
      throw Exception(
          'Maintenance submit failed: ${res.statusCode}\n${res.body}');
    }
  }
}
