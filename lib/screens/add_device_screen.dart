import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../config/sierro_environment.dart';
import '../services/bluetooth_provisioning.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/sierro_widgets.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  static const routeName = '/add-device';

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  var _step = 0;
  var _source = 'BLE';
  var _selectedIcon = Icons.kitchen_outlined;
  var _identifiedId = SierroEnvironment.demoDtuId;
  var _identifiedModel = 'Sierro 1000';
  final _nameController = TextEditingController(text: 'Fridge');
  final _qrController = TextEditingController(
    text: SierroEnvironment.demoSerialNumber,
  );
  final _wifiSsidController = TextEditingController(text: 'Home Wi-Fi');
  final _wifiPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _qrController.dispose();
    _wifiSsidController.dispose();
    _wifiPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titles = [
      'Add Your First Device',
      'Permissions',
      'Connect Device',
      'Wi-Fi Setup',
      'Device Name',
      'Display Icon',
    ];
    return SierroPage(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      child: Column(
        children: [
          SierroHeader(
            title: _step == 0 ? '' : titles[_step],
            leading: const BackCircleButton(),
            centerTitle: _step > 0,
            actions: _step == 0
                ? [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Skip for now',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ]
                : const [],
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: switch (_step) {
                0 => _AddChoice(
                  onBle: () => setState(() {
                    _source = 'BLE';
                    _step = 1;
                  }),
                  onQr: () => setState(() {
                    _source = 'QR';
                    _step = 1;
                  }),
                ),
                1 => _PermissionStep(onNext: () => setState(() => _step = 2)),
                2 =>
                  _source == 'BLE'
                      ? _BluetoothScan(
                          onNext: (id, model) => setState(() {
                            _identifiedId = id;
                            _identifiedModel = model;
                            _step = 3;
                          }),
                        )
                      : _QrScan(
                          controller: _qrController,
                          onNext: () => setState(() {
                            _identifiedId = _qrController.text.trim().isEmpty
                                ? SierroEnvironment.demoSerialNumber
                                : _qrController.text.trim();
                            _identifiedModel = 'Sierro 1000';
                            _step = 3;
                          }),
                        ),
                3 => _WifiSetup(
                  ssidController: _wifiSsidController,
                  passwordController: _wifiPasswordController,
                  onNext: () => setState(() => _step = 4),
                ),
                4 => _DeviceName(
                  controller: _nameController,
                  onNext: () => setState(() => _step = 5),
                ),
                _ => _DisplayIcon(
                  selected: _selectedIcon,
                  onSelect: (icon) => setState(() => _selectedIcon = icon),
                  onDone: _finish,
                ),
              },
            ),
          ),
        ],
      ),
    );
  }

  void _finish() {
    AppStateScope.of(context).addDevice(
      name: _nameController.text.trim().isEmpty
          ? 'Sierro'
          : _nameController.text.trim(),
      id: _identifiedId,
      model: _identifiedModel,
      icon: _selectedIcon,
      serialNumber: _identifiedId,
      wifiStatus: _wifiSsidController.text.trim().isEmpty
          ? 'Configured'
          : 'Connected to ${_wifiSsidController.text.trim()}',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Device connected'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }
}

class _AddChoice extends StatelessWidget {
  const _AddChoice({required this.onBle, required this.onQr});

  final VoidCallback onBle;
  final VoidCallback onQr;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(flex: 2),
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: SizedBox(
            width: double.infinity,
            height: 220,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset('assets/figma/setup_photo.png', fit: BoxFit.cover),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: .04),
                        Colors.black.withValues(alpha: .46),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 18,
                  bottom: 16,
                  child: Image.asset(
                    'assets/figma/sierro_logo_white.png',
                    width: 116,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'Add Your First Device',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Connect your first Sierro device to monitor battery status and stay prepared during power outages.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, height: 1.35),
          ),
        ),
        const Spacer(flex: 3),
        ElevatedButton.icon(
          onPressed: onBle,
          icon: const Icon(Icons.bluetooth_rounded),
          label: const Text('Connect with Bluetooth'),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: onQr,
          icon: const Icon(Icons.qr_code_scanner_rounded),
          label: const Text('Scan QR Code'),
        ),
      ],
    );
  }
}

