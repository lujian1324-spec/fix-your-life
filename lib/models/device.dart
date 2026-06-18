import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum DeviceConnectionStatus { connected, disconnected, warning }

class DeviceModelSpec {
  const DeviceModelSpec({
    required this.model,
    required this.capacityWh,
    required this.maxInputPowerW,
    required this.maxOutputPowerW,
    required this.batteryType,
    required this.voltage,
    required this.frequency,
    required this.hardwareVersion,
    required this.firmwareVersion,
  });

  final String model;
  final int capacityWh;
  final int maxInputPowerW;
  final int maxOutputPowerW;
  final String batteryType;
  final String voltage;
  final String frequency;
  final String hardwareVersion;
  final String firmwareVersion;
}

const sierro1000Spec = DeviceModelSpec(
  model: 'Sierro 1000',
  capacityWh: 1000,
  maxInputPowerW: 400,
  maxOutputPowerW: 500,
  batteryType: 'LiFePO4',
  voltage: '3.2V',
  frequency: '60Hz',
  hardwareVersion: 'V1.0.0',
  firmwareVersion: 'V1.0.0',
);

const sierro2000Spec = DeviceModelSpec(
  model: 'Sierro2000',
  capacityWh: 2000,
  maxInputPowerW: 1000,
  maxOutputPowerW: 1000,
  batteryType: 'LiFePO4',
  voltage: '6.4V',
  frequency: '60Hz',
  hardwareVersion: 'V1.0.0',
  firmwareVersion: 'V1.0.0',
);

const sierroModelSpecs = [sierro1000Spec, sierro2000Spec];

DeviceModelSpec specForModel(String model) {
  final normalized = model.replaceAll(' ', '').toLowerCase();
  return sierroModelSpecs.firstWhere(
    (spec) => spec.model.replaceAll(' ', '').toLowerCase() == normalized,
    orElse: () => sierro1000Spec,
  );
}

class EnergyDevice {
  const EnergyDevice({
    required this.id,
    required this.name,
    required this.model,
    required this.icon,
    required this.status,
    required this.isPoweredOn,
    required this.batteryPercent,
    required this.remaining,
    required this.acInputW,
    required this.solarInputW,
    required this.outputW,
    required this.todayKwh,
    this.serialNumber = 'SN26102503Z6104955',
    this.capacityWh = 1000,
    this.batteryType = 'LiFePO4',
    this.maxChargingPowerW = 400,
    this.peakOutputPowerW = 500,
    this.voltage = '3.2V',
    this.frequency = '60Hz',
    this.hardwareVersion = 'V1.0.0',
    this.firmwareVersion = 'V1.0.0',
    this.batteryHealth = 96,
    this.cycles = 128,
    this.temperatureF = 78,
    this.wifiStatus = 'Connected',
    this.dataSource = 'DEMO MODE',
    this.lastSyncLabel = 'Last sync: 2 min ago',
  });

  final String id;
  final String name;
  final String model;
  final IconData icon;
  final DeviceConnectionStatus status;
  final bool isPoweredOn;
  final int batteryPercent;
  final String remaining;
  final int acInputW;
  final int solarInputW;
  final int outputW;
  final double todayKwh;
  final String serialNumber;
  final int capacityWh;
  final String batteryType;
  final int maxChargingPowerW;
  final int peakOutputPowerW;
  final String voltage;
  final String frequency;
  final String hardwareVersion;
  final String firmwareVersion;
  final int batteryHealth;
  final int cycles;
  final int temperatureF;
  final String wifiStatus;
  final String dataSource;
  final String lastSyncLabel;

  bool get isConnected => status != DeviceConnectionStatus.disconnected;

  String get statusLabel {
    switch (status) {
      case DeviceConnectionStatus.connected:
        return 'Connected';
      case DeviceConnectionStatus.disconnected:
        return 'Disconnected';
      case DeviceConnectionStatus.warning:
        return 'Warning';
    }
  }

  Color get statusColor {
    switch (status) {
      case DeviceConnectionStatus.connected:
        return AppColors.primary;
      case DeviceConnectionStatus.disconnected:
        return AppColors.textDim;
      case DeviceConnectionStatus.warning:
        return AppColors.warning;
    }
  }

