import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/gpa_provider.dart';
import '../../providers/routine_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/pulse_button.dart';
import '../../widgets/stat_card.dart';
import 'widgets/pomodoro_slot_tile.dart';
import 'widgets/spaced_repetition_card.dart';

class RoutineScreen extends StatelessWidget {
  const RoutineScreen({super.key});

  void _showIntakeModal(BuildContext context) {
    final routineProv = context.read<RoutineProvider>();
    final gpaProv = context.read<GpaProvider>();
    final suggestedSubjects = gpaProv.weakestSubjectNames;

    double tempHours = routineProv.dailyHours;
    DateTime tempDate = routineProv.targetExamDate;
    double tempCgpa = routineProv.goalCgpa;
    final tempSelected = List<String>.from(routineProv.selectedWeakSubjects);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return GlassContainer(
            padding: const EdgeInsets.all(24),
            borderRadius: 24,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Devin AI Routine Intake Configuration',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Weakest Subjects Selection
                  const Text(
                    '1. Target Weakest Subjects (Auto-suggested from GPA Engine)',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: suggestedSubjects.map((subject) {
                      final isSelected = tempSelected.contains(subject);
                      return FilterChip(
                        label: Text(subject),
                        selected: isSelected,
                        onSelected: (selected) {
                          setModalState(() {
                            if (selected) {
                              tempSelected.add(subject);
                            } else {
                              if (tempSelected.length > 1) {
                                tempSelected.remove(subject);
                              }
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Available Daily Study Hours
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '2. Available Daily Study Hours',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${tempHours.toInt()} Hours / Day',
                        style: const TextStyle(
                          color: AppTheme.accentTealGlow,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: [2.0, 3.0, 4.0, 5.0, 6.0].map((h) {
                      return ChoiceChip(
                        label: Text('${h.toInt()} Hours'),
                        selected: tempHours == h,
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() => tempHours = h);
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Target Goal CGPA
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '3. Goal Target CGPA',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        tempCgpa.toStringAsFixed(2),
                        style: const TextStyle(
                          color: AppTheme.accentTealGlow,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: tempCgpa,
                    min: 3.0,
                    max: 4.0,
                    divisions: 20,
                    label: tempCgpa.toStringAsFixed(2),
                    activeColor: AppTheme.accentTealGlow,
                    onChanged: (val) {
                      setModalState(() => tempCgpa = val);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Target Exam Date Picker
                  ListTile(
                    tileColor: AppTheme.slateBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppTheme.slateBorder),
                    ),
                    leading: const Icon(Icons.event, color: AppTheme.accentTealGlow),
                    title: const Text('Target Exam Date', style: TextStyle(fontSize: 13)),
                    subtitle: Text(
                      DateFormat('EEE, MMM d, yyyy').format(tempDate),
                      style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                    trailing: const Text('Change Date', style: TextStyle(color: AppTheme.primaryIndigoLight)),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: tempDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setModalState(() => tempDate = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  PulseButton(
                    onPressed: () {
                      routineProv.updateIntake(
                        weakestSubjects: tempSelected,
                        dailyHours: tempHours,
                        targetExamDate: tempDate,
                        goalCgpa: tempCgpa,
                      );
                      routineProv.generateRoutine();
                      Navigator.pop(ctx);
                    },
                    label: 'Generate Devin AI Schedule',
                    icon: const Icon(Icons.auto_awesome, size: 18, color: Colors.white),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routineProv = context.watch<RoutineProvider>();
    final routine = routineProv.currentRoutine;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Screen Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personalized Study Routine Builder',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'AI Pomodoro Timetable • Spaced Repetition Tracker • Diagnostic Weak Area Drills',
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
                      onPressed: () => _showIntakeModal(context),
                      icon: const Icon(Icons.tune_rounded, size: 16),
                      label: const Text('Edit Intake Settings'),
                    ),
                    PulseButton(
                      onPressed: () => routineProv.generateRoutine(),
                      label: 'Regenerate Routine',
                      isLoading: routineProv.isGenerating,
                      icon: const Icon(Icons.refresh_rounded, size: 16, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (routine != null) ...[
              // Summary Progress Cards
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 780;
                  final cards = [
                    StatCard(
                      title: "Today's Pomodoro Progress",
                      value: '${routine.completedSlotsCount} / ${routine.pomodoroSlots.length} Slots',
                      subtitle: '${routine.completionPercentage.toStringAsFixed(0)}% Daily Target Met',
                      icon: Icons.check_circle_outline,
                      accentColor: AppTheme.successGreen,
                      progress: routine.completionPercentage / 100.0,
                    ),
                    StatCard(
                      title: 'Active Study Streak',
                      value: '${routine.streakDays} Days',
                      subtitle: 'Consistent Daily Retention',
                      icon: Icons.local_fire_department_rounded,
                      accentColor: AppTheme.warningAmber,
                    ),
                    StatCard(
                      title: 'Target Exam Horizon',
                      value: '${routine.targetExamDate.difference(DateTime.now()).inDays} Days Left',
                      subtitle: 'Goal CGPA: ${routine.goalCgpa.toStringAsFixed(2)}',
                      icon: Icons.flag_outlined,
                      accentColor: AppTheme.accentTealGlow,
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

              // Active Weak Subject Targets
              GlassContainer(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                child: Row(
                  children: [
                    const Icon(Icons.gps_fixed, size: 18, color: AppTheme.accentTealGlow),
                    const SizedBox(width: 10),
                    const Text(
                      'AI Focal Subjects: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: routine.weakestSubjects
                              .map((sub) => Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Chip(
                                      label: Text(sub),
                                      backgroundColor: AppTheme.primaryIndigo.withValues(alpha: 0.2),
                                      side: const BorderSide(color: AppTheme.primaryIndigo),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Timetable & Pomodoro Daily Schedule
              GlassContainer(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.schedule_rounded, color: AppTheme.accentTealGlow, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Daily Structured Pomodoro Timetable',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () => routineProv.resetDailyProgress(),
                          child: const Text('Reset Today'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Check off study blocks as you complete them. Progress is saved locally in daily telemetry.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: routine.pomodoroSlots.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final slot = routine.pomodoroSlots[index];
                        return PomodoroSlotTile(
                          slot: slot,
                          onToggle: (_) => routineProv.toggleSlotCompletion(slot.id),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Spaced Repetition & Active Recall Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.history_edu_rounded, color: AppTheme.primaryIndigoLight, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Ebbinghaus Spaced Repetition & Active Recall Dates',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Scientifically scheduled intervals (Day 1, 3, 7, 14) to cement mathematical formulas & proof structures.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 800;
                      if (isWide) {
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 2.2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                          ),
                          itemCount: routine.spacedRepetitionItems.length,
                          itemBuilder: (context, index) {
                            final item = routine.spacedRepetitionItems[index];
                            return SpacedRepetitionCard(
                              item: item,
                              onToggle: () => routineProv.toggleSpacedRepetition(item.id),
                            );
                          },
                        );
                      } else {
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: routine.spacedRepetitionItems.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = routine.spacedRepetitionItems[index];
                            return SpacedRepetitionCard(
                              item: item,
                              onToggle: () => routineProv.toggleSpacedRepetition(item.id),
                            );
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Devin AI Actionable Study Tips tailored to identified weak areas
              GlassContainer(
                padding: const EdgeInsets.all(22),
                borderColor: AppTheme.accentTeal.withValues(alpha: 0.35),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.tips_and_updates_outlined, color: AppTheme.accentTealGlow, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Actionable Study Tips Tailored to Your Diagnostic Weak Areas',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ...routine.actionableTips.map((tip) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 5),
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.accentTealGlow,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  tip,
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 13,
                                    height: 1.45,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
