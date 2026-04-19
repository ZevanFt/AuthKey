import 'package:flutter/material.dart';
import 'package:totp_auth/core/theme.dart';

/// 开源代码许可页面
///
/// "开放源代码许可"的含义：
/// 本应用使用了多个第三方开源库，这些库的作者以开源协议（如 MIT、BSD 等）
/// 发布了他们的代码。这些协议允许我们免费使用、修改和分发这些代码，
/// 前提是我们需要保留原始的版权声明和许可声明。
/// 这不是"可商用"的意思——每个协议的具体条款不同，但 MIT 和 BSD 类协议
/// 确实允许商业使用。GPL 类协议则要求衍生作品也必须开源。
class OpenSourceLicensesScreen extends StatelessWidget {
  const OpenSourceLicensesScreen({super.key});

  /// 所有依赖的开源库信息
  static const _licenses = [
    _LicenseInfo('Flutter', '3.32.8', 'BSD-3-Clause', 'Google LLC',
      'Flutter is Google\'s UI toolkit for building beautiful, natively compiled applications for mobile, web, and desktop from a single codebase.'),
    _LicenseInfo('Dart SDK', '3.8.1', 'BSD-3-Clause', 'Google LLC',
      'Dart is a client-optimized language for fast apps on any platform.'),
    _LicenseInfo('crypto', '3.0.7', 'BSD-3-Clause', 'Dart Team',
      'Cryptographic algorithms and primitives, implemented in pure Dart.'),
    _LicenseInfo('flutter_secure_storage', '9.2.4', 'BSD-3-Clause', 'Molteo / INVOBIAN',
      'A Flutter plugin for storing data in secure storage with AES encryption.'),
    _LicenseInfo('mobile_scanner', '6.0.11', 'BSD-3-Clause', 'Julian Bissekkou',
      'A Flutter plugin for barcode and QR code scanning using ML Kit.'),
    _LicenseInfo('qr_flutter', '4.1.0', 'BSD-3-Clause', 'Luke Freeman',
      'A Flutter library for rendering QR codes using custom painters.'),
    _LicenseInfo('provider', '6.1.5', 'MIT', 'Remi Rousselet',
      'A wrapper around InheritedWidget to make them easier to use and more reusable.'),
    _LicenseInfo('local_auth', '2.3.0', 'BSD-3-Clause', 'Google LLC',
      'A Flutter plugin for local authentication (fingerprint, face ID, etc.).'),
    _LicenseInfo('base32', '2.2.0', 'MIT', 'Kevin Moore',
      'A Dart library for encoding and decoding Base32 strings.'),
    _LicenseInfo('share_plus', '10.0.0', 'BSD-3-Clause', 'Flutter Community',
      'A Flutter plugin for sharing content via the platform share dialog.'),
    _LicenseInfo('file_picker', '9.0.0', 'MIT', 'Miguel Ruivo',
      'A Flutter plugin for picking files from the device.'),
    _LicenseInfo('path_provider', '2.1.5', 'BSD-3-Clause', 'Google LLC',
      'A Flutter plugin for finding commonly used locations on the filesystem.'),
    _LicenseInfo('uri', '1.0.0', 'BSD-3-Clause', 'Dart Team',
      'A Dart library for URI parsing and manipulation.'),
    _LicenseInfo('encrypt', '5.0.1', 'MIT', 'Diego García',
      'A Dart library for encryption and decryption using AES, Salsa20, etc.'),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('开放源代码许可')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 说明文字
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              '本应用基于以下开源软件构建。感谢开源社区的贡献。',
              style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 12, height: 1.6),
            ),
          ),
          // 许可列表
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _licenses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final lic = _licenses[index];
                return _buildLicenseCard(context, lic);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLicenseCard(BuildContext context, _LicenseInfo lic) {
    final colorScheme = Theme.of(context).colorScheme;

    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: colorScheme.outline, width: 0.5)),
      collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: colorScheme.outline, width: 0.5)),
      backgroundColor: colorScheme.surface,
      collapsedBackgroundColor: colorScheme.surface,
      title: Row(
        children: [
          Expanded(
            child: Text(lic.name, style: TextStyle(color: colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _licenseColor(lic.license).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(lic.license, style: TextStyle(
              color: _licenseColor(lic.license), fontSize: 10, fontWeight: FontWeight.w600,
            )),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Text('v${lic.version}', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 11)),
          const SizedBox(width: 8),
          Text(lic.author, style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 11)),
        ],
      ),
      children: [
        Text(lic.description, style: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12, height: 1.6,
        )),
        const SizedBox(height: 8),
        _buildLicenseText(context, lic.license),
      ],
    );
  }

  Color _licenseColor(String license) {
    if (license.startsWith('MIT')) return AppTheme.accentEmerald;
    if (license.startsWith('BSD')) return AppTheme.accentIndigo;
    if (license.startsWith('Apache')) return AppTheme.accentPurple;
    if (license.startsWith('GPL')) return AppTheme.accentRose;
    return AppTheme.accentAmber;
  }

  Widget _buildLicenseText(BuildContext context, String licenseType) {
    final colorScheme = Theme.of(context).colorScheme;
    String text;
    switch (licenseType) {
      case 'MIT':
        text = 'Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files, to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software.';
        break;
      case 'BSD-3-Clause':
        text = 'Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met: Redistributions must retain the copyright notice, this list of conditions and the following disclaimer.';
        break;
      default:
        text = 'See the original repository for full license terms.';
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: TextStyle(
        color: colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 10, height: 1.5,
      )),
    );
  }
}

class _LicenseInfo {
  final String name;
  final String version;
  final String license;
  final String author;
  final String description;

  const _LicenseInfo(this.name, this.version, this.license, this.author, this.description);
}
