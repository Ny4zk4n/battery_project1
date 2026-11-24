import 'package:flutter/material.dart';
import '../battery_service.dart';

class BatteryTest extends StatefulWidget {
  const BatteryTest({super.key});

  @override
  State<BatteryTest> createState() => _BatteryTestState();
}

class _BatteryTestState extends State<BatteryTest> {
  String text = 'Not checked yet';

  Future<void> checkBattery() async {
    final int? level = await BatteryService().getBatteryLevel();

    if (!mounted) return;

    setState(() {
      if (level == null) {
        text = 'Battery level could not be determined';
      } else {
        text = 'Battery level is $level%';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(text),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: checkBattery,
          child: const Text('Check Battery Level'),
        ),
      ],
    );  
  }
}