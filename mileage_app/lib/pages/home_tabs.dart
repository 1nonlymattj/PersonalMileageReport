import 'package:flutter/material.dart';
import 'mileage_page.dart';
import 'maintenance_page.dart';
import 'dashboard_gate_page.dart';

class HomeTabs extends StatefulWidget {
  const HomeTabs({super.key});

  @override
  State<HomeTabs> createState() => _HomeTabsState();
}

class _HomeTabsState extends State<HomeTabs> {
  int idx = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const [
      MileagePage(),
      MaintenancePage(),
      DashboardGatePage(),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Personal Mileage Tracker')),
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
