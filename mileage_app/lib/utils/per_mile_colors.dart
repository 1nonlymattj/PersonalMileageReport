import 'package:flutter/material.dart';

class PerMileColors {
  // Thresholds (same as your web dashboard)
  static const double good = 2.0;
  static const double ok = 1.25;

  static Color forValue(BuildContext context, double v) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Theme-aware palette (matches your JS COLORS)
    final goodC = isDark ? const Color(0xFF34D399) : const Color(0xFF16A34A);
    final okC = isDark ? const Color(0xFFFBBF24) : const Color(0xFFCA8A04);
    final badC = isDark ? const Color(0xFFFB7185) : const Color(0xFFDC2626);

    if (v >= good) return goodC;
    if (v >= ok) return okC;
    return badC;
  }

  static TextStyle style(BuildContext context, double v) => TextStyle(
        fontWeight: FontWeight.w900,
        color: forValue(context, v),
      );
}
