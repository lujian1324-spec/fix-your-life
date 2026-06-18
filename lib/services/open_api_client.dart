import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import '../config/sierro_environment.dart';
import 'sierro_signer.dart';

class OpenApiConfig {
  const OpenApiConfig({
    required this.baseUrl,
    required this.appId,
    required this.appSecret,
  });

  final String baseUrl;
  final String appId;
  final String appSecret;

  static const placeholder = OpenApiConfig(
    baseUrl: SierroEnvironment.baseUrl,
    appId: SierroEnvironment.appId,
    appSecret: SierroEnvironment.appSecret,
  );
}

class OpenApiAuthSession {
  const OpenApiAuthSession({
    required this.raw,
    this.accessToken,
    this.refreshToken,
  });

  final Map<String, dynamic> raw;
  final String? accessToken;
  final String? refreshToken;

  factory OpenApiAuthSession.fromResponse(Map<String, dynamic> response) {
    final data = response['data'];
    final source = data is Map<String, dynamic> ? data : response;
    return OpenApiAuthSession(
      raw: response,
      accessToken: _stringValue(source, const [
        'accessToken',
        'token',
        'iotToken',
        'IOT-Token',
      ]),
      refreshToken: _stringValue(source, const ['refreshToken']),
    );
  }

  static String? _stringValue(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value is String && value.isNotEmpty) return value;
    }
    return null;
  }
}

class OpenApiClient {
  OpenApiClient({
    OpenApiConfig config = OpenApiConfig.placeholder,
    http.Client? httpClient,
  }) : _config = config,
       _client = httpClient ?? http.Client(),
       _signer = SierroSigner(appId: config.appId, appSecret: config.appSecret),
       _accessToken = null;

  OpenApiClient.authenticated(
    String accessToken, {
    OpenApiConfig config = OpenApiConfig.placeholder,
    http.Client? httpClient,
  }) : _config = config,
       _client = httpClient ?? http.Client(),
       _signer = SierroSigner(appId: config.appId, appSecret: config.appSecret),
       _accessToken = accessToken;

  final OpenApiConfig _config;
  final http.Client _client;
  final SierroSigner _signer;
  String? _accessToken;

