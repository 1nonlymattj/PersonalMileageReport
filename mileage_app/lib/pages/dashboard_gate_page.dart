import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import '../widgets/app_buttons.dart';

class DashboardGatePage extends StatefulWidget {
  const DashboardGatePage({super.key});

  @override
  State<DashboardGatePage> createState() => _DashboardGatePageState();
}

class _DashboardGatePageState extends State<DashboardGatePage> {
  final pinCtrl = TextEditingController();

  void unlock() {
    if (pinCtrl.text.trim() == '5609') {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const DashboardPage()));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Incorrect PIN')));
      pinCtrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 24),
          const Text('Dashboard Access',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          TextField(
            controller: pinCtrl,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 4,
            decoration: const InputDecoration(labelText: 'Enter PIN'),
            onSubmitted: (_) => unlock(),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
              style: AppButtons.red(),
              onPressed: unlock,
              child: const Text('Unlock')),
        ],
      ),
    );
  }
}
