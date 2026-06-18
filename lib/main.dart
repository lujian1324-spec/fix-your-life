import 'dart:async';

import 'package:flutter/material.dart';

import 'screens/add_device_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/device_detail_screen.dart';
import 'screens/main_shell.dart';
import 'screens/notifications_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/smart_schedule_screen.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SierroApp());
}

class SierroApp extends StatefulWidget {
  const SierroApp({super.key});

  @override
  State<SierroApp> createState() => _SierroAppState();
}

class _SierroAppState extends State<SierroApp> {
  final _state = AppState();

  @override
  void initState() {
    super.initState();
    unawaited(_state.bootstrapCloudSync());
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      state: _state,
      child: MaterialApp(
        title: 'Sierro',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        initialRoute: MainShell.routeName,
        routes: {
          MainShell.routeName: (_) => const MainShell(),
          AuthScreen.routeName: (_) => const AuthScreen(),
          DeviceDetailScreen.routeName: (_) => const DeviceDetailScreen(),
          NotificationsScreen.routeName: (_) => const NotificationsScreen(),
          AddDeviceScreen.routeName: (_) => const AddDeviceScreen(),
          SmartScheduleScreen.routeName: (_) => const SmartScheduleScreen(),
          DeviceSettingsScreen.routeName: (_) => const DeviceSettingsScreen(),
          DisplayIconScreen.routeName: (_) => const DisplayIconScreen(),
          DeviceNameScreen.routeName: (_) => const DeviceNameScreen(),
          DeviceInfoScreen.routeName: (_) => const DeviceInfoScreen(),
          SleepModeScreen.routeName: (_) => const SleepModeScreen(),
          BatteryPriorityScreen.routeName: (_) => const BatteryPriorityScreen(),
          AccountScreen.routeName: (_) => const AccountScreen(),
          PushNotificationsScreen.routeName: (_) =>
              const PushNotificationsScreen(),
          FeedbackScreen.routeName: (_) => const FeedbackScreen(),
          LegalTextScreen.privacyRouteName: (_) =>
              const LegalTextScreen.privacy(),
          LegalTextScreen.termsRouteName: (_) => const LegalTextScreen.terms(),
        },
      ),
    );
  }
}
