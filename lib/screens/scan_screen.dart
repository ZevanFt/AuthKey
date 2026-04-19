import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:totp_auth/core/theme.dart';
import 'package:totp_auth/models/totp_account.dart';
import 'package:totp_auth/services/totp_provider.dart';

/// 二维码扫描屏幕 - Linear Aesthetic 风格
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessing = false;
  String? _error;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('扫描二维码')),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                MobileScanner(controller: _scannerController, onDetect: _onDetect),
                _buildScanOverlay(context),
                if (_error != null)
                  Positioned(bottom: 20, left: 20, right: 20, child: _buildErrorBanner(context)),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colorScheme.primary.withValues(alpha: 0.12), width: 0.5),
                  ),
                  child: Icon(Icons.qr_code_2_rounded, size: 24, color: colorScheme.primary.withValues(alpha: 0.6)),
                ),
                const SizedBox(height: 14),
                Text('将二维码对准扫描框', style: TextStyle(
                  color: colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.w500,
                )),
                const SizedBox(height: 4),
                Text('支持 otpauth:// 格式的 TOTP 二维码', style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.35), fontSize: 12,
                )),
                const SizedBox(height: 20),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: const Text('手动输入'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanOverlay(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scanSize = size.width * 0.65;
    final left = (size.width - scanSize) / 2;
    final top = (size.height * 0.75 - scanSize) / 2;

    return Stack(
      children: [
        ColorFiltered(
          colorFilter: const ColorFilter.mode(Colors.black54, BlendMode.srcOut),
          child: Stack(
            children: [
              Container(decoration: const BoxDecoration(color: Colors.red, backgroundBlendMode: BlendMode.dstOut)),
              Positioned(
                left: left, top: top,
                child: Container(width: scanSize, height: scanSize, decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.transparent)),
              ),
            ],
          ),
        ),
        Positioned(
          left: left, top: top,
          child: CustomPaint(
            size: Size(scanSize, scanSize),
            painter: _ScanCornerPainter(cornerLen: 24, cornerWidth: 2.5, color: AppTheme.accentIndigo, radius: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.accentRose.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.accentRose.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, size: 16, color: AppTheme.accentRose),
          const SizedBox(width: 8),
          Expanded(child: Text(_error!, style: const TextStyle(color: AppTheme.accentRose, fontSize: 12))),
        ],
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;
    final value = barcode.rawValue!;
    _isProcessing = true;

    if (!value.startsWith('otpauth://totp/')) {
      setState(() { _error = '不是有效的 TOTP 二维码'; _isProcessing = false; });
      return;
    }
    try {
      _addAccount(TotpAccount.fromOtpAuthUri(value));
    } catch (e) {
      setState(() { _error = '解析失败: $e'; _isProcessing = false; });
    }
  }

  void _addAccount(TotpAccount account) async {
    final provider = context.read<TotpProvider>();
    try {
      await provider.addAccount(account);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.check_circle_rounded, size: 16, color: AppTheme.accentEmerald),
            const SizedBox(width: 8), Text('已添加: ${account.displayName}'),
          ]),
        ));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) setState(() { _error = '添加失败: $e'; _isProcessing = false; });
    }
  }
}

class _ScanCornerPainter extends CustomPainter {
  final double cornerLen, cornerWidth, radius;
  final Color color;
  _ScanCornerPainter({required this.cornerLen, required this.cornerWidth, required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = cornerWidth..strokeCap = StrokeCap.round;
    final w = size.width, h = size.height, r = radius;

    canvas.drawPath(Path()..moveTo(r, 0)..lineTo(cornerLen, 0)..moveTo(0, cornerLen)..lineTo(0, r)..arcTo(Rect.fromLTWH(0, 0, 2*r, 2*r), 3.14, 1.57, false), paint);
    canvas.drawPath(Path()..moveTo(w-cornerLen, 0)..lineTo(w-r, 0)..arcTo(Rect.fromLTWH(w-2*r, 0, 2*r, 2*r), -1.57, 1.57, false)..lineTo(w, cornerLen), paint);
    canvas.drawPath(Path()..moveTo(0, h-cornerLen)..lineTo(0, h-r)..arcTo(Rect.fromLTWH(0, h-2*r, 2*r, 2*r), 3.14, -1.57, false)..lineTo(cornerLen, h), paint);
    canvas.drawPath(Path()..moveTo(w, h-cornerLen)..lineTo(w, h-r)..arcTo(Rect.fromLTWH(w-2*r, h-2*r, 2*r, 2*r), 0, 1.57, false)..lineTo(w-cornerLen, h), paint);
  }

  @override
  bool shouldRepaint(covariant _ScanCornerPainter oldDelegate) => false;
}
