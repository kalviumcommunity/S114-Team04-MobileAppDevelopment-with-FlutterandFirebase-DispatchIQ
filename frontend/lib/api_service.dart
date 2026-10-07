import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';

  static void check(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(response.body);
    }
  }

  // ---------------- TECHNICIANS ----------------

  static Future<List<dynamic>> getTechnicians() async {
    final response =
        await http.get(Uri.parse('$baseUrl/technicians'));

    check(response);
    return jsonDecode(response.body);
  }

  static Future<dynamic> updateTechnicianStatus(
    int id,
    String status,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/technicians/$id/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );

    check(response);
    return jsonDecode(response.body);
  }

  // ---------------- SERVICE REQUESTS ----------------

  static Future<List<dynamic>> getServiceRequests() async {
    final response =
        await http.get(Uri.parse('$baseUrl/service-requests'));

    check(response);
    return jsonDecode(response.body);
  }

  // ---------------- JOBS ----------------

  static Future<List<dynamic>> getJobs() async {
    final response =
        await http.get(Uri.parse('$baseUrl/jobs'));

    check(response);
    return jsonDecode(response.body);
  }

  static Future<dynamic> createJob({
    required int serviceRequestId,
    required int technicianId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/jobs'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'service_request_id': serviceRequestId,
        'technician_id': technicianId,
      }),
    );

    check(response);
    return jsonDecode(response.body);
  }

  static Future<dynamic> updateJobStatus(
    int id,
    String status,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/jobs/$id/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'status': status,
      }),
    );

    check(response);
    return jsonDecode(response.body);
  }

  static Future<dynamic> completeJob(
    int id, {
    String? diagnosis,
    String? repairPerformed,
    String? partsUsed,
    String? notes,
    bool firstTimeFix = true,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/jobs/$id/complete'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'diagnosis': diagnosis,
        'repair_performed': repairPerformed,
        'parts_used': partsUsed,
        'notes': notes,
        'first_time_fix': firstTimeFix,
      }),
    );

    check(response);
    return jsonDecode(response.body);
  }

  // ---------------- SERVICE HISTORY ----------------

  static Future<List<dynamic>> getServiceHistory() async {
    final response =
        await http.get(Uri.parse('$baseUrl/service-history'));

    check(response);
    return jsonDecode(response.body);
  }

  // ---------------- ANALYTICS ----------------

  static Future<Map<String, dynamic>> getDashboardAnalytics() async {
    final response =
        await http.get(Uri.parse('$baseUrl/analytics/dashboard'));

    check(response);
    return Map<String, dynamic>.from(
      jsonDecode(response.body),
    );
  }

  static Future<Map<String, dynamic>> getFirstTimeFix() async {
    final response =
        await http.get(Uri.parse('$baseUrl/analytics/first-time-fix'));

    check(response);
    return Map<String, dynamic>.from(
      jsonDecode(response.body),
    );
  }
}