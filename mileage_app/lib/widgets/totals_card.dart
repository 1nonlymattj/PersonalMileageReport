import 'package:flutter/material.dart';

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

  Color perMileColor(double v) {
    if (v >= 2.0) return Colors.green;
    if (v >= 1.25) return Colors.amber;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _metric('Miles', '$totalMiles'),
            _metric('Income', '\$${totalIncome.toStringAsFixed(2)}',
                valueColor: Colors.blue),
            _metric('\$/Mile', '\$${totalPerMile.toStringAsFixed(2)}',
                valueColor: perMileColor(totalPerMile)),
          ],
        ),
      ),
    );
  }

  Widget _metric(String label, String value, {Color? valueColor}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(value,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w900, color: valueColor)),
      ],
    );
  }
}
