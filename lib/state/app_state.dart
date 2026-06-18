import 'package:flutter/material.dart';

import '../config/sierro_environment.dart';
import '../models/device.dart';
import '../services/open_api_client.dart';
import '../theme/app_theme.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.color,
    this.deviceId,
    this.read = false,
  });

  final String id;
  final String title;
  final String message;
  final String time;
  final Color color;
  final String? deviceId;
  final bool read;

  AppNotification copyWith({bool? read}) {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      time: time,
      color: color,
      deviceId: deviceId,
      read: read ?? this.read,
    );
  }
}

class SmartScheduleSettings {
  const SmartScheduleSettings({
    required this.enabled,
    required this.peakStartHour,
    required this.peakEndHour,
    required this.offPeakStartHour,
    required this.offPeakEndHour,
    required this.peakPrice,
    required this.offPeakPrice,
    required this.maxChargePowerW,
    required this.maxDischargePowerW,
    required this.minSoc,
    required this.maxSoc,
  });

  final bool enabled;
  final int peakStartHour;
  final int peakEndHour;
  final int offPeakStartHour;
  final int offPeakEndHour;
  final double peakPrice;
  final double offPeakPrice;
  final int maxChargePowerW;
  final int maxDischargePowerW;
  final int minSoc;
  final int maxSoc;

  double get dailySavings {
    final capacityKwh = 1.0;
    final spread = (peakPrice - offPeakPrice).clamp(0, double.infinity);
    return spread * capacityKwh * 0.95 * 0.90 * 0.85;
  }

  double get monthlySavings => dailySavings * 30;

  double get yearlySavings => dailySavings * 365;

  SmartScheduleSettings copyWith({
    bool? enabled,
    int? peakStartHour,
    int? peakEndHour,
    int? offPeakStartHour,
    int? offPeakEndHour,
    double? peakPrice,
    double? offPeakPrice,
    int? maxChargePowerW,
    int? maxDischargePowerW,
    int? minSoc,
    int? maxSoc,
  }) {
    return SmartScheduleSettings(
      enabled: enabled ?? this.enabled,
      peakStartHour: peakStartHour ?? this.peakStartHour,
      peakEndHour: peakEndHour ?? this.peakEndHour,
      offPeakStartHour: offPeakStartHour ?? this.offPeakStartHour,
      offPeakEndHour: offPeakEndHour ?? this.offPeakEndHour,
      peakPrice: peakPrice ?? this.peakPrice,
      offPeakPrice: offPeakPrice ?? this.offPeakPrice,
      maxChargePowerW: maxChargePowerW ?? this.maxChargePowerW,
      maxDischargePowerW: maxDischargePowerW ?? this.maxDischargePowerW,
      minSoc: minSoc ?? this.minSoc,
      maxSoc: maxSoc ?? this.maxSoc,
    );
  }
}

const _demoNotifications = [
  AppNotification(
    id: 'n1',
    title: 'Low Battery',
    message: 'Fridge battery below 30%, estimated remaining time: 1h 24m.',
    time: 'Now',
    color: Color(0xFFFF3B30),
    deviceId: '39374839201847392837',
  ),
  AppNotification(
    id: 'n2',
    title: 'Solar Connected',
    message: 'Solar input detected, charging started.',
    time: '14m ago',
    color: Color(0xFF17D1C3),
    deviceId: '39374839201847392837',
  ),
  AppNotification(
    id: 'n3',
    title: 'Device disconnected',
    message: 'Garage lost connection. Please check network status.',
    time: 'Yesterday',
    color: Colors.grey,
    deviceId: '44782619375002837462',
    read: true,
  ),
];

class AppState extends ChangeNotifier {
  AppState({OpenApiClient? openApiClient})
    : _devices = demoDevices.toList(),
      selectedDeviceId = demoDevices.first.id,
      _openApiClient = openApiClient ?? OpenApiClient(),
      _notifications = _demoNotifications.toList();

  final List<EnergyDevice> _devices;
  final List<AppNotification> _notifications;
  final OpenApiClient _openApiClient;
  String selectedDeviceId;

  bool isCloudSyncing = false;
  bool hasCloudData = false;
  String cloudSyncStatus = 'Demo data';
  String? cloudSyncError;

  bool powerOutageAlerts = true;
  bool lowBatteryAlerts = true;
  int lowBatteryThreshold = 30;
  bool solarStatusAlerts = true;

  bool sleepModeEnabled = false;
  TimeOfDay sleepStart = const TimeOfDay(hour: 23, minute: 0);
  TimeOfDay sleepEnd = const TimeOfDay(hour: 7, minute: 0);
  String batteryPriorityMode = 'Backup Mode';

