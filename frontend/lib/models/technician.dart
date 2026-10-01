enum TechnicianStatus {
  available,
  onRoute,
  busy,
  offline,
}

class Technician {
  const Technician({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.location,
    required this.expertise,
    required this.status,
    required this.currentWorkload,
    required this.maxWorkload,
    required this.jobsCompleted,
    required this.firstTimeFixRate,
    required this.completedToday,
    required this.distanceKm,
    required this.currentAssignedJobs,
  });

  final String id;
  final String name;
  final String phone;
  final String email;
  final String location;
  final List<String> expertise;
  final TechnicianStatus status;
  final int currentWorkload;
  final int maxWorkload;
  final int jobsCompleted;
  final int firstTimeFixRate;
  final int completedToday;
  final double distanceKm;
  final List<String> currentAssignedJobs;

  Technician copyWith({
    TechnicianStatus? status,
    int? currentWorkload,
    List<String>? currentAssignedJobs,
  }) {
    return Technician(
      id: id,
      name: name,
      phone: phone,
      email: email,
      location: location,
      expertise: expertise,
      status: status ?? this.status,
      currentWorkload: currentWorkload ?? this.currentWorkload,
      maxWorkload: maxWorkload,
      jobsCompleted: jobsCompleted,
      firstTimeFixRate: firstTimeFixRate,
      completedToday: completedToday,
      distanceKm: distanceKm,
      currentAssignedJobs: currentAssignedJobs ?? this.currentAssignedJobs,
    );
  }

  String get statusLabel {
    switch (status) {
      case TechnicianStatus.available:
        return 'Available';
      case TechnicianStatus.onRoute:
        return 'On Route';
      case TechnicianStatus.busy:
        return 'Busy';
      case TechnicianStatus.offline:
        return 'Offline';
    }
  }
}
