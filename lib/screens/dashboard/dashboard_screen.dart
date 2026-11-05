import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/evaluation_provider.dart';
import '../../providers/gpa_provider.dart';
import '../../providers/routine_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/pulse_button.dart';
import '../../widgets/stat_card.dart';
import '../calculator/widgets/cgpa_chart.dart';
import '../routine/widgets/pomodoro_slot_tile.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int tabIndex) onNavigateTab;

  const DashboardScreen({super.key, required this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final gpa = context.watch<GpaProvider>();
    final eval = context.watch<EvaluationProvider>();
    final routineProv = context.watch<RoutineProvider>();

    final user = auth.currentUser;
    final semesters = gpa.semesters;
    final currentEval = eval.currentEvaluation;
    final routine = routineProv.currentRoutine;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Student Welcome Hero Banner
            GlassContainer(
              padding: const EdgeInsets.all(24),
              borderColor: AppTheme.primaryIndigo.withValues(alpha: 0.4),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppTheme.primaryIndigoDark,
                    child: Text(
                      user?.fullName.isNotEmpty == true ? user!.fullName[0] : 'S',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Welcome, ${user?.fullName ?? "Student"}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.accentTeal.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppTheme.accentTeal),
                              ),
                              child: const Text(
                                'ACTIVE SEMESTER',
                                style: TextStyle(
                                  color: AppTheme.accentTealGlow,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${user?.department ?? "Computer Science"} • ${user?.batch ?? "Class of 2026"} • Student ID: ${user?.studentId ?? "STU-8842"}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PulseButton(
                    onPressed: () => onNavigateTab(2), // Jump to Devin AI Eval
                    label: 'Launch Devin AI Scan',
                    icon: const Icon(Icons.psychology_rounded, size: 18, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Top Telemetry Metrics
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 850;
                final cards = [
                  StatCard(
                    title: 'Cumulative CGPA',
                    value: '${gpa.cumulativeCgpa.toStringAsFixed(2)} / 4.00',
                    subtitle: gpa.academicStanding,
                    icon: Icons.school_rounded,
                    accentColor: AppTheme.accentTealGlow,
                    progress: gpa.cumulativeCgpa / 4.0,
                  ),
                  StatCard(
                    title: 'Credits Completed',
                    value: '${gpa.totalCredits.toStringAsFixed(1)} cr',
                    subtitle: '${semesters.length} Semesters Graded',
                    icon: Icons.layers_outlined,
                    accentColor: AppTheme.primaryIndigoLight,
                  ),
                  StatCard(
                    title: 'Devin AI Exam Score',
                    value: currentEval != null
                        ? '${currentEval.accuracyPercentage.toStringAsFixed(0)}%'
                        : '78%',
                    subtitle: currentEval != null
                        ? '${currentEval.scoredMarks} / ${currentEval.totalMarks} Marks'
                        : 'Calculus Final Diagnostic',
                    icon: Icons.document_scanner_rounded,
                    accentColor: AppTheme.accentCyan,
                  ),
                  StatCard(
                    title: "Today's Study Target",
                    value: routine != null
                        ? '${routine.completionPercentage.toStringAsFixed(0)}%'
                        : '25%',
                    subtitle: routine != null
                        ? '${routine.completedSlotsCount} of ${routine.pomodoroSlots.length} Pomodoros Done'
                        : '1 of 4 Slots Done',
                    icon: Icons.timer_outlined,
                    accentColor: AppTheme.warningAmber,
                    progress: routine != null ? routine.completionPercentage / 100.0 : 0.25,
                  ),
                ];

                if (isWide) {
                  return Row(
                    children: cards
                        .map((c) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: c,
                              ),
                            ))
                        .toList(),
                  );
                } else {
                  return Column(
                    children: cards
                        .map((c) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: c,
                            ))
                        .toList(),
                  );
                }
              },
            ),
            const SizedBox(height: 24),

            // GPA Progression Chart
            if (semesters.isNotEmpty) ...[
              CgpaChart(semesters: semesters),
              const SizedBox(height: 28),
            ],

            // Feature Quick-Launch Cards
            Row(
              children: [
                Expanded(
                  child: _buildActionTile(
                    title: 'GPA & CGPA Engine',
                    desc: 'Manage semesters, subjects, credit weights & grade point curves.',
                    icon: Icons.calculate_rounded,
                    badge: '${semesters.length} Semesters',
                    color: AppTheme.primaryIndigo,
                    onTap: () => onNavigateTab(1),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionTile(
                    title: 'Devin AI Script Evaluator',
                    desc: 'Upload question paper & khata script for simulated rubric diagnosis.',
                    icon: Icons.auto_awesome_rounded,
                    badge: 'Rubric AI',
                    color: AppTheme.accentTeal,
                    onTap: () => onNavigateTab(2),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionTile(
                    title: 'Personalized Routine',
                    desc: 'Daily Pomodoro timetable, spaced repetition & weak-point drills.',
                    icon: Icons.calendar_month_rounded,
                    badge: 'Daily Tracker',
                    color: AppTheme.accentCyan,
                    onTap: () => onNavigateTab(3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Split Section: Recent AI Diagnostic & Today's Study Routine
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 900;

                final diagnosticWidget = GlassContainer(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.psychology_rounded, color: AppTheme.accentTealGlow, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Recent Devin AI Diagnostic Snapshot',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () => onNavigateTab(2),
                            child: const Text('View Full Diagnosis'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (currentEval != null) ...[
                        Text(
                          currentEval.questionPaperTitle,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Score: ${currentEval.scoredMarks} / ${currentEval.totalMarks} Marks (${currentEval.accuracyPercentage.toStringAsFixed(1)}%) • ${currentEval.pinpoints.length} Rubric Penalties',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.slateBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.dangerRose.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.error_outline, size: 14, color: AppTheme.dangerRose),
                                  const SizedBox(width: 6),
                                  Text(
                                    currentEval.pinpoints.isNotEmpty
                                        ? currentEval.pinpoints.first.title
                                        : 'Critical Step Omission',
                                    style: const TextStyle(
                                      color: AppTheme.dangerRose,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currentEval.pinpoints.isNotEmpty
                                    ? currentEval.pinpoints.first.explanation
                                    : 'Arbitrary constant omission in step 3 antiderivative.',
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );

                final routineWidget = GlassContainer(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.check_circle_outline, color: AppTheme.successGreen, size: 20),
                              SizedBox(width: 8),
                              Text(
                                "Today's Study Checklist",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () => onNavigateTab(3),
                            child: const Text('Open Routine Builder'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (routine != null && routine.pomodoroSlots.isNotEmpty) ...[
                        ...routine.pomodoroSlots.take(3).map(
                              (slot) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: PomodoroSlotTile(
                                  slot: slot,
                                  onToggle: (_) => routineProv.toggleSlotCompletion(slot.id),
                                ),
                              ),
                            ),
                      ],
                    ],
                  ),
                );

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: diagnosticWidget),
                      const SizedBox(width: 20),
                      Expanded(child: routineWidget),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      diagnosticWidget,
                      const SizedBox(height: 18),
                      routineWidget,
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String desc,
    required IconData icon,
    required String badge,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      onTap: onTap,
      borderColor: color.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Open Module',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward_rounded, size: 14, color: color),
            ],
          ),
        ],
      ),
    );
  }
}
