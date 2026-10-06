import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/technician.dart';
import '../../services/technician_service.dart';
import '../../widgets/technician_card.dart';

class TechniciansScreen extends StatelessWidget {
  const TechniciansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final technicians = TechnicianService.allTechnicians;

    return Scaffold(
      appBar: AppBar(title: const Text('Team')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Team',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.navy,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '10 technicians active today',
                style: TextStyle(color: AppTheme.muted, fontSize: 14),
              ),
              const SizedBox(height: 18),
              const Row(
                children: [
                  Expanded(child: _TeamStat(label: 'Available', value: '5', color: AppTheme.green)),
                  SizedBox(width: 12),
                  Expanded(child: _TeamStat(label: 'On Route', value: '3', color: AppTheme.primary)),
                  SizedBox(width: 12),
                  Expanded(child: _TeamStat(label: 'Busy', value: '2', color: AppTheme.amber)),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: technicians.length,
                  itemBuilder: (context, index) {
                    final technician = technicians[index];
                    return TechnicianCard(
                      technician: technician,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TechnicianDetailScreen(technician: technician),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeamStat extends StatelessWidget {
  const _TeamStat({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class TechnicianDetailScreen extends StatelessWidget {
  const TechnicianDetailScreen({super.key, required this.technician});

  final Technician technician;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(technician.name)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppTheme.primarySoft,
                        child: Text(
                          technician.name.split(' ').map((word) => word[0]).take(2).join(),
                          style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              technician.name,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.navy),
                            ),
                            Text(
                              technician.id,
                              style: const TextStyle(color: AppTheme.muted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Technician Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.navy)),
                    const SizedBox(height: 12),
                    Container(
                      height: 130,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.primarySoft,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.map_rounded, size: 30, color: AppTheme.primary),
                            SizedBox(height: 8),
                            Text('Technician Location', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _KeyValueSection(title: 'Profile', items: {
                'Contact': technician.phone,
                'Email': technician.email,
                'Expertise': technician.expertise.join(', '),
                'Current location': technician.location,
                'Current assigned jobs': technician.currentAssignedJobs.isEmpty ? 'None' : technician.currentAssignedJobs.join(', '),
                'Today\'s workload': '${technician.completedToday} jobs',
                'Completed jobs': '${technician.jobsCompleted}',
                'First-time fix rate': '${technician.firstTimeFixRate}%',
                'Average job completion time': '2.6 hrs',
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _KeyValueSection extends StatelessWidget {
  const _KeyValueSection({required this.title, required this.items});

  final String title;
  final Map<String, String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppTheme.navy)),
          const SizedBox(height: 14),
          ...items.entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 130,
                      child: Text(entry.key, style: const TextStyle(color: AppTheme.muted, fontWeight: FontWeight.w600)),
                    ),
                    Expanded(
                      child: Text(entry.value, style: const TextStyle(color: AppTheme.charcoal)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
