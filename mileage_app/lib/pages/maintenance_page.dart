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
    if (mounted) setState(() {});
  }

  Future<void> _saveCache() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(CacheKeys.maintType, typeCtrl.text);
    await sp.setString(CacheKeys.maintCost, costCtrl.text);

    await sp.setInt(
      CacheKeys.maintDraftTouchedAt,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<void> _clearCache() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(CacheKeys.maintType);
    await sp.remove(CacheKeys.maintCost);
    await sp.remove(CacheKeys.maintDraftTouchedAt);
    await sp.remove(CacheKeys.maintDraftLastRemindedAt);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> submit() async {
    final type = typeCtrl.text.trim();
    final cost = double.tryParse(costCtrl.text.trim());

    if (type.isEmpty) {
      _snack('Enter a maintenance type.');
      return;
    }
    if (cost == null || cost <= 0) {
      _snack('Enter a valid cost.');
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

      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Thank You'),
          content: Text(
            '${type.toUpperCase()} : \$${cost.toStringAsFixed(2)} submitted for ${DateUtilsX.displayToday()}.',
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

      typeCtrl.clear();
      costCtrl.clear();
      await _clearCache();

      if (mounted) setState(() {});
    } catch (e) {
      _snack('Submit failed: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> clear() async {
    typeCtrl.clear();
    costCtrl.clear();
    await _clearCache();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    typeCtrl.dispose();
    costCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom + 90;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: typeCtrl,
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: costCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Cost (\$)',
                border: OutlineInputBorder(),
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
