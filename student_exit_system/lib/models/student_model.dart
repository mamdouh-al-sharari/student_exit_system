class Student {
  final String id;
  final String name;
  final String studentId;
  final String grade;
  final String className;
  final String schoolId;
  final String parentPhone; // أضف هذا

  Student({
    required this.id,
    required this.name,
    required this.studentId,
    required this.grade,
    required this.className,
    required this.schoolId,
    required this.parentPhone, // أضف هذا
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      studentId: json['studentId'],
      grade: json['grade'],
      className: json['class'],
      schoolId: json['school'] is String
          ? json['school']
          : json['school']['_id'] ?? '',
      parentPhone: json['parentPhone'] ?? '', // أضف هذا
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'studentId': studentId,
      'grade': grade,
      'class': className,
      'school': schoolId,
      'parentPhone': parentPhone, // أضف هذا
    };
  }
}
