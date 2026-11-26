import 'package:flutter/material.dart';
import '../battery_service.dart';
import '../models/battery_info.dart';
class BatteryTest extends StatefulWidget {
  const BatteryTest({super.key});

  @override
  State<BatteryTest> createState() => _BatteryTestState();
}

class _BatteryTestState extends State<BatteryTest> {
  String text = 'Not checked yet';

  Future<void> checkBattery() async {
    final BatteryInfo? info = await BatteryService().getBatteryInfo();

    if (!mounted) return;

    setState(() {
      if (info == null) {
        text = 'Battery level could not be determined';
      } else {
        text = 'Battery level: ${info.level ?? 'Unknown'}%\n'
            'Temperature: ${info.temperature?.toStringAsFixed(1) ?? 'Unknown'}°C\n'
            'Voltage: ${info.voltage?.toStringAsFixed(2) ?? 'Unknown'}V\n'
            'Status: ${info.statusText ?? 'Unknown'}';
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