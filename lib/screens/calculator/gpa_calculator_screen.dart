import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/semester.dart';
import '../../models/subject.dart';
import '../../providers/gpa_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/stat_card.dart';
import 'widgets/cgpa_chart.dart';
import 'widgets/semester_card.dart';
import 'widgets/subject_dialog.dart';

class GpaCalculatorScreen extends StatelessWidget {
  const GpaCalculatorScreen({super.key});

  void _showAddSemesterDialog(BuildContext context) {
    final titleController = TextEditingController(text: 'Semester ${context.read<GpaProvider>().semesters.length + 1}');
    final termController = TextEditingController(text: 'Term 2026');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Academic Semester'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Semester Name (e.g. Semester 4)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: termController,
              decoration: const InputDecoration(labelText: 'Academic Term (e.g. Spring 2026)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<GpaProvider>().addSemester(
                    title: titleController.text,
                    term: termController.text,
                  );
              Navigator.pop(ctx);
            },
            child: const Text('Add Semester'),
          ),
        ],
      ),
    );
  }

  void _showEditSemesterDialog(BuildContext context, Semester semester) {
    final titleController = TextEditingController(text: semester.title);
    final termController = TextEditingController(text: semester.term);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Semester Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Semester Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: termController,
              decoration: const InputDecoration(labelText: 'Term / Session'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<GpaProvider>().editSemester(
                    semesterId: semester.id,
                    title: titleController.text,
                    term: termController.text,
                  );
              Navigator.pop(ctx);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showSubjectDialog(BuildContext context, String semesterId, [Subject? subject]) {
    showDialog(
      context: context,
      builder: (ctx) => SubjectDialog(
        initialSubject: subject,
        onSave: (name, code, credits, fullMarks, obtainedMarks) {
          if (subject == null) {
            context.read<GpaProvider>().addSubject(
                  semesterId: semesterId,
                  name: name,
                  code: code,
                  creditHours: credits,
                  fullMarks: fullMarks,
                  obtainedMarks: obtainedMarks,
                );
          } else {
            context.read<GpaProvider>().editSubject(
                  semesterId: semesterId,
                  subjectId: subject.id,
                  name: name,
                  code: code,
                  creditHours: credits,
                  fullMarks: fullMarks,
                  obtainedMarks: obtainedMarks,
                );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gpaProv = context.watch<GpaProvider>();
    final semesters = gpaProv.semesters;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Header & Action Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GPA & CGPA Engine',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Live dynamic grade points, cumulative weighting & persistent transcript records',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 12,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => gpaProv.loadSampleData(),
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Load Sample Data'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showAddSemesterDialog(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Semester'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Top Telemetry Metrics Cards
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 780;
                final cards = [
                  StatCard(
                    title: 'Cumulative CGPA',
                    value: '${gpaProv.cumulativeCgpa.toStringAsFixed(2)} / 4.00',
                    subtitle: gpaProv.academicStanding,
                    icon: Icons.emoji_events_rounded,
                    accentColor: AppTheme.accentTealGlow,
                    progress: gpaProv.cumulativeCgpa / 4.0,
                  ),
                  StatCard(
                    title: 'Total Credits Earned',
                    value: '${gpaProv.totalCredits.toStringAsFixed(1)} cr',
                    subtitle: 'Across ${semesters.length} Semesters',
                    icon: Icons.layers_rounded,
                    accentColor: AppTheme.primaryIndigoLight,
                  ),
                  StatCard(
                    title: 'Enrolled Subjects',
                    value: '${gpaProv.totalSubjectsCount}',
                    subtitle: 'All graded & saved locally',
                    icon: Icons.library_books_rounded,
                    accentColor: AppTheme.accentCyan,
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

            // Trajectory Line Chart
            if (semesters.isNotEmpty) ...[
              CgpaChart(semesters: semesters),
              const SizedBox(height: 28),
            ],

            // Semesters List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Academic Semesters (${semesters.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  'All changes auto-saved to local storage',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.accentTealGlow.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (semesters.isEmpty)
              EmptyState(
                icon: Icons.folder_open_rounded,
                title: 'No Semesters Configured',
                description: 'Add your first semester or click "Load Sample Data" to explore the dynamic CGPA calculation engine.',
                buttonLabel: 'Add First Semester',
                onButtonPressed: () => _showAddSemesterDialog(context),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: semesters.length,
                separatorBuilder: (_, __) => const SizedBox(height: 18),
                itemBuilder: (context, index) {
                  final sem = semesters[index];
                  return SemesterCard(
                    semester: sem,
                    onAddSubject: () => _showSubjectDialog(context, sem.id),
                    onEditSubject: (sub) => _showSubjectDialog(context, sem.id, sub),
                    onDeleteSubject: (subId) {
                      context.read<GpaProvider>().deleteSubject(
                            semesterId: sem.id,
                            subjectId: subId,
                          );
                    },
                    onEditSemester: () => _showEditSemesterDialog(context, sem),
                    onDeleteSemester: () {
                      context.read<GpaProvider>().deleteSemester(sem.id);
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
