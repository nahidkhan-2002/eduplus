import 'package:flutter/material.dart';

class GradeBadge extends StatelessWidget {
  final String letterGrade;
  final double? gradePoint;
  final bool isCompact;

  const GradeBadge({
    super.key,
    required this.letterGrade,
    this.gradePoint,
    this.isCompact = false,
  });

  static Color getGradeColor(String grade) {
    switch (grade.toUpperCase()) {
      case 'A+':
        return const Color(0xFF10B981);
      case 'A':
        return const Color(0xFF14B8A6);
      case 'A-':
        return const Color(0xFF06B6D4);
      case 'B+':
        return const Color(0xFF6366F1);
      case 'B':
        return const Color(0xFF38BDF8);
      case 'B-':
        return const Color(0xFF3B82F6);
      case 'C+':
        return const Color(0xFFF59E0B);
      case 'C':
        return const Color(0xFFF97316);
      case 'D':
        return const Color(0xFFFF5722);
      case 'F':
      default:
        return const Color(0xFFF43F5E);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = getGradeColor(letterGrade);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 12,
        vertical: isCompact ? 3 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            letterGrade,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: isCompact ? 12 : 14,
              letterSpacing: 0.5,
            ),
          ),
          if (gradePoint != null) ...[
            const SizedBox(width: 6),
            Container(
              width: 3,
              height: 3,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              gradePoint!.toStringAsFixed(2),
              style: TextStyle(
                color: color.withValues(alpha: 0.9),
                fontWeight: FontWeight.w600,
                fontSize: isCompact ? 11 : 13,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
