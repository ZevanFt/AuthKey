import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';

/// 应用设置服务 - 持久化用户偏好
class SettingsService {
  static const _themeModeKey = 'theme_mode';
  static const _biometricLockKey = 'biometric_lock';
  static const _transferPasswordKey = 'transfer_password';

  final FlutterSecureStorage _storage;

  SettingsService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  /// 对密码进行 SHA-256 哈希
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// 获取主题模式
  Future<ThemeMode> getThemeMode() async {
    final value = await _storage.read(key: _themeModeKey);
    switch (value) {
      case 'light': return ThemeMode.light;
      case 'dark': return ThemeMode.dark;
      default: return ThemeMode.system;
    }
  }

  /// 保存主题模式
  Future<void> setThemeMode(ThemeMode mode) async {
    await _storage.write(key: _themeModeKey, value: mode.name);
  }

  /// 获取生物识别锁开关
  Future<bool> getBiometricLock() async {
    final value = await _storage.read(key: _biometricLockKey);
    return value == 'true';
  }

  /// 保存生物识别锁开关
  Future<void> setBiometricLock(bool enabled) async {
    await _storage.write(key: _biometricLockKey, value: enabled.toString());
  }

  /// 获取转移密码（是否已设置）
  Future<bool> hasTransferPassword() async {
    final value = await _storage.read(key: _transferPasswordKey);
    return value != null && value.isNotEmpty;
  }

  /// 设置转移密码（存储 SHA-256 哈希值，不存明文）
  Future<void> setTransferPassword(String password) async {
    final hashed = _hashPassword(password);
    await _storage.write(key: _transferPasswordKey, value: hashed);
  }

  /// 验证转移密码（比较哈希值）
  Future<bool> verifyTransferPassword(String password) async {
    final stored = await _storage.read(key: _transferPasswordKey);
    if (stored == null || stored.isEmpty) return false;
    final hashed = _hashPassword(password);
    return stored == hashed;
  }

  /// 删除转移密码
  Future<void> removeTransferPassword() async {
    await _storage.delete(key: _transferPasswordKey);
  }
}
