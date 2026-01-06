import 'package:flutter/material.dart';

class PinGate extends StatefulWidget {
  final VoidCallback onUnlocked;
  const PinGate({super.key, required this.onUnlocked});

  @override
  State<PinGate> createState() => _PinGateState();
}

class _PinGateState extends State<PinGate> {
  static const String adminPin = '5609';
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _unlock() {
    if (_controller.text.trim() == adminPin) {
      widget.onUnlocked();
    } else {
      setState(() => _error = 'Incorrect PIN');
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Dashboard Access'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Enter PIN'),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 4,
            onSubmitted: (_) => _unlock(),
            textAlign: TextAlign.center,
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close')),
        ElevatedButton(onPressed: _unlock, child: const Text('Unlock')),
      ],
    );
  }
}
