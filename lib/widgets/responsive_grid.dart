import 'package:flutter/material.dart';

// Puts its children in rows and picks the number of columns itself.
// It uses the biggest number from columnOptions where every item is still
// at least minItemWidth wide. Children in the same row get the same height.
// (Made for a handful of items. For long lists use GridView instead.)
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final List<int> columnOptions; // smallest first, for example [1, 2, 3]
  final double minItemWidth;
  final double gap;

  const ResponsiveGrid({
    super.key,
    required this.children,
    required this.minItemWidth,
    this.columnOptions = const [1, 2, 3],
    this.gap = 12,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // constraints.maxWidth is the space this grid really has.
        int columns = columnOptions.first;
        for (final int option in columnOptions) {
          final double itemWidth =
              (constraints.maxWidth - gap * (option - 1)) / option;
          if (itemWidth >= minItemWidth) columns = option;
        }

        return Column(
          children: [
            // One Row for every group of "columns" children
            for (int start = 0; start < children.length; start += columns)
              Padding(
                padding: EdgeInsets.only(top: start == 0 ? 0 : gap),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (int i = start; i < start + columns; i++) ...[
                        if (i > start) SizedBox(width: gap),
                        Expanded(
                          // Empty box when the last row is not full
                          child: i < children.length
                              ? children[i]
                              : const SizedBox(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
