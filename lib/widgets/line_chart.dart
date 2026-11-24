import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme.dart';

// A line chart with labels on the left and under it.
// values are drawn between minY (bottom) and maxY (top).
// If markerValue is given, a thin amber line is drawn at that value.
class LineChart extends StatelessWidget {
  final List<double> values;
  final double minY;
  final double maxY;
  final Color color;
  final List<String> yLabels; // from top to bottom
  final List<String> xLabels; // from left to right
  final double? markerValue;

  const LineChart({
    super.key,
    required this.values,
    required this.minY,
    required this.maxY,
    required this.color,
    required this.yLabels,
    required this.xLabels,
    this.markerValue,
  });

  @override
  Widget build(BuildContext context) {
    const TextStyle labelStyle = TextStyle(color: kMuted, fontSize: 11);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Labels on the left (as wide as the text needs)
        SizedBox(
          height: 140,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final String label in yLabels)
                Text(label, style: labelStyle),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // The chart with its labels under it
        Expanded(
          child: Column(
            children: [
              SizedBox(
                height: 140,
                width: double.infinity,
                child: CustomPaint(
                  painter: LineChartPainter(
                    values: values,
                    minY: minY,
                    maxY: maxY,
                    color: color,
                    markerValue: markerValue,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // First label on the left, last on the right,
                  // the others centered.
                  for (int i = 0; i < xLabels.length; i++)
                    Expanded(
                      child: Text(
                        xLabels[i],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: i == 0
                            ? TextAlign.left
                            : (i == xLabels.length - 1
                                  ? TextAlign.right
                                  : TextAlign.center),
                        style: labelStyle,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Does the drawing for LineChart.
class LineChartPainter extends CustomPainter {
  final List<double> values;
  final double minY;
  final double maxY;
  final Color color;
  final double? markerValue;

  LineChartPainter({
    required this.values,
    required this.minY,
    required this.maxY,
    required this.color,
    this.markerValue,
  });

  // Turns a value into a y position on the canvas.
  double yFor(double value, Size size) {
    return size.height * (1 - (value - minY) / (maxY - minY));
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Grid lines at top, middle and bottom
    final Paint gridPaint = Paint()
      ..color = kBorder
      ..strokeWidth = 1;
    for (int i = 0; i <= 2; i++) {
      final double y = size.height * i / 2;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // A line needs at least 2 values and a real range. Otherwise stop here.
    if (values.length < 2 || maxY <= minY) return;

    // Nothing may be drawn far outside the chart, for example when a value
    // is below minY. The 5 px extra leaves room for the dot at the end.
    canvas.clipRect((Offset.zero & size).inflate(5));

    // Optional amber marker line
    if (markerValue != null) {
      final Paint markerPaint = Paint()
        ..color = kAmber
        ..strokeWidth = 1;
      final double y = yFor(markerValue!, size);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), markerPaint);
    }

    // Turn each value into a point on the canvas.
    // The line ends 5 px before the right edge so the last dot fits.
    final double lineWidth = size.width - 5;
    final List<Offset> points = [];
    for (int i = 0; i < values.length; i++) {
      final double x = lineWidth * i / (values.length - 1);
      points.add(Offset(x, yFor(values[i], size)));
    }

    // Line through the points
    final Path linePath = Path();
    linePath.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }

    // Soft fill under the line
    final Path fillPath = Path.from(linePath);
    fillPath.lineTo(lineWidth, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();
    final Paint fillPaint = Paint()
      ..color = color.withAlpha(34)
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    final Paint linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(linePath, linePaint);

    // Dot at the newest value
    final Paint dotPaint = Paint()..color = color;
    canvas.drawCircle(points.last, 4, dotPaint);
  }

  // Only repaint when something really changed.
  @override
  bool shouldRepaint(covariant LineChartPainter oldDelegate) {
    return !listEquals(oldDelegate.values, values) ||
        oldDelegate.minY != minY ||
        oldDelegate.maxY != maxY ||
        oldDelegate.color != color ||
        oldDelegate.markerValue != markerValue;
  }
}
