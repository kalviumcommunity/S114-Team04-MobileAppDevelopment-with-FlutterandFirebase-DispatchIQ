import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/job.dart';
import '../../models/technician.dart';
import '../../services/assignment_service.dart';
import '../../services/job_service.dart';
import '../../services/technician_service.dart';
import '../../utils/helpers.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _selectedFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobs = JobService.getFilteredJobs(
      query: _searchController.text,
      filter: _selectedFilter,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jobs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Search jobs',
            onPressed: () => _searchFocusNode.requestFocus(),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () => _showFilterSheet(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Search customer or fault',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 42,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    'All',
                    'Unassigned',
                    'Assigned',
                    'On Route',
                    'At Risk',
                    'Completed',
                  ].map((filter) {
                    final selected = filter == _selectedFilter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(filter),
                        selected: selected,
                        onSelected: (_) =>
                            setState(() => _selectedFilter = filter),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: jobs.isEmpty
                    ? const Center(child: Text('No jobs found for this filter'))
                    : ListView.builder(
                        itemCount: jobs.length,
                        itemBuilder: (_, index) {
                          final job = jobs[index];
                          return _JobTile(
                            job: job,
                            onTap: () async {
                              final updated =
                                  await Navigator.of(context).push<bool>(
                                MaterialPageRoute(
                                  builder: (_) => JobDetailScreen(job: job),
                                ),
                              );
                              if (updated == true && mounted) {
                                setState(() {});
                              }
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

  Future<void> _showFilterSheet() async {
    final picker = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => SizedBox(
        height: 260,
        child: ListView(
          children: [
            'All',
            'Unassigned',
            'Assigned',
            'On Route',
            'At Risk',
            'Completed',
          ]
              .map((filter) => ListTile(
                    title: Text(filter),
                    onTap: () => Navigator.of(context).pop(filter),
                  ))
              .toList(),
        ),
      ),
    );

    if (picker != null) {
      setState(() => _selectedFilter = picker);
    }
  }
}

class _JobTile extends StatelessWidget {
  const _JobTile({required this.job, this.onTap});

  final Job job;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isAtRisk =
        job.status == JobStatus.delayed || JobService.isRepeatVisit(job);
    final technician = job.technicianId == null
        ? null
        : TechnicianService.getById(job.technicianId!);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isAtRisk ? AppTheme.redSoft : AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isAtRisk ? AppTheme.red.withValues(alpha: 0.2) : AppTheme.line,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    job.id,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.7,
                      color: AppTheme.muted,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.primarySoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    JobService.isRepeatVisit(job)
                        ? 'Repeat Visit'
                        : job.statusLabel,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              job.fault,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.navy,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${job.customer.name} • ${job.address}',
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.charcoal,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 18,
              runSpacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.schedule_rounded,
                        size: 15, color: AppTheme.muted),
                    const SizedBox(width: 6),
                    Text(
                      '${AppHelpers.formatTime(job.appointmentStart)} – ${AppHelpers.formatTime(job.appointmentEnd)}',
                      style:
                          const TextStyle(fontSize: 12, color: AppTheme.muted),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person_outline_rounded,
                        size: 15, color: AppTheme.muted),
                    const SizedBox(width: 6),
                    Text(
                      technician?.name ?? 'Unassigned',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class JobDetailScreen extends StatelessWidget {
  const JobDetailScreen({super.key, required this.job});

  final Job job;

  @override
  Widget build(BuildContext context) {
    final technicianName =
        job.technicianId == null ? 'Unassigned' : job.technicianId!;
    final etaStatus =
        job.eta.isAfter(job.appointmentEnd) ? 'Delayed' : 'On Time';

    return Scaffold(
      appBar: AppBar(
        title: Text(job.id),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.fault,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.navy,
                        letterSpacing: -0.7,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primarySoft,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'ETA: ${AppHelpers.formatTime(job.eta)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (JobService.isRepeatVisit(job))
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.amberSoft,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Repeat Visit Detected',
                        style: TextStyle(
                          color: AppTheme.amber,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'This appliance was serviced 6 days ago for a similar issue.',
                        style: TextStyle(color: AppTheme.charcoal),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              _DetailSection(title: 'Customer', children: [
                _DetailRow(label: 'Name', value: job.customer.name),
                _DetailRow(label: 'Address', value: job.address),
                _DetailRow(label: 'Phone', value: job.phone),
              ]),
              const SizedBox(height: 16),
              _DetailSection(title: 'Appliance', children: [
                _DetailRow(label: 'Type', value: job.applianceType),
                _DetailRow(label: 'Brand', value: job.brand),
                _DetailRow(label: 'Model', value: job.model),
                _DetailRow(label: 'Issue', value: job.fault),
              ]),
              const SizedBox(height: 16),
              _DetailSection(title: 'Schedule', children: [
                _DetailRow(
                  label: 'Window',
                  value:
                      '${AppHelpers.formatTime(job.appointmentStart)} – ${AppHelpers.formatTime(job.appointmentEnd)}',
                ),
                _DetailRow(label: 'ETA', value: AppHelpers.formatTime(job.eta)),
                _DetailRow(label: 'Status', value: etaStatus),
                _DetailRow(label: 'Assigned Technician', value: technicianName),
              ]),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed: () => _chooseTechnician(context),
                    icon: const Icon(Icons.person_add_alt_1_rounded),
                    label: Text(job.technicianId == null
                        ? 'Assign Technician'
                        : 'Reassign'),
                  ),
                  if (!JobService.isRepeatVisit(job))
                    OutlinedButton.icon(
                      onPressed: () {
                        JobService.updateJob(
                          job.copyWith(
                              isRepeatVisit: true,
                              status: JobStatus.repeatVisit),
                        );
                        Navigator.of(context).pop(true);
                      },
                      icon: const Icon(Icons.flag_rounded),
                      label: const Text('Flag Repeat Visit'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _chooseTechnician(BuildContext context) async {
    final recommendedTechnicians =
        AssignmentService.getRecommendedTechnicians(job);
    final recommendedIds =
        recommendedTechnicians.map((technician) => technician.id).toSet();
    final otherTechnicians = TechnicianService.allTechnicians
        .where((technician) =>
            (technician.status == TechnicianStatus.available ||
                technician.status == TechnicianStatus.onRoute) &&
            technician.currentWorkload < technician.maxWorkload &&
            !recommendedIds.contains(technician.id))
        .toList();

    Widget buildTechnicianOption(
      Technician technician, {
      required bool recommended,
    }) {
      final match = technician.expertise.firstWhere(
        (skill) => skill.toLowerCase() == job.applianceType.toLowerCase(),
        orElse: () => technician.expertise.first,
      );
      return ListTile(
        leading: CircleAvatar(
          backgroundColor: recommended ? AppTheme.primarySoft : AppTheme.line,
          child: Text(
            technician.name.split(' ').map((word) => word[0]).take(2).join(),
            style: const TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        title: Text(technician.name),
        subtitle: Text(
          '$match · ${technician.statusLabel} · '
          '${technician.distanceKm.toStringAsFixed(1)} km · '
          '${technician.currentWorkload}/${technician.maxWorkload} jobs',
        ),
        trailing: recommended
            ? const Icon(Icons.auto_awesome_rounded, color: AppTheme.primary)
            : const Icon(Icons.chevron_right_rounded),
        onTap: () => Navigator.of(context).pop(technician.id),
      );
    }

    final technicianId = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.7,
          ),
          child: ListView(
            shrinkWrap: true,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Text(
                  'Select technician',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
              if (recommendedTechnicians.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 8, 20, 4),
                  child: Text(
                    'Recommended for this job',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                for (final technician in recommendedTechnicians)
                  buildTechnicianOption(technician, recommended: true),
              ],
              if (otherTechnicians.isNotEmpty) ...[
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    recommendedTechnicians.isEmpty ? 8 : 16,
                    20,
                    4,
                  ),
                  child: Text(
                    recommendedTechnicians.isEmpty
                        ? 'Eligible technicians'
                        : 'Other eligible technicians',
                    style: const TextStyle(
                      color: AppTheme.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                for (final technician in otherTechnicians)
                  buildTechnicianOption(technician, recommended: false),
              ],
              if (recommendedTechnicians.isEmpty && otherTechnicians.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                      'No technicians are currently eligible for assignment.'),
                ),
            ],
          ),
        ),
      ),
    );

    if (technicianId == null) return;
    JobService.assignTechnician(job.id, technicianId);
    if (context.mounted) {
      Navigator.of(context).pop(true);
    }
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

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
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.navy,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: AppTheme.charcoal, fontSize: 13),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                  fontWeight: FontWeight.w700, color: AppTheme.muted),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
