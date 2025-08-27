class ExitRequest {
  final String id;
  final String studentId;
  final String studentName; // أضف هذا
  final String parentId;
  final String parentName; // أضف هذا
  final String schoolId;
  final String schoolName; // أضف هذا
  final String status;
  final DateTime requestedAt;
  final DateTime? completedAt;
  final String? notes;

  ExitRequest({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.parentId,
    required this.parentName,
    required this.schoolId,
    required this.schoolName,
    required this.status,
    required this.requestedAt,
    this.completedAt,
    this.notes,
  });

  factory ExitRequest.fromJson(Map<String, dynamic> json) {
    final student = json['student'] is Map ? json['student'] : {};
    final parent = json['parent'] is Map ? json['parent'] : {};
    final school = json['school'] is Map ? json['school'] : {};

    return ExitRequest(
      id: json['_id'] ?? '',
      studentId: student['_id'] ?? '',
      studentName: student['name'] ?? '', // أضف هذا field
      parentId: parent['_id'] ?? '',
      parentName: parent['name'] ?? '', // أضف هذا field
      schoolId: school['_id'] ?? '',
      schoolName: school['name'] ?? '', // أضف هذا field
      status: json['status'] ?? 'pending',
      requestedAt: DateTime.parse(
        json['requestedAt'] is String
            ? json['requestedAt']
            : json['requestedAt']['\$date'],
      ),
      completedAt: json['completedAt'] != null
          ? (json['completedAt'] is String
                ? DateTime.parse(json['completedAt'])
                : DateTime.parse(json['completedAt']['\$date']))
          : null,
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student': studentId,
      'parent': parentId,
      'school': schoolId,
      'status': status,
      'requestedAt': requestedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'notes': notes,
    };
  }
}

