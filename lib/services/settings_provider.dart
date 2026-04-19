import 'package:flutter/material.dart';
import 'package:totp_auth/services/settings_service.dart';

/// 设置状态管理
class SettingsProvider extends ChangeNotifier {
  final SettingsService _service;

  ThemeMode _themeMode = ThemeMode.system;
  bool _biometricLock = false;
  bool _hasTransferPassword = false;
  bool _isLoaded = false;

  SettingsProvider(this._service) {
    _init();
  }

  ThemeMode get themeMode => _themeMode;
  bool get biometricLock => _biometricLock;
  bool get hasTransferPassword => _hasTransferPassword;
  bool get isLoaded => _isLoaded;

  void _init() async {
    _themeMode = await _service.getThemeMode();
    _biometricLock = await _service.getBiometricLock();
    _hasTransferPassword = await _service.hasTransferPassword();
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _service.setThemeMode(mode);
    notifyListeners();
  }

  Future<void> setBiometricLock(bool enabled) async {
    _biometricLock = enabled;
    await _service.setBiometricLock(enabled);
    notifyListeners();
  }

  Future<void> setTransferPassword(String password) async {
    await _service.setTransferPassword(password);
    _hasTransferPassword = true;
    notifyListeners();
  }

  Future<bool> verifyTransferPassword(String password) async {
    return _service.verifyTransferPassword(password);
  }

  Future<void> removeTransferPassword() async {
    await _service.removeTransferPassword();
    _hasTransferPassword = false;
    notifyListeners();
  }
}
