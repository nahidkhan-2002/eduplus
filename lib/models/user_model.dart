class UserModel {
  final String username;
  final String fullName;
  final String email;
  final String studentId;
  final String department;
  final String batch;
  final double targetCgpa;

  const UserModel({
    required this.username,
    required this.fullName,
    required this.email,
    required this.studentId,
    required this.department,
    required this.batch,
    this.targetCgpa = 3.85,
  });

  factory UserModel.demo() {
    return const UserModel(
      username: 'test',
      fullName: 'Alex Mercer',
      email: 'alex.mercer@apex.edu',
      studentId: 'STU-2024-8842',
      department: 'Computer Science & Software Engineering',
      batch: 'Class of 2026',
      targetCgpa: 3.85,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'fullName': fullName,
      'email': email,
      'studentId': studentId,
      'department': department,
      'batch': batch,
      'targetCgpa': targetCgpa,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'] as String? ?? 'test',
      fullName: json['fullName'] as String? ?? 'Student User',
      email: json['email'] as String? ?? 'student@edu.ai',
      studentId: json['studentId'] as String? ?? 'ID-9921',
      department: json['department'] as String? ?? 'Computer Science',
      batch: json['batch'] as String? ?? '2026',
      targetCgpa: (json['targetCgpa'] as num?)?.toDouble() ?? 3.85,
    );
  }
}