  String profileName = 'Jason';
  String profileEmail = 'jason@example.com';
  bool foundingMember = false;

  SmartScheduleSettings schedule = const SmartScheduleSettings(
    enabled: false,
    peakStartHour: 16,
    peakEndHour: 22,
    offPeakStartHour: 2,
    offPeakEndHour: 10,
    peakPrice: 0.40,
    offPeakPrice: 0.14,
    maxChargePowerW: 400,
    maxDischargePowerW: 500,
    minSoc: 0,
    maxSoc: 100,
  );

  List<EnergyDevice> get devices => List.unmodifiable(_devices);

  EnergyDevice get selectedDevice {
    return _devices.firstWhere(
      (device) => device.id == selectedDeviceId,
      orElse: () => _devices.first,
    );
  }

  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  bool get hasUnreadNotifications => _notifications.any((item) => !item.read);

  Future<void> bootstrapCloudSync() async {
    if (!SierroEnvironment.canAutoSync) {
      cloudSyncStatus = 'Demo data';
      return;
    }
    await syncFromOpenApi(
      account: SierroEnvironment.testAccount,
      password: SierroEnvironment.testPassword,
      dtuDtuid: SierroEnvironment.demoDtuId,
    );
  }

  Future<void> syncFromOpenApi({
    required String account,
    required String password,
    String? dtuDtuid,
  }) async {
    if (account.trim().isEmpty || password.trim().isEmpty) {
      cloudSyncError = 'Missing OpenAPI account or password.';
      cloudSyncStatus = 'Demo data';
      notifyListeners();
      return;
    }
    isCloudSyncing = true;
    cloudSyncError = null;
    cloudSyncStatus = 'Signing in to OpenAPI...';
    notifyListeners();

    try {
      final session = await _openApiClient.loginWithAccount(
        account: account.trim(),
        password: password,
      );
      if (session.accessToken == null || session.accessToken!.isEmpty) {
        throw const OpenApiException(200, 'OpenAPI login returned no token.');
      }

      cloudSyncStatus = 'Loading devices...';
      notifyListeners();

      final deviceResponse = await _openApiClient.deviceList(
        count: 100,
        dtuDtuid: dtuDtuid?.trim().isEmpty ?? true ? null : dtuDtuid!.trim(),
      );
      final deviceItems = _pageList(deviceResponse);
      final cloudDevices = <EnergyDevice>[];
      final cloudNotifications = <AppNotification>[];
      var telemetryCount = 0;

      for (final item in deviceItems) {
        final deviceId = _stringValue(item['id']);
        if (deviceId == null) continue;

        final detailResponse = await _safeCall(
          () => _openApiClient.deviceDetails(deviceId),
        );
        final latestResponse = await _safeCall(
          () => _openApiClient.latestDeviceState(deviceId),
        );
        final energyResponse = await _safeCall(
          () => _openApiClient.energyFlow(deviceId),
        );
        final alarmResponse = await _safeCall(
          () => _openApiClient.alarmList(deviceId: deviceId, count: 20),
        );

        final detail = _dataMap(detailResponse) ?? item;
        final latest = _dataMap(latestResponse);
        final energy = _dataMap(energyResponse);
        final telemetry = _TelemetryValues.from(latest: latest, energy: energy);
        if (telemetry.hasAnyValue) telemetryCount++;

        cloudDevices.add(_deviceFromCloud(detail, telemetry));
        cloudNotifications.addAll(
          _notificationsFromAlarmResponse(alarmResponse),
        );
      }

      if (cloudDevices.isNotEmpty) {
        _devices
          ..clear()
          ..addAll(cloudDevices);
        selectedDeviceId = _devices.first.id;
        _notifications
          ..clear()
          ..addAll(cloudNotifications);
        hasCloudData = true;
        cloudSyncStatus = telemetryCount > 0
            ? 'Cloud data synced'
            : 'Device linked - awaiting first telemetry';
      } else {
        cloudSyncStatus = 'Cloud login OK - no devices found';
        cloudSyncError =
            'No devices were returned for the configured account/DTU.';
      }
    } catch (error) {
      hasCloudData = false;
      cloudSyncStatus = 'Demo data';
      cloudSyncError = '$error';
    } finally {
      isCloudSyncing = false;
      notifyListeners();
    }
  }

  void selectDevice(String id) {
    selectedDeviceId = id;
    notifyListeners();
  }

