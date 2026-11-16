import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Battery monitor - static UI mockup (sample data only, no real battery data)
//
// Screens:
//   MainScreen        bottom navigation with 3 tabs:
//     DevicesPage     "Batteries" (home)
//     HistoryPage     health trend, recent charges, alerts
//     SettingsPage    alerts, units, sync, about
//   DetailScreen      one device in detail (opens from Devices and History)
//   AddDeviceScreen   form to pair a new device
//
// The layout adapts to the screen: 1 column on phones, more on tablets.
// ---------------------------------------------------------------------------

// Colors
const Color kBg = Color(0xFF0F1418);
const Color kCard = Color(0xFF182028);
const Color kBorder = Color(0xFF2A3640);
const Color kText = Color(0xFFE8EEF2);
const Color kMuted = Color(0xFF9FB0BD);
const Color kAccent = Color(0xFF4ADE80);
const Color kAmber = Color(0xFFFBBF24);
const Color kRed = Color(0xFFF87171);

// Screen width where the layout switches from phone to tablet.
const double kTabletWidth = 600;
// The content never gets wider than this, even on a big monitor.
const double kMaxContentWidth = 1100;
// The app is never laid out narrower than this. Real phones are at least
// 320 px wide. In a narrower window the app scrolls sideways instead.
const double kMinAppWidth = 320;

// A thin line between rows inside a card.
const Widget kDivider = Divider(height: 1, color: kBorder);

// Health rule: 85%+ green "Good", 70-84% amber "Worn", below 70% red.
Color healthColor(int percent) {
  if (percent >= 85) return kAccent;
  if (percent >= 70) return kAmber;
  return kRed;
}

String healthLabel(int percent) {
  if (percent >= 85) return 'Good';
  if (percent >= 70) return 'Worn';
  return 'Replace soon';
}

// Writes 4095 as "4,095".
String formatNumber(int value) {
  String digits = value.abs().toString();
  String result = '';
  while (digits.length > 3) {
    result = ',${digits.substring(digits.length - 3)}$result';
    digits = digits.substring(0, digits.length - 3);
  }
  result = digits + result;
  return value < 0 ? '-$result' : result;
}

// Padding around a page. On very wide screens the side padding grows,
// so the content stays centered and at most kMaxContentWidth wide.
EdgeInsets pagePadding(BuildContext context) {
  final double screenWidth = MediaQuery.sizeOf(context).width;
  double side = (screenWidth - kMaxContentWidth) / 2;
  if (side < 16) side = 16;
  return EdgeInsets.symmetric(horizontal: side, vertical: 16);
}

// ---------------------------------------------------------------------------
// Sample data
// ---------------------------------------------------------------------------

// One finished charge: the date and the capacity that was measured.
class ChargeRecord {
  final String date;
  final int capacity; // in mAh

  const ChargeRecord(this.date, this.capacity);
}

// How much power one app used.
class AppUsage {
  final String name;
  final String screenTime;
  final double watts;

  const AppUsage(this.name, this.screenTime, this.watts);
}

// Everything the app knows about one device.
// Health is not stored: it is calculated from the charge records.
class Device {
  final String name;
  final IconData icon;
  final int designCapacity; // mAh when the battery was new
  final int chargePercent;
  final bool charging;
  final String statusText;
  final String power;
  final String temperature;
  final String current;
  final String voltage;
  final String cycles;
  final List<double> chargeHistory; // charge % over the last 24 hours
  final List<double> healthHistory; // health % over the last 12 months
  final List<ChargeRecord> records; // last charges, newest first
  final List<AppUsage> apps;

  const Device({
    required this.name,
    required this.icon,
    required this.designCapacity,
    required this.chargePercent,
    required this.charging,
    required this.statusText,
    required this.power,
    required this.temperature,
    required this.current,
    required this.voltage,
    required this.cycles,
    required this.chargeHistory,
    required this.healthHistory,
    required this.records,
    required this.apps,
  });

  // Average measured capacity of all charge records, in mAh.
  int get averageCapacity {
    if (records.isEmpty) return 0;
    int sum = 0;
    for (final ChargeRecord record in records) {
      sum += record.capacity;
    }
    return (sum / records.length).round();
  }

  // Health = average measured capacity compared with the capacity when new.
  double get healthExact => averageCapacity / designCapacity * 100;
  int get health => healthExact.round();

  String get capacityText =>
      '${formatNumber(averageCapacity)} of ${formatNumber(designCapacity)} mAh';
  String get estimateText => 'Estimated from ${records.length} charges';

  // Values taken from the 12 month health history.
  int get healthYearAgo => healthHistory.first.round();
  int get healthHalfYearAgo =>
      healthHistory[(healthHistory.length - 1) ~/ 2].round();
  int get healthDrop => (healthHistory.first - healthHistory.last).round();

  // Lowest charge level in the last 24 hours.
  double get lowestCharge {
    double lowest = chargeHistory.first;
    for (final double value in chargeHistory) {
      if (value < lowest) lowest = value;
    }
    return lowest;
  }
}

