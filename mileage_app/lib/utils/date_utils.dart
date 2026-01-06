import 'package:intl/intl.dart';

class DateUtilsX {
  static String displayToday() =>
      DateFormat('MMMM d, yyyy').format(DateTime.now());
  static String ymd(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
}
