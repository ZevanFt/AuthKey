import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:totp_auth/core/theme.dart';
import 'package:totp_auth/services/totp_provider.dart';
import 'package:totp_auth/services/settings_provider.dart';

/// 转移动态密码页面
class TransferScreen extends StatelessWidget {
  const TransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('转移动态密码')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('将您的 TOTP 账户数据安全地转移到其他设备', style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 13, height: 1.6,
            )),
            const SizedBox(height: 24),

            _buildActionCard(
              context,
              icon: Icons.upload_file_rounded,
              iconColor: AppTheme.accentIndigo,
              title: '导出到文件',
              subtitle: '将账户数据导出为加密 JSON 文件，可通过任何方式传输',
              onTap: () => _exportToFile(context),
            ),
            const SizedBox(height: 12),

            _buildActionCard(
              context,
              icon: Icons.file_download_rounded,
              iconColor: AppTheme.accentEmerald,
              title: '从文件导入',
              subtitle: '从之前导出的 JSON 文件恢复账户数据',
              onTap: () => _importFromFile(context),
            ),
            const SizedBox(height: 12),

            _buildActionCard(
              context,
              icon: Icons.share_rounded,
              iconColor: AppTheme.accentPurple,
              title: '分享数据',
              subtitle: '通过系统分享功能发送账户数据',
              onTap: () => _shareData(context),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.accentAmber.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.accentAmber.withValues(alpha: 0.15), width: 0.5),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded, size: 18, color: AppTheme.accentAmber),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('导出的数据包含敏感密钥信息，请妥善保管传输文件，避免泄露。', style: TextStyle(
                      color: AppTheme.accentAmber.withValues(alpha: 0.9), fontSize: 12, height: 1.5,
                    )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, {
    required IconData icon, required Color iconColor,
    required String title, required String subtitle,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 12, height: 1.4)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: colorScheme.onSurface.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }

  /// 导出前的身份验证流程
  /// 1. 如果开启了生物识别 → 先弹生物识别
  /// 2. 如果还设了转移密码 → 生物识别通过后再验证转移密码
  /// 3. 如果只设了转移密码（没开生物识别）→ 只验证转移密码
  /// 导出前的身份验证流程（手机解锁逻辑）
  /// - 开了生物识别 → 优先弹生物识别，失败可回退到转移密码
  /// - 只设了转移密码 → 输转移密码
  /// - 都没设 → 直接通过
  Future<bool> _verifyBeforeExport(BuildContext context) async {
    final settings = context.read<SettingsProvider>();

    // 无任何保护，直接通过
    if (!settings.biometricLock && !settings.hasTransferPassword) {
      return true;
    }

    // 生物识别优先
    if (settings.biometricLock) {
      final bioOk = await _authenticateBiometric(context);
      if (bioOk) return true;
      // 生物识别失败，回退到转移密码
      if (settings.hasTransferPassword) {
        return _verifyTransferPassword(context);
      }
      return false;
    }

    // 只有转移密码
    if (settings.hasTransferPassword) {
      return _verifyTransferPassword(context);
    }

    return true;
  }

  /// 生物识别验证
  Future<bool> _authenticateBiometric(BuildContext context) async {
    final localAuth = LocalAuthentication();
    try {
      final authenticated = await localAuth.authenticate(
        localizedReason: '验证身份以导出账户数据',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      return authenticated;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('生物识别验证失败: $e')),
        );
      }
      return false;
    }
  }

  /// 转移密码验证
  Future<bool> _verifyTransferPassword(BuildContext context) async {
    final controller = TextEditingController();
    final settings = context.read<SettingsProvider>();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('验证转移密码'),
        content: TextField(
          controller: controller,
          obscureText: true,
          autofocus: true,
          decoration: const InputDecoration(hintText: '请输入转移密码'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('取消')),
          FilledButton(
            onPressed: () async {
              final verified = await settings.verifyTransferPassword(controller.text);
              if (!ctx.mounted) return;
              Navigator.of(ctx).pop(verified);
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );

    if (result != true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('转移密码验证失败')),
      );
    }
    return result ?? false;
  }

  void _exportToFile(BuildContext context) async {
    final provider = context.read<TotpProvider>();

    try {
      // 身份验证
      final verified = await _verifyBeforeExport(context);
      if (!verified) return;

      final data = await provider.exportAccounts();

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/totp_accounts_export.json');
      await file.writeAsString(data);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'AuthKey 账户数据',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('导出失败: $e')));
      }
    }
  }

  void _importFromFile(BuildContext context) async {
    final provider = context.read<TotpProvider>();

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final content = file.xFile;
      final data = await content.readAsString();

      final count = await provider.importAccounts(data);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('成功导入 $count 个账户'),
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('导入失败: $e')));
      }
    }
  }

  void _shareData(BuildContext context) async {
    final provider = context.read<TotpProvider>();

    try {
      // 分享也需要身份验证
      final verified = await _verifyBeforeExport(context);
      if (!verified) return;

      final data = await provider.exportAccounts();
      await Share.share(data);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('分享失败: $e')));
      }
    }
  }
}