const Device kPhone = Device(
  name: 'This phone',
  icon: Icons.smartphone,
  designCapacity: 4500,
  chargePercent: 78,
  charging: true,
  statusText: 'Charging, full in 41 min',
  power: '+7.8 W',
  temperature: '31 °C',
  current: '+1850 mA',
  voltage: '4.21 V',
  cycles: '187',
  // 60% falling to 22%, then charging up to 78%
  chargeHistory: [60, 56, 52, 47, 43, 38, 33, 28, 24, 22, 36, 50, 64, 72, 78],
  healthHistory: [97, 97, 96, 96, 95, 95, 94, 93, 93, 92, 92, 91],
  // The average of these is 4,095 mAh = 91% of 4,500 mAh
  records: [
    ChargeRecord('13 Nov', 4100),
    ChargeRecord('12 Nov', 4088),
    ChargeRecord('10 Nov', 4092),
    ChargeRecord('9 Nov', 4100),
    ChargeRecord('7 Nov', 4085),
    ChargeRecord('6 Nov', 4098),
    ChargeRecord('4 Nov', 4120),
    ChargeRecord('3 Nov', 4075),
    ChargeRecord('1 Nov', 4090),
    ChargeRecord('31 Oct', 4102),
    ChargeRecord('29 Oct', 4080),
    ChargeRecord('28 Oct', 4110),
  ],
  apps: [
    AppUsage('YouTube', '2 h 10 min on screen', 2.4),
    AppUsage('Instagram', '48 min on screen', 1.9),
    AppUsage('Chrome', '1 h 35 min on screen', 1.6),
  ],
);

const Device kTablet = Device(
  name: 'Galaxy Tab S8',
  icon: Icons.tablet_android,
  designCapacity: 8000,
  chargePercent: 64,
  charging: false,
  statusText: 'Using 3.1 W, about 10 h left',
  power: '-3.1 W',
  temperature: '27 °C',
  current: '-805 mA',
  voltage: '3.85 V',
  cycles: '96',
  chargeHistory: [92, 92, 91, 88, 84, 84, 83, 80, 76, 73, 73, 70, 68, 66, 64],
  healthHistory: [93, 93, 92, 92, 91, 91, 90, 90, 89, 89, 88, 88],
  // The average of these is 7,040 mAh = 88% of 8,000 mAh
  records: [
    ChargeRecord('12 Nov', 7060),
    ChargeRecord('9 Nov', 7025),
    ChargeRecord('6 Nov', 7050),
    ChargeRecord('3 Nov', 7030),
    ChargeRecord('31 Oct', 7045),
    ChargeRecord('28 Oct', 7020),
    ChargeRecord('25 Oct', 7055),
    ChargeRecord('22 Oct', 7035),
  ],
  apps: [
    AppUsage('Netflix', '1 h 50 min on screen', 3.6),
    AppUsage('Chrome', '55 min on screen', 2.8),
    AppUsage('Kindle', '40 min on screen', 1.9),
  ],
);

// One charging session for the History tab.
class ChargeSession {
  final String deviceName;
  final String when;
  final String range;
  final String duration;

  const ChargeSession(this.deviceName, this.when, this.range, this.duration);
}

const List<ChargeSession> kSessions = [
  ChargeSession('This phone', 'Today, 16:40', '22% → 78%', 'Charging now'),
  ChargeSession('This phone', '13 Nov, 23:05', '31% → 100%', '1 h 12 min'),
  ChargeSession('Galaxy Tab S8', '12 Nov, 21:30', '18% → 100%', '2 h 05 min'),
  ChargeSession('This phone', '12 Nov, 08:15', '27% → 100%', '1 h 16 min'),
  ChargeSession('This phone', '10 Nov, 19:42', '35% → 92%', '58 min'),
  ChargeSession('Galaxy Tab S8', '9 Nov, 22:10', '24% → 100%', '1 h 52 min'),
];

// One alert for the History tab.
class AlertEvent {
  final String text;
  final String when;

  const AlertEvent(this.text, this.when);
}

const List<AlertEvent> kAlerts = [
  AlertEvent('Earbuds dropped below 20%', 'Today, 17:52'),
  AlertEvent('Galaxy Tab S8 dropped below 20%', '12 Nov, 21:14'),
  AlertEvent('This phone reached 41 °C while charging', '9 Nov, 14:10'),
];

// ---------------------------------------------------------------------------
// App
// ---------------------------------------------------------------------------

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Batteries',
      debugShowCheckedModeBanner: false, // hides the red DEBUG banner
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBg,
        colorScheme: const ColorScheme.dark(
          primary: kAccent,
          onPrimary: kBg,
          surface: kCard,
          onSurface: kText,
        ),
        textTheme: ThemeData.dark().textTheme.apply(
              bodyColor: kText,
              displayColor: kText,
            ),
      ),
      // Some widgets (for example the switch rows) cannot be laid out in
      // almost no width. So when the window is narrower than kMinAppWidth,
      // the app keeps that width and can be scrolled sideways.
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= kMinAppWidth) {
              return child!;
            }
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              child: SizedBox(width: kMinAppWidth, child: child),
            );
          },
        );
      },
      home: const MainScreen(),
    );
  }
}

