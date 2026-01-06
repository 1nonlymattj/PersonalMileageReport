import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api.dart';
import '../utils/cache_keys.dart';
import '../utils/date_utils.dart';
import '../widgets/app_buttons.dart';

class MileagePage extends StatefulWidget {
  const MileagePage({super.key});

  @override
  State<MileagePage> createState() => _MileagePageState();
}

class _MileagePageState extends State<MileagePage> {
  final _api = ApiService();

  final startCtrl = TextEditingController();
  final endCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadCache();
    startCtrl.addListener(_saveCache);
    endCtrl.addListener(_saveCache);
    amountCtrl.addListener(_saveCache);
  }

  Future<void> _loadCache() async {
    final sp = await SharedPreferences.getInstance();
    startCtrl.text = sp.getString(CacheKeys.mileageStart) ?? '';
    endCtrl.text = sp.getString(CacheKeys.mileageEnd) ?? '';
    amountCtrl.text = sp.getString(CacheKeys.mileageAmount) ?? '';
    setState(() {});
  }

  Future<void> _saveCache() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(CacheKeys.mileageStart, startCtrl.text);
    await sp.setString(CacheKeys.mileageEnd, endCtrl.text);
    await sp.setString(CacheKeys.mileageAmount, amountCtrl.text);
  }

  Future<void> _clearCache() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(CacheKeys.mileageStart);
    await sp.remove(CacheKeys.mileageEnd);
    await sp.remove(CacheKeys.mileageAmount);
  }

  int get miles {
    final s = int.tryParse(startCtrl.text.trim()) ?? 0;
    final e = int.tryParse(endCtrl.text.trim()) ?? 0;
    return e - s;
  }

  double get amount => double.tryParse(amountCtrl.text.trim()) ?? 0;

  Color perMileColor(double v) {
    if (v >= 2.0) return Colors.green;
    if (v >= 1.25) return Colors.amber;
    return Colors.red;
  }

  Future<void> submit() async {
    final s = int.tryParse(startCtrl.text.trim());
    final e = int.tryParse(endCtrl.text.trim());
    final m = miles;
    final a = amount;

    if (s == null || e == null || m <= 0) {
      _snack('Enter valid starting/ending mileage.');
      return;
    }
    if (a < 0.01) {
      _snack('Enter Amount Made.');
      return;
    }

    final dateYmd = DateUtilsX.ymd(DateTime.now()); // YYYY-MM-DD

    setState(() => loading = true);
    try {
      await _api.submitMileage(
        date: dateYmd,
        startMileage: s,
        endMileage: e,
        miles: m,
        amountMade: a,
      );

      final pm = a / m;
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Thank You'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$m miles submitted for ${DateUtilsX.displayToday()}.'),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Amount Made:'),
                Text('\$${a.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.blue)),
              ]),
              const SizedBox(height: 6),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('\$/Mile:'),
                Text('\$${pm.toStringAsFixed(2)}',
                    style: TextStyle(
                        fontWeight: FontWeight.w900, color: perMileColor(pm))),
              ]),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                  backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );

      startCtrl.clear();
      endCtrl.clear();
      amountCtrl.clear();
      await _clearCache();
      setState(() {});
    } catch (e) {
      _snack('Submit failed: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void clear() async {
    startCtrl.clear();
    endCtrl.clear();
    amountCtrl.clear();
    await _clearCache();
    setState(() {});
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final m = miles;
    final a = amount;
    final pm = (m > 0 && a > 0) ? (a / m) : 0.0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: startCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Starting Mileage'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: endCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Ending Mileage'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Amount Made (\$)'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Miles: ${m > 0 ? m : 0}',
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              if (m > 0 && a > 0)
                Text('\$${pm.toStringAsFixed(2)}/mi',
                    style: TextStyle(
                        fontWeight: FontWeight.w900, color: perMileColor(pm))),
            ],
          ),
          const Spacer(),
          if (loading) const CircularProgressIndicator(),
          if (!loading)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: AppButtons.red(),
                    onPressed: clear,
                    child: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: AppButtons.green(),
                    onPressed: submit,
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