  void toggleDevicePower(String id) {
    final index = _devices.indexWhere((device) => device.id == id);
    if (index == -1) return;
    final device = _devices[index];
    if (!device.isConnected) return;
    _devices[index] = device.copyWith(isPoweredOn: !device.isPoweredOn);
    notifyListeners();
  }

  void renameSelectedDevice(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    _updateSelected((device) => device.copyWith(name: trimmed));
  }

  void updateSelectedDeviceIcon(IconData icon) {
    _updateSelected((device) => device.copyWith(icon: icon));
  }

  void deleteSelectedDevice() {
    final removed = selectedDevice;
    _devices.removeWhere((device) => device.id == removed.id);
    if (_devices.isNotEmpty) selectedDeviceId = _devices.first.id;
    _notifications.insert(
      0,
      AppNotification(
        id: 'deleted-${DateTime.now().millisecondsSinceEpoch}',
        title: '${removed.name} deleted',
        message:
            'This device was removed from your account. You can add it again at any time.',
        time: 'Now',
        color: Colors.grey,
        read: true,
      ),
    );
    notifyListeners();
  }

  void addDevice({
    required String name,
    required String id,
    required String model,
    required IconData icon,
    String? serialNumber,
    String? wifiStatus,
  }) {
    final spec = specForModel(model);
    final device = EnergyDevice(
      id: id,
      name: name,
      model: spec.model,
      icon: icon,
      serialNumber: serialNumber ?? SierroEnvironment.demoSerialNumber,
      capacityWh: spec.capacityWh,
      batteryType: spec.batteryType,
      maxChargingPowerW: spec.maxInputPowerW,
      peakOutputPowerW: spec.maxOutputPowerW,
      voltage: spec.voltage,
      frequency: spec.frequency,
      hardwareVersion: spec.hardwareVersion,
      firmwareVersion: spec.firmwareVersion,
      status: DeviceConnectionStatus.connected,
      isPoweredOn: true,
      batteryPercent: 88,
      remaining: '2h 12m remaining',
      acInputW: 80,
      solarInputW: 20,
      outputW: 160,
      todayKwh: 0.126,
      wifiStatus: wifiStatus ?? 'Configured',
      dataSource: 'BLE Direct',
      lastSyncLabel: 'Last sync: just now',
    );
    _devices.insert(0, device);
    selectedDeviceId = device.id;
    _notifications.insert(
      0,
      AppNotification(
        id: 'added-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Device Connected',
        message: '$name is connected and ready to monitor.',
        time: 'Now',
        color: const Color(0xFF17D1C3),
        deviceId: id,
      ),
    );
    notifyListeners();
  }

  void markNotificationsRead() {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(read: true);
    }
    notifyListeners();
  }

  void deleteNotification(String id) {
    _notifications.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void updatePushSettings({
    bool? powerOutage,
    bool? lowBattery,
    int? threshold,
    bool? solarStatus,
  }) {
    powerOutageAlerts = powerOutage ?? powerOutageAlerts;
    lowBatteryAlerts = lowBattery ?? lowBatteryAlerts;
    lowBatteryThreshold = threshold ?? lowBatteryThreshold;
    solarStatusAlerts = solarStatus ?? solarStatusAlerts;
    notifyListeners();
  }

  void updateSleepMode({
    required bool enabled,
    TimeOfDay? start,
    TimeOfDay? end,
  }) {
    sleepModeEnabled = enabled;
    sleepStart = start ?? sleepStart;
    sleepEnd = end ?? sleepEnd;
    notifyListeners();
  }

  void updateBatteryPriority(String mode) {
    batteryPriorityMode = mode;
    notifyListeners();
  }

  void updateSchedule(SmartScheduleSettings next) {
    schedule = next;
    notifyListeners();
  }

  void updateProfile({String? name, String? email, bool? member}) {
    profileName = name ?? profileName;
    profileEmail = email ?? profileEmail;
    foundingMember = member ?? foundingMember;
    notifyListeners();
  }

  @override
  void dispose() {
    _openApiClient.close();
    super.dispose();
  }

  void _updateSelected(EnergyDevice Function(EnergyDevice device) update) {
    final index = _devices.indexWhere(
      (device) => device.id == selectedDeviceId,
    );
    if (index == -1) return;
    _devices[index] = update(_devices[index]);
    notifyListeners();
  }
}

Future<Map<String, dynamic>?> _safeCall(
  Future<Map<String, dynamic>> Function() call,
) async {
  try {
    return await call();
  } catch (_) {
    return null;
  }
}

bool _isSuccess(Map<String, dynamic>? response) => response?['code'] == 0;

