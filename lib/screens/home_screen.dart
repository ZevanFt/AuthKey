import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:totp_auth/core/theme.dart';
import 'package:totp_auth/models/totp_account.dart';
import 'package:totp_auth/services/totp_provider.dart';
import 'package:totp_auth/screens/add_account_screen.dart';
import 'package:totp_auth/screens/scan_screen.dart';
import 'package:totp_auth/screens/settings_screen.dart';
import 'package:totp_auth/widgets/account_card.dart';

/// 主屏幕
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Consumer<TotpProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return _buildLoadingState();
          if (provider.error != null) return _buildErrorState(context, provider);
          if (provider.accounts.isEmpty) return _buildEmptyState(context);
          return _buildAccountList(context, provider);
        },
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          const Text('AuthKey'),
        ],
      ),
      actions: [
        // 设置按钮 - 纯icon，无边框
        IconButton(
          icon: const Icon(Icons.settings_rounded, size: 22),
          tooltip: '设置',
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentIndigo));
  }

  Widget _buildErrorState(BuildContext context, TotpProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 40, color: AppTheme.accentRose.withValues(alpha: 0.7)),
            const SizedBox(height: 16),
            Text('加载失败', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(provider.error ?? '', style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            OutlinedButton(onPressed: provider.loadAccounts, child: const Text('重试')),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(24),
                border: Border.all(color: colorScheme.primary.withValues(alpha: 0.12), width: 0.5),
              ),
              child: Icon(Icons.shield_outlined, size: 36, color: colorScheme.primary.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 28),
            Text('暂无验证账户', style: TextStyle(color: colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.01)),
            const SizedBox(height: 8),
            Text('扫描二维码或手动添加\n您的第一个 TOTP 账户', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.35), fontSize: 13, height: 1.6), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            FilledButton.icon(onPressed: () => _navigateToScan(context), icon: const Icon(Icons.qr_code_scanner_rounded, size: 18), label: const Text('扫描二维码')),
            const SizedBox(height: 10),
            OutlinedButton.icon(onPressed: () => _navigateToAdd(context), icon: const Icon(Icons.add_rounded, size: 18), label: const Text('手动添加')),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountList(BuildContext context, TotpProvider provider) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildStatsBar(context, provider)),
        SliverReorderableList(
          onReorder: provider.reorderAccounts,
          proxyDecorator: (child, index, animation) {
            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                final value = Curves.easeOutCubic.transform(animation.value);
                return Transform.scale(scale: 1.0 + value * 0.03, child: Opacity(opacity: 1.0 - value * 0.1, child: child));
              },
              child: child,
            );
          },
          itemCount: provider.accounts.length,
          itemBuilder: (context, index) {
            final account = provider.accounts[index];
            return AccountCard(
              key: ValueKey(account.id), account: account,
              code: provider.generateCode(account), progress: provider.progress(account),
              remainingSeconds: provider.remainingSeconds(account),
              onCopy: () => _copyCode(context, provider.generateCode(account)),
              onEdit: () => _navigateToEdit(context, account),
              onDelete: () => _confirmDelete(context, provider, account),
            );
          },
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }

  Widget _buildStatsBar(BuildContext context, TotpProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: colorScheme.outline, width: 0.5)),
      child: Row(
        children: [
          Icon(Icons.key_rounded, size: 14, color: colorScheme.primary.withValues(alpha: 0.7)),
          const SizedBox(width: 8),
          Text('${provider.accounts.length} 个账户', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12, fontWeight: FontWeight.w500)),
          const Spacer(),
          _buildNextExpiryHint(provider),
        ],
      ),
    );
  }

  Widget _buildNextExpiryHint(TotpProvider provider) {
    if (provider.accounts.isEmpty) return const SizedBox.shrink();
    int minRemaining = 30;
    for (final a in provider.accounts) { final r = provider.remainingSeconds(a); if (r < minRemaining) minRemaining = r; }
    if (minRemaining <= 5) {
      return Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 5, height: 5, decoration: const BoxDecoration(color: AppTheme.accentRose, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        const Text('即将刷新', style: TextStyle(color: AppTheme.accentRose, fontSize: 11, fontWeight: FontWeight.w500)),
      ]);
    }
    return const SizedBox.shrink();
  }

  /// FAB - 点击弹出扫描/手动输入选项
  Widget _buildFAB(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: AppTheme.accentIndigo.withValues(alpha: 0.25), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: FloatingActionButton(
        onPressed: () => _showAddOptions(context),
        backgroundColor: AppTheme.accentIndigo,
        foregroundColor: Colors.white,
        elevation: 0, highlightElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: const Icon(Icons.add_rounded, size: 24),
      ),
    );
  }

  /// 弹出添加选项
  void _showAddOptions(BuildContext context) {
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
              // 拖拽指示条
              Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: colorScheme.outline, borderRadius: BorderRadius.circular(2))),
              // 扫描二维码
              ListTile(
                leading: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: AppTheme.accentIndigo.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.qr_code_scanner_rounded, color: AppTheme.accentIndigo, size: 22),
                ),
                title: const Text('扫描二维码', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('扫描 otpauth:// 二维码'),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: () { Navigator.of(ctx).pop(); _navigateToScan(context); },
              ),
              const SizedBox(height: 8),
              // 手动输入
              ListTile(
                leading: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: AppTheme.accentPurple.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.edit_rounded, color: AppTheme.accentPurple, size: 22),
                ),
                title: const Text('手动输入', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('手动填写密钥信息'),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: () { Navigator.of(ctx).pop(); _navigateToAdd(context); },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _copyCode(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.check_circle_rounded, size: 16, color: AppTheme.accentEmerald),
        const SizedBox(width: 8), Text('已复制 $code'),
      ]), duration: const Duration(seconds: 2)),
    );
  }

  void _navigateToScan(BuildContext context) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ScanScreen()));
  void _navigateToAdd(BuildContext context, {TotpAccount? account}) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddAccountScreen(account: account)));
  void _navigateToEdit(BuildContext context, TotpAccount account) => _navigateToAdd(context, account: account);

  void _confirmDelete(BuildContext context, TotpProvider provider, TotpAccount account) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除账户'),
        content: Text('确定要删除 ${account.displayName} 吗？\n此操作不可撤销。'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('取消')),
          FilledButton(style: FilledButton.styleFrom(backgroundColor: AppTheme.accentRose),
            onPressed: () { Navigator.of(ctx).pop(); provider.deleteAccount(account.id); }, child: const Text('删除')),
        ],
      ),
    );
  }
}