  EnergyDevice copyWith({
    String? id,
    String? name,
    String? model,
    IconData? icon,
    DeviceConnectionStatus? status,
    bool? isPoweredOn,
    int? batteryPercent,
    String? remaining,
    int? acInputW,
    int? solarInputW,
    int? outputW,
    double? todayKwh,
    String? serialNumber,
    int? capacityWh,
    String? batteryType,
    int? maxChargingPowerW,
    int? peakOutputPowerW,
    String? voltage,
    String? frequency,
    String? hardwareVersion,
    String? firmwareVersion,
    int? batteryHealth,
    int? cycles,
    int? temperatureF,
    String? wifiStatus,
    String? dataSource,
    String? lastSyncLabel,
  }) {
    return EnergyDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      model: model ?? this.model,
      icon: icon ?? this.icon,
      status: status ?? this.status,
      isPoweredOn: isPoweredOn ?? this.isPoweredOn,
      batteryPercent: batteryPercent ?? this.batteryPercent,
      remaining: remaining ?? this.remaining,
      acInputW: acInputW ?? this.acInputW,
      solarInputW: solarInputW ?? this.solarInputW,
      outputW: outputW ?? this.outputW,
      todayKwh: todayKwh ?? this.todayKwh,
      serialNumber: serialNumber ?? this.serialNumber,
      capacityWh: capacityWh ?? this.capacityWh,
      batteryType: batteryType ?? this.batteryType,
      maxChargingPowerW: maxChargingPowerW ?? this.maxChargingPowerW,
      peakOutputPowerW: peakOutputPowerW ?? this.peakOutputPowerW,
      voltage: voltage ?? this.voltage,
      frequency: frequency ?? this.frequency,
      hardwareVersion: hardwareVersion ?? this.hardwareVersion,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      batteryHealth: batteryHealth ?? this.batteryHealth,
      cycles: cycles ?? this.cycles,
      temperatureF: temperatureF ?? this.temperatureF,
      wifiStatus: wifiStatus ?? this.wifiStatus,
      dataSource: dataSource ?? this.dataSource,
      lastSyncLabel: lastSyncLabel ?? this.lastSyncLabel,
    );
  }
}

const demoDevices = [
  EnergyDevice(
    id: '30340387838800344455',
    name: 'Fridge',
    model: 'Sierro 1000',
    icon: Icons.kitchen_outlined,
    status: DeviceConnectionStatus.connected,
    isPoweredOn: true,
    batteryPercent: 75,
    remaining: '1h 24m remaining',
    acInputW: 100,
    solarInputW: 30,
    outputW: 420,
    todayKwh: 0.997,
    serialNumber: 'SN26102503Z6104955',
    capacityWh: 1000,
    maxChargingPowerW: 400,
    peakOutputPowerW: 500,
    voltage: '3.2V',
  ),
  EnergyDevice(
    id: '283927489762819473827',
    name: 'NAS',
    model: 'Sierro2000',
    icon: Icons.dns_rounded,
    status: DeviceConnectionStatus.connected,
    isPoweredOn: true,
    batteryPercent: 100,
    remaining: '3h 10m remaining',
    acInputW: 20,
    solarInputW: 10,
    outputW: 90,
    todayKwh: 0.218,
    serialNumber: 'SN26102503Z6104955',
    capacityWh: 2000,
    maxChargingPowerW: 1000,
    peakOutputPowerW: 1000,
    voltage: '6.4V',
  ),
  EnergyDevice(
    id: '44782619375002837462',
    name: 'Garage',
    model: 'Sierro 1000',
    icon: Icons.chair_outlined,
    status: DeviceConnectionStatus.disconnected,
    isPoweredOn: false,
    batteryPercent: 45,
    remaining: '--',
    acInputW: 0,
    solarInputW: 0,
    outputW: 0,
    todayKwh: 0,
  ),
  EnergyDevice(
    id: '72839104728573912011',
    name: 'CPAP',
    model: 'Sierro 1000',
    icon: Icons.medical_services_outlined,
    status: DeviceConnectionStatus.connected,
    isPoweredOn: true,
    batteryPercent: 45,
    remaining: '58m remaining',
    acInputW: 42,
    solarInputW: 0,
    outputW: 120,
    todayKwh: 0.302,
  ),
];
