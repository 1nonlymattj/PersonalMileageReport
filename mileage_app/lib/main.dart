import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/home_tabs.dart';
import 'services/reminders.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initNotifications();
  await initWorkmanager();

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

  Future<void> toggleTheme() async {
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
      home: HomeTabs(
        isDark: _isDark,
        onToggleTheme: toggleTheme,
      ),
    );
  }
}
