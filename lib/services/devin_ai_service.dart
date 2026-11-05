import '../models/evaluation.dart';
import '../models/routine.dart';
import '../models/semester.dart';
import '../models/subject.dart';
import 'calculation_service.dart';

class ExamPreset {
  final String id;
  final String title;
  final String subjectCode;
  final String description;
  final double totalMarks;
  final String questionPreview;
  final String scriptPreview;

  const ExamPreset({
    required this.id,
    required this.title,
    required this.subjectCode,
    required this.description,
    required this.totalMarks,
    required this.questionPreview,
    required this.scriptPreview,
  });
}

class DevinAiService {
  static final List<ExamPreset> availablePresets = [
    const ExamPreset(
      id: 'calculus_math102',
      title: 'Multivariable Calculus & Differential Systems (MATH-102)',
      subjectCode: 'MATH-102',
      description: 'Definite integrals, polar coordinates, Green\'s theorem, and second order ODEs.',
      totalMarks: 50.0,
      questionPreview:
          'Q1. Evaluate ∫ x²·e^(3x) dx using integration by parts.\n'
          'Q2. Compute ∬_D (x² + y²) dA over region D bounded by x² + y² = 4 in the 1st quadrant.\n'
          'Q3. Find the general solution to y\'\' + 4y\' + 4y = 0.',
      scriptPreview:
          '1. By parts: u = x², dv = e^(3x)dx. du = 2xdx, v = 1/3 e^(3x).\n'
          '   = (1/3)x² e^(3x) - (2/3)∫ x e^(3x) dx\n'
          '   = (1/3)x² e^(3x) - (2/9)x e^(3x) + (2/27)e^(3x)  <-- (Missing + C)\n'
          '2. Polar: x = r cosθ, y = r sinθ, dA = r dr dθ.\n'
          '   Limits: 0 ≤ r ≤ 2, 0 ≤ θ ≤ 2π  <-- (Domain specified 1st quadrant only!)\n'
          '   Integral = ∫_0^(2π) ∫_0^2 r³ dr dθ = 8π.',
    ),
    const ExamPreset(
      id: 'algo_cse301',
      title: 'Algorithm Design & Asymptotic Complexity (CSE-301)',
      subjectCode: 'CSE-301',
      description: 'Master theorem recurrences, dynamic programming, and amortized data structures.',
      totalMarks: 50.0,
      questionPreview:
          'Q1. Solve recurrence T(n) = 4T(n/2) + Θ(n² log n) using Master Theorem.\n'
          'Q2. Write recurrence & pseudocode for 0/1 Knapsack with memoization.\n'
          'Q3. Prove that red-black tree insertion requires at most 2 tree rotations.',
      scriptPreview:
          '1. T(n) = 4T(n/2) + n² log n.\n'
          '   a = 4, b = 2, f(n) = n² log n. n^(log_b a) = n^(log_2 4) = n².\n'
          '   f(n) = Θ(n^(log_b a) log^k n) with k = 1.\n'
          '   Therefore by extended Master Case 2: T(n) = Θ(n² log² n).\n'
          '2. Knapsack DP table initialized: DP[i][w] = max(DP[i-1][w], val[i] + DP[i-1][w-wt[i]]).\n'
          '   Missing base case: w - wt[i] < 0 check leads to index out of bounds.',
    ),
    const ExamPreset(
      id: 'logic_ece205',
      title: 'Digital Systems & Processor Architecture (ECE-205)',
      subjectCode: 'ECE-205',
      description: 'Synchronous sequential circuits, Karnaugh map minimization, and pipeline hazards.',
      totalMarks: 50.0,
      questionPreview:
          'Q1. Minimize F(A,B,C,D) = Σm(0,2,5,7,8,10,13,15) + d(3,11) using 4-variable K-map.\n'
          'Q2. Design a Mod-6 synchronous counter using JK flip-flops.\n'
          'Q3. Calculate maximum operating frequency given t_pd = 1.2ns, t_setup = 0.4ns.',
      scriptPreview:
          '1. K-Map 4x4 matrix mapped.\n'
          '   Corners grouped: m(0,2,8,10) -> B\'D\'.\n'
          '   Center squares grouped: m(5,7,13,15) -> BD.\n'
          '   Result: F = B\'D\' + BD.\n'
          '2. Counter state transition table made.\n'
          '   Flip flop excitation inputs derived without glitch hazard suppression.',
    ),
  ];

