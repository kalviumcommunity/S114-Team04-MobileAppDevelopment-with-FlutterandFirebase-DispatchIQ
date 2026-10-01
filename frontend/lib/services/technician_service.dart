import '../data/mock_data.dart';
import '../models/technician.dart';

class TechnicianService {
  static List<Technician> get allTechnicians => MockData.technicians;

  static List<Technician> getAvailableTechnicians() {
    return allTechnicians
        .where((t) => t.status == TechnicianStatus.available)
        .toList();
  }

  static int countByStatus(TechnicianStatus status) {
    return allTechnicians
        .where((technician) => technician.status == status)
        .length;
  }

  static Technician? getById(String id) {
    for (final technician in allTechnicians) {
      if (technician.id == id) return technician;
    }
    return null;
  }

  static void updateTechnician(Technician updatedTechnician) {
    final index = MockData.technicians.indexWhere(
      (technician) => technician.id == updatedTechnician.id,
    );
    if (index == -1) {
      throw ArgumentError.value(
        updatedTechnician.id,
        'updatedTechnician',
        'No matching technician',
      );
    }

    MockData.technicians[index] = updatedTechnician;
  }
}
