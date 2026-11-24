import 'package:flutter/material.dart';

import '../theme.dart';

// A row of buttons where exactly one is selected,
// for example Phone / Tablet / Laptop / Earbuds.
class ChoiceButtons extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  const ChoiceButtons({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  Widget buildButton(String option) {
    final bool isSelected = option == selected;

    return Material(
      color: kCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? kAccent : kBorder,
          width: isSelected ? 2 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onSelected(option),
        child: SizedBox(
          height: 44,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              // FittedBox shrinks the text on very narrow screens
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? kAccent : kText,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < options.length; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: i == 0 ? 0 : 8),
              child: buildButton(options[i]),
            ),
          ),
      ],
    );
  }
}