Map<String, dynamic>? _dataMap(Map<String, dynamic>? response) {
  if (!_isSuccess(response)) return null;
  final data = response?['data'];
  return data is Map<String, dynamic> ? data : null;
}

List<Map<String, dynamic>> _pageList(Map<String, dynamic>? response) {
  if (!_isSuccess(response)) return const [];
  final data = response?['data'];
  if (data is Map<String, dynamic>) {
    final list = data['list'];
    if (list is List) return list.whereType<Map<String, dynamic>>().toList();
  }
  if (data is List) return data.whereType<Map<String, dynamic>>().toList();
  return const [];
}

EnergyDevice _deviceFromCloud(
  Map<String, dynamic> source,
  _TelemetryValues telemetry,
) {
  final rawModel = _stringValue(source['model']);
  final displayModel =
      rawModel != null && rawModel.toLowerCase().contains('sierro')
      ? rawModel
      : 'Sierro 1000';
  final spec = specForModel(displayModel);
  final stateValue = _intValue(source['state']);
  final noTelemetry = !telemetry.hasAnyValue;
  final status = stateValue == 120
      ? DeviceConnectionStatus.disconnected
      : noTelemetry
      ? DeviceConnectionStatus.warning
      : DeviceConnectionStatus.connected;
  final batteryPercent = telemetry.batteryPercent ?? (noTelemetry ? 0 : 75);
  final todayKwh =
      telemetry.todayKwh ??
      _numberFromStateItem(source['todayPvGenerationReadDirectly']) ??
      _doubleValue(source['dailyProducedQuantity']) ??
      0;

  return EnergyDevice(
    id: _stringValue(source['id']) ?? SierroEnvironment.demoDtuId,
    name: _stringValue(source['name']) ?? 'Sierro 1000',
    model: spec.model,
    icon: Icons.battery_charging_full_rounded,
    status: status,
    isPoweredOn: status != DeviceConnectionStatus.disconnected,
    batteryPercent: batteryPercent.clamp(0, 100).toInt(),
    remaining: noTelemetry ? 'Awaiting first report' : 'Live telemetry',
    acInputW: telemetry.acInputW ?? 0,
    solarInputW: telemetry.solarInputW ?? 0,
    outputW: telemetry.outputW ?? _intValue(source['producingPower']) ?? 0,
    todayKwh: todayKwh,
    serialNumber:
        _stringValue(source['serialNumber']) ??
        SierroEnvironment.demoSerialNumber,
    capacityWh: spec.capacityWh,
    batteryType: spec.batteryType,
    maxChargingPowerW: spec.maxInputPowerW,
    peakOutputPowerW: spec.maxOutputPowerW,
    voltage: spec.voltage,
    frequency: spec.frequency,
    hardwareVersion: spec.hardwareVersion,
    firmwareVersion:
        _stringValue(source['softwareVersion']) ?? spec.firmwareVersion,
    wifiStatus: _stringValue(source['dtuDtuid']) ?? 'Bound',
    dataSource: noTelemetry ? 'Cloud linked - no latest telemetry' : 'OpenAPI',
    lastSyncLabel: noTelemetry
        ? 'No latest data from cloud'
        : 'Last sync: ${_relativeTimeLabel(source['lastDataAt'])}',
  );
}

List<AppNotification> _notificationsFromAlarmResponse(
  Map<String, dynamic>? response,
) {
  final items = _pageList(response);
  return [
    for (final item in items)
      AppNotification(
        id: _stringValue(item['id']) ?? UniqueKey().toString(),
        title:
            _stringValue(item['name']) ??
            _stringValue(item['alarmRuleName']) ??
            'Device Alert',
        message:
            _stringValue(item['description']) ??
            _stringValue(item['alarmRuleDescription']) ??
            _stringValue(item['levelDict']) ??
            'An alarm was reported by the device.',
        time: _relativeTimeLabel(item['createdAt']),
        color: _alarmColor(item['level']),
        deviceId: _stringValue(item['deviceId']),
        read: item['isRead'] == true,
      ),
  ];
}

Color _alarmColor(Object? level) {
  final value = _stringValue(level)?.toLowerCase() ?? '';
  if (value.contains('1') || value.contains('critical')) {
    return const Color(0xFFFF3B30);
  }
  if (value.contains('2') || value.contains('warn')) {
    return AppColors.warning;
  }
  return AppColors.primary;
}

