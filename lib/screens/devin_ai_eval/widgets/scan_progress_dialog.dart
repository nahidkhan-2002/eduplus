import 'package:flutter/material.dart';
import '../../../providers/evaluation_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/glass_container.dart';

class ScanProgressDialog extends StatelessWidget {
  final EvaluationProvider provider;

  const ScanProgressDialog({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(20),
      child: GlassContainer(
        padding: const EdgeInsets.all(28),
        borderRadius: 20,
        borderColor: AppTheme.primaryIndigo.withValues(alpha: 0.5),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Scanner Animation Icon
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryIndigo.withValues(alpha: 0.15),
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: CircularProgressIndicator(
                      value: provider.scanProgress,
                      strokeWidth: 4,
                      backgroundColor: AppTheme.slateBorder,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentTealGlow),
                    ),
                  ),
                  const Icon(
                    Icons.document_scanner_rounded,
                    color: AppTheme.accentTealGlow,
                    size: 32,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Devin AI Neural OCR & Diagnostic Engine',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(provider.scanProgress * 100).toInt()}% Analysis Completed',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.accentTealGlow,
                ),
              ),
              const SizedBox(height: 20),

              // Linear progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: provider.scanProgress,
                  minHeight: 8,
                  backgroundColor: AppTheme.slateBorder,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentTealGlow),
                ),
              ),
              const SizedBox(height: 24),

              // 3-Phase Stepper List
              _buildPhaseItem(
                phaseNum: 1,
                title: 'Scanning handwriting & formulas...',
                isActive: provider.currentPhaseIndex == 0,
                isDone: provider.currentPhaseIndex > 0,
              ),
              const SizedBox(height: 12),
              _buildPhaseItem(
                phaseNum: 2,
                title: 'Matching against question scoring rubric...',
                isActive: provider.currentPhaseIndex == 1,
                isDone: provider.currentPhaseIndex > 1,
              ),
              const SizedBox(height: 12),
              _buildPhaseItem(
                phaseNum: 3,
                title: 'Generating gap diagnosis & step penalty breakdown...',
                isActive: provider.currentPhaseIndex == 2,
                isDone: provider.scanProgress >= 0.99,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhaseItem({
    required int phaseNum,
    required String title,
    required bool isActive,
    required bool isDone,
  }) {
    Color color;
    Widget icon;

    if (isDone) {
      color = AppTheme.successGreen;
      icon = const Icon(Icons.check_circle_rounded, color: AppTheme.successGreen, size: 18);
    } else if (isActive) {
      color = AppTheme.accentTealGlow;
      icon = const SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentTealGlow),
        ),
      );
    } else {
      color = AppTheme.textMuted;
      icon = Text(
        '$phaseNum',
        style: const TextStyle(
          color: AppTheme.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryIndigo.withValues(alpha: 0.12) : AppTheme.slateBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive ? AppTheme.primaryIndigo : AppTheme.slateBorder.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.15),
            ),
            child: icon,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.white : (isDone ? AppTheme.textPrimary : AppTheme.textMuted),
                fontSize: 12,
                fontWeight: isActive || isDone ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

