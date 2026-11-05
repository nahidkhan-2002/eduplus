import 'package:flutter/material.dart';
import '../../../models/routine.dart';
import '../../../theme/app_theme.dart';

class PomodoroSlotTile extends StatelessWidget {
  final PomodoroSlot slot;
  final ValueChanged<bool?> onToggle;

  const PomodoroSlotTile({
    super.key,
    required this.slot,
    required this.onToggle,
  });

  Color _getTypeColor() {
    switch (slot.slotType.toLowerCase()) {
      case 'focus drill':
        return AppTheme.primaryIndigoLight;
      case 'active recall':
        return AppTheme.accentTealGlow;
      case 'practice problem':
        return AppTheme.warningAmber;
      default:
        return AppTheme.infoBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: slot.isCompleted
            ? AppTheme.successGreen.withValues(alpha: 0.08)
            : AppTheme.slateBg.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: slot.isCompleted
              ? AppTheme.successGreen.withValues(alpha: 0.4)
              : AppTheme.slateBorder.withValues(alpha: 0.7),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Checkbox
          Transform.scale(
            scale: 1.15,
            child: Checkbox(
              value: slot.isCompleted,
              onChanged: onToggle,
              activeColor: AppTheme.successGreen,
              checkColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(width: 8),

          // Time Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.slateCardLight,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.slateBorder),
            ),
            child: Text(
              slot.timeLabel,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Subject & Topic Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        slot.subjectName,
                        style: TextStyle(
                          color: slot.isCompleted ? AppTheme.textSecondary : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          decoration: slot.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        slot.slotType,
                        style: TextStyle(
                          color: typeColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  slot.topic,
                  style: TextStyle(
                    color: slot.isCompleted ? AppTheme.textMuted : AppTheme.textSecondary,
                    fontSize: 12,
                    decoration: slot.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Duration pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryIndigo.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer_outlined, size: 12, color: AppTheme.accentTealGlow),
                const SizedBox(width: 4),
                Text(
                  '${slot.durationMinutes}m',
                  style: const TextStyle(
                    color: AppTheme.accentTealGlow,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

