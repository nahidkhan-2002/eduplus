import 'package:flutter/material.dart';
import '../../../models/evaluation.dart';
import '../../../theme/app_theme.dart';

class ScriptInspector extends StatelessWidget {
  final ScriptEvaluation evaluation;
  final PenaltyPinpoint? selectedPinpoint;
  final Function(PenaltyPinpoint pinpoint) onSelectPinpoint;
  final bool isScanning;

  const ScriptInspector({
    super.key,
    required this.evaluation,
    required this.selectedPinpoint,
    required this.onSelectPinpoint,
    this.isScanning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1424),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.slateBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Inspector Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF131D31),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(bottom: BorderSide(color: AppTheme.slateBorder)),
            ),
            child: Row(
              children: [
                const Icon(Icons.description_outlined, size: 16, color: AppTheme.accentTealGlow),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Student Khata Answer Script • ${evaluation.subjectCode} (${evaluation.customScriptImageName ?? "Authentic Handwritten Sheet"})',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.dangerRose.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.dangerRose.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    '${evaluation.pinpoints.length} Penalty Pinpoints',
                    style: const TextStyle(
                      color: AppTheme.dangerRose,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Khata Canvas Sheet with Overlaid Pinpoints
          LayoutBuilder(
            builder: (context, constraints) {
              final canvasWidth = constraints.maxWidth;
              final canvasHeight = (canvasWidth * 1.15).clamp(420.0, 580.0);

              return SizedBox(
                width: canvasWidth,
                height: canvasHeight,
                child: Stack(
                  children: [
                    // Simulated Paper with Ruled Lines & Handwritten Steps
                    Positioned.fill(
                      child: Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF1E293B)),
                        ),
                        child: CustomPaint(
                          painter: KhataPaperPainter(presetId: evaluation.presetId),
                        ),
                      ),
                    ),

                    // Overlaid Penalty Bounding Boxes
                    ...evaluation.pinpoints.map((pinpoint) {
                      final isSelected = selectedPinpoint?.id == pinpoint.id;
                      final boxLeft = 12 + (pinpoint.x * (canvasWidth - 24));
                      final boxTop = 12 + (pinpoint.y * (canvasHeight - 24));
                      final boxW = pinpoint.width * (canvasWidth - 24);
                      final boxH = pinpoint.height * (canvasHeight - 24);

                      final isCritical = pinpoint.severity.toLowerCase() == 'critical';
                      final color = isCritical ? AppTheme.dangerRose : AppTheme.warningAmber;

                      return Positioned(
                        left: boxLeft,
                        top: boxTop,
                        width: boxW,
                        height: boxH,
                        child: GestureDetector(
                          onTap: () => onSelectPinpoint(pinpoint),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? color.withValues(alpha: 0.28)
                                  : color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: color,
                                width: isSelected ? 2.5 : 1.5,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: color.withValues(alpha: 0.5),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  right: 4,
                                  top: -12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '-${pinpoint.deduction.toStringAsFixed(1)} pts',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),

                    // Laser Scanning Bar if scanning
                    if (isScanning)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 4,
                          decoration: const BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accentTealGlow,
                                blurRadius: 12,
                                spreadRadius: 3,
                              ),
                            ],
                            color: AppTheme.accentTealGlow,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Custom Canvas Painter rendering realistic student handwritten exam sheet
class KhataPaperPainter extends CustomPainter {
  final String presetId;

  KhataPaperPainter({required this.presetId});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw subtle notebook horizontal ruling lines
    final linePaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 1.0;

    const lineSpacing = 28.0;
    for (double y = 40.0; y < size.height; y += lineSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    // Draw left margin red line
    final marginPaint = Paint()
      ..color = const Color(0x33F43F5E)
      ..strokeWidth = 1.2;
    canvas.drawLine(const Offset(34, 0), Offset(34, size.height), marginPaint);

    // Text rendering of authentic exam student answers
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    if (presetId.contains('algo')) {
      _drawAlgoScript(canvas, size, textPainter);
    } else if (presetId.contains('logic')) {
      _drawLogicScript(canvas, size, textPainter);
    } else {
      _drawCalculusScript(canvas, size, textPainter);
    }
  }

  void _drawCalculusScript(Canvas canvas, Size size, TextPainter tp) {
    const headerStyle = TextStyle(
      color: Color(0xFF64748B),
      fontSize: 11,
      fontFamily: 'monospace',
    );
    const textStyle = TextStyle(
      color: Color(0xFFE2E8F0),
      fontSize: 13,
      fontFamily: 'monospace',
      height: 1.8,
    );
    const redDeductionStyle = TextStyle(
      color: Color(0xFFF43F5E),
      fontSize: 12,
      fontWeight: FontWeight.w700,
      fontFamily: 'monospace',
    );

    tp.text = const TextSpan(
      children: [
        TextSpan(text: "Ans to Q1 (Integration by Parts):\n", style: headerStyle),
        TextSpan(text: "Given I = ∫ x²·e^(3x) dx\n", style: textStyle),
        TextSpan(text: "Let u = x²  ==> du = 2x dx\n", style: textStyle),
        TextSpan(text: "dv = e^(3x) dx ==> v = (1/3) e^(3x)\n", style: textStyle),
        TextSpan(text: "I = (1/3)x² e^(3x) - (2/3) ∫ x e^(3x) dx\n", style: textStyle),
        TextSpan(text: "  = (1/3)x² e^(3x) - (2/9)x e^(3x) + (2/27) e^(3x)\n", style: textStyle),
        TextSpan(text: "    [Devin AI: Missing arbitrary constant + C !]\n", style: redDeductionStyle),
        TextSpan(text: "\nAns to Q2 (Double Integral in Polar Coordinates):\n", style: headerStyle),
        TextSpan(text: "∬_D (x² + y²) dA  where D: x² + y² = 4\n", style: textStyle),
        TextSpan(text: "Transforming: x = r cosθ, y = r sinθ, dA = r dr dθ\n", style: textStyle),
        TextSpan(text: "x² + y² = r²  ==> Integrand becomes r³\n", style: textStyle),
        TextSpan(text: "Limits taken: r ∈ [0, 2], θ ∈ [0, 2π]\n", style: textStyle),
        TextSpan(text: "    [Devin AI: Domain specified 1st quadrant only (0 ≤ θ ≤ π/2)!]\n", style: redDeductionStyle),
        TextSpan(text: "I = ∫_0^(2π) dθ ∫_0^2 r³ dr = [θ] * [r⁴/4] = 2π * 4 = 8π\n", style: textStyle),
        TextSpan(text: "\nAns to Q3 (Characteristic ODE Equation):\n", style: headerStyle),
        TextSpan(text: "y'' + 4y' + 4y = 0 ==> r² + 4r + 4 = 0 ==> (r+2)² = 0\n", style: textStyle),
        TextSpan(text: "Student Solution: y(x) = c1·e^(-2x) + c2·e^(-2x)\n", style: textStyle),
        TextSpan(text: "    [Devin AI: Repeated root requires independent term c2·x·e^(-2x)!]\n", style: redDeductionStyle),
      ],
    );

    tp.layout(maxWidth: size.width - 50);
    tp.paint(canvas, const Offset(42, 12));
  }

  void _drawAlgoScript(Canvas canvas, Size size, TextPainter tp) {
    const textStyle = TextStyle(
      color: Color(0xFFE2E8F0),
      fontSize: 13,
      fontFamily: 'monospace',
      height: 1.8,
    );
    const redStyle = TextStyle(
      color: Color(0xFFF43F5E),
      fontSize: 12,
      fontWeight: FontWeight.w700,
      fontFamily: 'monospace',
    );

    tp.text = const TextSpan(
      children: [
        TextSpan(text: "Ans to Q1 (Master Theorem Recurrence):\n", style: textStyle),
        TextSpan(text: "T(n) = 4T(n/2) + n² log n\n", style: textStyle),
        TextSpan(text: "a = 4, b = 2  ==> n^(log_2 4) = n²\n", style: textStyle),
        TextSpan(text: "f(n) = n² log n = Θ(n^(log_b a) · log¹ n)\n", style: textStyle),
        TextSpan(text: "By Master Theorem Case 2b: T(n) = Θ(n² log² n)\n", style: textStyle),
        TextSpan(text: "  [Devin AI: Omitted regularity condition lemma cite]\n", style: redStyle),
        TextSpan(text: "\nAns to Q2 (0/1 Knapsack Dynamic Programming):\n", style: textStyle),
        TextSpan(text: "for i = 1 to N:\n", style: textStyle),
        TextSpan(text: "  for w = 1 to W:\n", style: textStyle),
        TextSpan(text: "    DP[i][w] = max(DP[i-1][w], val[i] + DP[i-1][w - wt[i]])\n", style: textStyle),
        TextSpan(text: "  [Devin AI: Missing if (w - wt[i] >= 0) guard! Index < 0]\n", style: redStyle),
      ],
    );
    tp.layout(maxWidth: size.width - 50);
    tp.paint(canvas, const Offset(42, 12));
  }

  void _drawLogicScript(Canvas canvas, Size size, TextPainter tp) {
    const textStyle = TextStyle(
      color: Color(0xFFE2E8F0),
      fontSize: 13,
      fontFamily: 'monospace',
      height: 1.8,
    );
    const redStyle = TextStyle(
      color: Color(0xFFF43F5E),
      fontSize: 12,
      fontWeight: FontWeight.w700,
      fontFamily: 'monospace',
    );

    tp.text = const TextSpan(
      children: [
        TextSpan(text: "Ans to Q1 (Karnaugh Map Minimization):\n", style: textStyle),
        TextSpan(text: "F(A,B,C,D) = Σm(0,2,5,7,8,10,13,15) + d(3,11)\n", style: textStyle),
        TextSpan(text: "Group 1 (Four Corners): m(0,2,8,10) = B'D'\n", style: textStyle),
        TextSpan(text: "Group 2 (Center Column): m(5,7,13,15) = BD\n", style: textStyle),
        TextSpan(text: "Minimal SOP = B'D' + BD\n", style: textStyle),
        TextSpan(text: "  [Devin AI: Static hazard 1 uncovered between adjacent blocks!]\n", style: redStyle),
        TextSpan(text: "\nAns to Q2 (Max Clock Frequency):\n", style: textStyle),
        TextSpan(text: "T_min = t_pd + t_setup = 1.2ns + 0.4ns = 1.6ns\n", style: textStyle),
        TextSpan(text: "F_max = 1 / 1.6ns = 625 MHz\n", style: textStyle),
        TextSpan(text: "  [Devin AI: Ignored clock skew margin of 0.15ns]\n", style: redStyle),
      ],
    );
    tp.layout(maxWidth: size.width - 50);
    tp.paint(canvas, const Offset(42, 12));
  }

  @override
  bool shouldRepaint(covariant KhataPaperPainter oldDelegate) =>
      oldDelegate.presetId != presetId;
}

