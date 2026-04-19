import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:totp_auth/core/theme.dart';
import 'package:totp_auth/services/settings_provider.dart';

/// 安全隐私保护页面
class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _oldPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscureOld = true;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('安全隐私保护')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('转移密码保护', style: TextStyle(
              color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w600,
            )),
            const SizedBox(height: 6),
            Text('设置转移密码后，导出账户数据时需要验证密码，防止未授权的数据转移。', style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 13, height: 1.6,
            )),
            const SizedBox(height: 20),

            if (settings.hasTransferPassword) ...[
              _buildStatusCard(context, true),
              const SizedBox(height: 20),
              _buildUpdatePasswordForm(context),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _removePassword(context),
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text('移除转移密码'),
                style: OutlinedButton.styleFrom(foregroundColor: AppTheme.accentRose),
              ),
            ] else ...[
              _buildStatusCard(context, false),
              const SizedBox(height: 20),
              _buildSetPasswordForm(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, bool isSet) {
    final color = isSet ? AppTheme.accentEmerald : AppTheme.accentAmber;
    final icon = isSet ? Icons.check_circle_rounded : Icons.info_rounded;
    final text = isSet ? '转移密码已设置' : '转移密码未设置';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.15), width: 0.5),
      ),
      child: Row(children: [
        Icon(icon, size: 18, color: color), const SizedBox(width: 10),
        Text(text, style: TextStyle(color: color.withValues(alpha: 0.9), fontSize: 13, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  /// 首次设置密码表单
  Widget _buildSetPasswordForm(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('设置转移密码', style: TextStyle(
          color: colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.w600,
        )),
        const SizedBox(height: 12),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: '请输入密码（至少6位）',
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded, size: 18),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _confirmController,
          obscureText: _obscureConfirm,
          decoration: InputDecoration(
            hintText: '确认密码',
            suffixIcon: IconButton(
              icon: Icon(_obscureConfirm ? Icons.visibility_rounded : Icons.visibility_off_rounded, size: 18),
              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => _setPassword(context),
            child: const Text('设置密码'),
          ),
        ),
      ],
    );
  }

  /// 修改密码表单（含旧密码输入框）
  Widget _buildUpdatePasswordForm(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('修改转移密码', style: TextStyle(
          color: colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.w600,
        )),
        const SizedBox(height: 12),
        // 旧密码
        TextField(
          controller: _oldPasswordController,
          obscureText: _obscureOld,
          decoration: InputDecoration(
            hintText: '请输入当前密码',
            suffixIcon: IconButton(
              icon: Icon(_obscureOld ? Icons.visibility_rounded : Icons.visibility_off_rounded, size: 18),
              onPressed: () => setState(() => _obscureOld = !_obscureOld),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // 新密码
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: '请输入新密码（至少6位）',
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded, size: 18),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // 确认新密码
        TextField(
          controller: _confirmController,
          obscureText: _obscureConfirm,
          decoration: InputDecoration(
            hintText: '确认新密码',
            suffixIcon: IconButton(
              icon: Icon(_obscureConfirm ? Icons.visibility_rounded : Icons.visibility_off_rounded, size: 18),
              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => _updatePassword(context),
            child: const Text('修改密码'),
          ),
        ),
      ],
    );
  }

  /// 首次设置密码
  void _setPassword(BuildContext context) async {
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('密码至少需要6位')));
      return;
    }
    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('两次输入的密码不一致')));
      return;
    }

    final settings = context.read<SettingsProvider>();
    await settings.setTransferPassword(password);
    _passwordController.clear();
    _confirmController.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('转移密码已设置')));
    }
  }

  /// 修改密码（需验证旧密码）
  void _updatePassword(BuildContext context) async {
    final oldPassword = _oldPasswordController.text;
    final newPassword = _passwordController.text;
    final confirm = _confirmController.text;

    if (oldPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入当前密码')));
      return;
    }
    if (newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('新密码至少需要6位')));
      return;
    }
    if (newPassword != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('两次输入的新密码不一致')));
      return;
    }

    // 验证旧密码
    final settings = context.read<SettingsProvider>();
    final oldVerified = await settings.verifyTransferPassword(oldPassword);
    if (!oldVerified) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('当前密码验证失败')));
      }
      return;
    }

    // 旧密码正确，设置新密码
    await settings.setTransferPassword(newPassword);
    _oldPasswordController.clear();
    _passwordController.clear();
    _confirmController.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('转移密码已修改')));
    }
  }

  /// 移除密码 - 需验证当前密码
  void _removePassword(BuildContext context) async {
    final verified = await _showVerifyCurrentPasswordDialog(context);
    if (!verified) return;

    final settings = context.read<SettingsProvider>();
    await settings.removeTransferPassword();
    if (settings.biometricLock) {
      await settings.setBiometricLock(false);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('转移密码已移除，生物识别已关闭')));
    }
  }

  /// 弹出验证当前密码对话框
  Future<bool> _showVerifyCurrentPasswordDialog(BuildContext context) async {
    final controller = TextEditingController();
    final settings = context.read<SettingsProvider>();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('验证当前密码'),
        content: TextField(
          controller: controller,
          obscureText: true,
          autofocus: true,
          decoration: const InputDecoration(hintText: '请输入当前转移密码'),
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

    if (result != true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('当前密码验证失败')));
      }
    }
    return result ?? false;
  }
}
