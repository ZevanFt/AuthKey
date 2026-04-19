import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:totp_auth/core/theme.dart';
import 'package:totp_auth/services/settings_provider.dart';
import 'package:totp_auth/screens/about_screen.dart';
import 'package:totp_auth/screens/transfer_screen.dart';
import 'package:totp_auth/screens/security_screen.dart';
import 'package:totp_auth/screens/oss_licenses_screen.dart';

/// 设置页面
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _canCheckBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  void _checkBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      final enrolled = await _localAuth.getAvailableBiometrics();
      debugPrint('[Biometric] canCheckBiometrics=$canCheck, isDeviceSupported=$isSupported, enrolled=$enrolled');
      _canCheckBiometrics = canCheck && isSupported && enrolled.isNotEmpty;
    } catch (e) {
      debugPrint('[Biometric] check failed: $e');
      _canCheckBiometrics = false;
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          if (!settings.isLoaded) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentIndigo));
          }
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              _buildSectionHeader(context, '外观'),
              _buildThemeModeTile(context, settings),
              const SizedBox(height: 4),
              _buildSectionHeader(context, '数据'),
              _buildTransferTile(context),
              const SizedBox(height: 4),
              _buildSectionHeader(context, '安全'),
              _buildBiometricLockTile(context, settings),
              _buildTransferPasswordTile(context, settings),
              const SizedBox(height: 4),
              _buildSectionHeader(context, '其他'),
              _buildAboutTile(context),
              _buildOssLicensesTile(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
      child: Text(title, style: TextStyle(
        color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.06,
      )),
    );
  }

  Widget _buildThemeModeTile(BuildContext context, SettingsProvider settings) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(Icons.palette_rounded, color: colorScheme.primary),
      title: const Text('主题模式', style: TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(_themeModeLabel(settings.themeMode)),
      trailing: const Icon(Icons.chevron_right_rounded, size: 18),
      onTap: () => _showThemePicker(context, settings),
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system: return '跟随系统';
      case ThemeMode.light: return '浅色模式';
      case ThemeMode.dark: return '暗色模式';
    }
  }

  void _showThemePicker(BuildContext context, SettingsProvider settings) {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: colorScheme.outline, borderRadius: BorderRadius.circular(2))),
              Text('选择主题模式', style: TextStyle(color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              _buildThemeOption(ctx, settings, ThemeMode.system, Icons.brightness_auto_rounded, '跟随系统', '根据系统设置自动切换'),
              _buildThemeOption(ctx, settings, ThemeMode.light, Icons.light_mode_rounded, '浅色模式', '始终使用浅色主题'),
              _buildThemeOption(ctx, settings, ThemeMode.dark, Icons.dark_mode_rounded, '暗色模式', '始终使用深色主题'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption(BuildContext ctx, SettingsProvider settings, ThemeMode mode, IconData icon, String title, String subtitle) {
    final isSelected = settings.themeMode == mode;
    final colorScheme = Theme.of(ctx).colorScheme;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppTheme.accentIndigo : colorScheme.onSurface.withValues(alpha: 0.5)),
      title: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, color: isSelected ? AppTheme.accentIndigo : null)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withValues(alpha: 0.4))),
      trailing: isSelected ? Icon(Icons.check_circle_rounded, color: AppTheme.accentIndigo, size: 20) : null,
      onTap: () { settings.setThemeMode(mode); Navigator.of(ctx).pop(); },
    );
  }

  Widget _buildTransferTile(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(Icons.sync_alt_rounded, color: colorScheme.primary),
      title: const Text('转移动态密码', style: TextStyle(fontWeight: FontWeight.w500)),
      subtitle: const Text('导出或导入账户数据'),
      trailing: const Icon(Icons.chevron_right_rounded, size: 18),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TransferScreen())),
    );
  }

  Widget _buildBiometricLockTile(BuildContext context, SettingsProvider settings) {
    final colorScheme = Theme.of(context).colorScheme;
    // 开启生物识别的前提：设备支持 + 已设置转移密码
    final canEnable = _canCheckBiometrics && settings.hasTransferPassword;
    String subtitle;
    if (!_canCheckBiometrics) {
      subtitle = '设备不支持生物识别';
    } else if (!settings.hasTransferPassword) {
      subtitle = '需先设置转移密码';
    } else {
      subtitle = '使用指纹或人脸快速验证';
    }

    return SwitchListTile(
      secondary: Icon(Icons.fingerprint_rounded, color: canEnable ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.3)),
      title: const Text('生物识别解锁', style: TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle),
      value: settings.biometricLock,
      onChanged: canEnable ? (value) => _toggleBiometric(context, settings, value) : null,
    );
  }

  void _toggleBiometric(BuildContext context, SettingsProvider settings, bool enable) async {
    if (enable) {
      // 开启：先验证转移密码，再验证生物识别
      final pwdOk = await _verifyTransferPassword(context, settings);
      if (!pwdOk) return;

      try {
        debugPrint('[Biometric] Starting authentication to enable');
        final authenticated = await _localAuth.authenticate(
          localizedReason: '验证生物识别以开启解锁功能',
          options: const AuthenticationOptions(stickyAuth: true, biometricOnly: true),
        );
        if (authenticated) {
          settings.setBiometricLock(true);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('生物识别验证未通过')));
        }
      } catch (e) {
        debugPrint('[Biometric] Authentication error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('生物识别验证失败: $e')));
        }
      }
    } else {
      // 关闭：验证生物识别（或转移密码作为备选）
      try {
        final authenticated = await _localAuth.authenticate(
          localizedReason: '验证身份以关闭生物识别解锁',
          options: const AuthenticationOptions(stickyAuth: true, biometricOnly: false),
        );
        if (authenticated) {
          settings.setBiometricLock(false);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('验证未通过，操作已取消')));
        }
      } catch (e) {
        // 生物识别失败，回退到转移密码验证
        debugPrint('[Biometric] Fallback to password: $e');
        final pwdOk = await _verifyTransferPassword(context, settings);
        if (pwdOk) {
          settings.setBiometricLock(false);
        }
      }
    }
  }

  /// 验证转移密码弹窗
  Future<bool> _verifyTransferPassword(BuildContext context, SettingsProvider settings) async {
    final controller = TextEditingController();
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('转移密码验证失败')));
    }
    return result ?? false;
  }

  Widget _buildTransferPasswordTile(BuildContext context, SettingsProvider settings) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(Icons.password_rounded, color: colorScheme.primary),
      title: const Text('转移密码保护', style: TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(settings.hasTransferPassword ? '已设置转移密码' : '未设置'),
      trailing: const Icon(Icons.chevron_right_rounded, size: 18),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SecurityScreen())),
    );
  }

  Widget _buildAboutTile(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(Icons.info_outline_rounded, color: colorScheme.primary),
      title: const Text('关于', style: TextStyle(fontWeight: FontWeight.w500)),
      subtitle: const Text('v1.0.0'),
      trailing: const Icon(Icons.chevron_right_rounded, size: 18),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AboutScreen())),
    );
  }

  Widget _buildOssLicensesTile(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(Icons.description_outlined, color: colorScheme.primary),
      title: const Text('开放源代码许可', style: TextStyle(fontWeight: FontWeight.w500)),
      subtitle: const Text('第三方开源库声明'),
      trailing: const Icon(Icons.chevron_right_rounded, size: 18),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OpenSourceLicensesScreen())),
    );
  }
}
