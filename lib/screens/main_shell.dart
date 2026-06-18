import 'package:flutter/material.dart';

import '../widgets/sierro_widgets.dart';
import 'device_home_screen.dart';
import 'insights_screen.dart';
import 'settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  static const routeName = '/';

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  var _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const DeviceHomeScreen(),
      const InsightsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          IndexedStack(index: _index, children: pages),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SierroBottomNav(
              selectedIndex: _index,
              onChanged: (value) => setState(() => _index = value),
            ),
          ),
        ],
      ),
    );
  }
}
