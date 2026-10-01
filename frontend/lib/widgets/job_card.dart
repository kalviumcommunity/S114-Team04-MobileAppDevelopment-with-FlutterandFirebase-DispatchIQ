import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../models/job.dart';
import '../services/technician_service.dart';
import '../utils/helpers.dart';
import 'status_badge.dart';

class JobCard extends StatelessWidget {
  const JobCard({
    super.key,
    required this.job,
    this.onTap,
  });

  final Job job;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final technician = job.technicianId == null ? null : TechnicianService.getById(job.technicianId!);
    final statusColor = _statusColor(job.status);
    final statusBg = _statusBackground(job.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.muted,
                      ),
                    ),
                  ),
                  StatusBadge(
                    label: job.statusLabel,
                    color: statusColor,
                    backgroundColor: statusBg,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                job.customer.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.navy,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${job.applianceType} • ${job.fault}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.charcoal,
                ),
              ),
              const SizedBox(height: 12),
              _InfoRow(
                label: 'Appointment',
                value: '${AppHelpers.formatTime(job.appointmentStart)} – ${AppHelpers.formatTime(job.appointmentEnd)}',
              ),
              const SizedBox(height: 8),
              _InfoRow(
                label: 'Technician',
                value: technician?.name ?? 'Unassigned',
              ),
              const SizedBox(height: 8),
              _InfoRow(
                label: 'Priority',
                value: job.priorityLabel,
              ),
              if (job.isRepeatVisit) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.amberSoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 14, color: AppTheme.amber),
                      SizedBox(width: 6),
                      Text(
                        'Repeat Visit',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.amber,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(JobStatus status) {
    switch (status) {
      case JobStatus.unassigned:
        return StatusColor.unassigned;
      case JobStatus.assigned:
        return StatusColor.assigned;
      case JobStatus.onRoute:
        return StatusColor.onRoute;
      case JobStatus.inProgress:
        return StatusColor.onRoute;
      case JobStatus.completed:
        return StatusColor.done;
      case JobStatus.delayed:
        return StatusColor.delayed;
      case JobStatus.repeatVisit:
        return StatusColor.repeat;
    }
  }

  Color _statusBackground(JobStatus status) {
    switch (status) {
      case JobStatus.unassigned:
        return AppTheme.line;
      case JobStatus.assigned:
        return AppTheme.primarySoft;
      case JobStatus.onRoute:
        return const Color(0xFFE8F0FF);
      case JobStatus.inProgress:
        return const Color(0xFFE5F7EF);
      case JobStatus.completed:
        return AppTheme.greenSoft;
      case JobStatus.delayed:
        return AppTheme.redSoft;
      case JobStatus.repeatVisit:
        return AppTheme.amberSoft;
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.muted,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.navy,
            ),
          ),
        ),
      ],
    );
  }
}
