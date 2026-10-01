import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../models/technician.dart';
import 'status_badge.dart';

class TechnicianCard extends StatelessWidget {
  const TechnicianCard({super.key, required this.technician, this.onTap});

  final Technician technician;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(technician.status);
    final statusBg = _statusBackground(technician.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppTheme.primarySoft,
                child: Text(
                  technician.name.split(' ').map((word) => word[0]).take(2).join(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            technician.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                              color: AppTheme.navy,
                            ),
                          ),
                        ),
                        StatusBadge(
                          label: technician.statusLabel,
                          color: statusColor,
                          backgroundColor: statusBg,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'ID: ${technician.id}',
                      style: const TextStyle(
                        color: AppTheme.muted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Expertise: ${technician.expertise.join(' • ')}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.charcoal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.work_history_outlined, size: 15, color: AppTheme.muted),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Workload: ${technician.currentWorkload} / ${technician.maxWorkload} jobs',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: AppTheme.muted),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 15, color: AppTheme.muted),
                        const SizedBox(width: 6),
                        Text(
                          '${technician.distanceKm.toStringAsFixed(1)} km away',
                          style: const TextStyle(fontSize: 12, color: AppTheme.muted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(TechnicianStatus status) {
    switch (status) {
      case TechnicianStatus.available:
        return StatusColor.available;
      case TechnicianStatus.onRoute:
        return StatusColor.onRoute;
      case TechnicianStatus.busy:
        return StatusColor.busy;
      case TechnicianStatus.offline:
        return StatusColor.offline;
    }
  }

  Color _statusBackground(TechnicianStatus status) {
    switch (status) {
      case TechnicianStatus.available:
        return AppTheme.greenSoft;
      case TechnicianStatus.onRoute:
        return AppTheme.primarySoft;
      case TechnicianStatus.busy:
        return AppTheme.amberSoft;
      case TechnicianStatus.offline:
        return AppTheme.line;
    }
  }
}
