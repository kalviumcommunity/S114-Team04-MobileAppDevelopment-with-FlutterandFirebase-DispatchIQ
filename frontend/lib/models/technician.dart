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

  factory Technician.fromJson(Map<String, dynamic> json) {
    return Technician(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      location: json['location'] as String,
      expertise: List<String>.from(json['expertise'] as List),
      status: TechnicianStatus.values.byName(json['status'] as String),
      currentWorkload: json['currentWorkload'] as int,
      maxWorkload: json['maxWorkload'] as int,
      jobsCompleted: json['jobsCompleted'] as int,
      firstTimeFixRate: json['firstTimeFixRate'] as int,
      completedToday: json['completedToday'] as int,
      distanceKm: (json['distanceKm'] as num).toDouble(),
      currentAssignedJobs:
          List<String>.from(json['currentAssignedJobs'] as List),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'location': location,
        'expertise': expertise,
        'status': status.name,
        'currentWorkload': currentWorkload,
        'maxWorkload': maxWorkload,
        'jobsCompleted': jobsCompleted,
        'firstTimeFixRate': firstTimeFixRate,
        'completedToday': completedToday,
        'distanceKm': distanceKm,
        'currentAssignedJobs': currentAssignedJobs,
      };
}
