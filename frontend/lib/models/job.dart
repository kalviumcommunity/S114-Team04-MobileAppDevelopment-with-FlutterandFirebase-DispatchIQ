import 'customer.dart';

enum JobStatus {
  unassigned,
  assigned,
  onRoute,
  inProgress,
  completed,
  delayed,
  repeatVisit,
}

enum JobPriority {
  low,
  medium,
  high,
  urgent,
}

class PreviousVisit {
  const PreviousVisit({
    required this.date,
    required this.technicianName,
    required this.issue,
    required this.action,
  });

  final DateTime date;
  final String technicianName;
  final String issue;
  final String action;

  factory PreviousVisit.fromJson(Map<String, dynamic> json) {
    return PreviousVisit(
      date: DateTime.parse(json['date'] as String),
      technicianName: json['technicianName'] as String,
      issue: json['issue'] as String,
      action: json['action'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'technicianName': technicianName,
        'issue': issue,
        'action': action,
      };
}

class Job {
  const Job({
    required this.id,
    required this.customer,
    required this.applianceType,
    required this.brand,
    required this.model,
    required this.serialNumber,
    required this.fault,
    required this.address,
    required this.scheduledDate,
    required this.appointmentStart,
    required this.appointmentEnd,
    required this.technicianId,
    required this.status,
    required this.priority,
    required this.eta,
    required this.isRepeatVisit,
    required this.previousVisit,
    required this.previousDiagnosis,
    required this.previousRepair,
    required this.previousVisitCount,
    required this.warrantyStatus,
    required this.phone,
    required this.isFixedOnFirstVisit,
  });

  final String id;
  final Customer customer;
  final String applianceType;
  final String brand;
  final String model;
  final String serialNumber;
  final String fault;
  final String address;
  final DateTime scheduledDate;
  final DateTime appointmentStart;
  final DateTime appointmentEnd;
  final String? technicianId;
  final JobStatus status;
  final JobPriority priority;
  final DateTime eta;
  final bool isRepeatVisit;
  final PreviousVisit? previousVisit;
  final String previousDiagnosis;
  final String previousRepair;
  final int previousVisitCount;
  final String warrantyStatus;
  final String phone;
  final bool isFixedOnFirstVisit;

  Job copyWith({
    String? technicianId,
    JobStatus? status,
    bool? isRepeatVisit,
    DateTime? scheduledDate,
    DateTime? appointmentStart,
    DateTime? appointmentEnd,
    DateTime? eta,
  }) {
    return Job(
      id: id,
      customer: customer,
      applianceType: applianceType,
      brand: brand,
      model: model,
      serialNumber: serialNumber,
      fault: fault,
      address: address,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      appointmentStart: appointmentStart ?? this.appointmentStart,
      appointmentEnd: appointmentEnd ?? this.appointmentEnd,
      technicianId: technicianId ?? this.technicianId,
      status: status ?? this.status,
      priority: priority,
      eta: eta ?? this.eta,
      isRepeatVisit: isRepeatVisit ?? this.isRepeatVisit,
      previousVisit: previousVisit,
      previousDiagnosis: previousDiagnosis,
      previousRepair: previousRepair,
      previousVisitCount: previousVisitCount,
      warrantyStatus: warrantyStatus,
      phone: phone,
      isFixedOnFirstVisit: isFixedOnFirstVisit,
    );
  }

  String get statusLabel {
    switch (status) {
      case JobStatus.unassigned:
        return 'Unassigned';
      case JobStatus.assigned:
        return 'Assigned';
      case JobStatus.onRoute:
        return 'On Route';
      case JobStatus.inProgress:
        return 'In Progress';
      case JobStatus.completed:
        return 'Completed';
      case JobStatus.delayed:
        return 'Delayed';
      case JobStatus.repeatVisit:
        return 'Repeat Visit';
    }
  }

  String get priorityLabel {
    switch (priority) {
      case JobPriority.low:
        return 'Low';
      case JobPriority.medium:
        return 'Medium';
      case JobPriority.high:
        return 'High';
      case JobPriority.urgent:
        return 'Urgent';
    }
  }

  factory Job.fromJson(Map<String, dynamic> json) {
    final previousVisitJson = json['previousVisit'];
    return Job(
      id: json['id'] as String,
      customer:
          Customer.fromJson(Map<String, dynamic>.from(json['customer'] as Map)),
      applianceType: json['applianceType'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String,
      serialNumber: json['serialNumber'] as String,
      fault: json['fault'] as String,
      address: json['address'] as String,
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      appointmentStart: DateTime.parse(json['appointmentStart'] as String),
      appointmentEnd: DateTime.parse(json['appointmentEnd'] as String),
      technicianId: json['technicianId'] as String?,
      status: JobStatus.values.byName(json['status'] as String),
      priority: JobPriority.values.byName(json['priority'] as String),
      eta: DateTime.parse(json['eta'] as String),
      isRepeatVisit: json['isRepeatVisit'] as bool,
      previousVisit: previousVisitJson == null
          ? null
          : PreviousVisit.fromJson(
              Map<String, dynamic>.from(previousVisitJson as Map)),
      previousDiagnosis: json['previousDiagnosis'] as String,
      previousRepair: json['previousRepair'] as String,
      previousVisitCount: json['previousVisitCount'] as int,
      warrantyStatus: json['warrantyStatus'] as String,
      phone: json['phone'] as String,
      isFixedOnFirstVisit: json['isFixedOnFirstVisit'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'customer': customer.toJson(),
        'applianceType': applianceType,
        'brand': brand,
        'model': model,
        'serialNumber': serialNumber,
        'fault': fault,
        'address': address,
        'scheduledDate': scheduledDate.toIso8601String(),
        'appointmentStart': appointmentStart.toIso8601String(),
        'appointmentEnd': appointmentEnd.toIso8601String(),
        'technicianId': technicianId,
        'status': status.name,
        'priority': priority.name,
        'eta': eta.toIso8601String(),
        'isRepeatVisit': isRepeatVisit,
        'previousVisit': previousVisit?.toJson(),
        'previousDiagnosis': previousDiagnosis,
        'previousRepair': previousRepair,
        'previousVisitCount': previousVisitCount,
        'warrantyStatus': warrantyStatus,
        'phone': phone,
        'isFixedOnFirstVisit': isFixedOnFirstVisit,
      };
}
