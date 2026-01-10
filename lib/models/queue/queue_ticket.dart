class QueueTicket {
  final String id;
  final String ticketNumber;
  final String? studentName;
  final String? studentId;
  final String? departmentId;
  final String? departmentName;
  final String status;
  final DateTime createdAt;
  final DateTime? calledAt;
  final DateTime? servedAt;
  final String? windowId;
  final String? windowName;

  QueueTicket({
    required this.id,
    required this.ticketNumber,
    this.studentName,
    this.studentId,
    this.departmentId,
    this.departmentName,
    required this.status,
    required this.createdAt,
    this.calledAt,
    this.servedAt,
    this.windowId,
    this.windowName,
  });

  factory QueueTicket.fromJson(Map<String, dynamic> json) {
    // Handle both nested (with joins) and flat JSON structures
    String? deptName;
    if (json['departments'] != null && json['departments'] is Map) {
      deptName = json['departments']['name'] as String?;
    } else if (json['department_name'] != null) {
      deptName = json['department_name'] as String?;
    }

    String? winName;
    if (json['windows'] != null && json['windows'] is Map) {
      winName = json['windows']['name'] as String?;
    } else if (json['window_name'] != null) {
      winName = json['window_name'] as String?;
    }

    return QueueTicket(
      id: json['id'] as String,
      ticketNumber: json['ticket_number'] as String,
      studentName: json['student_name'] as String?,
      studentId: json['student_id'] as String?,
      departmentId: json['department_id'] as String?,
      departmentName: deptName,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      calledAt: json['called_at'] != null
          ? DateTime.parse(json['called_at'] as String)
          : null,
      servedAt: json['served_at'] != null
          ? DateTime.parse(json['served_at'] as String)
          : null,
      windowId: json['window_id'] as String?,
      windowName: winName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket_number': ticketNumber,
      'student_name': studentName,
      'student_id': studentId,
      'department_id': departmentId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'called_at': calledAt?.toIso8601String(),
      'served_at': servedAt?.toIso8601String(),
      'window_id': windowId,
    };
  }

  QueueTicket copyWith({
    String? id,
    String? ticketNumber,
    String? studentName,
    String? studentId,
    String? departmentId,
    String? departmentName,
    String? status,
    DateTime? createdAt,
    DateTime? calledAt,
    DateTime? servedAt,
    String? windowId,
    String? windowName,
  }) {
    return QueueTicket(
      id: id ?? this.id,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      studentName: studentName ?? this.studentName,
      studentId: studentId ?? this.studentId,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      calledAt: calledAt ?? this.calledAt,
      servedAt: servedAt ?? this.servedAt,
      windowId: windowId ?? this.windowId,
      windowName: windowName ?? this.windowName,
    );
  }
}
