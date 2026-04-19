import 'package:flutter/material.dart';
import 'package:totp_auth/core/theme.dart';

/// 关于页面
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('关于')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 应用图标和名称
            Center(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/icon.png',
                      width: 72, height: 72,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('AuthKey', style: TextStyle(
                    color: colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.02,
                  )),
                  const SizedBox(height: 4),
                  Text('v1.0.0', style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 13,
                  )),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // 软件介绍
            _buildSection(context, '软件介绍', [
              Text('AuthKey 是一款基于时间的一次性密码（TOTP）认证应用，支持 HMAC-SHA1/SHA256/SHA512 算法，严格遵循 RFC 6238 标准。', style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 13, height: 1.7,
              )),
              const SizedBox(height: 8),
              Text('本应用适用于 Android 和鸿蒙系统，为您的在线账户提供双因素认证（2FA）保护。', style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 13, height: 1.7,
              )),
            ]),
            const SizedBox(height: 20),

            // 功能特性
            _buildSection(context, '功能特性', [
              _buildFeatureItem(context, Icons.qr_code_scanner_rounded, '二维码扫描', '快速扫描 otpauth:// 二维码添加账户'),
              _buildFeatureItem(context, Icons.security_rounded, '安全存储', '密钥数据加密存储，保护敏感信息'),
              _buildFeatureItem(context, Icons.fingerprint_rounded, '生物识别', '支持指纹/人脸解锁，增强安全性'),
              _buildFeatureItem(context, Icons.sync_alt_rounded, '数据转移', '支持导出/导入，方便设备迁移'),
              _buildFeatureItem(context, Icons.phone_android_rounded, '跨平台', '支持 Android、鸿蒙OS 2.0 及鸿蒙NEXT'),
            ]),
            const SizedBox(height: 20),

            // 作者信息
            _buildSection(context, '作者', [
              _buildInfoRow(context, Icons.person_rounded, '开发者', '且试新茶趁年华'),
              _buildInfoRow(context, Icons.code_rounded, 'GitHub', 'ZevanFt'),
              _buildInfoRow(context, Icons.email_rounded, '邮箱', 'burachenji@126.com'),
            ]),
            const SizedBox(height: 32),

            // 版权
            Center(
              child: Text('© 2025 且试新茶趁年华\nAll rights reserved.', style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.3), fontSize: 11, height: 1.6,
              ), textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Container(
          width: double.infinity, padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: colorScheme.outline, width: 0.5)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String title, String subtitle) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppTheme.accentIndigo),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.w500)),
                Text(subtitle, style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 11, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: colorScheme.onSurface.withValues(alpha: 0.4)),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 12)),
          const Spacer(),
          Text(value, style: TextStyle(color: colorScheme.onSurface, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
