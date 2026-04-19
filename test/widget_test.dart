import 'package:flutter_test/flutter_test.dart';
import 'package:totp_auth/core/totp.dart';

void main() {
  group('TOTP Algorithm Tests', () {
    test('Generate TOTP code with known test vector', () {
      // RFC 6238 test vector for SHA1
      // Secret: "12345678901234567890" (Base32: GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ)
      final code = TotpAlgorithm.generateCode(
        secret: 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ',
        time: 59000, // 59 seconds
        timeStep: 30,
        digits: 6,
        algorithm: TotpHashAlgorithm.sha1,
      );
      // At T=59, the expected TOTP for SHA1 is 287082
      expect(code, '287082');
    });

    test('Remaining seconds calculation', () {
      // At 45 seconds, with 30s step, remaining = 30 - (45 % 30) = 30 - 15 = 15
      final remaining = TotpAlgorithm.remainingSeconds(time: 45000, timeStep: 30);
      expect(remaining, 15);
    });

    test('Progress calculation', () {
      final progress = TotpAlgorithm.progress(time: 45000, timeStep: 30);
      expect(progress, 0.5);
    });

    test('Generate random secret is valid Base32', () {
      final secret = TotpAlgorithm.generateRandomSecret();
      expect(secret.length, 20);
      expect(RegExp(r'^[A-Z2-7]+$').hasMatch(secret), true);
    });

    test('TOTP code has correct digit count', () {
      final code6 = TotpAlgorithm.generateCode(
        secret: 'JBSWY3DPEHPK3PXP',
        time: DateTime.now().millisecondsSinceEpoch,
        digits: 6,
      );
      expect(code6.length, 6);

      final code8 = TotpAlgorithm.generateCode(
        secret: 'JBSWY3DPEHPK3PXP',
        time: DateTime.now().millisecondsSinceEpoch,
        digits: 8,
      );
      expect(code8.length, 8);
    });

    test('Hash algorithm from string', () {
      expect(TotpHashAlgorithm.fromString('SHA1'), TotpHashAlgorithm.sha1);
      expect(TotpHashAlgorithm.fromString('SHA256'), TotpHashAlgorithm.sha256);
      expect(TotpHashAlgorithm.fromString('SHA512'), TotpHashAlgorithm.sha512);
      expect(TotpHashAlgorithm.fromString(null), TotpHashAlgorithm.sha1);
      expect(TotpHashAlgorithm.fromString('unknown'), TotpHashAlgorithm.sha1);
    });
  });
}