  /// Generate simulated realistic Devin AI script evaluation
  static ScriptEvaluation generateEvaluationForPreset(String presetId, {String? customQName, String? customAName}) {
    if (presetId == 'algo_cse301') {
      return ScriptEvaluation(
        id: 'eval_algo_${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
        questionPaperTitle: 'Algorithm Design & Asymptotic Complexity (CSE-301) Midterm',
        subjectCode: 'CSE-301',
        presetId: presetId,
        totalMarks: 50.0,
        scoredMarks: 41.5,
        accuracyPercentage: 83.0,
        customQuestionImageName: customQName,
        customScriptImageName: customAName,
        weakAreas: const [
          WeakArea(
            id: 'w1',
            topic: 'Dynamic Programming Boundary Protection',
            issue: 'Boundary check missing for capacity overflow (w - weight[i] < 0)',
            penaltyScore: 3.5,
            severity: 'Critical',
            remediation: 'Always wrap array access in conditional: if (w >= wt[i-1]) before taking max().',
          ),
          WeakArea(
            id: 'w2',
            topic: 'Master Theorem Asymptotic Regularity',
            issue: 'Omitted formal polynomial difference check between f(n) and n^(log_b a)',
            penaltyScore: 2.5,
            severity: 'Moderate',
            remediation: 'State the strict poly-growth ratio before applying extended Case 2.',
          ),
          WeakArea(
            id: 'w3',
            topic: 'Red-Black Tree Rebalance Invariance',
            issue: 'Proof sketched informally without establishing black-height preservation',
            penaltyScore: 2.5,
            severity: 'Moderate',
            remediation: 'List the 5 RB-invariants and trace black-height before and after the double rotation.',
          ),
        ],
        pinpoints: const [
          PenaltyPinpoint(
            id: 'p1',
            title: 'Unchecked Array Index in Recurrence',
            deduction: 3.5,
            severity: 'Critical',
            stepReference: 'Line 18 • Table State Transition',
            explanation: 'When w < wt[i], index is negative causing segmentation crash in runtime execution.',
            x: 0.12,
            y: 0.52,
            width: 0.76,
            height: 0.12,
          ),
          PenaltyPinpoint(
            id: 'p2',
            title: 'Informal Step Transition in Master Proof',
            deduction: 2.5,
            severity: 'Moderate',
            stepReference: 'Line 7 • Logarithmic Factor Substitution',
            explanation: 'Did not cite the polylogarithmic corollary theorem explicitly.',
            x: 0.15,
            y: 0.22,
            width: 0.70,
            height: 0.10,
          ),
          PenaltyPinpoint(
            id: 'p3',
            title: 'Missing Base Case Termination',
            deduction: 2.5,
            severity: 'Minor',
            stepReference: 'Line 26 • Recursive Unwinding',
            explanation: 'Did not specify T(1) = 1 boundary condition.',
            x: 0.18,
            y: 0.75,
            width: 0.65,
            height: 0.11,
          ),
        ],
        recommendationNotes: const [
          'Devin Rule 1: Add boundary guards in DP recurrences to protect against array negatives.',
          'Devin Rule 2: Quote the exact case name: "Master Theorem Case 2b (Polylogarithmic Form)" for full credit.',
          'Devin Rule 3: Frame complexity answers with upper (O), lower (Ω), and tight (Θ) bounds to capture 100% partial marks.',
          'Mark Recovery Projection: +17% improvement expected on next test following these 3 rubric adjustments.',
        ],
      );
    } else if (presetId == 'logic_ece205') {
      return ScriptEvaluation(
        id: 'eval_logic_${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
        questionPaperTitle: 'Digital Systems & CPU Architecture (ECE-205) Test',
        subjectCode: 'ECE-205',
        presetId: presetId,
        totalMarks: 50.0,
        scoredMarks: 43.0,
        accuracyPercentage: 86.0,
        customQuestionImageName: customQName,
        customScriptImageName: customAName,
        weakAreas: const [
          WeakArea(
            id: 'w1',
            topic: 'Static-1 Glitch Hazard Elimination',
            issue: 'Adjacent prime implicants not bridged with redundant consensus term',
            penaltyScore: 3.0,
            severity: 'Critical',
            remediation: 'Add consensus loop (B\'D + BD) -> add B term to avoid dynamic glitch.',
          ),
          WeakArea(
            id: 'w2',
            topic: 'Propagation Delay Margin Analysis',
            issue: 'Hold time skew (t_hold) ignored during clock frequency calculation',
            penaltyScore: 4.0,
            severity: 'Moderate',
            remediation: 'Verify t_clk > t_pd + t_setup + t_skew and t_cd > t_hold.',
          ),
        ],
        pinpoints: const [
          PenaltyPinpoint(
            id: 'p1',
            title: 'Uncovered Hazard Loop in K-Map',
            deduction: 3.0,
            severity: 'Critical',
            stepReference: 'Diagram 1 • Karnaugh Grouping',
            explanation: 'Transition between minterms 5 and 7 is vulnerable to combinational hazard spikes.',
            x: 0.14,
            y: 0.32,
            width: 0.72,
            height: 0.18,
          ),
          PenaltyPinpoint(
            id: 'p2',
            title: 'Clock Frequency Equation Incomplete',
            deduction: 4.0,
            severity: 'Moderate',
            stepReference: 'Formula 3 • Max Freq Derivation',
            explanation: 'Neglected clock jitter margin of 0.15ns specified in problem sheet.',
            x: 0.16,
            y: 0.68,
            width: 0.68,
            height: 0.14,
          ),
        ],
        recommendationNotes: const [
          'Devin Rule 1: Always check for prime implicant transitions across K-map boundary lines.',
          'Devin Rule 2: Write out the full timing inequality equation before substituting values.',
          'Devin Rule 3: Label flip-flop input equations explicitly with subscripts (J_0, K_0, J_1, K_1).',
          'Mark Recovery Projection: +14% recovery guaranteed on synchronous circuit design sections.',
        ],
      );
    } else {
      // Default: Calculus MATH-102
      return ScriptEvaluation(
        id: 'eval_calc_${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
        questionPaperTitle: 'Multivariable Calculus & Differential Systems (MATH-102) Final Exam',
        subjectCode: 'MATH-102',
        presetId: 'calculus_math102',
        totalMarks: 50.0,
        scoredMarks: 38.5,
        accuracyPercentage: 77.0,
        customQuestionImageName: customQName,
        customScriptImageName: customAName,
        weakAreas: const [
          WeakArea(
            id: 'w1',
            topic: 'Indefinite Integral Constant of Integration',
            issue: 'Step 3 calculus integration constant missing (+ C)',
            penaltyScore: 2.0,
            severity: 'Moderate',
            remediation: 'Always attach "+ C" immediately upon taking the antiderivative before algebraic cleanup.',
          ),
          WeakArea(
            id: 'w2',
            topic: 'Polar Double Integral Domain Boundaries',
            issue: 'Angle boundary integrated over [0, 2π] instead of 1st quadrant [0, π/2]',
            penaltyScore: 5.5,
            severity: 'Critical',
            remediation: 'Sketch the coordinate sector first and mark quadrant angles (0 to π/2).',
          ),
          WeakArea(
            id: 'w3',
            topic: 'Homogeneous ODE Repeated Root Formula',
            issue: 'Proof incomplete on theorem 2 (Missing the independent x·e^(rx) factor in general solution)',
            penaltyScore: 4.0,
            severity: 'Critical',
            remediation: 'For repeated characteristic roots r1=r2=r, basis solution is y = (c1 + c2·x)e^(rx).',
          ),
        ],
        pinpoints: const [
          PenaltyPinpoint(
            id: 'p1',
            title: 'Missing Integration Constant (+ C)',
            deduction: 2.0,
            severity: 'Moderate',
            stepReference: 'Step 3 • Line 14',
            explanation: 'Evaluation omitted arbitrary constant of integration, resulting in loss of generality.',
            x: 0.15,
            y: 0.28,
            width: 0.70,
            height: 0.11,
          ),
          PenaltyPinpoint(
            id: 'p2',
            title: 'Incorrect Polar Angular Limit (0 to 2π)',
            deduction: 5.5,
            severity: 'Critical',
            stepReference: 'Step 5 • Integral Setup Line 22',
            explanation: 'Question explicitly constrained domain to 1st Quadrant only (0 ≤ θ ≤ π/2). Result is 4x inflated.',
            x: 0.12,
            y: 0.50,
            width: 0.75,
            height: 0.13,
          ),
          PenaltyPinpoint(
            id: 'p3',
            title: 'Repeated Root Multiplicity Omitted',
            deduction: 4.0,
            severity: 'Critical',
            stepReference: 'Step 7 • Differential Equation Line 34',
            explanation: 'Linear independence requires second factor x·e^(-2x). Student wrote y = c1·e^(-2x) + c2·e^(-2x).',
            x: 0.14,
            y: 0.76,
            width: 0.72,
            height: 0.12,
          ),
        ],
        recommendationNotes: const [
          'Devin Rule 1: Always write explicit "+ C" immediately upon taking antiderivative before boundary evaluation.',
          'Devin Rule 2: Highlight domain constraints in the question sheet with a colored box (e.g. "1st quadrant" -> 0 to π/2).',
          'Devin Rule 3: Use Wronskian check W(y1, y2) ≠ 0 whenever dealing with 2nd order repeated differential roots.',
          'Devin AI Recovery Plan: Implementing these 3 habits guarantees +15% mark recovery in future calculus finals.',
        ],
      );
    }
  }

