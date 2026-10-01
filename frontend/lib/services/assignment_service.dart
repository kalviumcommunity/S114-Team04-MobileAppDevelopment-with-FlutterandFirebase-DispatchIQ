import '../data/mock_data.dart';
import '../models/job.dart';
import '../models/technician.dart';

class AssignmentService {
  static List<Technician> getRecommendedTechnicians(Job job) {
    final candidates = MockData.technicians.where((technician) {
      final hasExpertise = technician.expertise.any((item) => item.toLowerCase() == job.applianceType.toLowerCase());
      final isAvailable = technician.status == TechnicianStatus.available || technician.status == TechnicianStatus.onRoute;
      final withinLoad = technician.currentWorkload < technician.maxWorkload;
      final hasSchedule = technician.currentAssignedJobs.length < 3;
      return hasExpertise && isAvailable && withinLoad && hasSchedule;
    }).toList();

    candidates.sort((a, b) {
      final aScore = _scoreTechnician(a, job);
      final bScore = _scoreTechnician(b, job);
      return bScore.compareTo(aScore);
    });

    return candidates;
  }

  static int _scoreTechnician(Technician technician, Job job) {
    int score = 0;
    if (technician.expertise.any((item) => item.toLowerCase() == job.applianceType.toLowerCase())) score += 40;
    if (technician.status == TechnicianStatus.available) score += 25;
    if (technician.currentWorkload < technician.maxWorkload) score += 15;
    if (technician.distanceKm <= 5) score += 10;
    if (technician.currentAssignedJobs.length < 3) score += 10;
    return score;
  }
}
