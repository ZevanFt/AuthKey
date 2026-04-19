import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:base32/base32.dart';

/// TOTP 算法实现，支持 HMAC-SHA1/SHA256/SHA512
class TotpAlgorithm {
  /// 生成 TOTP 验证码
  ///
  /// [secret] Base32 编码的密钥
  /// [time] 当前时间（毫秒时间戳）
  /// [timeStep] 时间步长，默认30秒
  /// [digits] 验证码位数，默认6位
  /// [algorithm] HMAC算法，默认SHA1
  static String generateCode({
    required String secret,
    required int time,
    int timeStep = 30,
    int digits = 6,
    TotpHashAlgorithm algorithm = TotpHashAlgorithm.sha1,
  }) {
    final counter = _calculateCounter(time, timeStep);
    return _generateTOTP(
      secret: secret,
      counter: counter,
      digits: digits,
      algorithm: algorithm,
    );
  }

  /// 计算时间计数器
  static int _calculateCounter(int time, int timeStep) {
    return (time ~/ 1000) ~/ timeStep;
  }

  /// 生成 TOTP 码
  static String _generateTOTP({
    required String secret,
    required int counter,
    required int digits,
    required TotpHashAlgorithm algorithm,
  }) {
    // 解码 Base32 密钥
    final key = _decodeBase32(secret);

    // 将计数器转为8字节大端序
    final counterBytes = _intToBytes(counter);

    // 计算 HMAC
    final hmacDigest = _computeHmac(key, counterBytes, algorithm);

    // 动态截断
    final offset = hmacDigest[hmacDigest.length - 1] & 0x0F;
    final binary = ((hmacDigest[offset] & 0x7F) << 24) |
        ((hmacDigest[offset + 1] & 0xFF) << 16) |
        ((hmacDigest[offset + 2] & 0xFF) << 8) |
        (hmacDigest[offset + 3] & 0xFF);

    final otp = binary % _pow10(digits);
    return otp.toString().padLeft(digits, '0');
  }

  /// 解码 Base32 密钥（处理常见格式问题）
  static Uint8List _decodeBase32(String secret) {
    // 移除空格和连字符，转大写
    final cleaned = secret.replaceAll(RegExp(r'\s+'), '').replaceAll('-', '').toUpperCase();
    return base32.decode(cleaned);
  }

  /// 整数转8字节大端序
  static Uint8List _intToBytes(int value) {
    final bytes = Uint8List(8);
    for (var i = 7; i >= 0; i--) {
      bytes[i] = value & 0xFF;
      value >>= 8;
    }
    return bytes;
  }

  /// 计算 HMAC
  static Uint8List _computeHmac(
    Uint8List key,
    Uint8List message,
    TotpHashAlgorithm algorithm,
  ) {
    final hmacKey = key.toList();
    final hmacMessage = message.toList();

    switch (algorithm) {
      case TotpHashAlgorithm.sha1:
        return Uint8List.fromList(
          Hmac(sha1, hmacKey).convert(hmacMessage).bytes,
        );
      case TotpHashAlgorithm.sha256:
        return Uint8List.fromList(
          Hmac(sha256, hmacKey).convert(hmacMessage).bytes,
        );
      case TotpHashAlgorithm.sha512:
        return Uint8List.fromList(
          Hmac(sha512, hmacKey).convert(hmacMessage).bytes,
        );
    }
  }

  /// 10的n次方
  static int _pow10(int n) {
    var result = 1;
    for (var i = 0; i < n; i++) {
      result *= 10;
    }
    return result;
  }

  /// 计算当前时间步的剩余秒数（用于进度条）
  static int remainingSeconds({
    required int time,
    int timeStep = 30,
  }) {
    return timeStep - ((time ~/ 1000) % timeStep);
  }

  /// 计算进度百分比（0.0 ~ 1.0）
  static double progress({
    required int time,
    int timeStep = 30,
  }) {
    final remaining = remainingSeconds(time: time, timeStep: timeStep);
    return remaining / timeStep;
  }

  /// 生成随机 Base32 密钥（用于测试/手动添加）
  static String generateRandomSecret({int length = 20}) {
    final random = Random.secure();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    return List.generate(length, (_) => chars[random.nextInt(chars.length)])
        .join();
  }

  /// 验证 TOTP 码（用于验证用户输入）
  static bool verifyCode({
    required String secret,
    required String code,
    required int time,
    int timeStep = 30,
    int digits = 6,
    TotpHashAlgorithm algorithm = TotpHashAlgorithm.sha1,
    int window = 1,
  }) {
    for (var i = -window; i <= window; i++) {
      final adjustedTime = time + (i * timeStep * 1000);
      final expectedCode = generateCode(
        secret: secret,
        time: adjustedTime,
        timeStep: timeStep,
        digits: digits,
        algorithm: algorithm,
      );
      if (expectedCode == code) return true;
    }
    return false;
  }
}

/// TOTP 支持的哈希算法
enum TotpHashAlgorithm {
  sha1('SHA1'),
  sha256('SHA256'),
  sha512('SHA512');

  final String name;
  const TotpHashAlgorithm(this.name);

  /// 从字符串解析算法
  static TotpHashAlgorithm fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'SHA256':
      case 'SHA2':
        return TotpHashAlgorithm.sha256;
      case 'SHA512':
        return TotpHashAlgorithm.sha512;
      default:
        return TotpHashAlgorithm.sha1;
    }
  }
}
