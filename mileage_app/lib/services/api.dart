import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class ApiService {
  final http.Client _client;
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> fetchDashboard(
      {String? start, String? end}) async {
    final uri = Uri.parse(kScriptBaseUrl).replace(queryParameters: {
      'action': 'dashboard',
      if (start != null && start.isNotEmpty) 'start': start, // YYYY-MM-DD
      if (end != null && end.isNotEmpty) 'end': end, // YYYY-MM-DD
    });

    final res = await _client.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Dashboard fetch failed: ${res.statusCode}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<void> submitMileage({
    required String date, // "January 5, 2026" or whatever your web app sends
    required int startMileage,
    required int endMileage,
    required int miles,
    required double amountMade,
  }) async {
    final res = await _client.post(
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

    // Apps Script sometimes returns 200 even if it writes JSON text output
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Mileage submit failed: ${res.statusCode}');
    }
  }

  Future<void> submitMaintenance({
    required String date,
    required String type,
    required double cost,
  }) async {
    final res = await _client.post(
      Uri.parse(kScriptBaseUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'date': date,
        'type': type.toUpperCase(),
        'cost': cost.toStringAsFixed(2),
      },
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Maintenance submit failed: ${res.statusCode}');
    }
  }
}
