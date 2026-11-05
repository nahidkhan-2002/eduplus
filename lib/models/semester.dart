import 'subject.dart';

class Semester {
  final String id;
  final String title;
  final String term; // e.g., "Fall 2024", "Spring 2025"
  final List<Subject> subjects;
  final double gpa;
  final double totalCredits;

  const Semester({
    required this.id,
    required this.title,
    required this.term,
    required this.subjects,
    required this.gpa,
    required this.totalCredits,
  });

  Semester copyWith({
    String? id,
    String? title,
    String? term,
    List<Subject>? subjects,
    double? gpa,
    double? totalCredits,
  }) {
    return Semester(
      id: id ?? this.id,
      title: title ?? this.title,
      term: term ?? this.term,
      subjects: subjects ?? this.subjects,
      gpa: gpa ?? this.gpa,
      totalCredits: totalCredits ?? this.totalCredits,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'term': term,
      'subjects': subjects.map((s) => s.toJson()).toList(),
      'gpa': gpa,
      'totalCredits': totalCredits,
    };
  }

  factory Semester.fromJson(Map<String, dynamic> json) {
    final rawSubjects = json['subjects'] as List<dynamic>? ?? [];
    final subjects = rawSubjects
        .map((s) => Subject.fromJson(s as Map<String, dynamic>))
        .toList();

    return Semester(
      id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: json['title'] as String? ?? 'Semester',
      term: json['term'] as String? ?? 'Fall 2024',
      subjects: subjects,
      gpa: (json['gpa'] as num?)?.toDouble() ?? 0.0,
      totalCredits: (json['totalCredits'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
