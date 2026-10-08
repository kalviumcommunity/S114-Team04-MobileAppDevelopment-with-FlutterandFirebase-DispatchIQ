import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firedart/firedart.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

const String firebaseProjectId = 'dispatchiq-d1103';

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
  // Initialize Firestore
  Firestore.initialize(firebaseProjectId);
  final db = Firestore.instance;

  final router = Router();

  // 1. Health check
  router.get('/api/health', (Request req) {
    return _jsonResponse({
      'status': 'DispatchIQ Dart + Firebase Backend Running',
      'database': 'Firestore Connected',
      'timestamp': DateTime.now().toIso8601String(),
    });
  });

  // 2. Auth Login (PRD FR01)
  router.post('/api/auth/login', (Request req) async {
    final body = jsonDecode(await req.readAsString());
    final email = body['email'] ?? 'dispatcher@dispatchiq.com';
    return _jsonResponse({
      'token': 'firebase-session-token-live',
      'user': {
        'id': 'usr_001',
        'name': 'Shawn David',
        'email': email,
        'role': 'Dispatcher',
      }
    });
  });

  // 3. Technicians (PRD FR03)
  router.get('/api/technicians', (Request req) async {
    final docs = await db.collection('technicians').get();
    final data = docs.map((doc) => doc.map).toList();
    return _jsonResponse({'success': true, 'count': data.length, 'data': data});
  });

  router.put('/api/technicians/<id>/location', (Request req, String id) async {
    final body = jsonDecode(await req.readAsString());
    await db.collection('technicians').document(id).update({
      'currentLocation': {
        'latitude': body['latitude'],
        'longitude': body['longitude'],
        'updatedAt': DateTime.now().toIso8601String(),
      }
    });
    final updated = await db.collection('technicians').document(id).get();
    return _jsonResponse({'success': true, 'data': updated.map});
  });

  router.put('/api/technicians/<id>/status', (Request req, String id) async {
    final body = jsonDecode(await req.readAsString());
    final updates = <String, dynamic>{};
    if (body['status'] != null) updates['status'] = body['status'];
    if (body['availability'] != null) updates['availability'] = body['availability'];

    await db.collection('technicians').document(id).update(updates);
    final updated = await db.collection('technicians').document(id).get();
    return _jsonResponse({'success': true, 'data': updated.map});
  });

  // 4. Create Service Request + Repeat Visit Detection (PRD FR02, FR07)
  router.post('/api/service-requests', (Request req) async {
    final body = jsonDecode(await req.readAsString());
    final appliance = body['appliance'] ?? 'Unknown Appliance';
    final address = body['address'] ?? 'General Location';

    // Query Firestore history for repeat visits
    final historyDocs = await db.collection('serviceHistory').get();
    final repeatMatches = historyDocs
        .map((d) => d.map)
        .where((hist) =>
            (hist['appliance'] ?? '').toString().toLowerCase() == appliance.toString().toLowerCase())
        .toList();

    final jobId = 'job_${DateTime.now().millisecondsSinceEpoch}';
    final newRequest = {
      'id': jobId,
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
      'createdAt': DateTime.now().toIso8601String(),
    };

    await db.collection('serviceRequests').document(jobId).set(newRequest);
    return _jsonResponse({'success': true, 'data': newRequest, 'repeatHistory': repeatMatches}, statusCode: 201);
  });

  router.get('/api/service-requests', (Request req) async {
    final docs = await db.collection('serviceRequests').get();
    final list = docs.map((d) => d.map).toList();
    return _jsonResponse({'success': true, 'count': list.length, 'data': list});
  });

  router.get('/api/service-requests/<id>', (Request req, String id) async {
    try {
      final doc = await db.collection('serviceRequests').document(id).get();
      return _jsonResponse({'success': true, 'data': doc.map});
    } catch (_) {
      return _jsonResponse({'error': 'Service Request not found'}, statusCode: 404);
    }
  });

  // 5. Smart Assignment Ranking (PRD FR04, Section 9)
  router.get('/api/jobs/<id>/candidates', (Request req, String id) async {
    final jobDoc = await db.collection('serviceRequests').document(id).get();
    final job = jobDoc.map;
    final reqAppliance = (job['appliance'] as String).toLowerCase();
    final jobLat = (job['location']?['latitude'] ?? 12.9716) as num;
    final jobLon = (job['location']?['longitude'] ?? 77.5946) as num;

    final techDocs = await db.collection('technicians').get();
    final candidates = techDocs.map((doc) {
      final tech = doc.map;
      final skills = (tech['skills'] as List? ?? []).map((s) => s.toString().toLowerCase()).toList();
      final hasSkill = skills.any((s) => reqAppliance.contains(s) || s.contains(reqAppliance));

      final techLat = (tech['currentLocation']?['latitude'] ?? 12.9716) as num;
      final techLon = (tech['currentLocation']?['longitude'] ?? 77.5946) as num;
      final dist = _calculateDistance(jobLat.toDouble(), jobLon.toDouble(), techLat.toDouble(), techLon.toDouble());

      double score = 0;
      if (hasSkill) score += 40;
      if (tech['availability'] == 'Available') score += 30;
      final workload = (tech['workload'] as int? ?? 0);
      score += max(0, 20 - (workload * 4));
      score += max(0, 10 - dist);

      return {
        'technician': tech,
        'distanceKm': double.parse(dist.toStringAsFixed(1)),
        'hasSkillMatch': hasSkill,
        'matchScore': score.round(),
      };
    }).toList();

    candidates.sort((a, b) => (b['matchScore'] as int).compareTo(a['matchScore'] as int));
    return _jsonResponse({'success': true, 'jobId': id, 'candidates': candidates});
  });

  // 6. Assign Job (PRD FR04)
  router.post('/api/jobs/<id>/assign', (Request req, String id) async {
    final body = jsonDecode(await req.readAsString());
    final techId = body['technicianId'];

    await db.collection('serviceRequests').document(id).update({
      'technicianId': techId,
      'status': 'Assigned',
      'assignedAt': DateTime.now().toIso8601String(),
    });

    final techDoc = await db.collection('technicians').document(techId).get();
    final currentWorkload = (techDoc.map['workload'] as int? ?? 0) + 1;
    await db.collection('technicians').document(techId).update({'workload': currentWorkload});

    final updated = await db.collection('serviceRequests').document(id).get();
    return _jsonResponse({'success': true, 'message': 'Assigned successfully', 'data': updated.map});
  });

  // 7. Update Status (PRD FR05)
  router.put('/api/jobs/<id>/status', (Request req, String id) async {
    final body = jsonDecode(await req.readAsString());
    final newStatus = body['status'];

    await db.collection('serviceRequests').document(id).update({
      'status': newStatus,
      'lastStatusUpdate': DateTime.now().toIso8601String(),
    });

    final updated = await db.collection('serviceRequests').document(id).get();
    return _jsonResponse({'success': true, 'data': updated.map});
  });

  // 8. Complete Service Form (PRD FR08)
  router.post('/api/jobs/<id>/complete', (Request req, String id) async {
    final body = jsonDecode(await req.readAsString());
    final jobDoc = await db.collection('serviceRequests').document(id).get();
    final job = jobDoc.map;

    final histId = 'hist_${DateTime.now().millisecondsSinceEpoch}';
    final record = {
      'id': histId,
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

    await db.collection('serviceHistory').document(histId).set(record);
    await db.collection('serviceRequests').document(id).update({'status': 'Completed'});

    if (job['technicianId'] != null) {
      final techDoc = await db.collection('technicians').document(job['technicianId']).get();
      final currentWorkload = (techDoc.map['workload'] as int? ?? 1);
      if (currentWorkload > 0) {
        await db.collection('technicians').document(job['technicianId']).update({'workload': currentWorkload - 1});
      }
    }

    return _jsonResponse({'success': true, 'message': 'Job completed and recorded to Firestore', 'data': record});
  });

  // 9. Analytics Dashboard (PRD FR09)
  router.get('/api/analytics/dashboard', (Request req) async {
    final jobsDocs = await db.collection('serviceRequests').get();
    final historyDocs = await db.collection('serviceHistory').get();
    final techDocs = await db.collection('technicians').get();

    final jobs = jobsDocs.map((d) => d.map).toList();
    final history = historyDocs.map((d) => d.map).toList();

    final totalCompleted = jobs.where((j) => j['status'] == 'Completed').length;
    final ftfCount = history.where((h) => h['firstTimeFix'] == true).length;
    final ftfRate = totalCompleted > 0 ? ((ftfCount / totalCompleted) * 100).round() : 100;
    final repeatVisits = jobs.where((j) => j['isRepeatVisit'] == true).length;

    return _jsonResponse({
      'success': true,
      'kpis': {
        'firstTimeFixRate': '$ftfRate%',
        'targetFirstTimeFix': '>=85%',
        'totalCompletedJobs': totalCompleted,
        'repeatVisitsFlagged': repeatVisits,
        'activeTechnicians': techDocs.where((t) => t.map['status'] == 'Active').length,
      }
    });
  });

  // Middleware for CORS headers & OPTIONS preflight
  Middleware corsMiddleware() {
    return (Handler innerHandler) {
      return (Request request) async {
        if (request.method == 'OPTIONS') {
          return Response.ok('', headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
            'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
          });
        }
        final response = await innerHandler(request);
        return response.change(headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
        });
      };
    };
  }

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsMiddleware())
      .addHandler(router.call);

  final port = int.parse(Platform.environment['PORT'] ?? '5000');
  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
  print('DispatchIQ Server + Live Firestore running on port ${server.port}');
}