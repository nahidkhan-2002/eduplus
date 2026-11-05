import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eduplus/main.dart';
import 'package:eduplus/models/semester.dart';
import 'package:eduplus/models/subject.dart';
import 'package:eduplus/providers/auth_provider.dart';
import 'package:eduplus/providers/evaluation_provider.dart';
import 'package:eduplus/providers/gpa_provider.dart';
import 'package:eduplus/providers/routine_provider.dart';
import 'package:eduplus/services/calculation_service.dart';
import 'package:eduplus/services/devin_ai_service.dart';
import 'package:eduplus/services/storage_service.dart';

void main() {
  group('CalculationService & Grading Engine Tests', () {
    test('Standard university grading scale mapping', () {
      expect(CalculationService.calculateGradeAndPoint(95, 100)['grade'], 'A+');
      expect(CalculationService.calculateGradeAndPoint(95, 100)['point'], 4.00);

      expect(CalculationService.calculateGradeAndPoint(77, 100)['grade'], 'A');
      expect(CalculationService.calculateGradeAndPoint(77, 100)['point'], 3.75);

      expect(CalculationService.calculateGradeAndPoint(72, 100)['grade'], 'A-');
      expect(CalculationService.calculateGradeAndPoint(72, 100)['point'], 3.50);

      expect(CalculationService.calculateGradeAndPoint(67, 100)['grade'], 'B+');
      expect(CalculationService.calculateGradeAndPoint(67, 100)['point'], 3.25);

      expect(CalculationService.calculateGradeAndPoint(62, 100)['grade'], 'B');
      expect(CalculationService.calculateGradeAndPoint(62, 100)['point'], 3.00);

      expect(CalculationService.calculateGradeAndPoint(52, 100)['grade'], 'C+');
      expect(CalculationService.calculateGradeAndPoint(52, 100)['point'], 2.50);

      expect(CalculationService.calculateGradeAndPoint(42, 100)['grade'], 'D');
      expect(CalculationService.calculateGradeAndPoint(42, 100)['point'], 2.00);

      expect(CalculationService.calculateGradeAndPoint(30, 100)['grade'], 'F');
      expect(CalculationService.calculateGradeAndPoint(30, 100)['point'], 0.00);
    });

    test('Semester GPA weighted credit calculation: Σ(Credit × Grade Point) / Σ(Total Credits)', () {
      final subjects = [
        const Subject(
          id: '1',
          name: 'Calculus',
          code: 'MATH-101',
          creditHours: 3.0,
          fullMarks: 100,
          obtainedMarks: 85,
          letterGrade: 'A+',
          gradePoint: 4.00,
        ),
        const Subject(
          id: '2',
          name: 'Structured Programming',
          code: 'CSE-101',
          creditHours: 3.0,
          fullMarks: 100,
          obtainedMarks: 75,
          letterGrade: 'A',
          gradePoint: 3.75,
        ),
        const Subject(
          id: '3',
          name: 'Programming Lab',
          code: 'CSE-102',
          creditHours: 1.5,
          fullMarks: 100,
          obtainedMarks: 90,
          letterGrade: 'A+',
          gradePoint: 4.00,
        ),
      ];

      // Total credits = 3 + 3 + 1.5 = 7.5
      // Quality points = (3 * 4.0) + (3 * 3.75) + (1.5 * 4.0) = 12 + 11.25 + 6.0 = 29.25
      // GPA = 29.25 / 7.5 = 3.90
      final gpa = CalculationService.calculateSemesterGpa(subjects);
      expect(gpa, 3.90);
    });

    test('Cumulative CGPA calculation across multiple semesters', () {
      final mockSemesters = DevinAiService.getMockSemesters();
      expect(mockSemesters.length, 3);
      final cgpa = CalculationService.calculateCumulativeCgpa(mockSemesters);
      expect(cgpa, greaterThan(3.5));
      expect(cgpa, lessThanOrEqualTo(4.0));
    });
  });

  group('Provider & Storage Integration Tests', () {
    late StorageService storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = await StorageService.init();
    });

    test('AuthProvider quick demo bypass test', () async {
      final auth = AuthProvider(storage);
      expect(auth.isLoggedIn, false);

      final ok = await auth.quickDemoLogin();
      expect(ok, true);
      expect(auth.isLoggedIn, true);
      expect(auth.currentUser?.username, 'test');
      expect(auth.currentUser?.fullName, 'Alex Mercer');
    });

    test('GpaProvider adds, edits and persists semesters and subjects', () async {
      final gpa = GpaProvider(storage);
      expect(gpa.semesters.isNotEmpty, true); // Mock data initially loaded

      final countBefore = gpa.semesters.length;
      await gpa.addSemester(title: 'Semester 4', term: 'Spring 2026');
      expect(gpa.semesters.length, countBefore + 1);

      final newSemId = gpa.semesters.last.id;
      await gpa.addSubject(
        semesterId: newSemId,
        name: 'Compiler Design',
        code: 'CSE-401',
        creditHours: 3.0,
        fullMarks: 100,
        obtainedMarks: 86,
      );

      final updatedSem = gpa.semesters.firstWhere((s) => s.id == newSemId);
      expect(updatedSem.subjects.length, 1);
      expect(updatedSem.subjects.first.code, 'CSE-401');
      expect(updatedSem.subjects.first.letterGrade, 'A+');
      expect(updatedSem.gpa, 4.00);
    });

    test('EvaluationProvider 3-phase analysis test', () async {
      final eval = EvaluationProvider(storage);
      expect(eval.currentEvaluation, isNotNull);
      expect(eval.isScanning, false);

      await eval.runDevinAiAnalysis();
      expect(eval.isScanning, false);
      expect(eval.scanProgress, 1.0);
      expect(eval.currentEvaluation?.pinpoints.isNotEmpty, true);
      expect(eval.currentEvaluation?.weakAreas.isNotEmpty, true);
    });

    test('RoutineProvider slot toggling and completion tracking', () async {
      final routine = RoutineProvider(storage);
      expect(routine.currentRoutine, isNotNull);

      final slot = routine.currentRoutine!.pomodoroSlots.first;
      final initialStatus = slot.isCompleted;

      await routine.toggleSlotCompletion(slot.id);
      final updatedSlot = routine.currentRoutine!.pomodoroSlots.firstWhere((s) => s.id == slot.id);
      expect(updatedSlot.isCompleted, !initialStatus);
    });
  });

  group('Widget UI Smoke Tests', () {
    testWidgets('Renders EduPulse Login Screen with 1-Click bypass', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.init();

      await tester.pumpWidget(EduPulseApp(storageService: storage));
      await tester.pumpAndSettle();

      expect(find.text('EduPulse'), findsOneWidget);
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('1-Click Sign In'), findsOneWidget);
    });
  });
}
