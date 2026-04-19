# AuthKey

A Time-based One-Time Password (TOTP) authenticator app for Android & HarmonyOS.

## Features

- **TOTP Code Generation** — Supports HMAC-SHA1/SHA256/SHA512 algorithms, strictly following RFC 6238
- **QR Code Scanning** — Quickly add accounts by scanning `otpauth://` QR codes
- **Manual Entry** — Manually input issuer, account name, secret key, etc.
- **Secure Storage** — Key data encrypted via FlutterSecureStorage (AES-256)
- **Biometric Unlock** — Fingerprint/face recognition, following device security logic (depends on transfer password)
- **Transfer Password Protection** — SHA-256 hashed storage, password verification required for data export
- **Data Transfer** — Export/import JSON files, share via system share sheet
- **Theme Switching** — Follow system / Light mode / Dark mode
- **Cross-Platform** — Supports Android 6.0+, HarmonyOS 2.0, HarmonyOS NEXT

## Security Design

| Layer | Mechanism | Description |
|-------|-----------|-------------|
| Key Storage | FlutterSecureStorage | Android EncryptedSharedPreferences (AES-256) |
| Transfer Password | SHA-256 Hash | Plaintext never stored, only hash values |
| Biometric Auth | local_auth | Depends on transfer password, similar to device "fingerprint + PIN" logic |
| Network Security | No cleartext | networkSecurityConfig configured |
| Backup | Auto-backup disabled | allowBackup=false, fullBackupContent=false |

### Biometric Auth & Transfer Password Relationship

Following device security settings logic:

- Enabling biometric auth **requires setting a transfer password first** (like enabling fingerprint requires a PIN)
- Enabling biometric auth **requires verifying the transfer password**
- When exporting data: biometric auth preferred → fallback to transfer password on failure
- Removing transfer password: biometric auth is automatically disabled

## Installation

### Android

1. Download `AuthKey-v1.0.0-release.apk`
2. Enable "Install from unknown sources" in device settings
3. Install the APK

### HarmonyOS 2.0

HarmonyOS 2.0 is compatible with Android APK. Install the same way as Android.

### HarmonyOS NEXT

HarmonyOS NEXT requires building a HAP package via the Flutter ohos branch. Support coming later.

## Development

### Requirements

- Flutter 3.32+ (stable)
- Dart 3.8+
- Android SDK: compileSdk 36, minSdk 23, targetSdk 34
- NDK 27.0.12077973

### Build & Run

```bash
# Install dependencies
flutter pub get

# Run in debug mode
flutter run

# Build release APK
flutter build apk --release
```

## Tech Stack

- **Flutter** — Cross-platform UI framework
- **Provider** — State management
- **crypto** — TOTP core algorithm (HMAC-SHA1/SHA256/SHA512)
- **flutter_secure_storage** — Encrypted persistence
- **local_auth** — Biometric authentication
- **mobile_scanner** — QR code scanning (ML Kit)
- **share_plus** — System share
- **file_picker** — File selection

## Open Source Licenses

See the [Open Source Licenses](lib/screens/oss_licenses_screen.dart) page within the app.

## Author

- **Developer**: 且试新茶趁年华
- **GitHub**: [ZevanFt](https://github.com/ZevanFt)
- **Email**: burachenji@126.com

## License

© 2025 且试新茶趁年华. All rights reserved.
