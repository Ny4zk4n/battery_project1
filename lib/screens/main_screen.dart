import 'package:flutter/material.dart';

import 'devices_page.dart';
import 'history_page.dart';
import 'settings_page.dart';
import '../theme.dart';

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
          children: const [DevicesPage(), HistoryPage(), SettingsPage()],
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
