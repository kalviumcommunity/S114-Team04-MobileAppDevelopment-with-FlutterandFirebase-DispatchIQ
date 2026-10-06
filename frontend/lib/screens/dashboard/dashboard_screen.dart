import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/job.dart';
import '../../models/technician.dart';
import '../../services/job_service.dart';
import '../../services/technician_service.dart';
import '../../utils/helpers.dart';
import '../analytics/analytics_screen.dart';
import '../jobs/jobs_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';
import '../technicians/technicians_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final todayJobs = JobService.getTodayJobs();
    final availableTechs = TechnicianService.getAvailableTechnicians().length;
    final onRouteTechnicians =
        TechnicianService.countByStatus(TechnicianStatus.onRoute);
    final busyTechnicians =
        TechnicianService.countByStatus(TechnicianStatus.busy);
    final delayedJobs = JobService.getDelayedCount();
    final unassignedJobs = JobService.getUnassignedCount();
    final onRouteJobs = JobService.countByStatus(JobStatus.onRoute);
    final atRiskJobs = JobService.getAtRiskCount();
    final maxWorkload = TechnicianService.allTechnicians.fold<int>(
      0,
      (total, technician) => total + technician.maxWorkload,
    );
    final assignedWorkload = TechnicianService.allTechnicians.fold<int>(
      0,
      (total, technician) => total + technician.currentWorkload,
    );
    final workloadUtilization =
        maxWorkload == 0 ? 0.0 : assignedWorkload / maxWorkload;

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _DashboardBody(
              todayJobs: todayJobs,
              availableTechs: availableTechs,
              onRouteTechnicians: onRouteTechnicians,
              busyTechnicians: busyTechnicians,
              delayedJobs: delayedJobs,
              unassignedJobs: unassignedJobs,
              onRouteJobs: onRouteJobs,
              atRiskJobs: atRiskJobs,
              workloadUtilization: workloadUtilization,
            ),
            const JobsScreen(),
            const TechniciansScreen(),
            const AnalyticsScreen(),
            const ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.assignment_rounded), label: 'Jobs'),
          NavigationDestination(
              icon: Icon(Icons.groups_rounded), label: 'Team'),
          NavigationDestination(
              icon: Icon(Icons.insights_rounded), label: 'Insights'),
          NavigationDestination(
              icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({
    required this.todayJobs,
    required this.availableTechs,
    required this.onRouteTechnicians,
    required this.busyTechnicians,
    required this.delayedJobs,
    required this.unassignedJobs,
    required this.onRouteJobs,
    required this.atRiskJobs,
    required this.workloadUtilization,
  });

  final List<Job> todayJobs;
  final int availableTechs;
  final int onRouteTechnicians;
  final int busyTechnicians;
  final int delayedJobs;
  final int unassignedJobs;
  final int onRouteJobs;
  final int atRiskJobs;
  final double workloadUtilization;

  @override
  Widget build(BuildContext context) {
    final todayDate = DateTime.now();
    final currentGreeting =
        todayDate.hour < 12 ? 'Good morning' : 'Good afternoon';
    final riskJobs = JobService.getAtRiskJobs();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentGreeting,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.muted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Today\'s Dispatch',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.navy,
                        letterSpacing: -0.8,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const NotificationsScreen()),
                      );
                    },
                    icon: const Icon(Icons.notifications_none_rounded,
                        color: AppTheme.navy),
                  ),
                  const SizedBox(width: 4),
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: AppTheme.primarySoft,
                    child: Icon(Icons.person_rounded, color: AppTheme.primary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                _MetricItem(
                    label: 'Jobs',
                    value: '${todayJobs.length}',
                    accent: AppTheme.primary),
                _MetricItem(
                    label: 'On Route',
                    value: '$onRouteJobs',
                    accent: AppTheme.blue),
                _MetricItem(
                    label: 'Unassigned',
                    value: '$unassignedJobs',
                    accent: AppTheme.amber),
                _MetricItem(
                    label: 'At Risk',
                    value: '$atRiskJobs',
                    accent: AppTheme.red),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Live Dispatch',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.navy,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth < 420 ? 2 : 4;
                    final itemWidth =
                        (constraints.maxWidth - (columns - 1) * 8) / columns;
                    final pills = [
                      _StatusPill(
                          label: 'Available',
                          value: availableTechs,
                          color: AppTheme.green),
                      _StatusPill(
                          label: 'On Route',
                          value: onRouteTechnicians,
                          color: AppTheme.primary),
                      _StatusPill(
                          label: 'Busy',
                          value: busyTechnicians,
                          color: AppTheme.amber),
                      _StatusPill(
                          label: 'Delayed',
                          value: delayedJobs,
                          color: AppTheme.red),
                    ];

                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final pill in pills)
                          SizedBox(width: itemWidth, child: pill),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 10,
                    value: workloadUtilization.clamp(0.0, 1.0),
                    backgroundColor: AppTheme.line,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Needs Attention',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.navy,
            ),
          ),
          const SizedBox(height: 12),
          if (riskJobs.isEmpty)
            const _AlertCard(
              title: 'All clear',
              subtitle: 'No jobs need immediate attention',
              detail: 'At-risk jobs will appear here for follow-up.',
              action: 'View Jobs',
              color: AppTheme.green,
            )
          else
            ...riskJobs.take(3).map((job) {
              final isRepeatVisit = JobService.isRepeatVisit(job);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _AlertCard(
                  title: isRepeatVisit ? 'Repeat Visit' : 'Arrival Risk',
                  subtitle: '${job.id} • ${job.fault}',
                  detail: isRepeatVisit && job.previousVisit != null
                      ? 'Previous repair: ${job.previousVisit!.action}'
                      : 'Appointment ends ${AppHelpers.formatTime(job.appointmentEnd)} · ETA ${AppHelpers.formatTime(job.eta)}',
                  action: 'View Details',
                  color: isRepeatVisit ? AppTheme.amber : AppTheme.red,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => JobDetailScreen(job: job)),
                  ),
                ),
              );
            }),
          const SizedBox(height: 24),
          const Text(
            'Upcoming Jobs',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.navy,
            ),
          ),
          const SizedBox(height: 12),
          if (todayJobs.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('No jobs scheduled today.'),
              ),
            )
          else
            ...todayJobs.take(3).map((job) {
              final technician = job.technicianId == null
                  ? null
                  : TechnicianService.getById(job.technicianId!);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Column(
                      children: [
                        Icon(Icons.radio_button_checked_rounded,
                            size: 12, color: AppTheme.primary),
                        SizedBox(height: 8),
                        Icon(Icons.more_vert_rounded,
                            size: 12, color: AppTheme.line),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppHelpers.formatTime(job.appointmentStart),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.muted,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            job.fault,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.navy,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${job.customer.name} • ${technician?.name ?? 'Unassigned'}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.charcoal,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${AppHelpers.formatTime(job.appointmentStart)} - ${AppHelpers.formatTime(job.appointmentEnd)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem(
      {required this.label, required this.value, required this.accent});

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
          const SizedBox(height: 4),
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

class _StatusPill extends StatelessWidget {
  const _StatusPill(
      {required this.label, required this.value, required this.color});

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.action,
    required this.color,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String detail;
  final String action;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.warning_amber_rounded, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.navy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      detail,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.charcoal,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  action,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
