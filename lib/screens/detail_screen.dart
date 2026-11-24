import 'package:flutter/material.dart';

import '../models/device.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/app_card.dart';
import '../widgets/battery_blocks.dart';
import '../widgets/info_widgets.dart';
import '../widgets/line_chart.dart';
import '../widgets/responsive_grid.dart';

class DetailScreen extends StatelessWidget {
  final Device device;

  const DetailScreen({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    // true on tablets and other wide screens
    final bool wide = MediaQuery.sizeOf(context).width >= kTabletWidth;

    const Widget gap = SizedBox(height: 12);

    // Card: health and charge
    final Widget healthCard = AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HealthBlock(
            percent: device.health,
            capacityText: device.capacityText,
            estimateText: device.estimateText,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: kDivider,
          ),
          ChargeBlock(
            percent: device.chargePercent,
            statusText: device.statusText,
            charging: device.charging,
          ),
        ],
      ),
    );

    // Card: charge level chart
    final Widget chargeChartCard = AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Charge level, last 24 hours',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          LineChart(
            values: device.chargeHistory,
            minY: 0,
            maxY: 100,
            color: kAccent,
            yLabels: const ['100%', '50%', '0%'],
            xLabels: const ['24 h ago', '12 h ago', 'Now'],
          ),
          const SizedBox(height: 10),
          Text(
            'Started at ${device.chargeHistory.first.round()}%, '
            'lowest ${device.lowestCharge.round()}%, '
            'now ${device.chargeHistory.last.round()}%',
            style: const TextStyle(color: kMuted, fontSize: 13),
          ),
        ],
      ),
    );

    // Four stat tiles: 2 per row, or 4 per row when there is room
    final Widget statTiles = ResponsiveGrid(
      columnOptions: const [2, 4],
      minItemWidth: 110,
      gap: 8,
      children: [
        StatTile(label: 'Power', value: device.power, background: kCard),
        StatTile(
          label: 'Temperature',
          value: device.temperature,
          background: kCard,
        ),
        StatTile(label: 'Current', value: device.current, background: kCard),
        StatTile(label: 'Voltage', value: device.voltage, background: kCard),
      ],
    );

    // Card: battery health over time, as values and as a chart
    final Widget healthChartCard = AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Battery health, last 12 months',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: LabelValue(
                  label: '12 mo ago',
                  value: '${device.healthYearAgo}%',
                ),
              ),
              Expanded(
                child: LabelValue(
                  label: '6 mo ago',
                  value: '${device.healthHalfYearAgo}%',
                ),
              ),
              Expanded(
                child: LabelValue(label: 'Now', value: '${device.health}%'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LineChart(
            values: device.healthHistory,
            minY: 80,
            maxY: 100,
            color: healthColor(device.health),
            yLabels: const ['100%', '90%', '80%'],
            xLabels: const ['12 mo ago', '6 mo ago', 'Now'],
            markerValue: 85,
          ),
          const SizedBox(height: 10),
          Text(
            'Down ${device.healthDrop} points in 12 months. '
            'Amber line: below 85% the battery counts as worn.',
            style: const TextStyle(color: kMuted, fontSize: 13),
          ),
        ],
      ),
    );

    // Card: the estimated health values, one row per charge
    final Widget healthValuesCard = AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estimated battery health, last ${device.records.length} charges',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            'Measured capacity compared with '
            '${formatNumber(device.designCapacity)} mAh when new',
            style: const TextStyle(color: kMuted, fontSize: 13),
          ),
          const SizedBox(height: 12),

          // Column titles
          const Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  'Date',
                  style: TextStyle(color: kMuted, fontSize: 12),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  'Capacity',
                  style: TextStyle(color: kMuted, fontSize: 12),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Health',
                  textAlign: TextAlign.right,
                  style: TextStyle(color: kMuted, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // One row per charge
          for (final ChargeRecord record in device.records)
            HealthValueRow(
              record: record,
              designCapacity: device.designCapacity,
            ),

          // Average (calculated from the rows above)
          Container(
            padding: const EdgeInsets.only(top: 10),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: kBorder)),
            ),
            child: Row(
              children: [
                const Expanded(
                  flex: 3,
                  child: Text(
                    'Average',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    '${formatNumber(device.averageCapacity)} mAh',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '${device.healthExact.toStringAsFixed(1)}%',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: healthColor(device.health),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // Card: power used per app. The longest bar belongs to the app
    // with the highest watts.
    double maxWatts = 0;
    for (final AppUsage app in device.apps) {
      if (app.watts > maxWatts) maxWatts = app.watts;
    }

    final Widget appsCard = AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Power used per app, 24 h',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          const Text(
            'Estimated while on screen',
            style: TextStyle(color: kMuted, fontSize: 13),
          ),
          for (final AppUsage app in device.apps)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: AppPowerRow(app: app, maxWatts: maxWatts),
            ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
        backgroundColor: kBg,
        foregroundColor: kText,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: pagePadding(context),
          children: [
            // Tablet: two columns next to each other.
            // Left: now and today. Right: battery health history.
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        healthCard,
                        gap,
                        statTiles,
                        gap,
                        chargeChartCard,
                        gap,
                        appsCard,
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [healthChartCard, gap, healthValuesCard],
                    ),
                  ),
                ],
              ),

            // Phone: one column
            if (!wide) ...[
              healthCard,
              gap,
              chargeChartCard,
              gap,
              statTiles,
              gap,
              healthChartCard,
              gap,
              healthValuesCard,
              gap,
              appsCard,
            ],
          ],
        ),
      ),
    );
  }
}

// One row in the health values list: date, capacity and health in percent.
class HealthValueRow extends StatelessWidget {
  final ChargeRecord record;
  final int designCapacity;

  const HealthValueRow({
    super.key,
    required this.record,
    required this.designCapacity,
  });

  @override
  Widget build(BuildContext context) {
    // Health = measured capacity compared with the capacity when new
    final double health = record.capacity / designCapacity * 100;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: kBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              record.date,
              style: const TextStyle(color: kMuted, fontSize: 14),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              '${formatNumber(record.capacity)} mAh',
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${health.toStringAsFixed(1)}%',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: healthColor(health.round()),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// One row in "Power used per app": name, screen time, watts and a bar.
class AppPowerRow extends StatelessWidget {
  final AppUsage app;
  final double maxWatts;

  const AppPowerRow({super.key, required this.app, required this.maxWatts});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                app.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '${app.watts.toStringAsFixed(1)} W avg',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          app.screenTime,
          style: const TextStyle(color: kMuted, fontSize: 13),
        ),
        const SizedBox(height: 8),
        ProgressBar(
          value: maxWatts > 0 ? app.watts / maxWatts : 0.0,
          color: kAccent,
        ),
      ],
    );
  }
}
