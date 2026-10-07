import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../data/mock_data.dart';
import '../models/job.dart';
import '../models/technician.dart';

class BackendService {
  static const _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const _timeout = Duration(seconds: 5);
  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static String get _baseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl.replaceFirst(RegExp(r'/$'), '');
    }
    final host = !kIsWeb && defaultTargetPlatform == TargetPlatform.android
        ? '10.0.2.2'
        : '127.0.0.1';
    return 'http://$host:5000';
  }

  static Future<void> initialize() async {
    final response =
        await http.get(Uri.parse('$_baseUrl/api/state')).timeout(_timeout);
    if (response.statusCode != 200) {
      throw _requestError(response);
    }

    final state = jsonDecode(response.body);
    if (state == null) {
      await _writeCurrentState();
    } else {
      _applyState(Map<String, dynamic>.from(state as Map));
    }
    _initialized = true;
  }

  static Future<void> saveState() async {
    if (!_initialized) return;
    await _writeCurrentState();
  }

  static Future<void> _writeCurrentState() async {
    final response = await http
        .put(
          Uri.parse('$_baseUrl/api/state'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({
            'jobs': MockData.jobs.map((job) => job.toJson()).toList(),
            'technicians': MockData.technicians
                .map((technician) => technician.toJson())
                .toList(),
          }),
        )
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw _requestError(response);
    }
  }

  static void _applyState(Map<String, dynamic> state) {
    final jobs = (state['jobs'] as List)
        .map((job) => Job.fromJson(Map<String, dynamic>.from(job as Map)))
        .toList();
    final technicians = (state['technicians'] as List)
        .map((technician) =>
            Technician.fromJson(Map<String, dynamic>.from(technician as Map)))
        .toList();
    MockData.jobs
      ..clear()
      ..addAll(jobs);
    MockData.technicians
      ..clear()
      ..addAll(technicians);
  }

  static Exception _requestError(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final message = body['error'];
      if (message is String) return Exception(message);
    } on FormatException {
      // Use the HTTP status when the backend response is not JSON.
    }
    return Exception('Backend request failed (${response.statusCode})');
  }
}
