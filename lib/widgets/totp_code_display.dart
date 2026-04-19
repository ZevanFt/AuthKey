import 'dart:math' as math;

import 'package:flutter/material.dart';

/// TOTP 验证码显示组件 - Linear Aesthetic 风格
/// 自适应宽度，不会溢出
class TotpCodeDisplay extends StatelessWidget {
  final String code;
  final double progress;
  final int remainingSeconds;
  final VoidCallback? onCopy;
  final int digits;

  const TotpCodeDisplay({
    super.key,
    required this.code,
    required this.progress,
    required this.remainingSeconds,
    this.onCopy,
    this.digits = 6,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpiring = remainingSeconds <= 5;
    final accentColor = isExpiring ? theme.colorScheme.error : theme.colorScheme.primary;
    final textColor = isExpiring ? theme.colorScheme.error : theme.colorScheme.onSurface;

    return GestureDetector(
      onTap: onCopy,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 精密进度环
            _buildProgressRing(context, accentColor, isExpiring),
            const SizedBox(width: 10),
            // 分组验证码
            _buildCodeDigits(context, textColor, accentColor),
            const SizedBox(width: 8),
            // 复制图标
            _buildCopyIcon(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressRing(BuildContext context, Color accentColor, bool isExpiring) {
    final theme = Theme.of(context);
    final borderSubtle = theme.brightness == Brightness.dark
        ? const Color(0x1AFFFFFF)
        : const Color(0x1A000000);

    return SizedBox(
      width: 28,
      height: 28,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(28, 28),
            painter: _ProgressRingPainter(
              progress: progress,
              color: accentColor,
              backgroundColor: borderSubtle,
              strokeWidth: 2,
            ),
          ),
          Text(
            '$remainingSeconds',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: isExpiring ? accentColor : theme.hintColor,
              fontFamily: 'monospace',
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeDigits(BuildContext context, Color textColor, Color accentColor) {
    final half = digits ~/ 2;
    final firstHalf = code.substring(0, half);
    final secondHalf = code.substring(half);
    final theme = Theme.of(context);
    final separatorColor = theme.brightness == Brightness.dark
        ? const Color(0xFF565B66)
        : const Color(0xFF9CA3AF);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 第一组
        for (int i = 0; i < firstHalf.length; i++)
          _buildSingleDigit(firstHalf[i], textColor),
        // 分隔符
        Container(
          width: 6,
          height: 2,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: separatorColor,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        // 第二组
        for (int i = 0; i < secondHalf.length; i++)
          _buildSingleDigit(secondHalf[i], textColor),
      ],
    );
  }

  Widget _buildSingleDigit(String digit, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1.5),
      child: Text(
        digit,
        style: TextStyle(
          color: color,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: 'monospace',
          letterSpacing: 1,
          height: 1.1,
        ),
      ),
    );
  }

  Widget _buildCopyIcon(BuildContext context) {
    final theme = Theme.of(context);
    final borderSubtle = theme.brightness == Brightness.dark
        ? const Color(0x1AFFFFFF)
        : const Color(0x1A000000);
    final iconColor = theme.brightness == Brightness.dark
        ? const Color(0xFF565B66)
        : const Color(0xFF9CA3AF);

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: borderSubtle, width: 0.5),
      ),
      child: Icon(Icons.copy_rounded, size: 12, color: iconColor),
    );
  }
}

/// 自定义进度环绘制器
class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  _ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    final startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle, sweepAngle, false, progressPaint,
    );

    // 微光效果
    if (progress > 0.01) {
      final endAngle = startAngle + sweepAngle;
      final glowX = center.dx + radius * math.cos(endAngle);
      final glowY = center.dy + radius * math.sin(endAngle);
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(glowX, glowY), strokeWidth * 2, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
