import 'dart:async';

import 'package:flutter/material.dart';
import 'package:totp_auth/core/totp.dart';
import 'package:totp_auth/models/totp_account.dart';
import 'package:totp_auth/services/account_service.dart';

/// TOTP 状态管理
class TotpProvider extends ChangeNotifier {
  final AccountService _accountService;

  List<TotpAccount> _accounts = [];
  bool _isLoading = true;
  String? _error;

  // 每秒刷新的定时器
  Timer? _refreshTimer;

  TotpProvider(this._accountService) {
    _init();
  }

  List<TotpAccount> get accounts => _accounts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _init() {
    loadAccounts();
    // 每秒刷新以更新验证码和进度
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      notifyListeners();
    });
  }

  /// 加载所有账户
  Future<void> loadAccounts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _accounts = await _accountService.getAccounts();
      _isLoading = false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }

  /// 添加账户
  Future<TotpAccount> addAccount(TotpAccount account) async {
    try {
      final newAccount = await _accountService.addAccount(account);
      _accounts.add(newAccount);
      _error = null;
      notifyListeners();
      return newAccount;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// 更新账户
  Future<void> updateAccount(TotpAccount account) async {
    try {
      await _accountService.updateAccount(account);
      final index = _accounts.indexWhere((a) => a.id == account.id);
      if (index >= 0) {
        _accounts[index] = account;
      }
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// 删除账户
  Future<void> deleteAccount(String accountId) async {
    try {
      await _accountService.deleteAccount(accountId);
      _accounts.removeWhere((a) => a.id == accountId);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// 重新排序
  Future<void> reorderAccounts(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex -= 1;
    final account = _accounts.removeAt(oldIndex);
    _accounts.insert(newIndex, account);
    await _accountService.reorderAccounts(_accounts);
    notifyListeners();
  }

  /// 生成当前验证码
  String generateCode(TotpAccount account) {
    return TotpAlgorithm.generateCode(
      secret: account.secret,
      time: DateTime.now().millisecondsSinceEpoch,
      timeStep: account.period,
      digits: account.digits,
      algorithm: account.algorithm,
    );
  }

  /// 获取剩余秒数
  int remainingSeconds(TotpAccount account) {
    return TotpAlgorithm.remainingSeconds(
      time: DateTime.now().millisecondsSinceEpoch,
      timeStep: account.period,
    );
  }

  /// 获取进度
  double progress(TotpAccount account) {
    return TotpAlgorithm.progress(
      time: DateTime.now().millisecondsSinceEpoch,
      timeStep: account.period,
    );
  }

  /// 导出账户
  Future<String> exportAccounts() async {
    return _accountService.exportAccounts();
  }

  /// 导入账户
  Future<int> importAccounts(String jsonData, {bool overwrite = false}) async {
    final count = await _accountService.importAccounts(jsonData, overwrite: overwrite);
    await loadAccounts();
    return count;
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
