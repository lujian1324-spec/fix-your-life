import 'package:flutter/material.dart';

import '../models/device.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/sierro_widgets.dart';
import 'notifications_screen.dart';
import 'settings_screen.dart';

class DeviceDetailScreen extends StatefulWidget {
  const DeviceDetailScreen({super.key});

  static const routeName = '/device';

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  var _selectedMetric = 0;

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    if (state.devices.isEmpty) {
      return const SierroPage(
        child: Column(
          children: [
            SierroHeader(
              title: 'Device',
              leading: BackCircleButton(),
              centerTitle: true,
            ),
            Expanded(
              child: EmptyState(
                title: 'No devices yet',
                message:
                    'Add your first Sierro device to start monitoring and receiving alerts.',
              ),
            ),
          ],
        ),
      );
    }
    final device = state.selectedDevice;
    return SierroPage(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            height: 118,
            color: AppColors.header,
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
            child: SierroHeader(
              title: state.devices.length > 1 ? '${device.name}⌄' : device.name,
              subtitle: device.statusLabel,
              centerTitle: true,
              onTitleTap: state.devices.length > 1
                  ? () => _showDevicePicker(context, state)
                  : null,
              leading: const BackCircleButton(),
              actions: [
                CircleIconButton(
                  icon: Icons.settings_outlined,
                  onTap: () => Navigator.pushNamed(
                    context,
                    DeviceSettingsScreen.routeName,
                  ),
                ),
                CircleIconButton(
                  icon: Icons.notifications_none_rounded,
                  badge: state.hasUnreadNotifications,
                  onTap: () => Navigator.pushNamed(
                    context,
                    NotificationsScreen.routeName,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 18, 14, 34),
                physics: const BouncingScrollPhysics(),
                children: [
                  _BatteryCard(device: device),
                  const SizedBox(height: 14),
                  _RealTimePowerCard(
                    selectedIndex: _selectedMetric,
                    onChanged: (index) =>
                        setState(() => _selectedMetric = index),
                    disconnected: !device.isConnected,
                    dataSource: device.dataSource,
                    lastSyncLabel: device.lastSyncLabel,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDevicePicker(BuildContext context, AppState state) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Switch Device',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                for (final device in state.devices)
                  SettingsRow(
                    icon: device.icon,
                    title: device.name,
                    subtitle: device.statusLabel,
                    trailing: device.id == state.selectedDeviceId
                        ? const Icon(
                            Icons.check_rounded,
                            color: AppColors.primary,
                          )
                        : null,
                    onTap: () {
                      state.selectDevice(device.id);
                      Navigator.pop(context);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BatteryCard extends StatelessWidget {
  const _BatteryCard({required this.device});

  final EnergyDevice device;

  @override
  Widget build(BuildContext context) {
    return SierroCard(
      radius: 18,
      padding: const EdgeInsets.fromLTRB(22, 30, 22, 23),
      child: Column(
        children: [
          BatteryRing(
            percent: device.batteryPercent,
            subtitle: device.isConnected ? device.remaining : 'Disconnected',
            size: 186,
          ),
          const SizedBox(height: 31),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(
                child: Text(
                  'Input',
                  style: TextStyle(fontSize: 14, color: AppColors.textMuted),
                ),
              ),
              const Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Output',
                    style: TextStyle(fontSize: 14, color: AppColors.textMuted),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: PowerChip(
                  value: device.isConnected ? '${device.acInputW}' : '-',
                  unit: device.isConnected ? 'w' : '',
                  label: 'AC',
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 11),
                child: Text(
                  '+',
                  style: TextStyle(fontSize: 25, color: AppColors.textMuted),
                ),
              ),
              Expanded(
                child: PowerChip(
                  value: device.isConnected ? '${device.solarInputW}' : '-',
                  unit: device.isConnected ? 'w' : '',
                  label: 'Solar',
                ),
              ),
              const SizedBox(width: 22),
              Expanded(
                child: PowerChip(
                  value: device.isConnected ? '${device.outputW}' : '-',
                  unit: device.isConnected ? 'w' : '',
                  label: '',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RealTimePowerCard extends StatelessWidget {
  const _RealTimePowerCard({
    required this.selectedIndex,
    required this.onChanged,
    required this.disconnected,
    required this.dataSource,
    required this.lastSyncLabel,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final bool disconnected;
  final String dataSource;
  final String lastSyncLabel;

  @override
  Widget build(BuildContext context) {
    return SierroCard(
      radius: 18,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  disconnected ? 'Device disconnected' : 'Real-Time Power',
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (!disconnected)
                const StatusPill(
                  label: '75%',
                  color: AppColors.textMuted,
                  compact: true,
                ),
            ],
          ),
          if (disconnected) ...[
            const SizedBox(height: 6),
            const Text(
              'Reconnect the device to view chart data.',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
          const SizedBox(height: 12),
          disconnected
              ? const SizedBox(
                  height: 210,
                  child: Center(
                    child: Icon(
                      Icons.wifi_off_rounded,
                      color: AppColors.textDim,
                      size: 48,
                    ),
                  ),
                )
              : const LineChart(height: 210),
          const SizedBox(height: 14),
          Row(
            children: [
              _PowerTab(
                icon: Icons.battery_5_bar_rounded,
                label: 'Battery',
                selected: selectedIndex == 0,
                onTap: () => onChanged(0),
              ),
              _PowerTab(
                icon: Icons.power_rounded,
                label: 'AC',
                selected: selectedIndex == 1,
                onTap: () => onChanged(1),
              ),
              _PowerTab(
                icon: Icons.solar_power_outlined,
                label: 'Solar',
                selected: selectedIndex == 2,
                onTap: () => onChanged(2),
              ),
              _PowerTab(
                icon: Icons.output_rounded,
                label: 'Output',
                selected: selectedIndex == 3,
                onTap: () => onChanged(3),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DataSourceBadge(label: disconnected ? lastSyncLabel : dataSource),
        ],
      ),
    );
  }
}

class _PowerTab extends StatelessWidget {
  const _PowerTab({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 58,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: selected ? AppColors.surfaceLift : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: selected ? AppColors.text : AppColors.textDim,
                size: 23,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: selected ? AppColors.text : AppColors.textDim,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
