import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eduplus/main.dart';
import 'package:eduplus/services/calculation_service.dart';
import 'package:eduplus/services/storage_service.dart';

void main() {
  test('CalculationService calculates university grade points correctly', () {
    final gradeAplus = CalculationService.calculateGradeAndPoint(88, 100);
    expect(gradeAplus['grade'], 'A+');
    expect(gradeAplus['point'], 4.00);

    final gradeA = CalculationService.calculateGradeAndPoint(78, 100);
    expect(gradeA['grade'], 'A');
    expect(gradeA['point'], 3.75);

    final gradeF = CalculationService.calculateGradeAndPoint(35, 100);
    expect(gradeF['grade'], 'F');
    expect(gradeF['point'], 0.00);
  });

  testWidgets('EduPulse AI loads login screen smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.init();

    await tester.pumpWidget(EduPulseApp(storageService: storage));
    await tester.pumpAndSettle();

    expect(find.text('EduPulse'), findsOneWidget);
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('1-Click Sign In'), findsOneWidget);
  });
}