class _PermissionStep extends StatelessWidget {
  const _PermissionStep({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 24),
        const Text(
          'Sierro needs these permissions to connect nearby devices.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textMuted),
        ),
        const SizedBox(height: 18),
        const SierroCard(
          child: Column(
            children: [
              SettingsRow(
                title: 'Bluetooth',
                subtitle: 'Scan and connect nearby Sierro devices',
                icon: Icons.bluetooth_rounded,
                trailing: Icon(Icons.check_rounded, color: AppColors.primary),
              ),
              Divider(color: AppColors.border, height: 1),
              SettingsRow(
                title: 'Local Network',
                subtitle: 'Let the device join your Wi-Fi network',
                icon: Icons.wifi_rounded,
                trailing: Icon(Icons.check_rounded, color: AppColors.primary),
              ),
              Divider(color: AppColors.border, height: 1),
              SettingsRow(
                title: 'Notifications',
                subtitle: 'Battery and outage alerts after setup',
                icon: Icons.notifications_none_rounded,
                trailing: Icon(Icons.check_rounded, color: AppColors.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        ElevatedButton(onPressed: onNext, child: const Text('Continue')),
      ],
    );
  }
}

class _BluetoothScan extends StatefulWidget {
  const _BluetoothScan({required this.onNext});

  final void Function(String id, String model) onNext;

  @override
  State<_BluetoothScan> createState() => _BluetoothScanState();
}

class _BluetoothScanState extends State<_BluetoothScan> {
  final _provisioning = BluetoothProvisioning();
  final Map<String, _BleScanItem> _realDevices = {};
  StreamSubscription<List<ScanResult>>? _subscription;
  var _isScanning = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _startScan() async {
    await _subscription?.cancel();
    if (!mounted) return;
    setState(() {
      _isScanning = true;
      _error = null;
    });
    try {
      _subscription = _provisioning.scan().listen(
        _applyScanResults,
        onError: (Object error) {
          if (!mounted) return;
          setState(() {
            _error = '$error';
            _isScanning = false;
          });
        },
        onDone: () {
          if (!mounted) return;
          setState(() => _isScanning = false);
        },
      );
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _error = '$error';
        _isScanning = false;
      });
    }
  }

  void _applyScanResults(List<ScanResult> results) {
    if (!mounted) return;
    setState(() {
      for (final result in results) {
        final name = result.device.platformName.isNotEmpty
            ? result.device.platformName
            : result.advertisementData.advName;
        final dtuid = SierroBleCodec.dtuidFromAdvertisementName(name);
        final id = dtuid ?? result.device.remoteId.str;
        _realDevices[id] = _BleScanItem(
          id: id,
          name: name.isEmpty ? 'Sierro Collector' : name,
          model: 'Sierro Collector',
          signal: _signalBars(result.rssi),
          source: 'BLE',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final devices = [
      ..._realDevices.values,
      if (_realDevices.isEmpty)
        const _BleScanItem(
          id: 'SR-2024-08842',
          name: 'Sierro 1000',
          model: 'Sierro 1000',
          signal: 4,
          source: 'Demo',
        ),
      if (_realDevices.isEmpty)
        const _BleScanItem(
          id: 'SR-2024-10412',
          name: 'Sierro 2000',
          model: 'Sierro 2000',
          signal: 3,
          source: 'Demo',
        ),
    ];
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 26),
        SierroCard(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: .13),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bluetooth_searching_rounded,
                  color: AppColors.primary,
                  size: 46,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Nearby devices',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'Only Sierro-compatible BLE devices are listed.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _isScanning ? null : _startScan,
                icon: Icon(
                  _isScanning ? Icons.sync_rounded : Icons.refresh_rounded,
                ),
                label: Text(_isScanning ? 'Scanning...' : 'Scan Again'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.warning),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        for (final device in devices)
          _ScannedDevice(
            onTap: () => widget.onNext(device.id, device.model),
            name: device.name,
            id: '${device.id} · ${device.source}',
            signal: device.signal,
          ),
      ],
    );
  }

  int _signalBars(int rssi) {
    if (rssi >= -55) return 4;
    if (rssi >= -67) return 3;
    if (rssi >= -80) return 2;
    return 1;
  }
}

class _BleScanItem {
  const _BleScanItem({
    required this.id,
    required this.name,
    required this.model,
    required this.signal,
    required this.source,
  });

  final String id;
  final String name;
  final String model;
  final int signal;
  final String source;
}

class _QrScan extends StatelessWidget {
  const _QrScan({required this.controller, required this.onNext});

  final TextEditingController controller;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: SizedBox(
            width: double.infinity,
            height: 230,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset('assets/figma/setup_photo.png', fit: BoxFit.cover),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: .12),
                  ),
                ),
                const Center(
                  child: Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Colors.white,
                    size: 76,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Scan the QR code on the side of the device.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textMuted),
        ),
        const SizedBox(height: 18),
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Device serial / QR payload',
          ),
        ),
        const Spacer(),
        ElevatedButton(onPressed: onNext, child: const Text('Connect')),
      ],
    );
  }
}

