import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final bool isDarkMode;

  const SettingsScreen(
      {super.key, required this.onThemeChanged, required this.isDarkMode});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
  }

  void _toggleTheme(bool value) {
    setState(() {
      _isDarkMode = value;
    });
    widget.onThemeChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: Text('Dark Mode'),
              trailing: Switch(
                value: _isDarkMode,
                onChanged: _toggleTheme,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ThemePreferences {
  static const String _themeKey = "themeMode";

  static Future<void> setTheme(bool isDark) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }

  static Future<bool> getTheme() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_themeKey) ?? false;
    } catch (e) {
      return false; // Default to light mode if an error occurs
    }
  }
}
