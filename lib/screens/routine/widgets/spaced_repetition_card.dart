import 'package:flutter/material.dart';
import '../../../models/routine.dart';
import '../../../theme/app_theme.dart';

class SpacedRepetitionCard extends StatelessWidget {
  final SpacedRepetitionItem item;
  final VoidCallback onToggle;

  const SpacedRepetitionCard({
    super.key,
    required this.item,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: item.isCompleted
            ? AppTheme.successGreen.withValues(alpha: 0.08)
            : AppTheme.slateBg.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: item.isCompleted
              ? AppTheme.successGreen.withValues(alpha: 0.4)
              : AppTheme.slateBorder.withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryIndigo.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.primaryIndigo.withValues(alpha: 0.4)),
                ),
                child: Text(
                  item.stage,
                  style: const TextStyle(
                    color: AppTheme.primaryIndigoLight,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.psychology_outlined,
                    size: 14,
                    color: item.retentionRate > 80 ? AppTheme.accentTealGlow : AppTheme.warningAmber,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${item.retentionRate}% Retention',
                    style: TextStyle(
                      color: item.retentionRate > 80 ? AppTheme.accentTealGlow : AppTheme.warningAmber,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.concept,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: item.isCompleted ? AppTheme.textSecondary : Colors.white,
              decoration: item.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Target Subject: ${item.subjectName}',
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 13, color: AppTheme.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    item.scheduledDate,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: onToggle,
                icon: Icon(
                  item.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                  size: 16,
                  color: item.isCompleted ? AppTheme.successGreen : AppTheme.accentTealGlow,
                ),
                label: Text(
                  item.isCompleted ? 'Reviewed' : 'Mark Review',
                  style: TextStyle(
                    color: item.isCompleted ? AppTheme.successGreen : AppTheme.accentTealGlow,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

