import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:totp_auth/core/theme.dart';
import 'package:totp_auth/core/totp.dart';
import 'package:totp_auth/models/totp_account.dart';
import 'package:totp_auth/services/totp_provider.dart';

/// 添加/编辑 TOTP 账户屏幕 - Linear Aesthetic 风格
class AddAccountScreen extends StatefulWidget {
  final TotpAccount? account;
  const AddAccountScreen({super.key, this.account});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _issuerController = TextEditingController();
  final _accountNameController = TextEditingController();
  final _secretController = TextEditingController();

  TotpHashAlgorithm _algorithm = TotpHashAlgorithm.sha1;
  int _digits = 6;
  int _period = 30;
  bool _obscureSecret = true;
  bool _isEditing = false;
  bool _showAdvanced = false;

  @override
  void initState() {
    super.initState();
    if (widget.account != null) {
      _isEditing = true;
      final a = widget.account!;
      _issuerController.text = a.issuer;
      _accountNameController.text = a.accountName;
      _secretController.text = a.secret;
      _algorithm = a.algorithm;
      _digits = a.digits;
      _period = a.period;
      if (a.algorithm != TotpHashAlgorithm.sha1 || a.digits != 6 || a.period != 30) {
        _showAdvanced = true;
      }
    }
  }

  @override
  void dispose() {
    _issuerController.dispose();
    _accountNameController.dispose();
    _secretController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? '编辑账户' : '添加账户')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionLabel(context, '发行方', optional: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _issuerController,
                decoration: const InputDecoration(
                  hintText: 'Google, GitHub, Microsoft...',
                  prefixIcon: Icon(Icons.business_rounded, size: 18),
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionLabel(context, '账户名'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _accountNameController,
                decoration: const InputDecoration(
                  hintText: 'user@example.com',
                  prefixIcon: Icon(Icons.person_rounded, size: 18),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return '请输入账户名';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildSectionLabel(context, '密钥 (Base32)'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _secretController,
                decoration: InputDecoration(
                  hintText: 'JBSWY3DPEHPK3PXP',
                  prefixIcon: const Icon(Icons.key_rounded, size: 18),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(_obscureSecret ? Icons.visibility_rounded : Icons.visibility_off_rounded, size: 18),
                        onPressed: () => setState(() => _obscureSecret = !_obscureSecret),
                      ),
                      if (!_isEditing)
                        IconButton(
                          icon: const Icon(Icons.auto_fix_high_rounded, size: 18),
                          tooltip: '生成随机密钥',
                          onPressed: _generateRandomSecret,
                        ),
                    ],
                  ),
                ),
                obscureText: _obscureSecret,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return '请输入密钥';
                  final cleaned = value.replaceAll(RegExp(r'\s+'), '').replaceAll('-', '').toUpperCase();
                  if (!RegExp(r'^[A-Z2-7]+=*$').hasMatch(cleaned)) return '密钥格式无效，应为 Base32 编码';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _buildAdvancedSection(context),
              const SizedBox(height: 28),
              if (_secretController.text.isNotEmpty) ...[
                _buildPreview(context),
                const SizedBox(height: 24),
              ],
              SizedBox(
                width: double.infinity,
                child: FilledButton(onPressed: _save, child: Text(_isEditing ? '保存修改' : '添加账户')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String text, {bool optional = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(text, style: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.04,
        )),
        if (optional) ...[
          const SizedBox(width: 6),
          Text('可选', style: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.35), fontSize: 10, fontWeight: FontWeight.w500,
          )),
        ],
      ],
    );
  }

  Widget _buildAdvancedSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tertiary = colorScheme.onSurface.withValues(alpha: 0.35);
    final surfaceElevated = colorScheme.surfaceContainerHighest;
    final borderSubtle = colorScheme.outline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _showAdvanced = !_showAdvanced),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(_showAdvanced ? Icons.unfold_less_rounded : Icons.unfold_more_rounded, size: 16, color: tertiary),
                const SizedBox(width: 8),
                Text('高级设置', style: TextStyle(color: tertiary, fontSize: 12, fontWeight: FontWeight.w500)),
                const Spacer(),
                if (_algorithm != TotpHashAlgorithm.sha1 || _digits != 6 || _period != 30)
                  Container(width: 5, height: 5, decoration: const BoxDecoration(color: AppTheme.accentIndigo, shape: BoxShape.circle)),
              ],
            ),
          ),
        ),
        if (_showAdvanced) ...[
          const SizedBox(height: 12),
          _buildSectionLabel(context, '哈希算法'),
          const SizedBox(height: 6),
          _buildSegmentedSelector(context, surfaceElevated, borderSubtle,
            TotpHashAlgorithm.values.map((a) => a.name).toList(),
            _algorithm.name, (v) => setState(() => _algorithm = TotpHashAlgorithm.fromString(v))),
          const SizedBox(height: 16),
          _buildSectionLabel(context, '验证码位数'),
          const SizedBox(height: 6),
          _buildSegmentedSelector(context, surfaceElevated, borderSubtle,
            ['6 位', '8 位'], _digits == 6 ? '6 位' : '8 位',
            (v) => setState(() => _digits = v == '6 位' ? 6 : 8)),
          const SizedBox(height: 16),
          _buildSectionLabel(context, '时间步长'),
          const SizedBox(height: 6),
          _buildSegmentedSelector(context, surfaceElevated, borderSubtle,
            ['30 秒', '60 秒'], _period == 30 ? '30 秒' : '60 秒',
            (v) => setState(() => _period = v == '30 秒' ? 30 : 60)),
        ],
      ],
    );
  }

  Widget _buildSegmentedSelector(BuildContext context, Color bgColor, Color borderColor,
      List<String> options, String selected, ValueChanged<String> onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor, borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Row(
        children: options.map((opt) {
          final isSelected = opt == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(opt),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.accentIndigo.withValues(alpha: 0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected ? Border.all(color: AppTheme.accentIndigo.withValues(alpha: 0.3), width: 0.5) : null,
                ),
                alignment: Alignment.center,
                child: Text(opt, style: TextStyle(
                  color: isSelected ? AppTheme.accentIndigo : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35),
                  fontSize: 12, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                )),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPreview(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final secret = _secretController.text.trim();
    try {
      final code = TotpAlgorithm.generateCode(
        secret: secret, time: DateTime.now().millisecondsSinceEpoch,
        timeStep: _period, digits: _digits, algorithm: _algorithm,
      );
      final remaining = TotpAlgorithm.remainingSeconds(
        time: DateTime.now().millisecondsSinceEpoch, timeStep: _period,
      );
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.accentIndigo.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.accentIndigo.withValues(alpha: 0.12), width: 0.5),
        ),
        child: Row(
          children: [
            Icon(Icons.preview_rounded, size: 18, color: AppTheme.accentIndigo.withValues(alpha: 0.7)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('预览', style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.04,
                  )),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(code, style: TextStyle(
                        color: colorScheme.onSurface, fontFamily: 'monospace',
                        fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: 3,
                      )),
                      const SizedBox(width: 8),
                      Text('${remaining}s', style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.35), fontSize: 12, fontWeight: FontWeight.w500,
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } catch (_) {
      return const SizedBox.shrink();
    }
  }

  void _generateRandomSecret() {
    _secretController.text = TotpAlgorithm.generateRandomSecret();
    setState(() => _obscureSecret = false);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<TotpProvider>();

    if (_isEditing) {
      final updated = widget.account!.copyWith(
        issuer: _issuerController.text.trim(), accountName: _accountNameController.text.trim(),
        secret: _secretController.text.trim().toUpperCase(), algorithm: _algorithm, digits: _digits, period: _period,
      );
      provider.updateAccount(updated).then((_) {
        if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('账户已更新'))); Navigator.of(context).pop(); }
      }).catchError((e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('更新失败: $e')));
      });
    } else {
      final account = TotpAccount(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        issuer: _issuerController.text.trim(), accountName: _accountNameController.text.trim(),
        secret: _secretController.text.trim().toUpperCase(), algorithm: _algorithm, digits: _digits, period: _period,
      );
      provider.addAccount(account).then((_) {
        if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('账户已添加'))); Navigator.of(context).pop(); }
      }).catchError((e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('添加失败: $e')));
      });
    }
  }
}