  void setAccessToken(String? accessToken) {
    _accessToken = accessToken;
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final base = Uri.parse(_config.baseUrl);
    final normalized = path.startsWith('/') ? path.substring(1) : path;
    return base.replace(
      path: '${base.path.replaceFirst(RegExp(r'/$'), '')}/$normalized',
      queryParameters: query?.map((key, value) => MapEntry(key, '$value')),
    );
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> payload, [
    Map<String, dynamic>? query,
    Map<String, String>? extraHeaders,
  ]) async {
    final body = jsonEncode(payload);
    final response = await _client.post(
      _uri(path, query),
      headers: _signer.signedHeaders(
        body: body,
        queryParameters: query,
        accessToken: _accessToken,
        extraHeaders: extraHeaders,
      ),
      body: body,
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> getJson(
    String path, [
    Map<String, dynamic>? query,
    Map<String, String>? extraHeaders,
  ]) async {
    final response = await _client.get(
      _uri(path, query),
      headers: _signer.signedHeaders(
        body: '',
        queryParameters: query,
        accessToken: _accessToken,
        extraHeaders: extraHeaders,
      ),
    );
    return _decode(response);
  }

  Future<OpenApiAuthSession> loginWithAccount({
    required String account,
    required String password,
  }) async {
    final encryptedPassword = md5.convert(utf8.encode(password)).toString();
    final response = await postJson('/login/account', {
      'account': account,
      'password': encryptedPassword,
    });
    final session = OpenApiAuthSession.fromResponse(response);
    setAccessToken(session.accessToken);
    return session;
  }

  Future<OpenApiAuthSession> refreshAccessToken({
    required String accessToken,
    required String refreshToken,
  }) async {
    final response = await postJson('/login/refresh/access/token', {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    });
    final session = OpenApiAuthSession.fromResponse(response);
    setAccessToken(session.accessToken ?? accessToken);
    return session;
  }

  Future<Map<String, dynamic>> sendEmailCaptcha(String email) {
    return postJson('/user/send/email/captcha', {'email': email});
  }

  Future<Map<String, dynamic>> loginByEmail({
    required String email,
    required String captcha,
  }) {
    return postJson('/login/email', {'email': email, 'captcha': captcha});
  }

  Future<Map<String, dynamic>> stationList({
    int page = 1,
    int count = 100,
    String? name,
  }) {
    final payload = <String, dynamic>{'page': page, 'count': count};
    if (name != null && name.isNotEmpty) payload['name'] = name;
    return postJson('/station/list', payload);
  }

  Future<Map<String, dynamic>> deviceList({
    int page = 1,
    int count = 100,
    int? stationId,
    String? dtuDtuid,
    String? name,
  }) {
    final payload = <String, dynamic>{'page': page, 'count': count};
    if (stationId != null) payload['stationId'] = stationId;
    if (dtuDtuid != null) payload['dtuDtuid'] = dtuDtuid;
    if (name != null && name.isNotEmpty) payload['name'] = name;
    return postJson('/device/list', payload);
  }

  Future<Map<String, dynamic>> addSingleDevice({
    required String deviceName,
    required String dtuDtuid,
    required Object stationId,
    String? deviceSerialNumber,
    String? place,
    String? installVendor,
    double? ratedPower,
    bool? isRestartAfterAdded,
    bool? isVirtualSerialNumber,
    DateTime? installedAt,
    Map<String, dynamic>? extraProperty,
  }) {
    final payload = <String, dynamic>{
      'deviceName': deviceName,
      'dtuDtuid': dtuDtuid,
      'stationId': stationId,
    };
    if (deviceSerialNumber != null && deviceSerialNumber.isNotEmpty) {
      payload['deviceSerialNumber'] = deviceSerialNumber;
    }
    if (place != null && place.isNotEmpty) payload['place'] = place;
    if (installVendor != null && installVendor.isNotEmpty) {
      payload['installVendor'] = installVendor;
    }
    if (ratedPower != null) payload['ratedPower'] = ratedPower;
    if (isRestartAfterAdded != null) {
      payload['isRestartAfterAdded'] = isRestartAfterAdded;
    }
    if (isVirtualSerialNumber != null) {
      payload['isVirtualSerialNumber'] = isVirtualSerialNumber;
    }
    if (installedAt != null) {
      payload['installedAt'] = installedAt.toUtc().toIso8601String();
    }
    if (extraProperty != null) payload['extraProperty'] = extraProperty;
    return postJson('/device/add/single', payload);
  }

  Future<Map<String, dynamic>> devicesByDtuDtuid(String dtuDtuid) {
    return deviceList(dtuDtuid: dtuDtuid);
  }

  Future<Map<String, dynamic>> deviceDtuInfo(String dtuDtuid) {
    return getJson('/device/dtu/info', {'dtuDtuid': dtuDtuid});
  }

  Future<Map<String, dynamic>> deviceByDtuId(String dtuId) {
    return getJson('/device/query/by/dtuId', {'dtuId': dtuId});
  }

  Future<Map<String, dynamic>> queryDeviceDtuids(List<String> dtuids) {
    return getJson('/device/query/dtuids', {'dtuids': dtuids.join(',')});
  }

  Future<Map<String, dynamic>> dtuList({
    int page = 1,
    int count = 100,
    String? dtuid,
    bool? fuzzyDtuid,
    int? stationId,
    String? model,
  }) {
    final payload = <String, dynamic>{'page': page, 'count': count};
    if (dtuid != null && dtuid.isNotEmpty) payload['dtuid'] = dtuid;
    if (fuzzyDtuid != null) payload['fuzzyDtuid'] = fuzzyDtuid;
    if (stationId != null) payload['stationId'] = stationId;
    if (model != null && model.isNotEmpty) payload['model'] = model;
    return postJson('/dtu/query/list', payload);
  }

  Future<Map<String, dynamic>> deviceDetails(Object deviceId) {
    return getJson('/device/details', {'deviceId': deviceId});
  }

  Future<Map<String, dynamic>> updateDevice({
    required Object id,
    required String name,
    String? place,
    String? installVendor,
    double? ratedPower,
    DateTime? installedAt,
    Map<String, dynamic>? extraProperty,
  }) {
    final payload = <String, dynamic>{'id': id, 'name': name};
    if (place != null && place.isNotEmpty) payload['place'] = place;
    if (installVendor != null && installVendor.isNotEmpty) {
      payload['installVendor'] = installVendor;
    }
    if (ratedPower != null) payload['ratedPower'] = ratedPower;
    if (installedAt != null) {
      payload['installedAt'] = installedAt.toUtc().toIso8601String();
    }
    if (extraProperty != null) payload['extraProperty'] = extraProperty;
    return postJson('/device/update', payload);
  }

  Future<Map<String, dynamic>> deleteDevice(Object id) {
    return postJson('/device/delete', {'id': id});
  }

  Future<Map<String, dynamic>> latestDeviceState(
    Object deviceId, {
    int? dataSource,
  }) {
    return getJson(
      '/remote/device/state/latest',
      _deviceQuery(deviceId, dataSource),
    );
  }

  Future<Map<String, dynamic>> latestSimpleDeviceState(
    Object deviceId, {
    int? dataSource,
  }) {
    return getJson(
      '/deviceState/simple/state/latest/v1',
      _deviceQuery(deviceId, dataSource),
    );
  }

  Future<Map<String, dynamic>> energyFlow(Object deviceId, {int? dataSource}) {
    return getJson(
      '/remote/device/energy/flow',
      _deviceQuery(deviceId, dataSource),
    );
  }

  Future<Map<String, dynamic>> simpleEnergyFlow(
    Object deviceId, {
    int? dataSource,
  }) {
    return getJson(
      '/deviceState/simple/energy/flow/v1',
      _deviceQuery(deviceId, dataSource),
    );
  }

  Future<Map<String, dynamic>> alarmList({
    int page = 1,
    int count = 50,
    Object? deviceId,
    String? certificateDtuId,
  }) {
    final payload = <String, dynamic>{
      'page': page,
      'count': count,
      'orderByCreatedTimeDesc': true,
    };
    if (deviceId != null) payload['deviceId'] = deviceId;
    if (certificateDtuId != null) {
      payload['certificateDtuID'] = certificateDtuId;
    }
    return postJson('/alarm/query/list', payload);
  }

  Future<Map<String, dynamic>> deviceAttributeHistory({
    required Object deviceId,
    required DateTime fromTime,
    required DateTime toTime,
    List<String>? keys,
    int page = 1,
    int count = 200,
    bool orderByTimeAsc = true,
    bool simple = true,
  }) {
    final payload = <String, dynamic>{
      'deviceId': deviceId,
      'fromTime': fromTime.toUtc().toIso8601String(),
      'toTime': toTime.toUtc().toIso8601String(),
      'page': page,
      'count': count,
      'orderByTimeAsc': orderByTimeAsc,
    };
    if (keys != null && keys.isNotEmpty) payload['keys'] = keys;
    return postJson(
      simple
          ? '/deviceState/simple/attribute/keys/history/v1'
          : '/deviceState/attribute/keys/history',
      payload,
    );
  }

  Future<Map<String, dynamic>> deviceStateRecordList({
    required Object deviceId,
    required DateTime fromTime,
    required DateTime toTime,
    int page = 1,
    int count = 200,
    bool orderByTimeAsc = true,
    bool simple = true,
  }) {
    return postJson(
      simple
          ? '/deviceState/simple/attribute/record/list/v1'
          : '/deviceState/attribute/record/list',
      {
        'deviceId': deviceId,
        'fromTime': fromTime.toUtc().toIso8601String(),
        'toTime': toTime.toUtc().toIso8601String(),
        'page': page,
        'count': count,
        'orderByTimeAsc': orderByTimeAsc,
      },
    );
  }

  Future<Map<String, dynamic>> deviceGenerationPowerDaily({
    required Object deviceId,
    required String time,
  }) {
    return postJson(
      '/deviceOverView/generationPower/daily',
      {'time': time},
      {'deviceId': deviceId},
    );
  }

  Future<Map<String, dynamic>> deviceGeneratedEnergyMonthly({
    required Object deviceId,
    required String time,
  }) {
    return postJson(
      '/deviceOverView/generatedEnergy/monthly',
      {'time': time},
      {'deviceId': deviceId},
    );
  }

  Future<Map<String, dynamic>> deviceGeneratedEnergyYearly({
    required Object deviceId,
    required String time,
  }) {
    return postJson(
      '/deviceOverView/generatedEnergy/yearly',
      {'time': time},
      {'deviceId': deviceId},
    );
  }

  Future<Map<String, dynamic>> deviceGeneratedEnergyTotal(Object deviceId) {
    return postJson('/deviceOverView/generatedEnergy/total', {}, {
      'deviceId': deviceId,
    });
  }

  Future<Map<String, dynamic>> readRemoteDeviceConfig({
    required Object deviceId,
    required String key,
  }) {
    return postJson(
      '/remote/device/config/read',
      {'key': key},
      {'deviceId': deviceId},
    );
  }

  Future<Map<String, dynamic>> readRemoteDeviceConfigs({
    required Object deviceId,
    required List<String> keys,
  }) {
    return postJson(
      '/remote/device/configs/read',
      {'keys': keys},
      {'deviceId': deviceId},
    );
  }

  Future<Map<String, dynamic>> writeRemoteDeviceConfig({
    required Object deviceId,
    required String key,
    required Object? value,
  }) {
    return postJson(
      '/remote/device/config/write',
      {'key': key, 'value': value},
      {'deviceId': deviceId},
    );
  }

  Future<Map<String, dynamic>> peakValleyTypes(Object deviceId) {
    return getJson('/peakValley/types/device', {'deviceId': deviceId});
  }

  Future<Map<String, dynamic>> peakValleySettings(Object deviceId) {
    return getJson('/peakValley/device/get', {'deviceId': deviceId});
  }

  Future<Map<String, dynamic>> setPeakValleyEnabled({
    required Object deviceId,
    required bool isEnabled,
    String? category,
  }) {
    final payload = <String, dynamic>{
      'deviceId': deviceId,
      'isEnabled': isEnabled,
    };
    if (category != null && category.isNotEmpty) payload['category'] = category;
    return postJson('/peakValley/device/enable', payload);
  }

  Future<Map<String, dynamic>> nearDtuCheckin(String dtuid) {
    return postJson('/near/dtu/checkin', {}, null, {'IOT-DTUID': dtuid});
  }

  Future<Map<String, dynamic>> parseNearDeviceState({
    required String dtuid,
    required String protocolNo,
    required String verCode,
    required List<Map<String, dynamic>> commands,
  }) {
    return postJson(
      '/near/dtu/parse/device/state',
      {'ct': commands},
      {'protocolNo': protocolNo, 'verCode': verCode},
      {'IOT-DTUID': dtuid},
    );
  }

  Future<Map<String, dynamic>> parseNearEnergyFlow({
    required String dtuid,
    required String protocolNo,
    required String verCode,
    required List<Map<String, dynamic>> commands,
  }) {
    return postJson(
      '/near/dtu/parse/device/energy/flow',
      {'ct': commands},
      {'protocolNo': protocolNo, 'verCode': verCode},
      {'IOT-DTUID': dtuid},
    );
  }

  Map<String, dynamic> _decode(http.Response response) {
    final text = utf8.decode(response.bodyBytes);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw OpenApiException(response.statusCode, text);
    }
    final decoded = jsonDecode(text);
    if (decoded is Map<String, dynamic>) return decoded;
    return {'data': decoded};
  }

  Map<String, dynamic> _deviceQuery(Object deviceId, int? dataSource) {
    final query = <String, dynamic>{'deviceId': deviceId};
    if (dataSource != null) query['dataSource'] = dataSource;
    return query;
  }

  void close() => _client.close();
}

class OpenApiException implements Exception {
  const OpenApiException(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  String toString() => 'OpenApiException($statusCode): $body';
}
