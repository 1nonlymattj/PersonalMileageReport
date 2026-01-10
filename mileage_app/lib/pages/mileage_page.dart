import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api.dart';
import '../utils/cache_keys.dart';
import '../utils/date_utils.dart';
import '../utils/per_mile_colors.dart';
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
    if (mounted) setState(() {});
  }

  Future<void> _saveCache() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(CacheKeys.mileageStart, startCtrl.text);
    await sp.setString(CacheKeys.mileageEnd, endCtrl.text);
    await sp.setString(CacheKeys.mileageAmount, amountCtrl.text);

    // mark draft touched (for reminders)
    await sp.setInt(
      CacheKeys.mileageDraftTouchedAt,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<void> _clearCache() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(CacheKeys.mileageStart);
    await sp.remove(CacheKeys.mileageEnd);
    await sp.remove(CacheKeys.mileageAmount);
    await sp.remove(CacheKeys.mileageDraftTouchedAt);
    await sp.remove(CacheKeys.mileageDraftLastRemindedAt);
  }

  int get miles {
    final s = int.tryParse(startCtrl.text.trim()) ?? 0;
    final e = int.tryParse(endCtrl.text.trim()) ?? 0;
    final m = e - s;
    return m > 0 ? m : 0;
  }

  double get amount => double.tryParse(amountCtrl.text.trim()) ?? 0;

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> submit() async {
    final s = int.tryParse(startCtrl.text.trim());
    final e = int.tryParse(endCtrl.text.trim());
    final m = miles;
    final a = amount;

    if (s == null || e == null) {
      _snack('Enter starting and ending mileage.');
      return;
    }
    if (e <= s) {
      _snack('Ending mileage must be greater than starting mileage.');
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

      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Thank You'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$m miles submitted for ${DateUtilsX.displayToday()}.'),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Amount Made:'),
                  Text(
                    '\$${a.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('\$/Mile:'),
                  Text(
                    '\$${pm.toStringAsFixed(2)}/mi',
                    style: PerMileColors.style(context, pm),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );

      // clear fields + cache
      startCtrl.clear();
      endCtrl.clear();
      amountCtrl.clear();
      await _clearCache();

      if (mounted) setState(() {});
    } catch (e) {
      _snack('Submit failed: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> clear() async {
    startCtrl.clear();
    endCtrl.clear();
    amountCtrl.clear();
    await _clearCache();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    startCtrl.dispose();
    endCtrl.dispose();
    amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = miles;
    final a = amount;
    final pm = (m > 0 && a > 0) ? (a / m) : 0.0;

    // keeps buttons above bottom nav + gesture bar
    final bottomPad = MediaQuery.of(context).padding.bottom + 90;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: startCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Starting Mileage',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: endCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Ending Mileage',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount Made (\$)',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Miles: ${m > 0 ? m : 0}',
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                    if (m > 0 && a > 0)
                      Text(
                        '\$${pm.toStringAsFixed(2)}/mi',
                        style: PerMileColors.style(context, pm),
                      )
                    else
                      const Text('\$/mi: --'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (loading) ...[
              const Center(child: CircularProgressIndicator()),
            ] else ...[
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
          ],
        ),
      ),
    );
  }
}