  /// Generate personalized study routine based on intake inputs
  static StudyRoutine generatePersonalizedRoutine({
    required List<String> weakestSubjects,
    required double dailyHours,
    required DateTime targetExamDate,
    required double goalCgpa,
    List<WeakArea>? weakAreas,
  }) {
    final effectiveSubjects = weakestSubjects.isNotEmpty
        ? weakestSubjects
        : ['Multivariable Calculus', 'Algorithm Complexity', 'Digital Logic Systems'];

    // Generate Pomodoro slots based on daily hours (e.g. 2h = 2 slots, 4h = 4 slots, 6h = 6 slots)
    final slotCount = (dailyHours * 1.0).clamp(2.0, 6.0).toInt();
    final pomodoroSlots = <PomodoroSlot>[];

    final timeSlots = [
      '08:00 AM - 08:50 AM',
      '09:00 AM - 09:50 AM',
      '11:00 AM - 11:50 AM',
      '02:00 PM - 02:50 PM',
      '04:00 PM - 04:50 PM',
      '07:30 PM - 08:20 PM',
    ];

    final slotTypes = ['Focus Drill', 'Active Recall', 'Practice Problem', 'Spaced Review'];
    final topicsMap = {
      'Calculus': [
        'Integration by Parts & Constant (+C) Drills',
        'Polar Coordinate Domain Transformations',
        'Second-Order ODE Repeated Roots & Wronskian',
      ],
      'Algorithm': [
        'Master Theorem Case 1, 2, 3 Formal Boundary Proofs',
        'Dynamic Programming Memoization Safety Checks',
        'Amortized Analysis & Tree Rotations',
      ],
      'Logic': [
        'K-Map Static Hazard Consensus Terms',
        'Synchronous Counter JK Excitation Mapping',
        'Setup & Hold Timing Margins Under Clock Skew',
      ],
      'General': [
        'Formulas Mastery & Retrieval Flashcards',
        'Timed Past Paper Simulation (50 mins)',
        'Error Log Review & Devin AI Recommendation Audit',
      ],
    };

    for (int i = 0; i < slotCount; i++) {
      final sub = effectiveSubjects[i % effectiveSubjects.length];
      String topic = 'Foundations & Formula Recall';
      if (sub.toLowerCase().contains('calc') || sub.toLowerCase().contains('math')) {
        topic = topicsMap['Calculus']![i % topicsMap['Calculus']!.length];
      } else if (sub.toLowerCase().contains('algo') || sub.toLowerCase().contains('cse')) {
        topic = topicsMap['Algorithm']![i % topicsMap['Algorithm']!.length];
      } else if (sub.toLowerCase().contains('logic') || sub.toLowerCase().contains('ece')) {
        topic = topicsMap['Logic']![i % topicsMap['Logic']!.length];
      } else {
        topic = topicsMap['General']![i % topicsMap['General']!.length];
      }

      pomodoroSlots.add(
        PomodoroSlot(
          id: 'slot_${i + 1}',
          timeLabel: timeSlots[i % timeSlots.length],
          subjectName: sub,
          topic: topic,
          slotType: slotTypes[i % slotTypes.length],
          durationMinutes: 50,
          isCompleted: i == 0, // First slot marked completed for demo satisfaction
          priority: i == 0 || i == 1 ? 'High' : 'Standard',
        ),
      );
    }

    // Spaced repetition schedule based on Ebbinghaus forgetting curve
    final spacedRepetition = <SpacedRepetitionItem>[
      SpacedRepetitionItem(
        id: 'sr_1',
        subjectName: effectiveSubjects[0],
        concept: 'Integration by Parts & Missing Constant Prevention Rule',
        stage: 'Day 1: Encoding & Active Retrieval',
        scheduledDate: 'Today (Immediate)',
        isCompleted: true,
        retentionRate: 92,
      ),
      SpacedRepetitionItem(
        id: 'sr_2',
        subjectName: effectiveSubjects.length > 1 ? effectiveSubjects[1] : effectiveSubjects[0],
        concept: 'Master Theorem Asymptotic Regularity Conditions',
        stage: 'Day 3: Rapid Formula Flashcard Test',
        scheduledDate: 'In 2 Days',
        isCompleted: false,
        retentionRate: 84,
      ),
      SpacedRepetitionItem(
        id: 'sr_3',
        subjectName: effectiveSubjects[0],
        concept: 'Polar & Cylindrical Double Integral Domain Sketching',
        stage: 'Day 7: Full Timed Practice Exam',
        scheduledDate: 'In 6 Days',
        isCompleted: false,
        retentionRate: 78,
      ),
      SpacedRepetitionItem(
        id: 'sr_4',
        subjectName: effectiveSubjects.last,
        concept: 'Comprehensive Course Syntheses & Mock Khata Script',
        stage: 'Day 14: Final Exam Simulation',
        scheduledDate: 'In 12 Days',
        isCompleted: false,
        retentionRate: 68,
      ),
    ];

    // Devin AI actionable study tips based on diagnostic weak areas
    final actionableTips = <String>[
      'Dedicate first 15 mins of every Pomodoro block strictly to closed-book recall before referencing textbooks.',
      'Always sketch boundaries and label coordinate quadrants before setting up double/triple integrals.',
      'Maintain an "Error Ledger" recording every algebraic slip identified by Devin AI.',
      'Target Pace: 50 mins focus + 10 mins physical detachment (no screen/phone) to maximize cognitive consolidation.',
    ];

    if (weakAreas != null && weakAreas.isNotEmpty) {
      actionableTips.insert(0, 'High Priority Fix: ${weakAreas.first.remediation}');
    }

    return StudyRoutine(
      id: 'routine_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      weakestSubjects: effectiveSubjects,
      dailyStudyHours: dailyHours,
      targetExamDate: targetExamDate,
      goalCgpa: goalCgpa,
      pomodoroSlots: pomodoroSlots,
      spacedRepetitionItems: spacedRepetition,
      actionableTips: actionableTips,
      streakDays: 6,
    );
  }

