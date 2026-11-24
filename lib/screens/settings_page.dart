import 'package:flutter/material.dart';

import '../theme.dart';
import '../utils.dart';
import '../widgets/app_card.dart';
import '../widgets/choice_buttons.dart';
import '../widgets/headers.dart';
import '../widgets/info_widgets.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool lowBatteryAlert = true;
  String alertLevel = '20%';
  bool fullChargeAlert = false;
  bool temperatureAlert = true;
  String temperatureUnit = '°C';
  bool wifiOnly = true;

  // A switch with a title and a grey line under it.
  Widget buildSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontSize: 15)),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: kMuted, fontSize: 13),
      ),
      value: value,
      onChanged: onChanged,
    );
  }

  // Asks "are you sure?" before resetting. Nothing is really reset.
  void showResetDialog() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset health estimates?'),
          content: const Text(
            'The stored charges of all devices are deleted. '
            'New estimates need a few full charges.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: kMuted)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Reset', style: TextStyle(color: kRed)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= kTabletWidth;

    // Section: alerts
    final Widget alertsSection = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionTitle('Alerts'),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildSwitch(
                title: 'Low battery alert',
                subtitle: 'When a device drops below the level under this',
                value: lowBatteryAlert,
                onChanged: (value) {
                  setState(() {
                    lowBatteryAlert = value;
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: ChoiceButtons(
                  options: const ['10%', '15%', '20%', '30%'],
                  selected: alertLevel,
                  onSelected: (value) {
                    setState(() {
                      alertLevel = value;
                    });
                  },
                ),
              ),
              kDivider,
              buildSwitch(
                title: 'Full charge alert',
                subtitle: 'When a device reaches 100%',
                value: fullChargeAlert,
                onChanged: (value) {
                  setState(() {
                    fullChargeAlert = value;
                  });
                },
              ),
              kDivider,
              buildSwitch(
                title: 'High temperature alert',
                subtitle: 'When a battery gets hotter than 40 °C',
                value: temperatureAlert,
                onChanged: (value) {
                  setState(() {
                    temperatureAlert = value;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );

    // Section: sync
    final Widget syncSection = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionTitle('Sync'),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildSwitch(
                title: 'Sync over Wi-Fi only',
                subtitle: 'Other devices send their data on Wi-Fi',
                value: wifiOnly,
                onChanged: (value) {
                  setState(() {
                    wifiOnly = value;
                  });
                },
              ),
              kDivider,
              const InfoRow(label: 'Last sync', value: 'Today, 18:02'),
              kDivider,
              const InfoRow(label: 'Devices', value: '4 paired, 2 reporting'),
            ],
          ),
        ),
      ],
    );

    // Section: units
    final Widget unitsSection = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionTitle('Units'),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Temperature', style: TextStyle(fontSize: 15)),
              const SizedBox(height: 10),
              ChoiceButtons(
                options: const ['°C', '°F'],
                selected: temperatureUnit,
                onSelected: (value) {
                  setState(() {
                    temperatureUnit = value;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );

    // Section: how battery health is shown
    final Widget healthSection = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionTitle('Battery health'),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const InfoRow(
                label: 'Good',
                value: '85% and above',
                valueColor: kAccent,
              ),
              kDivider,
              const InfoRow(
                label: 'Worn',
                value: '70% to 84%',
                valueColor: kAmber,
              ),
              kDivider,
              const InfoRow(
                label: 'Replace soon',
                value: 'Below 70%',
                valueColor: kRed,
              ),
              kDivider,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: showResetDialog,
                    child: const Text(
                      'Reset health estimates',
                      style: TextStyle(color: kRed),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    // Section: about
    const Widget aboutSection = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle('About'),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InfoRow(label: 'Version', value: '1.0.0'),
              kDivider,
              InfoRow(label: 'Data', value: 'Sample data only'),
            ],
          ),
        ),
      ],
    );

    return ListView(
      padding: pagePadding(context),
      children: [
        const PageHeader(title: 'Settings', subtitle: 'Alerts, units and sync'),

        // Tablet: two columns next to each other
        if (wide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [alertsSection, syncSection],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [unitsSection, healthSection, aboutSection],
                ),
              ),
            ],
          ),

        // Phone: one column
        if (!wide) ...[
          alertsSection,
          unitsSection,
          healthSection,
          syncSection,
          aboutSection,
        ],
      ],
    );
  }
}
