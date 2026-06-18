import 'package:flutter/material.dart';

import '../models/device.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/sierro_widgets.dart';
import 'add_device_screen.dart';
import 'device_detail_screen.dart';
import 'notifications_screen.dart';

class DeviceHomeScreen extends StatelessWidget {
  const DeviceHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    return SierroPage(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            height: 118,
            color: AppColors.header,
            padding: const EdgeInsets.fromLTRB(14, 11, 14, 12),
            child: SierroHeader(
              title: 'Device',
              actions: [
                CircleIconButton(
                  icon: Icons.add_rounded,
                  onTap: () =>
                      Navigator.pushNamed(context, AddDeviceScreen.routeName),
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
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: state.devices.isEmpty
                  ? EmptyState(
                      title: 'No devices yet',
                      message:
                          'Add your first Sierro device to start monitoring and receiving alerts.',
                      buttonLabel: 'Add Device',
                      imageAsset: 'assets/figma/sierro_product.png',
                      onButtonPressed: () => Navigator.pushNamed(
                        context,
                        AddDeviceScreen.routeName,
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 126),
                      physics: const BouncingScrollPhysics(),
                      itemCount: state.devices.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final device = state.devices[index];
                        return HomeDeviceCard(device: device);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeDeviceCard extends StatelessWidget {
  const HomeDeviceCard({super.key, required this.device});

  final EnergyDevice device;

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final disconnected = device.status == DeviceConnectionStatus.disconnected;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          state.selectDevice(device.id);
          Navigator.pushNamed(context, DeviceDetailScreen.routeName);
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 99),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(device.icon, color: Colors.white, size: 21),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          device.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            height: 1.05,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          device.model,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (disconnected)
                    const _DisconnectedPill()
                  else
                    _BatteryPill(
                      percent: device.batteryPercent,
                      tone: device.batteryPercent < 50
                          ? AppColors.warning
                          : AppColors.primary,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (device.name == 'CPAP')
                    const _TypePill(label: 'CPAP')
                  else
                    const SizedBox(width: 1, height: 1),
                  const Spacer(),
                  GestureDetector(
                    onTap: disconnected
                        ? null
                        : () => state.toggleDevicePower(device.id),
                    child: SierroSwitch(
                      on: device.isPoweredOn && !disconnected,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BatteryPill extends StatelessWidget {
  const _BatteryPill({required this.percent, required this.tone});

  final int percent;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceLift,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            percent < 25
                ? Icons.battery_alert_outlined
                : Icons.battery_5_bar_rounded,
            size: 15,
            color: tone,
          ),
          const SizedBox(width: 3),
          Text(
            '$percent%',
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _DisconnectedPill extends StatelessWidget {
  const _DisconnectedPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: .2),
        borderRadius: BorderRadius.circular(99),
      ),
      alignment: Alignment.center,
      child: const Text(
        'Disconnected',
        style: TextStyle(
          color: AppColors.danger,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _TypePill extends StatelessWidget {
  const _TypePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class SierroSwitch extends StatelessWidget {
  const SierroSwitch({super.key, required this.on});

  final bool on;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      width: 44,
      height: 26,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: on ? AppColors.primary : AppColors.surfaceLift,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Align(
        alignment: on ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