  /// Load rich demo mock data for presentations
  static List<Semester> getMockSemesters() {
    final sem1Subjects = [
      CalculationService.calculateGradeAndPoint(88, 100).let((res) => Subject(
            id: 's1_1',
            name: 'Structured Programming in C',
            code: 'CSE-101',
            creditHours: 3.0,
            fullMarks: 100,
            obtainedMarks: 88,
            letterGrade: res['grade'] as String,
            gradePoint: res['point'] as double,
          )),
      CalculationService.calculateGradeAndPoint(78, 100).let((res) => Subject(
            id: 's1_2',
            name: 'Differential & Integral Calculus',
            code: 'MATH-101',
            creditHours: 3.0,
            fullMarks: 100,
            obtainedMarks: 78,
            letterGrade: res['grade'] as String,
            gradePoint: res['point'] as double,
          )),
      CalculationService.calculateGradeAndPoint(82, 100).let((res) => Subject(
            id: 's1_3',
            name: 'Physics I (Mechanics & Waves)',
            code: 'PHY-101',
            creditHours: 3.0,
            fullMarks: 100,
            obtainedMarks: 82,
            letterGrade: res['grade'] as String,
            gradePoint: res['point'] as double,
          )),
      CalculationService.calculateGradeAndPoint(94, 100).let((res) => Subject(
            id: 's1_4',
            name: 'Structured Programming Lab',
            code: 'CSE-102',
            creditHours: 1.5,
            fullMarks: 100,
            obtainedMarks: 94,
            letterGrade: res['grade'] as String,
            gradePoint: res['point'] as double,
          )),
    ];

    final sem2Subjects = [
      CalculationService.calculateGradeAndPoint(84, 100).let((res) => Subject(
            id: 's2_1',
            name: 'Data Structures & Algorithms I',
            code: 'CSE-201',
            creditHours: 3.0,
            fullMarks: 100,
            obtainedMarks: 84,
            letterGrade: res['grade'] as String,
            gradePoint: res['point'] as double,
          )),
      CalculationService.calculateGradeAndPoint(72, 100).let((res) => Subject(
            id: 's2_2',
            name: 'Multivariable Calculus & ODE',
            code: 'MATH-102',
            creditHours: 3.0,
            fullMarks: 100,
            obtainedMarks: 72,
            letterGrade: res['grade'] as String,
            gradePoint: res['point'] as double,
          )),
      CalculationService.calculateGradeAndPoint(86, 100).let((res) => Subject(
            id: 's2_3',
            name: 'Digital Logic & Computer Design',
            code: 'ECE-205',
            creditHours: 3.0,
            fullMarks: 100,
            obtainedMarks: 86,
            letterGrade: res['grade'] as String,
            gradePoint: res['point'] as double,
          )),
      CalculationService.calculateGradeAndPoint(90, 100).let((res) => Subject(
            id: 's2_4',
            name: 'Data Structures Lab',
            code: 'CSE-202',
            creditHours: 1.5,
            fullMarks: 100,
            obtainedMarks: 90,
            letterGrade: res['grade'] as String,
            gradePoint: res['point'] as double,
          )),
    ];

    final sem3Subjects = [
      CalculationService.calculateGradeAndPoint(91, 100).let((res) => Subject(
            id: 's3_1',
            name: 'Database Management Systems',
            code: 'CSE-305',
            creditHours: 3.0,
            fullMarks: 100,
            obtainedMarks: 91,
            letterGrade: res['grade'] as String,
            gradePoint: res['point'] as double,
          )),
      CalculationService.calculateGradeAndPoint(87, 100).let((res) => Subject(
            id: 's3_2',
            name: 'Operating Systems & Concurrency',
            code: 'CSE-311',
            creditHours: 3.0,
            fullMarks: 100,
            obtainedMarks: 87,
            letterGrade: res['grade'] as String,
            gradePoint: res['point'] as double,
          )),
      CalculationService.calculateGradeAndPoint(79, 100).let((res) => Subject(
            id: 's3_3',
            name: 'Discrete Mathematics & Graph Theory',
            code: 'CSE-209',
            creditHours: 3.0,
            fullMarks: 100,
            obtainedMarks: 79,
            letterGrade: res['grade'] as String,
            gradePoint: res['point'] as double,
          )),
      CalculationService.calculateGradeAndPoint(95, 100).let((res) => Subject(
            id: 's3_4',
            name: 'DBMS Applied Studio Lab',
            code: 'CSE-306',
            creditHours: 1.5,
            fullMarks: 100,
            obtainedMarks: 95,
            letterGrade: res['grade'] as String,
            gradePoint: res['point'] as double,
          )),
    ];

    final semester1 = Semester(
      id: 'sem_1',
      title: 'Semester 1',
      term: 'Fall 2024',
      subjects: sem1Subjects,
      gpa: CalculationService.calculateSemesterGpa(sem1Subjects),
      totalCredits: CalculationService.calculateTotalCredits(sem1Subjects),
    );

    final semester2 = Semester(
      id: 'sem_2',
      title: 'Semester 2',
      term: 'Spring 2025',
      subjects: sem2Subjects,
      gpa: CalculationService.calculateSemesterGpa(sem2Subjects),
      totalCredits: CalculationService.calculateTotalCredits(sem2Subjects),
    );

    final semester3 = Semester(
      id: 'sem_3',
      title: 'Semester 3',
      term: 'Fall 2025',
      subjects: sem3Subjects,
      gpa: CalculationService.calculateSemesterGpa(sem3Subjects),
      totalCredits: CalculationService.calculateTotalCredits(sem3Subjects),
    );

    return [semester1, semester2, semester3];
  }
}

extension ObjectExt<T> on T {
  R let<R>(R Function(T it) op) => op(this);
}

