import 'package:flutter/material.dart';
import 'package:totp_auth/core/theme.dart';
import 'package:totp_auth/models/totp_account.dart';
import 'package:totp_auth/widgets/totp_code_display.dart';

/// TOTP 账户卡片 - Linear Aesthetic 风格
class AccountCard extends StatelessWidget {
  final TotpAccount account;
  final String code;
  final double progress;
  final int remainingSeconds;
  final VoidCallback? onCopy;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AccountCard({
    super.key,
    required this.account,
    required this.code,
    required this.progress,
    required this.remainingSeconds,
    this.onCopy,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final surface = colorScheme.surface;
    final borderSubtle = colorScheme.outline;
    final textPrimary = colorScheme.onSurface;
    final textTertiary = colorScheme.onSurface.withValues(alpha: 0.35);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderSubtle, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentIndigo.withValues(alpha: isDark ? 0.03 : 0.02),
            blurRadius: 20,
            spreadRadius: -2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onCopy,
          borderRadius: BorderRadius.circular(14),
          splashColor: AppTheme.accentIndigo.withValues(alpha: 0.08),
          highlightColor: AppTheme.accentIndigo.withValues(alpha: 0.04),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            child: Row(
              children: [
                _buildIssuerIcon(context),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAccountHeader(context, textPrimary, textTertiary),
                      const SizedBox(height: 8),
                      TotpCodeDisplay(
                        code: code,
                        progress: progress,
                        remainingSeconds: remainingSeconds,
                        onCopy: onCopy,
                        digits: account.digits,
                      ),
                    ],
                  ),
                ),
                _buildMoreButton(context, textTertiary, surface, borderSubtle),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIssuerIcon(BuildContext context) {
    final initial = (account.issuer.isNotEmpty
            ? account.issuer[0]
            : account.accountName[0])
        .toUpperCase();

    final colors = [
      AppTheme.accentIndigo,
      AppTheme.accentPurple,
      AppTheme.accentEmerald,
      AppTheme.accentAmber,
    ];
    final colorIndex = initial.codeUnitAt(0) % colors.length;
    final accentColor = colors[colorIndex];

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: 0.15), width: 0.5),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(color: accentColor, fontWeight: FontWeight.w700, fontSize: 17, height: 1),
      ),
    );
  }

  Widget _buildAccountHeader(BuildContext context, Color textPrimary, Color textTertiary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          account.issuer.isNotEmpty ? account.issuer : account.accountName,
          style: TextStyle(
            color: textPrimary, fontSize: 14, fontWeight: FontWeight.w600,
            letterSpacing: -0.01, height: 1.3,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (account.issuer.isNotEmpty)
          Text(
            account.accountName,
            style: TextStyle(
              color: textTertiary, fontSize: 12, fontWeight: FontWeight.w400, height: 1.4,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  Widget _buildMoreButton(BuildContext context, Color textTertiary, Color surface, Color borderSubtle) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_horiz_rounded, size: 18, color: textTertiary),
      padding: const EdgeInsets.all(4),
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: borderSubtle, width: 0.5),
      ),
      onSelected: (value) {
        switch (value) {
          case 'edit': onEdit?.call(); break;
          case 'delete': onDelete?.call(); break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          height: 40,
          child: Row(
            children: [
              Icon(Icons.edit_rounded, size: 15, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
              const SizedBox(width: 10),
              const Text('编辑', style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
        const PopupMenuEntryDivider(),
        PopupMenuItem(
          value: 'delete',
          height: 40,
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, size: 15, color: AppTheme.accentRose),
              const SizedBox(width: 10),
              const Text('删除', style: TextStyle(fontSize: 13, color: AppTheme.accentRose)),
            ],
          ),
        ),
      ],
    );
  }
}

/// 分隔线 PopupMenuEntry
class PopupMenuEntryDivider extends PopupMenuEntry<String> {
  const PopupMenuEntryDivider({super.key});

  @override
  double get height => 0.5;

  @override
  bool represents(String? value) => false;

  @override
  State<PopupMenuEntryDivider> createState() => _PopupMenuEntryDividerState();
}

class _PopupMenuEntryDividerState extends State<PopupMenuEntryDivider> {
  @override
  Widget build(BuildContext context) {
    return Divider(
      color: Theme.of(context).colorScheme.outline,
      thickness: 0.5,
      height: 0.5,
      indent: 12,
      endIndent: 12,
    );
  }
}
