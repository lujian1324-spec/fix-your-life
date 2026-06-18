import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sierro_app/services/bluetooth_provisioning.dart';
import 'package:sierro_app/services/open_api_client.dart';
import 'package:sierro_app/services/sierro_signer.dart';
import 'package:sierro_app/state/app_state.dart';

void main() {
  test('OpenAPI signer matches the official sample', () {
    const signer = SierroSigner(appId: 'IamAppID', appSecret: 'IamAppSecret');

    final headers = signer.signedHeaders(
      body: '{"Jackie":"Chan","Andy":"Lau","Jay":"Chou"}',
      nonce: '12345678901234567890123456789012',
      queryParameters: const {
        'hello': 'world',
        'address': 'china',
        'solar': 'super',
        'EmptyText': '',
        'monkey': '黑悟空',
      },
    );

    expect(
      headers['IOT-Open-Body-Hash'],
      '992fffa7ee7f171121d08a1806d6465a52ed77814dd9eda975df290d55bbbe74',
    );
    expect(headers['IOT-Open-Sign'], 'a7da3c4152b2de366659d109450955ea');
  });

  test('OpenAPI account login sends an MD5 password', () async {
    late Map<String, dynamic> requestBody;
    final client = OpenApiClient(
      config: const OpenApiConfig(
        baseUrl: 'https://solar.siseli.com/openapis',
        appId: 'app',
        appSecret: 'secret',
      ),
      httpClient: MockClient((request) async {
        requestBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            'code': 0,
            'message': 'Success',
            'data': {'accessToken': 'access-token'},
          }),
          200,
        );
      }),
    );

    final session = await client.loginWithAccount(
      account: 'jason1324',
      password: 'plain-password',
    );

    expect(requestBody, {
      'account': 'jason1324',
      'password': '9a0ef3ecf101a8b0856f98eb6b2e2c24',
    });
    expect(session.accessToken, 'access-token');
  });

  test('App state sync replaces demo devices with OpenAPI devices', () async {
    final state = AppState(openApiClient: _FakeOpenApiClient());

    await state.syncFromOpenApi(
      account: 'jason1324',
      password: 'plain-password',
      dtuDtuid: '30340387838800344455',
    );

    expect(state.hasCloudData, isTrue);
    expect(state.devices, hasLength(1));
    expect(state.devices.single.id, '488330252727058433');
    expect(state.devices.single.name, 'Sierro 1000');
    expect(state.devices.single.batteryPercent, 0);
    expect(state.cloudSyncStatus, 'Device linked - awaiting first telemetry');

    state.dispose();
  });

  test('BLE codec matches the provisioning encryption sample', () {
    final codec = SierroBleCodec(dtuid: '10716326125928113457');

    expect(codec.keyHex, '3e5f74c8f617610ec1480f8ccd8cfd82');
    expect(codec.encodePayload({'CID': 30003}), 'WHboM5bZRx0PUqSVzYPFYw==');
    expect(
      _hex(codec.encodePackets({'CID': 30003}).single),
      '0101185748626f4d35625a52783050557153567a59504659773d3d',
    );
  });

  test('BLE codec parses DTUID from advertisement name', () {
    expect(
      SierroBleCodec.dtuidFromAdvertisementName('SSL_0IIOTUJF3AgEpIA=='),
      '20839350917702012920',
    );
  });

  test('BLE packet assembler decodes local command round trips', () {
    final codec = SierroBleCodec(
      dtuid: '10716326125928113457',
      maxPacketDataLength: 8,
    );
    final assembler = SierroBlePacketAssembler(codec);
    Map<String, dynamic>? decoded;

    for (final packet in codec.encodePackets({
      'CID': 30005,
      'PL': {'SSID': 'Lab', 'Key': 'secret'},
    })) {
      decoded = assembler.addPacket(packet) ?? decoded;
    }

    expect(decoded, {
      'CID': 30005,
      'PL': {'SSID': 'Lab', 'Key': 'secret'},
    });
  });
}

String _hex(List<int> bytes) {
  return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
}

class _FakeOpenApiClient extends OpenApiClient {
  _FakeOpenApiClient()
    : super(
        config: const OpenApiConfig(
          baseUrl: 'https://solar.siseli.com/openapis',
          appId: 'app',
          appSecret: 'secret',
        ),
      );

  @override
  Future<OpenApiAuthSession> loginWithAccount({
    required String account,
    required String password,
  }) async {
    return const OpenApiAuthSession(
      raw: {
        'code': 0,
        'data': {'accessToken': 'token'},
      },
      accessToken: 'token',
    );
  }

  @override
  Future<Map<String, dynamic>> deviceList({
    int page = 1,
    int count = 100,
    int? stationId,
    String? dtuDtuid,
    String? name,
  }) async {
    return {
      'code': 0,
      'data': {
        'list': [
          {
            'id': '488330252727058433',
            'name': 'Sierro 1000',
            'serialNumber': '2412315001',
            'dtuDtuid': '30340387838800344455',
            'state': 0,
          },
        ],
      },
    };
  }

  @override
  Future<Map<String, dynamic>> deviceDetails(Object deviceId) async {
    return {
      'code': 0,
      'data': {
        'id': '$deviceId',
        'name': 'Sierro 1000',
        'serialNumber': '2412315001',
        'dtuDtuid': '30340387838800344455',
        'state': 0,
      },
    };
  }

  @override
  Future<Map<String, dynamic>> latestDeviceState(
    Object deviceId, {
    int? dataSource,
  }) async {
    return {'code': 71311, 'message': 'No latest data'};
  }

  @override
  Future<Map<String, dynamic>> energyFlow(Object deviceId, {int? dataSource}) {
    return Future.value({'code': 71311, 'message': 'No latest data'});
  }

  @override
  Future<Map<String, dynamic>> alarmList({
    int page = 1,
    int count = 50,
    Object? deviceId,
    String? certificateDtuId,
  }) async {
    return {
      'code': 0,
      'data': {'list': []},
    };
  }

  @override
  void close() {}
}
