import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

// --- IN-MEMORY DATA STORES (PRD Section 14) ---
final List<Map<String, dynamic>> technicians = [
  {
    'id': 'tech_01',
    'name': 'Alex Rivera',
    'skills': ['Refrigerator', 'Washing Machine'],
    'currentLocation': {'latitude': 12.9716, 'longitude': 77.5946},
    'availability': 'Available',
    'workload': 2,
    'status': 'Active',
  },
  {
    'id': 'tech_02',
    'name': 'Jordan Lee',
    'skills': ['Microwave', 'Dishwasher', 'Oven'],
    'currentLocation': {'latitude': 12.9352, 'longitude': 77.6245},
    'availability': 'Available',
    'workload': 1,
    'status': 'Active',
  },
  {
    'id': 'tech_03',
    'name': 'Samira Khan',
    'skills': ['Washing Machine', 'Dryer', 'Dishwasher'],
    'currentLocation': {'latitude': 13.0358, 'longitude': 77.5970},
    'availability': 'Busy',
    'workload': 4,
    'status': 'Active',
  },
];

final List<Map<String, dynamic>> serviceRequests = [
  {
    'id': 'job_101',
    'customerId': 'cust_01',
    'technicianId': 'tech_01',
    'appliance': 'Washing Machine',
    'brand': 'Samsung',
    'model': 'EcoBubble 8kg',
    'fault': 'Drain pump failure',
    'address': 'Koramangala 4th Block, Bangalore',
    'location': {'latitude': 12.9352, 'longitude': 77.6245},
    'priority': 'High',
    'status': 'Completed',
    'createdAt': '2026-09-10T10:00:00.000Z',
    'appointmentWindow': '10:00 AM - 12:00 PM',
  },
];

final List<Map<String, dynamic>> serviceHistory = [
  {
    'id': 'hist_01',
    'serviceRequestId': 'job_101',
    'appliance': 'Washing Machine',
    'brand': 'Samsung',
    'diagnosis': 'Foreign object lodged in drain impeller',
    'repairPerformed': 'Cleared blockage and replaced drain filter gasket',
    'partsUsed': ['Drain Filter Gasket (Part #DC62-00008A)'],
    'firstTimeFix': true,
    'notes': 'Advised customer to inspect pocket contents prior to washing cycle.',
    'completedAt': '2026-09-10T11:45:00.000Z',
  },
];

// Helper: Haversine distance in km
double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const p = 0.017453292519943295;
  final a = 0.5 -
      cos((lat2 - lat1) * p) / 2 +
      cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a));
}

Response _jsonResponse(dynamic data, {int statusCode = 200}) {
  return Response(
    statusCode,
    body: jsonEncode(data),
    headers: {
      'content-type': 'application/json',
      'access-control-allow-origin': '*',
      'access-control-allow-methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'access-control-allow-headers': 'Origin, Content-Type, Authorization',
    },
  );
}