class _ScannedDevice extends StatelessWidget {
  const _ScannedDevice({
    required this.onTap,
    required this.name,
    required this.id,
    required this.signal,
  });

  final VoidCallback onTap;
  final String name;
  final String id;
  final int signal;

  @override
  Widget build(BuildContext context) {
    return SierroCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: SettingsRow(
        icon: Icons.battery_charging_full_outlined,
        title: name,
        subtitle: id,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.signal_cellular_alt_rounded,
              size: 20,
              color: signal >= 4 ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

class _WifiSetup extends StatelessWidget {
  const _WifiSetup({
    required this.ssidController,
    required this.passwordController,
    required this.onNext,
  });

  final TextEditingController ssidController;
  final TextEditingController passwordController;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 28),
        SierroCard(
          child: Column(
            children: [
              Image.asset(
                'assets/figma/sierro_product.png',
                width: 112,
                height: 112,
              ),
              const SizedBox(height: 14),
              const Text(
                'Connect Sierro to Wi-Fi',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              const Text(
                'Use a 2.4 GHz network if the collector firmware requires it.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, height: 1.35),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: ssidController,
                decoration: const InputDecoration(labelText: 'Wi-Fi SSID'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Wi-Fi Password'),
              ),
            ],
          ),
        ),
        const Spacer(),
        ElevatedButton(onPressed: onNext, child: const Text('Continue')),
      ],
    );
  }
}

class _DeviceName extends StatelessWidget {
  const _DeviceName({required this.controller, required this.onNext});

  final TextEditingController controller;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 28),
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Device Name',
            hintText: 'Enter device name',
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Give your Sierro a name that is easy to recognize.',
          style: TextStyle(color: AppColors.textMuted),
        ),
        const Spacer(),
        ElevatedButton(onPressed: onNext, child: const Text('Continue')),
      ],
    );
  }
}

class _DisplayIcon extends StatelessWidget {
  const _DisplayIcon({
    required this.selected,
    required this.onSelect,
    required this.onDone,
  });

  final IconData selected;
  final ValueChanged<IconData> onSelect;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    const icons = [
      Icons.kitchen_outlined,
      Icons.bed_outlined,
      Icons.desktop_windows_outlined,
      Icons.light_outlined,
      Icons.router_outlined,
      Icons.medical_services_outlined,
      Icons.battery_charging_full_outlined,
      Icons.home_work_outlined,
      Icons.devices_other_outlined,
    ];
    return Column(
      children: [
        const SizedBox(height: 24),
        Expanded(
          child: GridView.builder(
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: icons.length,
            itemBuilder: (context, index) {
              final isSelected = selected == icons[index];
              return GestureDetector(
                onTap: () => onSelect(icons[index]),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: .15)
                        : AppColors.surface,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.transparent,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    icons[index],
                    size: 34,
                    color: isSelected ? AppColors.primary : AppColors.textMuted,
                  ),
                ),
              );
            },
          ),
        ),
        ElevatedButton(onPressed: onDone, child: const Text('Done')),
      ],
    );
  }
}
