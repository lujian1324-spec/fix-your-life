import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

class SierroSigner {
  const SierroSigner({required this.appId, required this.appSecret});

  final String appId;
  final String appSecret;

  Map<String, String> signedHeaders({
    required String body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? extraHeaders,
    String? accessToken,
    String acceptLanguage = 'en-US',
    String timeZone = 'Asia/Shanghai',
    String? nonce,
  }) {
    final requestNonce = nonce ?? _randomNonce();
    final bodyHash = _bodyHash(body);
    final sign = calculateSign({
      ..._stringQueryParameters(queryParameters),
      'IOT-Open-AppID': appId,
      'IOT-Open-Nonce': requestNonce,
      'IOT-Open-Body-Hash': bodyHash,
    });

    final headers = {
      'Content-Type': 'application/json;charset=UTF-8',
      'Accept-Language': acceptLanguage,
      'IOT-Time-Zone': timeZone,
      'IOT-Open-AppID': appId,
      'IOT-Open-Nonce': requestNonce,
      'IOT-Open-Body-Hash': bodyHash,
      'IOT-Open-Sign': sign,
    };
    if (accessToken != null && accessToken.isNotEmpty) {
      headers['IOT-Token'] = accessToken;
    }
    if (extraHeaders != null) headers.addAll(extraHeaders);
    return headers;
  }

  String calculateSign(Map<String, String> params) {
    final sortedKeys = params.keys.toList()..sort();
    final canonical = sortedKeys.map((key) => '$key=${params[key]}').join('&');
    final encoded = base64Encode(utf8.encode(canonical));
    final hmacDigest = Hmac(
      sha256,
      utf8.encode(appSecret),
    ).convert(utf8.encode(encoded));
    return md5.convert(hmacDigest.bytes).toString();
  }

  String _bodyHash(String body) {
    if (body.isEmpty) return '';
    return sha256.convert(utf8.encode(body)).toString().toLowerCase();
  }

  Map<String, String> _stringQueryParameters(Map<String, dynamic>? query) {
    final result = <String, String>{};
    if (query == null) return result;
    for (final entry in query.entries) {
      if (entry.key == 'IOT-Open-AppID' ||
          entry.key == 'IOT-Open-Nonce' ||
          entry.key == 'IOT-Open-Body-Hash') {
        continue;
      }
      result[entry.key] = '${entry.value}';
    }
    return result;
  }

  String _randomNonce() {
    const chars =
        '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final random = Random.secure();
    return List.generate(32, (_) => chars[random.nextInt(chars.length)]).join();
  }
}
