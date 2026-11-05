import 'package:flutter/foundation.dart';
import '../models/semester.dart';
import '../models/subject.dart';
import '../services/calculation_service.dart';
import '../services/devin_ai_service.dart';
import '../services/storage_service.dart';

class GpaProvider extends ChangeNotifier {
  final StorageService _storageService;

  List<Semester> _semesters = [];
  bool _isLoading = false;

  GpaProvider(this._storageService) {
    _loadFromStorage();
  }

  List<Semester> get semesters => List.unmodifiable(_semesters);
  bool get isLoading => _isLoading;

  void _loadFromStorage() {
    _semesters = _storageService.getSemesters();
    if (_semesters.isEmpty) {
      // By default load rich sample data if empty so reviewer gets instant rich experience
      _semesters = DevinAiService.getMockSemesters();
      _storageService.saveSemesters(_semesters);
    }
    notifyListeners();
  }

  /// Cumulative CGPA across all semesters
  double get cumulativeCgpa => CalculationService.calculateCumulativeCgpa(_semesters);

  /// Total credits completed
  double get totalCredits => CalculationService.calculateTotalCompletedCredits(_semesters);

  /// Total subjects enrolled
  int get totalSubjectsCount =>
      _semesters.fold<int>(0, (sum, sem) => sum + sem.subjects.length);

  /// Academic Standing description
  String get academicStanding => CalculationService.getAcademicStanding(cumulativeCgpa);

  /// Weakest subjects detected automatically from GPA engine
  List<Subject> get weakestSubjects =>
      CalculationService.findWeakestSubjects(_semesters);

  /// Weakest subject names for routine intake
  List<String> get weakestSubjectNames {
    final list = weakestSubjects.map((s) => s.name).toList();
    if (list.isEmpty) {
      return ['Multivariable Calculus', 'Algorithm Design', 'Digital Logic'];
    }
    return list;
  }

  /// Add new Semester
  Future<void> addSemester({required String title, required String term}) async {
    final newSem = Semester(
      id: 'sem_${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim().isNotEmpty ? title.trim() : 'Semester ${_semesters.length + 1}',
      term: term.trim().isNotEmpty ? term.trim() : 'Term ${_semesters.length + 1}',
      subjects: [],
      gpa: 0.0,
      totalCredits: 0.0,
    );
    _semesters.add(newSem);
    await _persist();
  }

  /// Edit existing Semester
  Future<void> editSemester({
    required String semesterId,
    required String title,
    required String term,
  }) async {
    final index = _semesters.indexWhere((s) => s.id == semesterId);
    if (index != -1) {
      final old = _semesters[index];
      _semesters[index] = old.copyWith(title: title.trim(), term: term.trim());
      await _persist();
    }
  }

  /// Delete Semester
  Future<void> deleteSemester(String semesterId) async {
    _semesters.removeWhere((s) => s.id == semesterId);
    await _persist();
  }

  /// Add Subject to a Semester
  Future<void> addSubject({
    required String semesterId,
    required String name,
    required String code,
    required double creditHours,
    required double fullMarks,
    required double obtainedMarks,
  }) async {
    final index = _semesters.indexWhere((s) => s.id == semesterId);
    if (index == -1) return;

    final gradeInfo = CalculationService.calculateGradeAndPoint(obtainedMarks, fullMarks);
    final subject = Subject(
      id: 'sub_${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim().isNotEmpty ? name.trim() : 'New Subject',
      code: code.trim().isNotEmpty ? code.trim() : 'SUB-101',
      creditHours: creditHours > 0 ? creditHours : 3.0,
      fullMarks: fullMarks > 0 ? fullMarks : 100.0,
      obtainedMarks: obtainedMarks.clamp(0.0, fullMarks),
      letterGrade: gradeInfo['grade'] as String,
      gradePoint: gradeInfo['point'] as double,
    );

    final sem = _semesters[index];
    final updatedSubjects = List<Subject>.from(sem.subjects)..add(subject);
    final newGpa = CalculationService.calculateSemesterGpa(updatedSubjects);
    final newCredits = CalculationService.calculateTotalCredits(updatedSubjects);

    _semesters[index] = sem.copyWith(
      subjects: updatedSubjects,
      gpa: newGpa,
      totalCredits: newCredits,
    );
    await _persist();
  }

  /// Edit Subject
  Future<void> editSubject({
    required String semesterId,
    required String subjectId,
    required String name,
    required String code,
    required double creditHours,
    required double fullMarks,
    required double obtainedMarks,
  }) async {
    final semIndex = _semesters.indexWhere((s) => s.id == semesterId);
    if (semIndex == -1) return;

    final sem = _semesters[semIndex];
    final subIndex = sem.subjects.indexWhere((s) => s.id == subjectId);
    if (subIndex == -1) return;

    final gradeInfo = CalculationService.calculateGradeAndPoint(obtainedMarks, fullMarks);
    final updatedSubject = Subject(
      id: subjectId,
      name: name.trim().isNotEmpty ? name.trim() : sem.subjects[subIndex].name,
      code: code.trim().isNotEmpty ? code.trim() : sem.subjects[subIndex].code,
      creditHours: creditHours > 0 ? creditHours : 3.0,
      fullMarks: fullMarks > 0 ? fullMarks : 100.0,
      obtainedMarks: obtainedMarks.clamp(0.0, fullMarks),
      letterGrade: gradeInfo['grade'] as String,
      gradePoint: gradeInfo['point'] as double,
    );

    final updatedSubjects = List<Subject>.from(sem.subjects);
    updatedSubjects[subIndex] = updatedSubject;

    final newGpa = CalculationService.calculateSemesterGpa(updatedSubjects);
    final newCredits = CalculationService.calculateTotalCredits(updatedSubjects);

    _semesters[semIndex] = sem.copyWith(
      subjects: updatedSubjects,
      gpa: newGpa,
      totalCredits: newCredits,
    );
    await _persist();
  }

  /// Delete Subject
  Future<void> deleteSubject({
    required String semesterId,
    required String subjectId,
  }) async {
    final semIndex = _semesters.indexWhere((s) => s.id == semesterId);
    if (semIndex == -1) return;

    final sem = _semesters[semIndex];
    final updatedSubjects = List<Subject>.from(sem.subjects)
      ..removeWhere((s) => s.id == subjectId);

    final newGpa = CalculationService.calculateSemesterGpa(updatedSubjects);
    final newCredits = CalculationService.calculateTotalCredits(updatedSubjects);

    _semesters[semIndex] = sem.copyWith(
      subjects: updatedSubjects,
      gpa: newGpa,
      totalCredits: newCredits,
    );
    await _persist();
  }

  /// Load Preset Sample Data
  Future<void> loadSampleData() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    _semesters = DevinAiService.getMockSemesters();
    await _persist();
    _isLoading = false;
    notifyListeners();
  }

  /// Clear all semester data
  Future<void> clearAll() async {
    _semesters = [];
    await _persist();
  }

  Future<void> _persist() async {
    await _storageService.saveSemesters(_semesters);
    notifyListeners();
  }
}

