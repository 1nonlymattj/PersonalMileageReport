import 'package:flutter/material.dart';

import 'mileage_page.dart';
import 'maintenance_page.dart';
import 'dashboard_gate_page.dart';
import 'dashboard_page.dart';

class HomeTabs extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const HomeTabs({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<HomeTabs> createState() => _HomeTabsState();
}

class _HomeTabsState extends State<HomeTabs> {
  int idx = 0;

  bool _dashboardUnlocked = false;

  @override
  Widget build(BuildContext context) {
    final pages = [
      MileagePage(),
      MaintenancePage(),
      _dashboardUnlocked
          ? const DashboardPage()
          : DashboardGatePage(
              onUnlocked: () => setState(() => _dashboardUnlocked = true),
            ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Mileage Tracker'),
        actions: [
          IconButton(
            tooltip: 'Toggle theme',
            icon: Icon(widget.isDark ? Icons.dark_mode : Icons.light_mode),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: pages[idx],
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (v) => setState(() => idx = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.route), label: 'Mileage'),
          NavigationDestination(icon: Icon(Icons.build), label: 'Maintenance'),
          NavigationDestination(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
        ],
      ),
    );
  }
}
