import 'dart:math';

import '../models/job.dart';

class AppHelpers {
  static String formatTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute;
    final formattedHour = hour % 12 == 0 ? 12 : hour % 12;
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final minuteText = minute.toString().padLeft(2, '0');
    return '$formattedHour:$minuteText $suffix';
  }

  static String formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  static String statusForJob(Job job) {
    if (job.isRepeatVisit) {
      return 'Repeat Visit';
    }
    if (job.status == JobStatus.delayed) {
      return 'Delayed';
    }
    return job.statusLabel;
  }

  static String formatEta(DateTime eta) {
    return formatTime(eta);
  }

  static int calculateFirstTimeFixRate(int fixedOnFirstVisit, int totalCompleted) {
    if (totalCompleted == 0) return 0;
    return ((fixedOnFirstVisit / totalCompleted) * 100).round();
  }

  static int scoreTechnicianMatch({
    required bool hasExpertise,
    required bool isAvailable,
    required int workload,
    required int maxWorkload,
    required double distanceKm,
    required bool hasSchedule,
  }) {
    var score = 0;
    if (hasExpertise) score += 35;
    if (isAvailable) score += 25;
    if (workload < maxWorkload) score += 15;
    if (distanceKm < 8) score += 15;
    if (hasSchedule) score += 10;
    return score + Random().nextInt(10);
  }
}
