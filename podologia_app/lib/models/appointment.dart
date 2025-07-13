class Appointment {
  final String id;
  final String patientId;
  final String patientName;
  final String date;
  final String time;
  final String status; // scheduled, confirmed, completed, cancelled
  final DateTime createdAt;

  Appointment({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.date,
    required this.time,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'patient_name': patientName,
      'date': date,
      'time': time,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] ?? '',
      patientId: map['patient_id'] ?? '',
      patientName: map['patient_name'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      status: map['status'] ?? 'scheduled',
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Appointment copyWith({
    String? id,
    String? patientId,
    String? patientName,
    String? date,
    String? time,
    String? status,
    DateTime? createdAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class NotificationModel {
  final String id;
  final String appointmentId;
  final String patientId;
  final String patientName;
  final String patientContact;
  final String notificationType; // "1_day_before" or "1_hour_30_before"
  final DateTime scheduledTime;
  final String appointmentDate;
  final String appointmentTime;
  final String message;
  final bool sent;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.appointmentId,
    required this.patientId,
    required this.patientName,
    required this.patientContact,
    required this.notificationType,
    required this.scheduledTime,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.message,
    required this.sent,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'appointment_id': appointmentId,
      'patient_id': patientId,
      'patient_name': patientName,
      'patient_contact': patientContact,
      'notification_type': notificationType,
      'scheduled_time': scheduledTime.toIso8601String(),
      'appointment_date': appointmentDate,
      'appointment_time': appointmentTime,
      'message': message,
      'sent': sent,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      appointmentId: map['appointment_id'] ?? '',
      patientId: map['patient_id'] ?? '',
      patientName: map['patient_name'] ?? '',
      patientContact: map['patient_contact'] ?? '',
      notificationType: map['notification_type'] ?? '',
      scheduledTime: DateTime.parse(map['scheduled_time'] ?? DateTime.now().toIso8601String()),
      appointmentDate: map['appointment_date'] ?? '',
      appointmentTime: map['appointment_time'] ?? '',
      message: map['message'] ?? '',
      sent: map['sent'] ?? false,
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  NotificationModel copyWith({
    String? id,
    String? appointmentId,
    String? patientId,
    String? patientName,
    String? patientContact,
    String? notificationType,
    DateTime? scheduledTime,
    String? appointmentDate,
    String? appointmentTime,
    String? message,
    bool? sent,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      appointmentId: appointmentId ?? this.appointmentId,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientContact: patientContact ?? this.patientContact,
      notificationType: notificationType ?? this.notificationType,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      appointmentTime: appointmentTime ?? this.appointmentTime,
      message: message ?? this.message,
      sent: sent ?? this.sent,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}