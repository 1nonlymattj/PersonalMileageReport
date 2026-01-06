import 'package:flutter/material.dart';
import '../services/api.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _api = ApiService();

  String _start = '';
  String _end = '';

  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final d = await _api.fetchDashboard(start: _start, end: _end);
      setState(() => _data = d);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Color perMileColor(double v) {
    if (v >= 2.0) return Colors.green;
    if (v >= 1.25) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final mileage = (_data?['mileage'] as List?) ?? const [];
    final monthly = (_data?['monthly'] as List?) ?? const [];
    final maintenance = (_data?['maintenance'] as List?) ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : Column(
                    children: [
                      // Filters
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                  labelText: 'Start (YYYY-MM-DD)'),
                              onChanged: (v) => _start = v.trim(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                  labelText: 'End (YYYY-MM-DD)'),
                              onChanged: (v) => _end = v.trim(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                              onPressed: _load, child: const Text('Apply')),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Expanded(
                        child: ListView(
                          children: [
                            const Text('Mileage Summary',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            ...mileage.map((r) {
                              final pm =
                                  (r['perMile'] as num?)?.toDouble() ?? 0.0;
                              final amt =
                                  (r['amount'] as num?)?.toDouble() ?? 0.0;
                              return ListTile(
                                title:
                                    Text('${r['date']} • ${r['miles']} miles'),
                                subtitle:
                                    Text('Amount: \$${amt.toStringAsFixed(2)}'),
                                trailing: Text(
                                  '\$${pm.toStringAsFixed(2)}/mi',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: perMileColor(pm)),
                                ),
                              );
                            }),
                            const Divider(height: 28),
                            const Text('Monthly Totals',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            ...monthly.map((r) {
                              final pm =
                                  (r['perMile'] as num?)?.toDouble() ?? 0.0;
                              final amt =
                                  (r['amount'] as num?)?.toDouble() ?? 0.0;
                              return ListTile(
                                title:
                                    Text('${r['label']} • ${r['miles']} miles'),
                                subtitle:
                                    Text('Amount: \$${amt.toStringAsFixed(2)}'),
                                trailing: Text(
                                  '\$${pm.toStringAsFixed(2)}/mi',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: perMileColor(pm)),
                                ),
                              );
                            }),
                            const Divider(height: 28),
                            const Text('Maintenance & Repairs',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            ...maintenance.map((r) {
                              final cost =
                                  (r['cost'] as num?)?.toDouble() ?? 0.0;
                              return ListTile(
                                title: Text(
                                    '${r['date']} • ${(r['type'] ?? '').toString()}'),
                                trailing: Text(
                                  '-\$${cost.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
