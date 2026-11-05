import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/evaluation.dart';
import '../../providers/evaluation_provider.dart';
import '../../providers/routine_provider.dart';
import '../../services/devin_ai_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/pulse_button.dart';
import '../../widgets/stat_card.dart';
import 'widgets/penalty_chip.dart';
import 'widgets/scan_progress_dialog.dart';
import 'widgets/script_inspector.dart';

class DevinAiEvalScreen extends StatefulWidget {
  final VoidCallback? onNavigateToRoutine;

  const DevinAiEvalScreen({super.key, this.onNavigateToRoutine});

  @override
  State<DevinAiEvalScreen> createState() => _DevinAiEvalScreenState();
}

class _DevinAiEvalScreenState extends State<DevinAiEvalScreen> {
  void _pickQuestionImage(EvaluationProvider provider) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg', 'pdf'],
      );
      if (result != null && result.files.isNotEmpty) {
        provider.setCustomQuestionFile(result.files.first.name);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Uploaded Question Sheet: ${result.files.first.name}'),
              backgroundColor: AppTheme.accentTeal,
            ),
          );
        }
      }
    } catch (_) {
      // Fallback
    }
  }

  void _pickScriptImage(EvaluationProvider provider) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg', 'pdf'],
      );
      if (result != null && result.files.isNotEmpty) {
        provider.setCustomScriptFile(result.files.first.name);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Uploaded Answer Script: ${result.files.first.name}'),
              backgroundColor: AppTheme.accentTeal,
            ),
          );
        }
      }
    } catch (_) {
      // Fallback
    }
  }

  void _startAnalysis(EvaluationProvider provider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Consumer<EvaluationProvider>(
        builder: (_, prov, __) => ScanProgressDialog(provider: prov),
      ),
    );

    provider.runDevinAiAnalysis(
      onComplete: () {
        if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final evalProv = context.watch<EvaluationProvider>();
    final currentEval = evalProv.currentEvaluation;
    final presets = DevinAiService.availablePresets;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Devin AI Script Evaluator',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.auto_awesome, color: AppTheme.accentTealGlow, size: 22),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      'AI Handwriting OCR • Step Penalty Pinpointing • Rubric Gap Diagnosis',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                PulseButton(
                  onPressed: () => _startAnalysis(evalProv),
                  label: 'Analyze with Devin AI',
                  isLoading: evalProv.isScanning,
                  icon: const Icon(Icons.psychology_rounded, size: 20, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Upload & Preset Configuration Row
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 800;
                final uploadCard1 = _buildUploaderCard(
                  title: '1. Question Paper Image',
                  subtitle: evalProv.customQuestionFileName != null
                      ? 'Custom File: ${evalProv.customQuestionFileName}'
                      : 'Active Preset: ${evalProv.selectedPresetId}',
                  icon: Icons.quiz_outlined,
                  actionLabel: 'Upload Custom File',
                  onAction: () => _pickQuestionImage(evalProv),
                  badge: evalProv.customQuestionFileName != null ? 'Custom Upload' : 'Preset Loaded',
                  isUploaded: evalProv.customQuestionFileName != null,
                );

                final uploadCard2 = _buildUploaderCard(
                  title: '2. Answer Script / Khata Page',
                  subtitle: evalProv.customScriptFileName != null
                      ? 'Custom File: ${evalProv.customScriptFileName}'
                      : 'Authentic Student Handwritten Sheet',
                  icon: Icons.draw_outlined,
                  actionLabel: 'Upload Khata Scan',
                  onAction: () => _pickScriptImage(evalProv),
                  badge: evalProv.customScriptFileName != null ? 'Custom Upload' : 'Preset Loaded',
                  isUploaded: evalProv.customScriptFileName != null,
                );

                if (isWide) {
                  return Row(
                    children: [
                      Expanded(child: uploadCard1),
                      const SizedBox(width: 16),
                      Expanded(child: uploadCard2),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      uploadCard1,
                      const SizedBox(height: 12),
                      uploadCard2,
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 16),

            // Preset Selection Bar
            GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Text(
                    'Pre-loaded Exam Presets:',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: presets.map((preset) {
                          final isSelected = evalProv.selectedPresetId == preset.id &&
                              evalProv.customQuestionFileName == null;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(preset.subjectCode),
                              selected: isSelected,
                              avatar: isSelected
                                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                                  : null,
                              onSelected: (_) {
                                evalProv.selectPreset(preset.id);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Diagnostic Results Section
            if (currentEval != null) ...[
              // Summary Telemetry Cards
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 780;
                  final cards = [
                    StatCard(
                      title: 'Rubric Accuracy Score',
                      value: '${currentEval.accuracyPercentage.toStringAsFixed(1)}%',
                      subtitle: '${currentEval.scoredMarks} / ${currentEval.totalMarks} Marks',
                      icon: Icons.analytics_outlined,
                      accentColor: currentEval.accuracyPercentage >= 80
                          ? AppTheme.successGreen
                          : AppTheme.warningAmber,
                      progress: currentEval.accuracyPercentage / 100.0,
                    ),
                    StatCard(
                      title: 'Identified Weak Areas',
                      value: '${currentEval.weakAreas.length} Areas',
                      subtitle: 'Direct gap points diagnosed',
                      icon: Icons.error_outline_rounded,
                      accentColor: AppTheme.dangerRose,
                    ),
                    StatCard(
                      title: 'Mark Recovery Target',
                      value: '+15.0%',
                      subtitle: 'Expected next exam boost',
                      icon: Icons.trending_up_rounded,
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

              // Interactive Script Inspector & Penalty Pinpoints Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 920;

                  final scriptWidget = ScriptInspector(
                    evaluation: currentEval,
                    selectedPinpoint: evalProv.selectedPinpoint,
                    onSelectPinpoint: (pinpoint) => evalProv.selectPinpoint(pinpoint),
                  );

                  final pinpointListWidget = Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Penalty Pinpoints & Step Deductions',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            'Click item to highlight on script',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.accentTealGlow.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: currentEval.pinpoints.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final pinpoint = currentEval.pinpoints[index];
                          final isSelected = evalProv.selectedPinpoint?.id == pinpoint.id;
                          return PenaltyChip(
                            pinpoint: pinpoint,
                            isSelected: isSelected,
                            onTap: () => evalProv.selectPinpoint(pinpoint),
                          );
                        },
                      ),
                    ],
                  );

                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 6, child: scriptWidget),
                        const SizedBox(width: 20),
                        Expanded(flex: 5, child: pinpointListWidget),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        scriptWidget,
                        const SizedBox(height: 20),
                        pinpointListWidget,
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 28),

              // Weak Areas Diagnostic Breakdown
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
                            Icon(Icons.warning_amber_rounded, color: AppTheme.warningAmber, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Diagnosed Weak Areas & Remediation Steps',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        if (widget.onNavigateToRoutine != null)
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentTeal,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                            onPressed: () {
                              context.read<RoutineProvider>().generateRoutine(
                                    diagnosticWeakAreas: currentEval.weakAreas,
                                  );
                              widget.onNavigateToRoutine!();
                            },
                            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                            label: const Text('Export to Routine Builder'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: currentEval.weakAreas.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final area = currentEval.weakAreas[index];
                        final isCritical = area.severity.toLowerCase() == 'critical';

                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.slateBg.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isCritical
                                  ? AppTheme.dangerRose.withValues(alpha: 0.35)
                                  : AppTheme.warningAmber.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    area.topic,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: (isCritical ? AppTheme.dangerRose : AppTheme.warningAmber)
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '-${area.penaltyScore} Marks • ${area.severity}',
                                      style: TextStyle(
                                        color: isCritical ? AppTheme.dangerRose : AppTheme.warningAmber,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                area.issue,
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryIndigo.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.lightbulb_outline, size: 16, color: AppTheme.accentTealGlow),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Devin Remediation: ${area.remediation}',
                                        style: const TextStyle(
                                          color: AppTheme.accentTealGlow,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Devin AI +15% Mark Recovery Recommendation Notes
              GlassContainer(
                padding: const EdgeInsets.all(22),
                borderColor: AppTheme.accentTeal.withValues(alpha: 0.4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.verified_rounded, color: AppTheme.accentTealGlow, size: 22),
                        SizedBox(width: 10),
                        Text(
                          'Devin AI Recommendation Notes for +15% Mark Recovery',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ...currentEval.recommendationNotes.map((note) => Padding(
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
                                  note,
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

  Widget _buildUploaderCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String actionLabel,
    required VoidCallback onAction,
    required String badge,
    required bool isUploaded,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryIndigo.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppTheme.primaryIndigoLight, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isUploaded
                      ? AppTheme.accentTeal.withValues(alpha: 0.2)
                      : AppTheme.slateCardLight,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isUploaded ? AppTheme.accentTeal : AppTheme.slateBorder,
                  ),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: isUploaded ? AppTheme.accentTealGlow : AppTheme.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.file_upload_outlined, size: 16),
            label: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