void main(List<String> args) async {
  final router = Router();

  // Handle CORS preflight
  router.all('/<ignored|.*>', (Request request) {
    if (request.method == 'OPTIONS') {
      return Response.ok('', headers: {
        'access-control-allow-origin': '*',
        'access-control-allow-methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'access-control-allow-headers': 'Origin, Content-Type, Authorization',
      });
    }
    return Response.notFound('Not found');
  });

  // 1. Health check
  router.get('/api/health', (Request req) {
    return _jsonResponse({
      'status': 'DispatchIQ Dart Backend Live',
      'timestamp': DateTime.now().toIso8601String(),
    });
  });

  // 2. Auth Login Mock
  router.post('/api/auth/login', (Request req) async {
    final body = jsonDecode(await req.readAsString());
    final email = body['email'] ?? 'dispatcher@dispatchiq.com';
    return _jsonResponse({
      'token': 'mock-jwt-token-xyz',
      'user': {
        'id': 'usr_001',
        'name': 'Shawn David',
        'email': email,
        'role': 'Dispatcher',
      }
    });
  });

  // 3. Technician Management
  router.get('/api/technicians', (Request req) {
    return _jsonResponse({'success': true, 'count': technicians.length, 'data': technicians});
  });

  router.put('/api/technicians/<id>/location', (Request req, String id) async {
    final body = jsonDecode(await req.readAsString());
    final tech = technicians.firstWhere((t) => t['id'] == id, orElse: () => {});
    if (tech.isEmpty) return _jsonResponse({'error': 'Technician not found'}, statusCode: 404);

    tech['currentLocation'] = {
      'latitude': body['latitude'],
      'longitude': body['longitude'],
      'updatedAt': DateTime.now().toIso8601String(),
    };
    return _jsonResponse({'success': true, 'data': tech});
  });

  router.put('/api/technicians/<id>/status', (Request req, String id) async {
    final body = jsonDecode(await req.readAsString());
    final tech = technicians.firstWhere((t) => t['id'] == id, orElse: () => {});
    if (tech.isEmpty) return _jsonResponse({'error': 'Technician not found'}, statusCode: 404);

    if (body['status'] != null) tech['status'] = body['status'];
    if (body['availability'] != null) tech['availability'] = body['availability'];
    return _jsonResponse({'success': true, 'data': tech});
  });

  // 4. Create Service Request + Repeat Visit Detection
  router.post('/api/service-requests', (Request req) async {
    final body = jsonDecode(await req.readAsString());
    final appliance = body['appliance'] ?? 'Unknown Appliance';
    final address = body['address'] ?? 'General Location';

    final repeatMatches = serviceHistory.where((hist) {
      return (hist['appliance'] as String).toLowerCase() == appliance.toString().toLowerCase();
    }).toList();

    final newRequest = {
      'id': 'job_${DateTime.now().millisecondsSinceEpoch}',
      'customerId': body['customerId'] ?? 'cust_guest',
      'technicianId': null,
      'appliance': appliance,
      'brand': body['brand'] ?? '',
      'model': body['model'] ?? '',
      'fault': body['fault'] ?? '',
      'address': address,
      'location': body['location'] ?? {'latitude': 12.9716, 'longitude': 77.5946},
      'appointmentWindow': body['preferredWindow'] ?? 'Within 2 Hours',
      'priority': body['priority'] ?? 'Standard',
      'status': 'Requested',
      'isRepeatVisit': repeatMatches.isNotEmpty,
      'repeatHistory': repeatMatches,
      'createdAt': DateTime.now().toIso8601String(),
    };

    serviceRequests.add(newRequest);
    return _jsonResponse({'success': true, 'data': newRequest}, statusCode: 201);
  });

  router.get('/api/service-requests', (Request req) {
    return _jsonResponse({'success': true, 'count': serviceRequests.length, 'data': serviceRequests});
  });

  router.get('/api/service-requests/<id>', (Request req, String id) {
    final job = serviceRequests.firstWhere((j) => j['id'] == id, orElse: () => {});
    if (job.isEmpty) return _jsonResponse({'error': 'Service Request not found'}, statusCode: 404);
    return _jsonResponse({'success': true, 'data': job});
  });

  // 5. Smart Assignment Ranking
  router.get('/api/jobs/<id>/candidates', (Request req, String id) {
    final job = serviceRequests.firstWhere((j) => j['id'] == id, orElse: () => {});
    if (job.isEmpty) return _jsonResponse({'error': 'Job not found'}, statusCode: 404);

    final reqAppliance = (job['appliance'] as String).toLowerCase();
    final jobLat = (job['location']?['latitude'] ?? 12.9716) as num;
    final jobLon = (job['location']?['longitude'] ?? 77.5946) as num;

    final rankedCandidates = technicians.map((tech) {
      final skills = (tech['skills'] as List).map((s) => s.toString().toLowerCase()).toList();
      final hasSkill = skills.any((s) => reqAppliance.contains(s) || s.contains(reqAppliance));
      
      final techLat = (tech['currentLocation']?['latitude'] ?? 12.9716) as num;
      final techLon = (tech['currentLocation']?['longitude'] ?? 77.5946) as num;
      final distanceKm = _calculateDistance(jobLat.toDouble(), jobLon.toDouble(), techLat.toDouble(), techLon.toDouble());

      double score = 0;
      if (hasSkill) score += 40;
      if (tech['availability'] == 'Available') score += 30;
      final workload = (tech['workload'] as int);
      score += max(0, 20 - (workload * 4));
      score += max(0, 10 - distanceKm);

      return {
        'technician': tech,
        'distanceKm': double.parse(distanceKm.toStringAsFixed(1)),
        'hasSkillMatch': hasSkill,
        'matchScore': score.round(),
      };
    }).toList();

    rankedCandidates.sort((a, b) => (b['matchScore'] as int).compareTo(a['matchScore'] as int));

    return _jsonResponse({'success': true, 'jobId': id, 'candidates': rankedCandidates});
  });

  // 6. Assign Technician to Job
  router.post('/api/jobs/<id>/assign', (Request req, String id) async {
    final body = jsonDecode(await req.readAsString());
    final technicianId = body['technicianId'];

    final job = serviceRequests.firstWhere((j) => j['id'] == id, orElse: () => {});
    if (job.isEmpty) return _jsonResponse({'error': 'Job not found'}, statusCode: 404);

    final tech = technicians.firstWhere((t) => t['id'] == technicianId, orElse: () => {});
    if (tech.isEmpty) return _jsonResponse({'error': 'Technician not found'}, statusCode: 404);

    job['technicianId'] = technicianId;
    job['status'] = 'Assigned';
    job['assignedAt'] = DateTime.now().toIso8601String();
    tech['workload'] = (tech['workload'] as int) + 1;

    return _jsonResponse({'success': true, 'message': 'Technician assigned successfully', 'data': job});
  });

  // 7. Update Job Status Lifecycle
  router.put('/api/jobs/<id>/status', (Request req, String id) async {
    final body = jsonDecode(await req.readAsString());
    final newStatus = body['status'];

    final job = serviceRequests.firstWhere((j) => j['id'] == id, orElse: () => {});
    if (job.isEmpty) return _jsonResponse({'error': 'Job not found'}, statusCode: 404);

    job['status'] = newStatus;
    job['lastStatusUpdate'] = DateTime.now().toIso8601String();
    return _jsonResponse({'success': true, 'data': job});
  });

  // 8. Complete Service Form
  router.post('/api/jobs/<id>/complete', (Request req, String id) async {
    final body = jsonDecode(await req.readAsString());
    final job = serviceRequests.firstWhere((j) => j['id'] == id, orElse: () => {});
    if (job.isEmpty) return _jsonResponse({'error': 'Job not found'}, statusCode: 404);

    final record = {
      'id': 'hist_${DateTime.now().millisecondsSinceEpoch}',
      'serviceRequestId': id,
      'appliance': job['appliance'],
      'brand': job['brand'],
      'diagnosis': body['diagnosis'] ?? 'General diagnosis completed',
      'repairPerformed': body['repairPerformed'] ?? 'Standard repair',
      'partsUsed': body['partsUsed'] ?? [],
      'firstTimeFix': body['firstTimeFix'] ?? true,
      'notes': body['notes'] ?? '',
      'completedAt': DateTime.now().toIso8601String(),
    };

    serviceHistory.add(record);
    job['status'] = 'Completed';

    if (job['technicianId'] != null) {
      final tech = technicians.firstWhere((t) => t['id'] == job['technicianId'], orElse: () => {});
      if (tech.isNotEmpty && (tech['workload'] as int) > 0) {
        tech['workload'] = (tech['workload'] as int) - 1;
      }
    }

    return _jsonResponse({'success': true, 'message': 'Job closed and service history recorded', 'data': record});
  });

  // 9. Analytics Dashboard
  router.get('/api/analytics/dashboard', (Request req) {
    final totalCompleted = serviceRequests.where((j) => j['status'] == 'Completed').length;
    final ftfCount = serviceHistory.where((h) => h['firstTimeFix'] == true).length;
    final ftfRate = totalCompleted > 0 ? ((ftfCount / totalCompleted) * 100).round() : 100;
    final repeatVisits = serviceRequests.where((j) => j['isRepeatVisit'] == true).length;

    return _jsonResponse({
      'success': true,
      'kpis': {
        'firstTimeFixRate': '$ftfRate%',
        'targetFirstTimeFix': '>=85%',
        'totalCompletedJobs': totalCompleted,
        'repeatVisitsFlagged': repeatVisits,
        'activeTechnicians': technicians.where((t) => t['status'] == 'Active').length,
      }
    });
  });

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addHandler(router.call);

  final port = int.parse(Platform.environment['PORT'] ?? '5000');
  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
  print('DispatchIQ PRD Backend running on port ${server.port}');
}