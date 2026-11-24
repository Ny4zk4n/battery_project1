import 'package:flutter/material.dart';

import '../theme.dart';

// Small tile with a label and a value, for example "Power  +7.8 W".
// The text never overflows: the label is cut with "..." and the value
// shrinks a little when the tile is very narrow.
class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color background;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.background = kBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: kMuted, fontSize: 12),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// A small grey label with a bigger value under it (no box around it).
class LabelValue extends StatelessWidget {
  final String label;
  final String value;

  const LabelValue({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: kMuted, fontSize: 12),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// A label on the left and a value on the right, for lists inside a card.
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor = kMuted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 15))),
          const SizedBox(width: 12),
          Text(value, style: TextStyle(color: valueColor, fontSize: 15)),
        ],
      ),
    );
  }
}