// Opens the detail screen of a device.
void openDetail(BuildContext context, Device device) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => DetailScreen(device: device)),
  );
}

// Opens the Add device screen.
void openAddDevice(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const AddDeviceScreen()),
  );
}

// The screen with the bottom navigation. It shows one of the three tabs.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // IndexedStack keeps all three tabs alive, so the switches on the
        // Settings tab keep their values when you change tabs.
        child: IndexedStack(
          index: selectedIndex,
          children: const [
            DevicesPage(),
            HistoryPage(),
            SettingsPage(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: kBorder)),
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: kCard,
          selectedItemColor: kAccent,
          unselectedItemColor: kMuted,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.devices),
              label: 'Devices',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Small reusable widgets
// ---------------------------------------------------------------------------

// A dark card with a border. If onTap is given, the card is tappable.
class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: kBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

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

// Big title at the top of a tab, with a grey line under it.
class PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;

  const PageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: kMuted, fontSize: 14),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

// Small grey title above a section.
class SectionTitle extends StatelessWidget {
  final String text;

  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          color: kMuted,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

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
        Text(
          estimateText,
          style: const TextStyle(color: kMuted, fontSize: 13),
        ),
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
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ProgressBar(value: percent / 100, color: kAccent),
        const SizedBox(height: 8),
        Text(
          statusText,
          style: const TextStyle(color: kMuted, fontSize: 13),
        ),
      ],
    );
  }
}

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
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
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

// ---------------------------------------------------------------------------
// Line chart
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// Tab 1: Devices ("Batteries")
// ---------------------------------------------------------------------------

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
        Expanded(child: StatTile(label: 'Power', value: kPhone.power)),
        const SizedBox(width: 8),
        Expanded(
          child: StatTile(label: 'Temperature', value: kPhone.temperature),
        ),
        const SizedBox(width: 8),
        Expanded(child: StatTile(label: 'Cycles', value: kPhone.cycles)),
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

// ---------------------------------------------------------------------------
// Tab 2: History
// ---------------------------------------------------------------------------

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

  const AlertRow({
    super.key,
    required this.alert,
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

// ---------------------------------------------------------------------------
// Tab 3: Settings
// ---------------------------------------------------------------------------

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
        const PageHeader(
          title: 'Settings',
          subtitle: 'Alerts, units and sync',
        ),

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

// ---------------------------------------------------------------------------
// Device detail (works for any Device)
// ---------------------------------------------------------------------------

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
                      children: [
                        healthChartCard,
                        gap,
                        healthValuesCard,
                      ],
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

// ---------------------------------------------------------------------------
// Add device
// ---------------------------------------------------------------------------

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final List<String> pairingCode = ['4', '8', '2', '9', '1', '3'];

  String selectedType = 'Phone';
  bool alertOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add device'),
        backgroundColor: kBg,
        foregroundColor: kText,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      // The form stays at most 480 px wide and centered on tablets.
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Device name
                const Text(
                  'Device name',
                  style: TextStyle(color: kMuted, fontSize: 13),
                ),
                const SizedBox(height: 8),
                TextField(
                  style: const TextStyle(color: kText),
                  cursorColor: kAccent,
                  // Tapping outside the field closes the keyboard
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  decoration: InputDecoration(
                    hintText: 'For example: My tablet',
                    hintStyle: const TextStyle(color: kMuted),
                    filled: true,
                    fillColor: kCard,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: kBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: kAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Device type
                const Text(
                  'Device type',
                  style: TextStyle(color: kMuted, fontSize: 13),
                ),
                const SizedBox(height: 8),
                ChoiceButtons(
                  options: const ['Phone', 'Tablet', 'Laptop', 'Earbuds'],
                  selected: selectedType,
                  onSelected: (value) {
                    setState(() {
                      selectedType = value;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Pairing code: six boxes that share the width
                const Text(
                  'Pairing code',
                  style: TextStyle(color: kMuted, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (int i = 0; i < pairingCode.length; i++)
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: i == 0 ? 0 : 8),
                          child: Container(
                            height: 56,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: kCard,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: kBorder),
                            ),
                            child: Text(
                              pairingCode[i],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter this code on the other device. Expires in 4 min 30 s',
                  style: TextStyle(color: kMuted, fontSize: 13),
                ),
                const SizedBox(height: 24),

                // Alert switch (the whole row is tappable)
                AppCard(
                  padding: EdgeInsets.zero,
                  child: SwitchListTile(
                    title: const Text(
                      'Alert me when it drops below 20%',
                      style: TextStyle(fontSize: 15),
                    ),
                    value: alertOn,
                    onChanged: (value) {
                      setState(() {
                        alertOn = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons (both just go back, this is a mockup)
                SizedBox(
                  height: 50,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: kAccent,
                      foregroundColor: kBg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Add device',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: kMuted)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