String _relativeTimeLabel(Object? rawTime) {
  final text = _stringValue(rawTime);
  if (text == null) return 'Now';
  final time = DateTime.tryParse(text);
  if (time == null) return text;
  final diff = DateTime.now().toUtc().difference(time.toUtc());
  if (diff.inMinutes < 1) return 'Now';
  if (diff.inHours < 1) return '${diff.inMinutes}m ago';
  if (diff.inDays < 1) return '${diff.inHours}h ago';
  if (diff.inDays == 1) return 'Yesterday';
  return '${diff.inDays}d ago';
}

String? _stringValue(Object? value) {
  if (value == null) return null;
  if (value is String) return value.isEmpty ? null : value;
  return '$value';
}

int? _intValue(Object? value) {
  if (value is int) return value;
  if (value is num) return value.round();
  final parsed = double.tryParse(_stringValue(value) ?? '');
  return parsed?.round();
}

double? _doubleValue(Object? value) {
  if (value is num) return value.toDouble();
  final text = _stringValue(value);
  if (text == null) return null;
  return double.tryParse(text.replaceAll(RegExp(r'[^0-9.\-]'), ''));
}

double? _numberFromStateItem(Object? item) {
  if (item is Map<String, dynamic>) {
    return _doubleValue(item['value']) ?? _doubleValue(item['valueDisplay']);
  }
  return _doubleValue(item);
}

class _TelemetryValues {
  const _TelemetryValues({
    this.batteryPercent,
    this.acInputW,
    this.solarInputW,
    this.outputW,
    this.todayKwh,
  });

  final int? batteryPercent;
  final int? acInputW;
  final int? solarInputW;
  final int? outputW;
  final double? todayKwh;

  bool get hasAnyValue =>
      batteryPercent != null ||
      acInputW != null ||
      solarInputW != null ||
      outputW != null ||
      todayKwh != null;

  factory _TelemetryValues.from({
    Map<String, dynamic>? latest,
    Map<String, dynamic>? energy,
  }) {
    final stateItems = _stateItems(latest);
    final energyState = _stateItems(_asMap(energy?['deviceAttributeState']));
    stateItems.addAll(energyState);

    return _TelemetryValues(
      batteryPercent: _numberForKeys(stateItems, const [
        'soc',
        'battery_soc',
        'battery_capacity',
        'battery_percent',
        'electric_quantity',
        '电量',
      ])?.round(),
      acInputW:
          _flowPower(energy, 'gridFlow') ??
          _numberForKeys(stateItems, const [
            'grid_power',
            'ac_input',
            'ac',
          ])?.round(),
      solarInputW:
          _flowPower(energy, 'pvPanelFlow') ??
          _numberForKeys(stateItems, const [
            'pv_power',
            'solar',
            '光伏',
          ])?.round(),
      outputW:
          _flowPower(energy, 'loadFlow') ??
          _numberForKeys(stateItems, const [
            'load_power',
            'output',
            '负载',
          ])?.round(),
      todayKwh: _numberForKeys(stateItems, const [
        'today',
        'daily',
        'day_energy',
        'generated_energy',
        '发电量',
      ]),
    );
  }
}

Map<String, dynamic>? _asMap(Object? value) =>
    value is Map<String, dynamic> ? value : null;

Map<String, dynamic> _stateItems(Map<String, dynamic>? state) {
  final result = <String, dynamic>{};
  if (state == null) return result;

  final fields = state['fields'];
  if (fields is Map) {
    for (final entry in fields.entries) {
      final key = _stringValue(entry.key);
      if (key != null) result[key] = entry.value;
    }
  }

  final groups = state['groups'];
  if (groups is List) {
    for (final group in groups.whereType<Map<String, dynamic>>()) {
      final items = group['stateItems'];
      if (items is List) {
        for (final item in items.whereType<Map<String, dynamic>>()) {
          final key = _stringValue(item['key']);
          if (key != null) result[key] = item;
        }
      }
    }
  }
  return result;
}

int? _flowPower(Map<String, dynamic>? energy, String flowKey) {
  final flow = _asMap(energy?[flowKey]);
  final valueItem = _asMap(flow?['value']);
  return _numberFromStateItem(valueItem)?.round();
}

double? _numberForKeys(Map<String, dynamic> items, List<String> keys) {
  for (final entry in items.entries) {
    final key = entry.key.toLowerCase();
    final item = _asMap(entry.value);
    final name = [
      key,
      _stringValue(item?['name']),
      _stringValue(item?['nameDisplay']),
    ].whereType<String>().join(' ').toLowerCase();
    if (keys.any((needle) => name.contains(needle))) {
      final value = _numberFromStateItem(entry.value);
      if (value != null) return value;
    }
  }
  return null;
}

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState state,
    required super.child,
  }) : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope not found in widget tree');
    return scope!.notifier!;
  }
}
