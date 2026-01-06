import 'package:flutter/material.dart';
import '../services/api.dart';
import '../models/dashboard_models.dart';
import '../utils/csv_export.dart';
import '../widgets/app_buttons.dart';
import '../widgets/totals_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _api = ApiService();

  String? startYmd;
  String? endYmd;
  bool loading = true;

  DashboardData? data;

  Color perMileColor(double v) {
    if (v >= 2.0) return Colors.green;
    if (v >= 1.25) return Colors.amber;
    return Colors.red;
  }

  Color incomeColor() => Colors.blue; // avoid confusion with per-mile colors

  Color expenseColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade300
          : Colors.grey.shade700;

  Future<void> refresh() async {
    setState(() => loading = true);
    try {
      final raw = await _api.fetchDashboard(
        start: startYmd ?? '',
        end: endYmd ?? '',
      );

      // Convert Map -> DashboardData
      final d = DashboardData.fromJson(raw);

      if (mounted) setState(() => data = d);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Dashboard error: $e')));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    refresh();
  }

  int get totalMiles =>
      (data?.mileage ?? []).fold(0, (sum, r) => sum + r.miles);
  double get totalIncome =>
      (data?.mileage ?? []).fold(0.0, (sum, r) => sum + r.amount);
  double get totalPerMile => totalMiles > 0 ? (totalIncome / totalMiles) : 0;

  Future<void> pickStart() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 2),
      lastDate: DateTime(DateTime.now().year + 1),
      initialDate: DateTime.now(),
    );
    if (picked == null) return;

    setState(() => startYmd =
        '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}');
    await refresh();
  }

  Future<void> pickEnd() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 2),
      lastDate: DateTime(DateTime.now().year + 1),
      initialDate: DateTime.now(),
    );
    if (picked == null) return;

    setState(() => endYmd =
        '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}');
    await refresh();
  }

  Future<void> clearFilter() async {
    setState(() {
      startYmd = null;
      endYmd = null;
    });
    await refresh();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    final d = data ?? DashboardData(mileage: [], monthly: [], maintenance: []);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            OutlinedButton.icon(
              onPressed: pickStart,
              icon: const Icon(Icons.date_range),
              label: Text(startYmd == null ? 'Start' : 'Start: $startYmd'),
            ),
            OutlinedButton.icon(
              onPressed: pickEnd,
              icon: const Icon(Icons.date_range),
              label: Text(endYmd == null ? 'End' : 'End: $endYmd'),
            ),
            ElevatedButton(
              style: AppButtons.red(),
              onPressed: clearFilter,
              child: const Text('Clear'),
            ),
            ElevatedButton(
              style: AppButtons.blue(),
              onPressed: () async {
                if (data == null) return;
                await CsvExport.exportDashboardToCsv(data!);
              },
              child: const Text('Export CSV'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        TotalsCard(
          totalMiles: totalMiles,
          totalIncome: totalIncome,
          totalPerMile: totalPerMile,
        ),
        const SizedBox(height: 16),
        const Text('Mileage Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        ...d.mileage.map((r) => Card(
              child: ListTile(
                title: Text(r.date),
                subtitle: Text('${r.miles} miles'),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('\$${r.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontWeight: FontWeight.w900, color: incomeColor())),
                    Text('\$${r.perMile.toStringAsFixed(2)}/mi',
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: perMileColor(r.perMile))),
                  ],
                ),
              ),
            )),
        const SizedBox(height: 16),
        const Text('Monthly Totals',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        ...d.monthly.map((r) => Card(
              child: ListTile(
                title: Text(r.label),
                subtitle: Text('${r.miles} miles'),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('\$${r.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontWeight: FontWeight.w900, color: incomeColor())),
                    Text('\$${r.perMile.toStringAsFixed(2)}/mi',
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: perMileColor(r.perMile))),
                  ],
                ),
              ),
            )),
        const SizedBox(height: 16),
        const Text('Maintenance & Repairs',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        ...d.maintenance.map((r) => Card(
              child: ListTile(
                title: Text(r.date),
                subtitle: Text(r.type),
                trailing: Text(
                  '-\$${r.cost.toStringAsFixed(2)}',
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: expenseColor(context)),
                ),
              ),
            )),
      ],
    );
  }
}
