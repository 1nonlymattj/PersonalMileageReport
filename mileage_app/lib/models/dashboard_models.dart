class MileageRow {
  final String date; // "January 5, 2026"
  final int miles;
  final double amount;
  final double perMile;

  MileageRow(
      {required this.date,
      required this.miles,
      required this.amount,
      required this.perMile});

  factory MileageRow.fromJson(Map<String, dynamic> j) => MileageRow(
        date: (j['date'] ?? '').toString(),
        miles: (j['miles'] ?? 0) is num
            ? (j['miles'] as num).round()
            : int.tryParse('${j['miles']}') ?? 0,
        amount: (j['amount'] ?? 0) is num
            ? (j['amount'] as num).toDouble()
            : double.tryParse('${j['amount']}') ?? 0,
        perMile: (j['perMile'] ?? 0) is num
            ? (j['perMile'] as num).toDouble()
            : double.tryParse('${j['perMile']}') ?? 0,
      );
}

class MonthlyRow {
  final String label; // "January 2026"
  final int miles;
  final double amount;
  final double perMile;

  MonthlyRow(
      {required this.label,
      required this.miles,
      required this.amount,
      required this.perMile});

  factory MonthlyRow.fromJson(Map<String, dynamic> j) => MonthlyRow(
        label: (j['label'] ?? '').toString(),
        miles: (j['miles'] ?? 0) is num
            ? (j['miles'] as num).round()
            : int.tryParse('${j['miles']}') ?? 0,
        amount: (j['amount'] ?? 0) is num
            ? (j['amount'] as num).toDouble()
            : double.tryParse('${j['amount']}') ?? 0,
        perMile: (j['perMile'] ?? 0) is num
            ? (j['perMile'] as num).toDouble()
            : double.tryParse('${j['perMile']}') ?? 0,
      );
}

class MaintenanceRow {
  final String date;
  final String type;
  final double cost;

  MaintenanceRow({required this.date, required this.type, required this.cost});

  factory MaintenanceRow.fromJson(Map<String, dynamic> j) => MaintenanceRow(
        date: (j['date'] ?? '').toString(),
        type: (j['type'] ?? '').toString(),
        cost: (j['cost'] ?? 0) is num
            ? (j['cost'] as num).toDouble()
            : double.tryParse('${j['cost']}') ?? 0,
      );
}

class DashboardData {
  final List<MileageRow> mileage;
  final List<MonthlyRow> monthly;
  final List<MaintenanceRow> maintenance;

  DashboardData(
      {required this.mileage,
      required this.monthly,
      required this.maintenance});

  factory DashboardData.fromJson(Map<String, dynamic> j) => DashboardData(
        mileage: ((j['mileage'] ?? []) as List)
            .map((e) => MileageRow.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        monthly: ((j['monthly'] ?? []) as List)
            .map((e) => MonthlyRow.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        maintenance: ((j['maintenance'] ?? []) as List)
            .map((e) => MaintenanceRow.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
}
