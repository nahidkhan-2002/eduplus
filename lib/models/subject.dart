class Subject {
  final String id;
  final String name;
  final String code;
  final double creditHours;
  final double fullMarks;
  final double obtainedMarks;
  final String letterGrade;
  final double gradePoint;

  const Subject({
    required this.id,
    required this.name,
    required this.code,
    required this.creditHours,
    required this.fullMarks,
    required this.obtainedMarks,
    required this.letterGrade,
    required this.gradePoint,
  });

  Subject copyWith({
    String? id,
    String? name,
    String? code,
    double? creditHours,
    double? fullMarks,
    double? obtainedMarks,
    String? letterGrade,
    double? gradePoint,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      creditHours: creditHours ?? this.creditHours,
      fullMarks: fullMarks ?? this.fullMarks,
      obtainedMarks: obtainedMarks ?? this.obtainedMarks,
      letterGrade: letterGrade ?? this.letterGrade,
      gradePoint: gradePoint ?? this.gradePoint,
    );
  }

  double get percentage => fullMarks > 0 ? (obtainedMarks / fullMarks) * 100 : 0.0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'creditHours': creditHours,
      'fullMarks': fullMarks,
      'obtainedMarks': obtainedMarks,
      'letterGrade': letterGrade,
      'gradePoint': gradePoint,
    };
  }

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
      name: json['name'] as String? ?? 'Subject',
      code: json['code'] as String? ?? 'SUB-101',
      creditHours: (json['creditHours'] as num?)?.toDouble() ?? 3.0,
      fullMarks: (json['fullMarks'] as num?)?.toDouble() ?? 100.0,
      obtainedMarks: (json['obtainedMarks'] as num?)?.toDouble() ?? 0.0,
      letterGrade: json['letterGrade'] as String? ?? 'F',
      gradePoint: (json['gradePoint'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
