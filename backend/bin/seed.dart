import 'package:firedart/firedart.dart';

void main() async {
  Firestore.initialize('dispatchiq-d1103');
  print('Connecting to Firestore and creating collections...');

  final firestore = Firestore.instance;

  // 1. Seed Technicians (PRD Section 14)
  final techs = [
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

  for (var tech in techs) {
    await firestore.collection('technicians').document(tech['id'] as String).set(tech);
    print('Seeded technician: ${tech['name']}');
  }

  // 2. Seed Initial Completed Request (PRD Section 14)
  final initialJob = {
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
    'isRepeatVisit': false,
  };
  await firestore.collection('serviceRequests').document('job_101').set(initialJob);
  print('Seeded serviceRequest: job_101');

  // 3. Seed Service History (for Repeat Visit Checks)
  final initialHistory = {
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
  };
  await firestore.collection('serviceHistory').document('hist_01').set(initialHistory);
  print('Seeded serviceHistory: hist_01');

  print('Database seeding complete!');
}