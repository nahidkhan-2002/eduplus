import '../models/semester.dart';
import '../models/subject.dart';

class CalculationService {
  /// Standard University Grading Scale:
  /// 80% to 100% -> A+ (4.00)
  /// 75% to 79%  -> A  (3.75)
  /// 70% to 74%  -> A- (3.50)
  /// 65% to 69%  -> B+ (3.25)
  /// 60% to 64%  -> B  (3.00)
  /// 55% to 59%  -> B- (2.75)
  /// 50% to 54%  -> C+ (2.50)
  /// 45% to 49%  -> C  (2.25)
  /// 40% to 44%  -> D  (2.00)
  /// < 40%       -> F  (0.00)
  static Map<String, dynamic> calculateGradeAndPoint(double obtainedMarks, double fullMarks) {
    if (fullMarks <= 0) {
      return {'grade': 'F', 'point': 0.0};
    }
    final percentage = (obtainedMarks / fullMarks) * 100.0;

    if (percentage >= 80.0) {
      return {'grade': 'A+', 'point': 4.00};
    } else if (percentage >= 75.0) {
      return {'grade': 'A', 'point': 3.75};
    } else if (percentage >= 70.0) {
      return {'grade': 'A-', 'point': 3.50};
    } else if (percentage >= 65.0) {
      return {'grade': 'B+', 'point': 3.25};
    } else if (percentage >= 60.0) {
      return {'grade': 'B', 'point': 3.00};
    } else if (percentage >= 55.0) {
      return {'grade': 'B-', 'point': 2.75};
    } else if (percentage >= 50.0) {
      return {'grade': 'C+', 'point': 2.50};
    } else if (percentage >= 45.0) {
      return {'grade': 'C', 'point': 2.25};
    } else if (percentage >= 40.0) {
      return {'grade': 'D', 'point': 2.00};
    } else {
      return {'grade': 'F', 'point': 0.00};
    }
  }

  /// Semester GPA: Σ(Credit × Grade Point) / Σ(Total Credits)
  static double calculateSemesterGpa(List<Subject> subjects) {
    if (subjects.isEmpty) return 0.0;
    double totalCreditPoints = 0.0;
    double totalCredits = 0.0;

    for (final subject in subjects) {
      totalCreditPoints += (subject.creditHours * subject.gradePoint);
      totalCredits += subject.creditHours;
    }

    if (totalCredits <= 0) return 0.0;
    final gpa = totalCreditPoints / totalCredits;
    return double.parse(gpa.toStringAsFixed(2));
  }

  /// Total semester credits
  static double calculateTotalCredits(List<Subject> subjects) {
    return subjects.fold<double>(0.0, (sum, s) => sum + s.creditHours);
  }

  /// Overall Cumulative CGPA across all semesters
  /// CGPA = Σ(All Subject Credit × Grade Point) / Σ(All Credits)
  static double calculateCumulativeCgpa(List<Semester> semesters) {
    double totalQualityPoints = 0.0;
    double totalCredits = 0.0;

    for (final semester in semesters) {
      for (final subject in semester.subjects) {
        totalQualityPoints += (subject.creditHours * subject.gradePoint);
        totalCredits += subject.creditHours;
      }
    }

    if (totalCredits <= 0) return 0.0;
    final cgpa = totalQualityPoints / totalCredits;
    return double.parse(cgpa.toStringAsFixed(2));
  }

  /// Total credits across all semesters
  static double calculateTotalCompletedCredits(List<Semester> semesters) {
    double totalCredits = 0.0;
    for (final semester in semesters) {
      for (final subject in semester.subjects) {
        if (subject.gradePoint > 0) {
          totalCredits += subject.creditHours;
        }
      }
    }
    return totalCredits;
  }

  /// Academic Standing description
  static String getAcademicStanding(double cgpa) {
    if (cgpa >= 3.85) return "Summa Cum Laude Track (Highest Distinction)";
    if (cgpa >= 3.70) return "Magna Cum Laude Track (High Distinction)";
    if (cgpa >= 3.50) return "Dean's Honor List Track";
    if (cgpa >= 3.00) return "Good Academic Standing";
    if (cgpa >= 2.50) return "Satisfactory Standing";
    if (cgpa >= 2.00) return "Academic Warning";
    return "Academic Probation";
  }

  /// Identify Weakest Subjects (Subjects with grade point < 3.25 or lowest marks)
  static List<Subject> findWeakestSubjects(List<Semester> semesters, {int limit = 4}) {
    final allSubjects = <Subject>[];
    for (final sem in semesters) {
      allSubjects.addAll(sem.subjects);
    }
    if (allSubjects.isEmpty) return [];

    allSubjects.sort((a, b) {
      final cmp = a.gradePoint.compareTo(b.gradePoint);
      if (cmp != 0) return cmp;
      return a.percentage.compareTo(b.percentage);
    });

    return allSubjects.take(limit).toList();
  }
}
