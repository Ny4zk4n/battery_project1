import 'package:flutter/material.dart';

import '../theme.dart';
import '../utils.dart';

// A simple horizontal bar. value goes from 0.0 to 1.0.
class ProgressBar extends StatelessWidget {
  final double value;
  final Color color;

  const ProgressBar({super.key, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        height: 8,
        color: kBorder,
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          // clamp keeps the bar inside 0..1 even with odd values
          widthFactor: value.clamp(0.0, 1.0).toDouble(),
          child: Container(color: color),
        ),
      ),
    );
  }
}

// Big battery health number with its label and capacity text.
class HealthBlock extends StatelessWidget {
  final int percent;
  final String capacityText;
  final String estimateText;

  const HealthBlock({
    super.key,
    required this.percent,
    required this.capacityText,
    required this.estimateText,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = healthColor(percent);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Battery health',
          style: TextStyle(color: kMuted, fontSize: 13),
        ),
        const SizedBox(height: 4),
        // Wrap moves the label under the number if there is no room.
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 4,
          children: [
            Text(
              '$percent%',
              style: TextStyle(
                color: color,
                fontSize: 56,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color),
              ),
              child: Text(
                healthLabel(percent),
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(capacityText, style: const TextStyle(fontSize: 15)),
        const SizedBox(height: 2),
        Text(estimateText, style: const TextStyle(color: kMuted, fontSize: 13)),
      ],
    );
  }
}

// "Charge 78%" with a bar and a status line under it.
// The bolt icon is only shown while charging.
class ChargeBlock extends StatelessWidget {
  final int percent;
  final String statusText;
  final bool charging;

  const ChargeBlock({
    super.key,
    required this.percent,
    required this.statusText,
    required this.charging,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('Charge', style: TextStyle(fontSize: 15)),
            ),
            if (charging) const Icon(Icons.bolt, color: kAccent, size: 18),
            Text(
              '$percent%',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ProgressBar(value: percent / 100, color: kAccent),
        const SizedBox(height: 8),
        Text(statusText, style: const TextStyle(color: kMuted, fontSize: 13)),
      ],
    );
  }
}
