import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/sierro_widgets.dart';
import 'smart_schedule_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    return SierroPage(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 106),
      child: Column(
        children: [
          const SierroHeader(title: 'Setting'),
          const SizedBox(height: 14),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                SierroCard(
                  child: Column(
                    children: [
                      SettingsRow(
                        icon: state.foundingMember
                            ? Icons.diamond_outlined
                            : Icons.bolt_rounded,
                        title: state.profileName,
                        subtitle: state.foundingMember
                            ? 'Founding Member #42'
                            : 'Manage My Account',
                        onTap: () => Navigator.pushNamed(
                          context,
                          AccountScreen.routeName,
                        ),
                      ),
                      const Divider(color: AppColors.border, height: 1),
                      SettingsRow(
                        icon: Icons.notifications_none_rounded,
                        title: 'Push Notifications',
                        subtitle: 'Power outage, low battery, and solar status',
                        onTap: () => Navigator.pushNamed(
                          context,
                          PushNotificationsScreen.routeName,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SierroCard(
                  child: Column(
                    children: [
                      SettingsRow(
                        icon: Icons.feedback_outlined,
                        title: 'Feedback',
                        onTap: () => Navigator.pushNamed(
                          context,
                          FeedbackScreen.routeName,
                        ),
                      ),
                      const Divider(color: AppColors.border, height: 1),
                      SettingsRow(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Policy',
                        onTap: () => Navigator.pushNamed(
                          context,
                          LegalTextScreen.privacyRouteName,
                        ),
                      ),
                      const Divider(color: AppColors.border, height: 1),
                      SettingsRow(
                        icon: Icons.article_outlined,
                        title: 'Terms of Use',
                        onTap: () => Navigator.pushNamed(
                          context,
                          LegalTextScreen.termsRouteName,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DeviceSettingsScreen extends StatelessWidget {
  const DeviceSettingsScreen({super.key});

  static const routeName = '/device-settings';

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    if (state.devices.isEmpty) {
      return const SierroPage(
        child: Column(
          children: [
            SierroHeader(
              title: 'Device Settings',
              leading: BackCircleButton(),
              centerTitle: true,
            ),
            Expanded(
              child: EmptyState(
                title: 'No device selected',
                message: 'Add a Sierro device before editing device settings.',
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
            color: AppColors.background,
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
            child: const SierroHeader(
              title: 'Device Settings',
              leading: BackCircleButton(),
              centerTitle: true,
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 2, 14, 26),
              physics: const BouncingScrollPhysics(),
              children: [
                _DeviceSettingCard(
                  title: 'Device Name',
                  value: device.name,
                  onTap: () =>
                      Navigator.pushNamed(context, DeviceNameScreen.routeName),
                ),
                _DeviceSettingCard(
                  title: 'Display Icon',
                  trailing: Icon(device.icon, size: 30, color: Colors.white),
                  onTap: () =>
                      Navigator.pushNamed(context, DisplayIconScreen.routeName),
                ),
                _DeviceSettingCard(
                  title: 'Device Info',
                  onTap: () =>
                      Navigator.pushNamed(context, DeviceInfoScreen.routeName),
                ),
                _DeviceSettingCard(
                  title: 'Sleep Mode',
                  value: state.sleepModeEnabled ? 'On' : 'Off',
                  onTap: () =>
                      Navigator.pushNamed(context, SleepModeScreen.routeName),
                ),
                _DeviceSettingCard(
                  title: 'Battery Priority',
                  value: state.batteryPriorityMode,
                  onTap: () => Navigator.pushNamed(
                    context,
                    BatteryPriorityScreen.routeName,
                  ),
                ),
                _DeviceSettingCard(
                  title: 'Smart Schedule',
                  value: state.schedule.enabled ? 'On' : 'Off',
                  onTap: () => Navigator.pushNamed(
                    context,
                    SmartScheduleScreen.routeName,
                  ),
                ),
                const SizedBox(height: 12),
                Material(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () async {
                      final confirm = await _confirmDanger(
                        context,
                        title: 'Delete ${device.name}?',
                        message:
                            'This device will be removed from your account. You can add it again at any time.',
                        action: 'Delete',
                      );
                      if (!confirm || !context.mounted) {
                        return;
                      }
                      state.deleteSelectedDevice();
                      _toast(context, '${device.name} deleted');
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    child: const SizedBox(
                      height: 72,
                      child: Center(
                        child: Text(
                          'Delete Device',
                          style: TextStyle(
                            color: AppColors.danger,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceSettingCard extends StatelessWidget {
  const _DeviceSettingCard({
    required this.title,
    this.value,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: SizedBox(
            height: 72,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (value != null)
                    Text(
                      value!,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ?trailing,
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DeviceNameScreen extends StatefulWidget {
  const DeviceNameScreen({super.key});

  static const routeName = '/device-name';

  @override
  State<DeviceNameScreen> createState() => _DeviceNameScreenState();
}

class _DeviceNameScreenState extends State<DeviceNameScreen> {
  late final TextEditingController _controller;
  late final String _initial;

  @override
  void initState() {
    super.initState();
    final scope =
        context.getElementForInheritedWidgetOfExactType<AppStateScope>()!.widget
            as AppStateScope;
    _initial = scope.notifier!.selectedDevice.name;
    _controller = TextEditingController(text: _initial);
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final changed =
        _controller.text.trim().isNotEmpty &&
        _controller.text.trim() != _initial;
    return SierroPage(
      child: Column(
        children: [
          const SierroHeader(
            title: 'Device Name',
            leading: BackCircleButton(),
            centerTitle: true,
          ),
          const SizedBox(height: 26),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(labelText: 'Device Name'),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: changed
                ? () {
                    AppStateScope.of(
                      context,
                    ).renameSelectedDevice(_controller.text);
                    _toast(context, 'Device name updated');
                    Navigator.pop(context);
                  }
                : null,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class DisplayIconScreen extends StatefulWidget {
  const DisplayIconScreen({super.key});

  static const routeName = '/display-icon';

  @override
  State<DisplayIconScreen> createState() => _DisplayIconScreenState();
}

class _DisplayIconScreenState extends State<DisplayIconScreen> {
  var _selected = 0;

  @override
  Widget build(BuildContext context) {
    const icons = [
      Icons.kitchen_outlined,
      Icons.bed_outlined,
      Icons.desktop_windows_outlined,
      Icons.lightbulb_outline_rounded,
      Icons.router_outlined,
      Icons.medical_services_outlined,
      Icons.battery_charging_full_outlined,
      Icons.home_work_outlined,
      Icons.devices_other_outlined,
      Icons.solar_power_outlined,
      Icons.power_outlined,
      Icons.phone_iphone_outlined,
    ];
    return SierroPage(
      child: Column(
        children: [
          const SierroHeader(
            title: 'Display Icon',
            leading: BackCircleButton(),
            centerTitle: true,
          ),
          const SizedBox(height: 22),
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: icons.length,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () => setState(() => _selected = index),
                child: Container(
                  decoration: BoxDecoration(
                    color: _selected == index
                        ? AppColors.primary.withValues(alpha: .14)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _selected == index
                          ? AppColors.primary
                          : Colors.transparent,
                    ),
                  ),
                  child: Icon(
                    icons[index],
                    size: 34,
                    color: _selected == index
                        ? AppColors.primary
                        : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              AppStateScope.of(
                context,
              ).updateSelectedDeviceIcon(icons[_selected]);
              _toast(context, 'Display icon updated');
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class DeviceInfoScreen extends StatelessWidget {
  const DeviceInfoScreen({super.key});

  static const routeName = '/device-info';

  @override
  Widget build(BuildContext context) {
    final device = AppStateScope.of(context).selectedDevice;
    return SierroPage(
      child: Column(
        children: [
          const SierroHeader(
            title: 'Device Info',
            leading: BackCircleButton(),
            centerTitle: true,
          ),
          const SizedBox(height: 16),
          SierroCard(
            child: Column(
              children: [
                _InfoRow(label: 'Model', value: device.model),
                _InfoRow(label: 'Serial Number', value: device.serialNumber),
                _InfoRow(label: 'Capacity', value: '${device.capacityWh} Wh'),
                _InfoRow(label: 'Battery Type', value: device.batteryType),
                _InfoRow(
                  label: 'Max Input Power',
                  value: '${device.maxChargingPowerW} W',
                ),
                _InfoRow(
                  label: 'Max Output Power',
                  value: '${device.peakOutputPowerW} W',
                ),
                _InfoRow(label: 'Voltage', value: device.voltage),
                _InfoRow(label: 'Frequency', value: device.frequency),
                _InfoRow(
                  label: 'Hardware Version',
                  value: device.hardwareVersion,
                ),
                _InfoRow(
                  label: 'Firmware Version',
                  value: device.firmwareVersion,
                ),
                _InfoRow(
                  label: 'Battery Health',
                  value: '${device.batteryHealth}%',
                ),
                _InfoRow(label: 'Cycles', value: '${device.cycles}'),
                _InfoRow(
                  label: 'Temperature',
                  value: '${device.temperatureF}°F',
                ),
                _InfoRow(label: 'Wifi Status', value: device.wifiStatus),
                _InfoRow(label: 'Data Source', value: device.dataSource),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SleepModeScreen extends StatefulWidget {
  const SleepModeScreen({super.key});

  static const routeName = '/sleep-mode';

  @override
  State<SleepModeScreen> createState() => _SleepModeScreenState();
}

class _SleepModeScreenState extends State<SleepModeScreen> {
  late bool _enabled;
  late TimeOfDay _start;
  late TimeOfDay _end;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = AppStateScope.of(context);
    _enabled = state.sleepModeEnabled;
    _start = state.sleepStart;
    _end = state.sleepEnd;
  }

  @override
  Widget build(BuildContext context) {
    return SierroPage(
      child: Column(
        children: [
          const SierroHeader(
            title: 'Sleep Mode',
            leading: BackCircleButton(),
            centerTitle: true,
          ),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                SierroCard(
                  child: Column(
                    children: [
                      _SwitchRow(
                        title: 'Sleep Mode',
                        value: _enabled,
                        onChanged: (value) => setState(() => _enabled = value),
                      ),
                      if (_enabled) ...[
                        const Divider(color: AppColors.border, height: 1),
                        SettingsRow(
                          title: 'Start Time',
                          subtitle: _start.format(context),
                          icon: Icons.bedtime_outlined,
                          onTap: () => _pickTime(true),
                        ),
                        const Divider(color: AppColors.border, height: 1),
                        SettingsRow(
                          title: 'End Time',
                          subtitle: _end.format(context),
                          icon: Icons.wb_sunny_outlined,
                          onTap: () => _pickTime(false),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              AppStateScope.of(
                context,
              ).updateSleepMode(enabled: _enabled, start: _start, end: _end);
              _toast(context, 'Sleep Mode updated');
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickTime(bool start) async {
    final value = await showTimePicker(
      context: context,
      initialTime: start ? _start : _end,
      builder: (context, child) => Theme(data: AppTheme.dark, child: child!),
    );
    if (value == null) {
      return;
    }
    setState(() {
      if (start) {
        _start = value;
      } else {
        _end = value;
      }
    });
  }
}

class BatteryPriorityScreen extends StatefulWidget {
  const BatteryPriorityScreen({super.key});

  static const routeName = '/battery-priority';

  @override
  State<BatteryPriorityScreen> createState() => _BatteryPriorityScreenState();
}

class _BatteryPriorityScreenState extends State<BatteryPriorityScreen> {
  late String _mode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mode = AppStateScope.of(context).batteryPriorityMode;
  }

  @override
  Widget build(BuildContext context) {
    const modes = [
      ('Backup Mode', 'Preserve battery for outages and emergency loads.'),
      (
        'Saving Mode',
        'Use more stored energy to reduce peak electricity cost.',
      ),
    ];
    return SierroPage(
      child: Column(
        children: [
          const SierroHeader(
            title: 'Battery Priority',
            leading: BackCircleButton(),
            centerTitle: true,
          ),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                for (final mode in modes)
                  SierroCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: SettingsRow(
                      title: mode.$1,
                      subtitle: mode.$2,
                      icon: mode.$1 == 'Backup Mode'
                          ? Icons.shield_outlined
                          : Icons.savings_outlined,
                      trailing: _mode == mode.$1
                          ? const Icon(
                              Icons.check_rounded,
                              color: AppColors.primary,
                            )
                          : const SizedBox.shrink(),
                      onTap: () => setState(() => _mode = mode.$1),
                    ),
                  ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              AppStateScope.of(context).updateBatteryPriority(_mode);
              _toast(context, 'Battery Priority updated');
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  static const routeName = '/account';

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    return SierroPage(
      child: Column(
        children: [
          const SierroHeader(
            title: 'Account',
            leading: BackCircleButton(),
            centerTitle: true,
          ),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                SierroCard(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: state.foundingMember
                            ? AppColors.warning
                            : AppColors.primary,
                        child: Icon(
                          state.foundingMember
                              ? Icons.diamond_outlined
                              : Icons.bolt_rounded,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.profileName,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              state.foundingMember
                                  ? 'Founding Member #42'
                                  : state.profileEmail,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14),
                SierroCard(
                  child: Column(
                    children: [
                      SettingsRow(
                        title: 'Name',
                        icon: Icons.person_outline_rounded,
                        subtitle: state.profileName,
                      ),
                      const Divider(color: AppColors.border, height: 1),
                      SettingsRow(
                        title: 'Linked Email',
                        icon: Icons.mail_outline_rounded,
                        subtitle: state.profileEmail,
                      ),
                      const Divider(color: AppColors.border, height: 1),
                      SettingsRow(
                        title: 'Redeem Founder Badge',
                        icon: Icons.workspace_premium_outlined,
                        subtitle: state.foundingMember
                            ? 'Activated'
                            : 'Enter founder code',
                        onTap: () {
                          state.updateProfile(member: true);
                          _toast(context, 'Founder Badge activated');
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SierroCard(
                  child: SettingsRow(
                    title: 'Sign Out',
                    icon: Icons.logout_rounded,
                    trailing: const SizedBox.shrink(),
                    onTap: () async {
                      final confirm = await _confirmDanger(
                        context,
                        title: 'Sign out?',
                        message:
                            'You will need to sign in again to access your account.',
                        action: 'Sign Out',
                      );
                      if (confirm && context.mounted) {
                        _toast(context, 'Signed out');
                      }
                    },
                  ),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () async {
                    final confirm = await _confirmDanger(
                      context,
                      title: 'Delete account?',
                      message:
                          'This will permanently delete your account and saved data. This action cannot be undone.',
                      action: 'Delete',
                    );
                    if (confirm && context.mounted) {
                      _toast(context, 'Account delete requested');
                    }
                  },
                  child: const Text(
                    'Delete Account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PushNotificationsScreen extends StatefulWidget {
  const PushNotificationsScreen({super.key});

  static const routeName = '/push-notifications';

  @override
  State<PushNotificationsScreen> createState() =>
      _PushNotificationsScreenState();
}

class _PushNotificationsScreenState extends State<PushNotificationsScreen> {
  late bool _powerOutage;
  late bool _battery;
  late bool _solar;
  late int _threshold;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = AppStateScope.of(context);
    _powerOutage = state.powerOutageAlerts;
    _battery = state.lowBatteryAlerts;
    _solar = state.solarStatusAlerts;
    _threshold = state.lowBatteryThreshold;
  }

  @override
  Widget build(BuildContext context) {
    return SierroPage(
      child: Column(
        children: [
          const SierroHeader(
            title: 'Push Notifications',
            leading: BackCircleButton(),
            centerTitle: true,
          ),
          const SizedBox(height: 16),
          SierroCard(
            child: Column(
              children: [
                _SwitchRow(
                  title: 'Power Outage',
                  value: _powerOutage,
                  onChanged: (v) => setState(() => _powerOutage = v),
                ),
                const Divider(color: AppColors.border, height: 1),
                _SwitchRow(
                  title: 'Low Battery',
                  value: _battery,
                  onChanged: (v) => setState(() => _battery = v),
                ),
                if (_battery) ...[
                  const Divider(color: AppColors.border, height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Alert threshold',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        DropdownButton<int>(
                          value: _threshold,
                          dropdownColor: AppColors.surface,
                          items: const [
                            DropdownMenuItem(value: 30, child: Text('30%')),
                            DropdownMenuItem(value: 20, child: Text('20%')),
                            DropdownMenuItem(value: 10, child: Text('10%')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _threshold = value);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
                const Divider(color: AppColors.border, height: 1),
                _SwitchRow(
                  title: 'Solar Status',
                  value: _solar,
                  onChanged: (v) => setState(() => _solar = v),
                ),
              ],
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              AppStateScope.of(context).updatePushSettings(
                powerOutage: _powerOutage,
                lowBattery: _battery,
                threshold: _threshold,
                solarStatus: _solar,
              );
              _toast(context, 'Push notifications updated');
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  static const routeName = '/feedback';

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _message = TextEditingController();
  final _email = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_email.text.isEmpty) {
      _email.text = AppStateScope.of(context).profileEmail;
    }
  }

  @override
  void dispose() {
    _message.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SierroPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SierroHeader(
            title: 'Feedback',
            leading: BackCircleButton(),
            centerTitle: true,
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _message,
            maxLines: 7,
            decoration: const InputDecoration(
              labelText: 'Tell us what happened',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _email,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              _toast(context, 'Feedback sent');
              Navigator.pop(context);
            },
            child: const Text('Send Feedback'),
          ),
        ],
      ),
    );
  }
}

class LegalTextScreen extends StatelessWidget {
  const LegalTextScreen.privacy({super.key})
    : title = 'Privacy Policy',
      body = _privacy;

  const LegalTextScreen.terms({super.key})
    : title = 'Terms of Use',
      body = _terms;

  static const privacyRouteName = '/privacy-policy';
  static const termsRouteName = '/terms-of-use';

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return SierroPage(
      child: Column(
        children: [
          SierroHeader(
            title: title,
            leading: const BackCircleButton(),
            centerTitle: true,
          ),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                Text(
                  body,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

const _privacy = '''
Sierro respects your privacy. This app uses your account information, device identifiers, Bluetooth status, and energy data only to provide monitoring, alerts, device configuration, and customer support.

Data displayed in this demo is placeholder data until the OpenAPI credentials and production server environment are configured.
''';

const _terms = '''
By using Sierro, you agree to use the app responsibly and follow device safety guidance. Energy data and alerts are provided for monitoring purposes and should be verified against the physical device when safety matters.

This source package is prepared for Android and iOS Flutter development.
''';

void _toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
}

Future<bool> _confirmDanger(
  BuildContext context, {
  required String title,
  required String message,
  required String action,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(title),
      content: Text(
        message,
        style: const TextStyle(color: AppColors.textMuted),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            action,
            style: const TextStyle(
              color: AppColors.danger,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}
