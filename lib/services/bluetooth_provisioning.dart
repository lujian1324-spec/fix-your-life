import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothProvisioning {
  static final serviceUuid = Guid('0000fee7-0000-1000-8000-00805f9b34fb');
  static final readUuid = Guid('0000fed6-0000-1000-8000-00805f9b34fb');
  static final writeUuid = Guid('0000fed5-0000-1000-8000-00805f9b34fb');

  Future<void> ensurePermissions() async {
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();
  }

  Stream<List<ScanResult>> scan({
    Duration timeout = const Duration(seconds: 8),
  }) async* {
    await ensurePermissions();
    await FlutterBluePlus.startScan(
      withServices: [serviceUuid],
      timeout: timeout,
    );
    yield* FlutterBluePlus.scanResults.map((results) {
      return results
          .where((result) => result.device.platformName.startsWith('SSL_'))
          .toList();
    });
  }

  Future<BluetoothProvisioningSession> connect(
    BluetoothDevice device, {
    String? dtuid,
  }) async {
    final resolvedDtuid =
        dtuid ?? SierroBleCodec.dtuidFromAdvertisementName(device.platformName);
    if (resolvedDtuid == null) {
      throw const BluetoothProvisioningException(
        'Cannot resolve DTUID from BLE name. Pass the DTUID from QR/API.',
      );
    }
    await device.connect(
      timeout: const Duration(seconds: 12),
      autoConnect: false,
      mtu: 240,
    );
    final services = await device.discoverServices();
    final service = services.firstWhere((item) => item.uuid == serviceUuid);
    final write = service.characteristics.firstWhere(
      (item) => item.uuid == writeUuid,
    );
    final read = service.characteristics.firstWhere(
      (item) => item.uuid == readUuid,
    );
    await read.setNotifyValue(true);
    return BluetoothProvisioningSession(
      device: device,
      write: write,
      read: read,
      codec: SierroBleCodec(dtuid: resolvedDtuid),
    );
  }
}

class BluetoothProvisioningSession {
  BluetoothProvisioningSession({
    required this.device,
    required this.write,
    required this.read,
    required this.codec,
  });

  final BluetoothDevice device;
  final BluetoothCharacteristic write;
  final BluetoothCharacteristic read;
  final SierroBleCodec codec;
  late final SierroBlePacketAssembler _assembler = SierroBlePacketAssembler(
    codec,
  );

  Stream<Map<String, dynamic>> get messages {
    return read.lastValueStream
        .where((value) => value.isNotEmpty)
        .map(_assembler.addPacket)
        .where((value) => value != null)
        .cast<Map<String, dynamic>>();
  }

  Future<void> sendWifiConfig({
    required String ssid,
    required String password,
    bool dhcp = true,
    String? staticIp,
    String? subnet,
    String? gateway,
    String? dns,
  }) async {
    final payload = {
      'CID': 30005,
      'PL': {
        'SSID': ssid,
        'Key': password,
        'DHCP': dhcp ? 1 : 0,
        'IP': ?staticIp,
        'Subnet': ?subnet,
        'GW': ?gateway,
        'DNS': ?dns,
      },
    };
    await sendJson(payload);
  }

  Future<void> confirmBleKey(String bleKey) {
    return sendJson({
      'CID': 30050,
      'PL': {'BleKey': bleKey},
    });
  }

  Future<void> queryVersion() => sendJson({'CID': 30001});

  Future<void> scanAccessPoints() => sendJson({'CID': 30003});

  Future<void> queryWifiConfig() => sendJson({'CID': 30009});

  Future<void> queryNetConfig() => sendJson({'CID': 30011});

  Future<void> queryWifiStatus() => sendJson({'CID': 30020});

  Future<void> queryNetworkStatus({String? ping}) {
    return sendJson({
      'CID': 30022,
      if (ping != null) 'PL': {'Ping': ping},
    });
  }

  Future<void> queryDiagnosis() async {
    await sendJson({'CID': 30020});
  }

  Future<void> restartDevice() => sendJson({'CID': 30007});

  Future<void> sendJson(Map<String, dynamic> command) async {
    final packets = codec.encodePackets(command);
    for (final packet in packets) {
      await write.write(packet, withoutResponse: false);
    }
  }

  Future<void> disconnect() => device.disconnect();
}

class SierroBleCodec {
  SierroBleCodec({
    required this.dtuid,
    this.keyPrefix = 'SEC_',
    this.maxPacketDataLength = 237,
  }) : assert(maxPacketDataLength > 0 && maxPacketDataLength <= 255) {
    final digest = md5.convert(utf8.encode('$dtuid$keyPrefix'));
    _keyBytes = Uint8List.fromList(digest.bytes);
  }

