import 'screens/pin_gate.dart';
import 'screens/dashboard.dart';
import 'services/api.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('darkMode') ?? false;
  runApp(MyApp(isDark: isDark));
}

class MyApp extends StatefulWidget {
  final bool isDark;
  const MyApp({super.key, required this.isDark});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isDark = widget.isDark;

  Future<void> _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _isDark = !_isDark);
    await prefs.setBool('darkMode', _isDark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Personal Mileage Tracker',
      theme: _isDark ? ThemeData.dark() : ThemeData.light(),
      home: HomeScreen(
        isDark: _isDark,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const HomeScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);

  //API Controller
  final ApiService _api = ApiService();

  // Mileage controllers
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();

  // Maintenance controllers
  final _typeCtrl = TextEditingController();
  final _costCtrl = TextEditingController();

  bool _submitting = false;

  int get _miles {
    final s = int.tryParse(_startCtrl.text.trim()) ?? 0;
    final e = int.tryParse(_endCtrl.text.trim()) ?? 0;
    final m = e - s;
    return m > 0 ? m : 0;
  }

  double get _amount {
    return double.tryParse(_amountCtrl.text.trim()) ?? 0.0;
  }

  double get _perMile {
    final m = _miles;
    if (m <= 0) return 0;
    return _amount / m;
  }

  Future<void> _submitMileage() async {
    final s = int.tryParse(_startCtrl.text.trim());
    final e = int.tryParse(_endCtrl.text.trim());
    final amount = double.tryParse(_amountCtrl.text.trim());

    if (s == null || e == null || e <= s) {
      _toast('Enter valid start/end mileage.');
      return;
    }
    if (amount == null || amount < 0) {
      _toast('Enter a valid Amount Made.');
      return;
    }

    final miles = e - s;

    setState(() => _submitting = true);
    try {
      // Send an ISO date (Apps Script can parse it)
      final now = DateTime.now();
      final dateStr = DateTime(now.year, now.month, now.day).toIso8601String();

      await _api.submitMileage(
        date: dateStr,
        startMileage: s,
        endMileage: e,
        miles: miles,
        amountMade: amount,
      );

      _toast('Mileage submitted: $miles mi, \$${amount.toStringAsFixed(2)}');
      _startCtrl.clear();
      _endCtrl.clear();
      _amountCtrl.clear();
      setState(() {});
    } catch (e) {
      _toast('Submit error: $e');
    } finally {
      setState(() => _submitting = false);
    }
  }

  Future<void> _submitMaintenance() async {
    final type = _typeCtrl.text.trim();
    final cost = double.tryParse(_costCtrl.text.trim());

    if (type.isEmpty) {
      _toast('Enter a maintenance type.');
      return;
    }
    if (cost == null || cost <= 0) {
      _toast('Enter a valid cost.');
      return;
    }

    setState(() => _submitting = true);
    try {
      final now = DateTime.now();
      final dateStr = DateTime(now.year, now.month, now.day).toIso8601String();

      await _api.submitMaintenance(
        date: dateStr,
        type: type,
        cost: cost,
      );

      _toast(
          'Maintenance submitted: ${type.toUpperCase()} \$${cost.toStringAsFixed(2)}');
      _typeCtrl.clear();
      _costCtrl.clear();
      setState(() {});
    } catch (e) {
      _toast('Submit error: $e');
    } finally {
      setState(() => _submitting = false);
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  @override
  void dispose() {
    _tabs.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    _amountCtrl.dispose();
    _typeCtrl.dispose();
    _costCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final submitGreen = const Color(0xFF28DB10);
    final clearRed = const Color(0xFFCF2A2A);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mileage Tracker'),
        actions: [
          IconButton(
            tooltip: 'Dashboard',
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => PinGate(
                  onUnlocked: () {
                    Navigator.pop(context); // close PIN dialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DashboardScreen(),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Toggle theme',
            onPressed: widget.onToggleTheme,
            icon: Icon(widget.isDark ? Icons.dark_mode : Icons.light_mode),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Mileage'),
            Tab(text: 'Maintenance'),
          ],
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabs,
            children: [
              // Mileage tab
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextField(
                    controller: _startCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Starting Mileage',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _endCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Ending Mileage',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _amountCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Amount Made (\$)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),

                  // Preview row
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Miles: $_miles'),
                          Text(
                              '\$/mile: ${_miles == 0 ? '--' : _perMile.toStringAsFixed(2)}'),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: clearRed,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _submitting
                              ? null
                              : () {
                                  _startCtrl.clear();
                                  _endCtrl.clear();
                                  _amountCtrl.clear();
                                  setState(() {});
                                },
                          child: const Text('Clear'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: submitGreen,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _submitting ? null : _submitMileage,
                          child: const Text('Submit'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Maintenance tab
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextField(
                    controller: _typeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _costCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Cost (\$)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: clearRed,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _submitting
                              ? null
                              : () {
                                  _typeCtrl.clear();
                                  _costCtrl.clear();
                                },
                          child: const Text('Clear'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: submitGreen,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _submitting ? null : _submitMaintenance,
                          child: const Text('Submit'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          if (_submitting)
            Container(
              color: Colors.black.withOpacity(0.15),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
