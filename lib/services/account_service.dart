import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:totp_auth/models/totp_account.dart';

/// 账户管理服务 - 负责安全存储和 CRUD 操作
class AccountService {
  static const _accountsKey = 'totp_accounts';

  final FlutterSecureStorage _storage;

  AccountService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  /// 获取所有账户
  Future<List<TotpAccount>> getAccounts() async {
    final data = await _storage.read(key: _accountsKey);
    if (data == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList
          .map((json) => TotpAccount.fromJson(json as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    } catch (_) {
      return [];
    }
  }

  /// 保存所有账户
  Future<void> _saveAccounts(List<TotpAccount> accounts) async {
    final jsonList = accounts.map((a) => a.toJson()).toList();
    await _storage.write(key: _accountsKey, value: jsonEncode(jsonList));
  }

  /// 添加账户
  Future<TotpAccount> addAccount(TotpAccount account) async {
    final accounts = await getAccounts();
    // 设置排序权重
    final maxOrder = accounts.isEmpty
        ? 0
        : accounts.map((a) => a.sortOrder).reduce((a, b) => a > b ? a : b);
    final newAccount = account.copyWith(sortOrder: maxOrder + 1);
    accounts.add(newAccount);
    await _saveAccounts(accounts);
    return newAccount;
  }

  /// 更新账户
  Future<void> updateAccount(TotpAccount account) async {
    final accounts = await getAccounts();
    final index = accounts.indexWhere((a) => a.id == account.id);
    if (index >= 0) {
      accounts[index] = account;
      await _saveAccounts(accounts);
    }
  }

  /// 删除账户
  Future<void> deleteAccount(String accountId) async {
    final accounts = await getAccounts();
    accounts.removeWhere((a) => a.id == accountId);
    await _saveAccounts(accounts);
  }

  /// 重新排序
  Future<void> reorderAccounts(List<TotpAccount> reordered) async {
    final updated = <TotpAccount>[];
    for (var i = 0; i < reordered.length; i++) {
      updated.add(reordered[i].copyWith(sortOrder: i));
    }
    await _saveAccounts(updated);
  }

  /// 导出所有账户为 JSON 字符串
  Future<String> exportAccounts() async {
    final accounts = await getAccounts();
    final jsonList = accounts.map((a) => a.toJson()).toList();
    return jsonEncode(jsonList);
  }

  /// 从 JSON 字符串导入账户
  Future<int> importAccounts(String jsonData, {bool overwrite = false}) async {
    final List<dynamic> jsonList = jsonDecode(jsonData);
    final imported = jsonList
        .map((json) => TotpAccount.fromJson(json as Map<String, dynamic>))
        .toList();

    if (overwrite) {
      await _saveAccounts(imported);
      return imported.length;
    }

    final existing = await getAccounts();
    final existingIds = existing.map((a) => a.id).toSet();
    final newAccounts = imported.where((a) => !existingIds.contains(a.id)).toList();

    // 为新账户设置排序权重
    final maxOrder = existing.isEmpty
        ? 0
        : existing.map((a) => a.sortOrder).reduce((a, b) => a > b ? a : b);
    for (var i = 0; i < newAccounts.length; i++) {
      newAccounts[i] = newAccounts[i].copyWith(sortOrder: maxOrder + i + 1);
    }

    existing.addAll(newAccounts);
    await _saveAccounts(existing);
    return newAccounts.length;
  }

  /// 检查是否已存在相同账户
  Future<bool> hasAccount(String issuer, String accountName) async {
    final accounts = await getAccounts();
    return accounts.any(
      (a) => a.issuer == issuer && a.accountName == accountName,
    );
  }
}
