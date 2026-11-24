import 'package:flutter/material.dart';
import '../models/sample_data.dart';
import '../navigation.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/app_card.dart';
import '../widgets/battery_blocks.dart';
import '../widgets/headers.dart';
import '../widgets/info_widgets.dart';
import '../widgets/responsive_grid.dart';

class DevicesPage extends StatelessWidget {
  const DevicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // true on tablets and other wide screens
    final bool wide = MediaQuery.sizeOf(context).width >= kTabletWidth;

    // The three parts of the "This phone" card
    final Widget health = HealthBlock(
      percent: kPhone.health,
      capacityText: kPhone.capacityText,
      estimateText: kPhone.estimateText,
    );
    final Widget charge = ChargeBlock(
      percent: kPhone.chargePercent,
      statusText: kPhone.statusText,
      charging: kPhone.charging,
    );
    final Widget tiles = Row(
      children: [
        Expanded(
          child: StatTile(label: 'Power', value: kPhone.power),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatTile(label: 'Temperature', value: kPhone.temperature),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatTile(label: 'Cycles', value: kPhone.cycles),
        ),
      ],
    );

    // The three "Other devices" cards
    final Widget tabletCard = AppCard(
      onTap: () => openDetail(context, kTablet),
      child: Row(
        children: [
          Icon(kTablet.icon, color: kMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  kTablet.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Health ${kTablet.health}% · ${healthLabel(kTablet.health)}',
                  style: TextStyle(
                    color: healthColor(kTablet.health),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  kTablet.statusText,
                  style: const TextStyle(color: kMuted, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${kTablet.chargePercent}%',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Icon(Icons.chevron_right, color: kMuted),
        ],
      ),
    );

    const Widget laptopCard = AppCard(
      child: Row(
        children: [
          Icon(Icons.laptop, color: kMuted),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Laptop',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(
                  'No data yet, waiting for first sync',
                  style: TextStyle(color: kMuted, fontSize: 13),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.sync, color: kMuted, size: 20),
        ],
      ),
    );

    const Widget earbudsCard = AppCard(
      child: Row(
        children: [
          Icon(Icons.headphones, color: kMuted),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Earbuds',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(
                  'Low battery',
                  style: TextStyle(color: kAmber, fontSize: 13),
                ),
                SizedBox(height: 2),
                Text(
                  'Health not available',
                  style: TextStyle(color: kMuted, fontSize: 13),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          Text(
            '18%',
            style: TextStyle(
              color: kAmber,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

    return ListView(
      padding: pagePadding(context),
      children: [
        // Header with the + button
        PageHeader(
          title: 'Batteries',
          subtitle: '4 devices, 2 reporting',
          trailing: Container(
            decoration: BoxDecoration(
              color: kCard,
              shape: BoxShape.circle,
              border: Border.all(color: kBorder),
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: kAccent),
              tooltip: 'Add device',
              onPressed: () => openAddDevice(context),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // "This phone" card
        AppCard(
          onTap: () => openDetail(context, kPhone),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(kPhone.icon, color: kMuted, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      kPhone.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: kMuted),
                ],
              ),
              const SizedBox(height: 14),

              // Tablet: health on the left, charge on the right.
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: health),
                    const SizedBox(width: 24),
                    Expanded(child: charge),
                  ],
                ),

              // Phone: health and charge under each other.
              if (!wide) ...[
                health,
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: kDivider,
                ),
                charge,
              ],

              // The three stat tiles use the full width of the card.
              const SizedBox(height: 14),
              tiles,
            ],
          ),
        ),

        // Other devices: 1 card per row on phones, 2 or 3 when wider
        const SectionTitle('Other devices'),
        ResponsiveGrid(
          minItemWidth: 260,
          children: [tabletCard, laptopCard, earbudsCard],
        ),
      ],
    );
  }
}
