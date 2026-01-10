// lib/widgets/totals_card.dart
import 'package:flutter/material.dart';
import '../utils/per_mile_colors.dart';

class TotalsCard extends StatelessWidget {
  final int totalMiles;
  final double totalIncome;
  final double totalPerMile;

  const TotalsCard({
    super.key,
    required this.totalMiles,
    required this.totalIncome,
    required this.totalPerMile,
  });

  // Income stays BLUE to avoid confusion with red/amber/green per-mile scale
  Color incomeColor() => Colors.blue;

  @override
  Widget build(BuildContext context) {
    final perMile = totalMiles > 0 ? (totalIncome / totalMiles) : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _metric(context, 'Miles', '$totalMiles'),
            _metric(
              context,
              'Income',
              '\$${totalIncome.toStringAsFixed(2)}',
              valueStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: incomeColor(),
              ),
            ),
            _metric(
              context,
              '\$/Mile',
              totalMiles > 0 ? '\$${perMile.toStringAsFixed(2)}' : '--',
              valueStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: PerMileColors.forValue(context, perMile),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metric(
    BuildContext context,
    String label,
    String value, {
    TextStyle? valueStyle,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: valueStyle ??
              const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
        ),
      ],
    );
  }
}
