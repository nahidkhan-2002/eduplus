import 'package:flutter/material.dart';
import '../../../models/semester.dart';
import '../../../models/subject.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/glass_container.dart';
import '../../../widgets/grade_badge.dart';

class SemesterCard extends StatelessWidget {
  final Semester semester;
  final VoidCallback onAddSubject;
  final Function(Subject subject) onEditSubject;
  final Function(String subjectId) onDeleteSubject;
  final VoidCallback onEditSemester;
  final VoidCallback onDeleteSemester;

  const SemesterCard({
    super.key,
    required this.semester,
    required this.onAddSubject,
    required this.onEditSubject,
    required this.onDeleteSubject,
    required this.onEditSemester,
    required this.onDeleteSemester,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Title, GPA, and actions
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryIndigo.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryIndigo.withValues(alpha: 0.3)),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: AppTheme.primaryIndigoLight,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      semester.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${semester.term} • ${semester.totalCredits.toStringAsFixed(1)} Total Credits',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // GPA Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppTheme.tealCyanGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentTeal.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'GPA ',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      semester.gpa.toStringAsFixed(2),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: AppTheme.textSecondary),
                color: AppTheme.slateSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppTheme.slateBorder),
                ),
                onSelected: (val) {
                  if (val == 'edit') onEditSemester();
                  if (val == 'delete') onDeleteSemester();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 16, color: AppTheme.textPrimary),
                        SizedBox(width: 8),
                        Text('Edit Semester Details'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 16, color: AppTheme.dangerRose),
                        SizedBox(width: 8),
                        Text('Delete Semester', style: TextStyle(color: AppTheme.dangerRose)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppTheme.slateBorder),
          const SizedBox(height: 12),

          // Subjects List / Table
          if (semester.subjects.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Text(
                    'No subjects added to this semester yet.',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: onAddSubject,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add First Subject'),
                  ),
                ],
              ),
            )
          else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: semester.subjects.length,
              separatorBuilder: (ctx, idx) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final sub = semester.subjects[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.slateBg.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.slateBorder.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Code Tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.slateCardLight,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppTheme.slateBorder),
                        ),
                        child: Text(
                          sub.code,
                          style: const TextStyle(
                            color: AppTheme.accentTealGlow,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Name & Credit
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sub.name,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${sub.creditHours} Credits • ${sub.obtainedMarks.toStringAsFixed(1)} / ${sub.fullMarks.toStringAsFixed(0)} marks (${sub.percentage.toStringAsFixed(1)}%)',
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Grade Badge
                      GradeBadge(
                        letterGrade: sub.letterGrade,
                        gradePoint: sub.gradePoint,
                        isCompact: true,
                      ),
                      const SizedBox(width: 8),

                      // Edit button
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.textSecondary),
                        tooltip: 'Edit Subject',
                        onPressed: () => onEditSubject(sub),
                      ),
                      // Delete button
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18, color: AppTheme.dangerRose),
                        tooltip: 'Delete Subject',
                        onPressed: () => onDeleteSubject(sub.id),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onAddSubject,
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text('Add Another Subject'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