  final String dtuid;
  final String keyPrefix;
  final int maxPacketDataLength;
  late final Uint8List _keyBytes;

  String get keyHex {
    return _keyBytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  List<List<int>> encodePackets(Map<String, dynamic> command) {
    final encodedPayload = utf8.encode(encodePayload(command));
    final totalPackets = (encodedPayload.length / maxPacketDataLength).ceil();
    if (totalPackets <= 0 || totalPackets > 255) {
      throw BluetoothProvisioningException(
        'BLE payload requires $totalPackets packets, but protocol supports 1-255.',
      );
    }
    return [
      for (var index = 0; index < totalPackets; index++)
        _packet(
          seqNo: index + 1,
          seqNum: totalPackets,
          data: encodedPayload.sublist(
            index * maxPacketDataLength,
            (index + 1) * maxPacketDataLength > encodedPayload.length
                ? encodedPayload.length
                : (index + 1) * maxPacketDataLength,
          ),
        ),
    ];
  }

  String encodePayload(Map<String, dynamic> command) {
    final jsonText = jsonEncode(command);
    final padded = _zeroPad(Uint8List.fromList(utf8.encode(jsonText)));
    final encrypted = _aes.encrypt(padded, iv: _iv);
    return encrypted.base64;
  }

  Map<String, dynamic> decodePayload(List<int> encodedPayload) {
    final payloadText = utf8.decode(encodedPayload, allowMalformed: true);
    final encrypted = encrypt.Encrypted.fromBase64(payloadText);
    final decrypted = _aes.decrypt(encrypted, iv: _iv);
    final trimmed = _stripTrailingZeros(decrypted);
    final decoded = jsonDecode(utf8.decode(trimmed));
    if (decoded is Map<String, dynamic>) return decoded;
    return {'raw': decoded};
  }

  encrypt.AES get _aes {
    return encrypt.AES(
      encrypt.Key(_keyBytes),
      mode: encrypt.AESMode.cbc,
      padding: null,
    );
  }

  encrypt.IV get _iv => encrypt.IV(_keyBytes);

  Uint8List _zeroPad(Uint8List input) {
    final remainder = input.length % 16;
    if (remainder == 0) return input;
    final output = Uint8List(input.length + 16 - remainder)..setAll(0, input);
    return output;
  }

  Uint8List _stripTrailingZeros(List<int> input) {
    var end = input.length;
    while (end > 0 && input[end - 1] == 0) {
      end--;
    }
    return Uint8List.fromList(input.sublist(0, end));
  }

  List<int> _packet({
    required int seqNo,
    required int seqNum,
    required List<int> data,
  }) {
    if (data.length > 255) {
      throw BluetoothProvisioningException(
        'BLE packet data is ${data.length} bytes, max is 255.',
      );
    }
    return [seqNo, seqNum, data.length, ...data];
  }

  static String? dtuidFromAdvertisementName(
    String name, {
    String prefix = 'SSL_',
  }) {
    if (!name.startsWith(prefix)) return null;
    final rest = name.substring(prefix.length);
    if (rest.length < 2) return null;
    final base64Part = rest.substring(1);
    try {
      final bytes = base64Decode(base64Part);
      return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    } on FormatException {
      return null;
    }
  }
}

class SierroBlePacketAssembler {
  SierroBlePacketAssembler(this.codec);

  final SierroBleCodec codec;
  List<List<int>?>? _chunks;

  Map<String, dynamic>? addPacket(List<int> packet) {
    if (packet.length < 3) {
      throw const BluetoothProvisioningException('BLE packet is too short.');
    }
    final seqNo = packet[0];
    final seqNum = packet[1];
    final dataLength = packet[2];
    if (seqNo < 1 || seqNo > seqNum) {
      throw BluetoothProvisioningException('Invalid BLE packet seqNo=$seqNo.');
    }
    if (dataLength != packet.length - 3) {
      throw BluetoothProvisioningException(
        'BLE packet length mismatch: header=$dataLength actual=${packet.length - 3}.',
      );
    }
    if (_chunks == null || _chunks!.length != seqNum || seqNo == 1) {
      _chunks = List<List<int>?>.filled(seqNum, null);
    }
    _chunks![seqNo - 1] = packet.sublist(3);
    if (_chunks!.any((chunk) => chunk == null)) return null;

    final payload = <int>[];
    for (final chunk in _chunks!) {
      payload.addAll(chunk!);
    }
    _chunks = null;
    return codec.decodePayload(payload);
  }
}

class BluetoothProvisioningException implements Exception {
  const BluetoothProvisioningException(this.message);

  final String message;

  @override
  String toString() => 'BluetoothProvisioningException: $message';
}
