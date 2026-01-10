import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/app_buttons.dart';

class DashboardGatePage extends StatefulWidget {
  final VoidCallback onUnlocked;
  const DashboardGatePage({super.key, required this.onUnlocked});

  @override
  State<DashboardGatePage> createState() => _DashboardGatePageState();
}

class _DashboardGatePageState extends State<DashboardGatePage> {
  static const String _pin = '5609';

  final _c1 = TextEditingController();
  final _c2 = TextEditingController();
  final _c3 = TextEditingController();
  final _c4 = TextEditingController();

  late final _f1 = FocusNode();
  late final _f2 = FocusNode();
  late final _f3 = FocusNode();
  late final _f4 = FocusNode();

  String get _entered => '${_c1.text}${_c2.text}${_c3.text}${_c4.text}';

  void _clearAll({bool focusFirst = true}) {
    _c1.clear();
    _c2.clear();
    _c3.clear();
    _c4.clear();
    if (focusFirst) _f1.requestFocus();
    setState(() {});
  }

  void _closeKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  Future<void> _unlock() async {
    _closeKeyboard();

    if (_entered == _pin) {
      _clearAll(focusFirst: false);
      widget.onUnlocked();
    } else {
      await _vibrateError(); // ✅ REAL vibration

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Incorrect PIN')));
      _clearAll();
    }
  }

  Future<void> _vibrateError() async {
    // stronger than lightImpact; good “wrong pin” feedback
    await HapticFeedback.heavyImpact();
  }

  void _handlePaste(String v) {
    final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 4) return;

    _c1.text = digits[0];
    _c2.text = digits[1];
    _c3.text = digits[2];
    _c4.text = digits[3];
    setState(() {});
    _unlock();
  }

  Widget _box({
    required TextEditingController controller,
    required FocusNode node,
    required FocusNode? next,
    required FocusNode? prev,
    required int index,
  }) {
    return SizedBox(
      width: 56,
      child: Focus(
        onKeyEvent: (focusNode, event) {
          // Backspace on empty -> go to previous box
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace &&
              controller.text.isEmpty &&
              prev != null) {
            prev.requestFocus();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: TextField(
          controller: controller,
          focusNode: node,
          autofocus: index == 0,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          textInputAction:
              (index == 3) ? TextInputAction.done : TextInputAction.next,
          obscureText: true,
          maxLength: 1,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1),
          ],
          decoration: InputDecoration(
            counterText: '',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onChanged: (v) {
            // paste support (e.g. user long-press paste "5609")
            if (v.length > 1) {
              _handlePaste(v);
              return;
            }

            if (v.isNotEmpty) {
              if (next != null) {
                next.requestFocus();
              } else {
                // last box filled
                setState(() {});
                _unlock();
              }
            } else {
              // cleared
              setState(() {});
            }
          },
          onSubmitted: (_) {
            if (index == 3) _unlock();
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _c1.dispose();
    _c2.dispose();
    _c3.dispose();
    _c4.dispose();
    _f1.dispose();
    _f2.dispose();
    _f3.dispose();
    _f4.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min, // good for dialog
        children: [
          const SizedBox(height: 8),
          const Text(
            'Dashboard Access',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _box(controller: _c1, node: _f1, next: _f2, prev: null, index: 0),
              const SizedBox(width: 10),
              _box(controller: _c2, node: _f2, next: _f3, prev: _f1, index: 1),
              const SizedBox(width: 10),
              _box(controller: _c3, node: _f3, next: _f4, prev: _f2, index: 2),
              const SizedBox(width: 10),
              _box(controller: _c4, node: _f4, next: null, prev: _f3, index: 3),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: AppButtons.red(),
              onPressed: _entered.length == 4 ? _unlock : null,
              child: const Text('Unlock'),
            ),
          ),
          TextButton(
            onPressed: _clearAll,
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
