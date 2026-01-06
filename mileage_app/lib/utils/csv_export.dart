import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/dashboard_models.dart';

class CsvExport {
  static Future<void> exportDashboardToCsv(DashboardData data) async {
    final rows = <List<dynamic>>[];

    rows.add(['Mileage Summary']);
    rows.add(['Date', 'Miles', 'Amount Made', 'Per Mile']);
    for (final r in data.mileage) {
      rows.add([
        r.date,
        r.miles,
        r.amount.toStringAsFixed(2),
        r.perMile.toStringAsFixed(2)
      ]);
    }

    rows.add([]);
    rows.add(['Monthly Totals']);
    rows.add(['Month', 'Miles', 'Amount Made', 'Per Mile']);
    for (final r in data.monthly) {
      rows.add([
        r.label,
        r.miles,
        r.amount.toStringAsFixed(2),
        r.perMile.toStringAsFixed(2)
      ]);
    }

    rows.add([]);
    rows.add(['Maintenance & Repairs']);
    rows.add(['Date', 'Type', 'Cost']);
    for (final r in data.maintenance) {
      rows.add(
          [r.date, r.type, (-r.cost).toStringAsFixed(2)]); // export as negative
    }

    final csv = const ListToCsvConverter().convert(rows);

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/pmr_dashboard_export.csv');
    await file.writeAsString(csv);

    await Share.shareXFiles([XFile(file.path)], text: 'PMR Dashboard Export');
  }
}
