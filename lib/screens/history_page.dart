import 'package:flutter/material.dart';

import '../models/device.dart';
import '../models/history.dart';
import '../models/sample_data.dart';
import '../navigation.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/app_card.dart';
import '../widgets/headers.dart';
import '../widgets/info_widgets.dart';
import '../widgets/responsive_grid.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= kTabletWidth;

    // Left side: health per device and alerts
    final Widget healthSection = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionTitle('Battery health by device'),
        HealthHistoryCard(
          device: kPhone,
          onTap: () => openDetail(context, kPhone),
        ),
        const SizedBox(height: 12),
        HealthHistoryCard(
          device: kTablet,
          onTap: () => openDetail(context, kTablet),
        ),
        const SectionTitle('Alerts'),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Column(
            children: [
              for (int i = 0; i < kAlerts.length; i++)
                AlertRow(alert: kAlerts[i], showDivider: i > 0),
            ],
          ),
        ),
      ],
    );

    // Right side: recent charges
    final Widget chargesSection = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionTitle('Recent charges'),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Column(
            children: [
              for (int i = 0; i < kSessions.length; i++)
                SessionRow(session: kSessions[i], showDivider: i > 0),
            ],
          ),
        ),
      ],
    );

    return ListView(
      padding: pagePadding(context),
      children: [
        const PageHeader(
          title: 'History',
          subtitle: 'Last 30 days, all devices',
        ),
        const SizedBox(height: 20),

        // Summary numbers: 2 per row, or 4 per row when there is room
        const ResponsiveGrid(
          columnOptions: [2, 4],
          minItemWidth: 110,
          gap: 8,
          children: [
            StatTile(label: 'Charges', value: '24', background: kCard),
            StatTile(
              label: 'Avg. charge time',
              value: '1 h 21 min',
              background: kCard,
            ),
            StatTile(label: 'Lowest level', value: '18%', background: kCard),
            StatTile(label: 'Alerts', value: '3', background: kCard),
          ],
        ),

        // Tablet: two columns next to each other
        if (wide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: healthSection),
              const SizedBox(width: 12),
              Expanded(child: chargesSection),
            ],
          ),

        // Phone: one column
        if (!wide) ...[healthSection, chargesSection],
      ],
    );
  }
}

// Card with the health of one device: 12 months ago, 6 months ago and now.
class HealthHistoryCard extends StatelessWidget {
  final Device device;
  final VoidCallback onTap;

  const HealthHistoryCard({
    super.key,
    required this.device,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(device.icon, color: kMuted, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  device.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                healthLabel(device.health),
                style: TextStyle(
                  color: healthColor(device.health),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Icon(Icons.chevron_right, color: kMuted),
            ],
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
          const SizedBox(height: 10),
          Text(
            'Down ${device.healthDrop} points in 12 months, '
            '${device.capacityText}',
            style: const TextStyle(color: kMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// One row in "Recent charges".
class SessionRow extends StatelessWidget {
  final ChargeSession session;
  final bool showDivider;

  const SessionRow({
    super.key,
    required this.session,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: showDivider
          ? const BoxDecoration(
              border: Border(top: BorderSide(color: kBorder)),
            )
          : null,
      child: Row(
        children: [
          const Icon(Icons.bolt, color: kAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.deviceName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  session.when,
                  style: const TextStyle(color: kMuted, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                session.range,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                session.duration,
                style: const TextStyle(color: kMuted, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// One row in "Alerts".
class AlertRow extends StatelessWidget {
  final AlertEvent alert;
  final bool showDivider;

  const AlertRow({super.key, required this.alert, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: showDivider
          ? const BoxDecoration(
              border: Border(top: BorderSide(color: kBorder)),
            )
          : null,
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: kAmber, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert.text, style: const TextStyle(fontSize: 15)),
                const SizedBox(height: 2),
                Text(
                  alert.when,
                  style: const TextStyle(color: kMuted, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
