import 'package:flutter/material.dart';

import 'screens/main_screen.dart';
import 'theme.dart';

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
