import '../data/mock_data.dart';
import '../models/job.dart';
import '../models/technician.dart';
import 'backend_service.dart';
import 'technician_service.dart';

class JobService {
  static List<Job> get allJobs => MockData.jobs;

  static List<Job> getTodayJobs() {
    final today = DateTime.now();
    return allJobs.where((job) {
      return job.scheduledDate.year == today.year &&
          job.scheduledDate.month == today.month &&
          job.scheduledDate.day == today.day;
    }).toList();
  }

  static List<Job> getFilteredJobs({String query = '', String filter = 'All'}) {
    final lower = query.trim().toLowerCase();
    final jobs = allJobs.where((job) {
      final matchesQuery = lower.isEmpty ||
          job.id.toLowerCase().contains(lower) ||
          job.customer.name.toLowerCase().contains(lower) ||
          job.fault.toLowerCase().contains(lower) ||
          job.applianceType.toLowerCase().contains(lower);

      final matchesFilter = switch (filter) {
        'All' => true,
        'Unassigned' => job.status == JobStatus.unassigned,
        'Assigned' => job.status == JobStatus.assigned,
        'On Route' => job.status == JobStatus.onRoute,
        'In Progress' => job.status == JobStatus.inProgress,
        'Completed' => job.status == JobStatus.completed,
        'Delayed' => job.status == JobStatus.delayed,
        'At Risk' => job.status == JobStatus.delayed || isRepeatVisit(job),
        'Repeat Visit' => isRepeatVisit(job),
        _ => true,
      };

      return matchesQuery && matchesFilter;
    }).toList();

    return jobs;
  }

  static int getUnassignedCount() {
    return allJobs.where((job) => job.status == JobStatus.unassigned).length;
  }

  static int getDelayedCount() {
    return allJobs.where((job) => job.status == JobStatus.delayed).length;
  }

  static int countByStatus(JobStatus status) {
    return allJobs.where((job) => job.status == status).length;
  }

  static int getAtRiskCount() {
    return getAtRiskJobs().length;
  }

  static List<Job> getAtRiskJobs() {
    return allJobs
        .where((job) => job.status == JobStatus.delayed || isRepeatVisit(job))
        .toList();
  }

  static bool isRepeatVisit(Job job, {DateTime? asOf}) {
    if (job.isRepeatVisit || job.status == JobStatus.repeatVisit) return true;

    final previousVisit = job.previousVisit;
    if (previousVisit == null || job.previousVisitCount == 0) return false;

    final daysSinceVisit =
        (asOf ?? DateTime.now()).difference(previousVisit.date).inDays;
    return daysSinceVisit >= 0 &&
        daysSinceVisit <= 30 &&
        previousVisit.issue.trim().toLowerCase() ==
            job.fault.trim().toLowerCase();
  }

  static int getRepeatVisitCount() {
    return allJobs
        .where(
            (job) => job.isRepeatVisit || job.status == JobStatus.repeatVisit)
        .length;
  }

  static Future<void> assignTechnician(
      String jobId, String technicianId) async {
    final originalJobs = List<Job>.from(MockData.jobs);
    final originalTechnicians = List<Technician>.from(MockData.technicians);
    try {
      final index = MockData.jobs.indexWhere((job) => job.id == jobId);
      if (index == -1) {
        throw ArgumentError.value(jobId, 'jobId', 'No matching job');
      }

      final job = MockData.jobs[index];
      if (job.status == JobStatus.completed) {
        throw StateError('Completed jobs cannot be assigned');
      }

      final technician = TechnicianService.getById(technicianId);
      if (technician == null) {
        throw ArgumentError.value(
            technicianId, 'technicianId', 'No matching technician');
      }
      if ((technician.status != TechnicianStatus.available &&
              technician.status != TechnicianStatus.onRoute) ||
          technician.currentWorkload >= technician.maxWorkload) {
        throw StateError('Technician is not available for assignment');
      }

      if (job.technicianId != technicianId) {
        final previousTechnician = job.technicianId == null
            ? null
            : TechnicianService.getById(job.technicianId!);
        if (previousTechnician != null) {
          final previousJobs = previousTechnician.currentAssignedJobs
              .where((assignedJobId) => assignedJobId != jobId)
              .toList();
          final previousWorkload = (previousTechnician.currentWorkload - 1)
              .clamp(0, previousTechnician.maxWorkload);
          TechnicianService.updateTechnician(
            previousTechnician.copyWith(
              status: previousTechnician.status == TechnicianStatus.busy &&
                      previousWorkload < previousTechnician.maxWorkload
                  ? TechnicianStatus.available
                  : previousTechnician.status,
              currentWorkload: previousWorkload,
              currentAssignedJobs: previousJobs,
            ),
          );
        }

        final alreadyScheduled = technician.currentAssignedJobs.contains(jobId);
        final assignedJobs = alreadyScheduled
            ? technician.currentAssignedJobs
            : [...technician.currentAssignedJobs, jobId];
        final updatedWorkload =
            technician.currentWorkload + (alreadyScheduled ? 0 : 1);
        TechnicianService.updateTechnician(
          technician.copyWith(
            status: updatedWorkload >= technician.maxWorkload
                ? TechnicianStatus.busy
                : technician.status,
            currentWorkload: updatedWorkload,
            currentAssignedJobs: assignedJobs,
          ),
        );
      }

      MockData.jobs[index] = job.copyWith(
        technicianId: technicianId,
        status: JobStatus.assigned,
      );

      await BackendService.saveState();
    } catch (_) {
      MockData.jobs
        ..clear()
        ..addAll(originalJobs);
      MockData.technicians
        ..clear()
        ..addAll(originalTechnicians);
      rethrow;
    }
  }

  static Future<void> updateJob(Job updatedJob) async {
    final index = MockData.jobs.indexWhere((job) => job.id == updatedJob.id);
    if (index == -1) {
      throw ArgumentError.value(updatedJob.id, 'updatedJob', 'No matching job');
    }

    final originalJob = MockData.jobs[index];
    MockData.jobs[index] = updatedJob;
    try {
      await BackendService.saveState();
    } catch (_) {
      MockData.jobs[index] = originalJob;
      rethrow;
    }
  }
}
