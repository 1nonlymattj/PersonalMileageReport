import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api.dart';
import '../utils/cache_keys.dart';
import '../utils/date_utils.dart';
import '../widgets/app_buttons.dart';

class MaintenancePage extends StatefulWidget {
  const MaintenancePage({super.key});

  @override
  State<MaintenancePage> createState() => _MaintenancePageState();
}

class _MaintenancePageState extends State<MaintenancePage> {
  final _api = ApiService();

  final typeCtrl = TextEditingController();
  final costCtrl = TextEditingController();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadCache();
    typeCtrl.addListener(_saveCache);
    costCtrl.addListener(_saveCache);
  }

  Future<void> _loadCache() async {
    final sp = await SharedPreferences.getInstance();
    typeCtrl.text = sp.getString(CacheKeys.maintType) ?? '';
    costCtrl.text = sp.getString(CacheKeys.maintCost) ?? '';
    setState(() {});
  }

  Future<void> _saveCache() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(CacheKeys.maintType, typeCtrl.text);
    await sp.setString(CacheKeys.maintCost, costCtrl.text);
  }

  Future<void> _clearCache() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(CacheKeys.maintType);
    await sp.remove(CacheKeys.maintCost);
  }

  Future<void> submit() async {
    final type = typeCtrl.text.trim();
    final cost = double.tryParse(costCtrl.text.trim()) ?? 0;
    if (type.isEmpty || cost <= 0) {
      _snack('Enter type and cost.');
      return;
    }

    final dateYmd = DateUtilsX.ymd(DateTime.now()); // YYYY-MM-DD

    setState(() => loading = true);
    try {
      await _api.submitMaintenance(
        date: dateYmd,
        type: type,
        cost: cost,
      );

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Thank You'),
          content: Text(
              '${type.toUpperCase()} : \$${cost.toStringAsFixed(2)} submitted for ${DateUtilsX.displayToday()}.'),
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

      typeCtrl.clear();
      costCtrl.clear();
      await _clearCache();
    } catch (e) {
      _snack('Submit failed: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void clear() async {
    typeCtrl.clear();
    costCtrl.clear();
    await _clearCache();
    setState(() {});
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
              controller: typeCtrl,
              decoration: const InputDecoration(labelText: 'Type')),
          const SizedBox(height: 10),
          TextField(
              controller: costCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Cost (\$)')),
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
