import 'package:flutter/material.dart';

/// AuthKey 主题配置 - Linear Aesthetic 风格
/// 支持深色和浅色模式，跟随系统切换
class AppTheme {
  AppTheme._();

  // ============ 深色模式色彩 ============
  static const _darkCanvas = Color(0xFF050506);
  static const _darkSurface = Color(0xFF0A0A0B);
  static const _darkSurfaceElevated = Color(0xFF111113);
  static const _darkSurfaceOverlay = Color(0xFF18181B);
  static const _darkTextPrimary = Color(0xFFEDEDEF);
  static const _darkTextSecondary = Color(0xFF8A8F98);
  static const _darkTextTertiary = Color(0xFF565B66);
  static const _darkBorderSubtle = Color(0x1AFFFFFF);
  static const _darkBorderMedium = Color(0x26FFFFFF);

  // ============ 浅色模式色彩 ============
  static const _lightCanvas = Color(0xFFFAFAFA);
  static const _lightSurface = Color(0xFFFFFFFF);
  static const _lightSurfaceElevated = Color(0xFFF5F5F7);
  static const _lightSurfaceOverlay = Color(0xFFEEEEEF);
  static const _lightTextPrimary = Color(0xFF1D1D1F);
  static const _lightTextSecondary = Color(0xFF6E6E73);
  static const _lightTextTertiary = Color(0xFF9CA3AF);
  static const _lightBorderSubtle = Color(0x1A000000);
  static const _lightBorderMedium = Color(0x26000000);

  // ============ 共用强调色 ============
  static const accentIndigo = Color(0xFF6366F1);
  static const accentPurple = Color(0xFFA855F7);
  static const accentEmerald = Color(0xFF10B981);
  static const accentAmber = Color(0xFFF59E0B);
  static const accentRose = Color(0xFFF43F5E);

  // ============ 深色主题 ============
  static ThemeData get darkTheme {
    return _buildTheme(
      brightness: Brightness.dark,
      canvas: _darkCanvas,
      surface: _darkSurface,
      surfaceElevated: _darkSurfaceElevated,
      surfaceOverlay: _darkSurfaceOverlay,
      textPrimary: _darkTextPrimary,
      textSecondary: _darkTextSecondary,
      textTertiary: _darkTextTertiary,
      borderSubtle: _darkBorderSubtle,
      borderMedium: _darkBorderMedium,
    );
  }

  // ============ 浅色主题 ============
  static ThemeData get lightTheme {
    return _buildTheme(
      brightness: Brightness.light,
      canvas: _lightCanvas,
      surface: _lightSurface,
      surfaceElevated: _lightSurfaceElevated,
      surfaceOverlay: _lightSurfaceOverlay,
      textPrimary: _lightTextPrimary,
      textSecondary: _lightTextSecondary,
      textTertiary: _lightTextTertiary,
      borderSubtle: _lightBorderSubtle,
      borderMedium: _lightBorderMedium,
    );
  }

  // ============ 通用主题构建 ============
  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color canvas,
    required Color surface,
    required Color surfaceElevated,
    required Color surfaceOverlay,
    required Color textPrimary,
    required Color textSecondary,
    required Color textTertiary,
    required Color borderSubtle,
    required Color borderMedium,
  }) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: canvas,
      colorScheme: ColorScheme(
        primary: accentIndigo,
        secondary: accentPurple,
        surface: surface,
        error: accentRose,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onError: Colors.white,
        brightness: brightness,
        // 浅色模式下调整 primary 容器色
        primaryContainer: accentIndigo.withValues(alpha: isDark ? 0.15 : 0.10),
        onPrimaryContainer: accentIndigo,
        secondaryContainer: accentPurple.withValues(alpha: isDark ? 0.15 : 0.10),
        onSecondaryContainer: accentPurple,
        errorContainer: accentRose.withValues(alpha: isDark ? 0.15 : 0.10),
        onErrorContainer: accentRose,
        surfaceContainerHighest: surfaceElevated,
        outline: borderSubtle,
        outlineVariant: borderMedium,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: borderSubtle, width: 0.5),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.02,
        ),
        iconTheme: IconThemeData(color: textSecondary, size: 22),
        actionsIconTheme: IconThemeData(color: textSecondary, size: 22),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: textPrimary, fontSize: 32, fontWeight: FontWeight.w700,
          letterSpacing: -0.03, height: 1.1,
        ),
        headlineMedium: TextStyle(
          color: textPrimary, fontSize: 24, fontWeight: FontWeight.w700,
          letterSpacing: -0.02, height: 1.2,
        ),
        titleLarge: TextStyle(
          color: textPrimary, fontSize: 18, fontWeight: FontWeight.w600,
          letterSpacing: -0.01,
        ),
        titleMedium: TextStyle(
          color: textPrimary, fontSize: 15, fontWeight: FontWeight.w600,
          letterSpacing: -0.01,
        ),
        titleSmall: TextStyle(
          color: textSecondary, fontSize: 13, fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: textPrimary, fontSize: 15, fontWeight: FontWeight.w400, height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: textSecondary, fontSize: 13, fontWeight: FontWeight.w400, height: 1.5,
        ),
        bodySmall: TextStyle(
          color: textTertiary, fontSize: 11, fontWeight: FontWeight.w400,
        ),
        labelLarge: TextStyle(
          color: textPrimary, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.02,
        ),
        labelMedium: TextStyle(
          color: textSecondary, fontSize: 12, fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          color: textTertiary, fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 0.04,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accentIndigo,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.02),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: borderMedium, width: 0.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.02),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentIndigo,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.01),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: borderSubtle, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: borderSubtle, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: accentIndigo, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: accentRose, width: 0.5),
        ),
        hintStyle: TextStyle(color: textTertiary, fontSize: 14),
        labelStyle: TextStyle(color: textSecondary, fontSize: 13),
      ),
      iconTheme: IconThemeData(color: textSecondary, size: 20),
      dividerTheme: DividerThemeData(
        color: borderSubtle, thickness: 0.5, space: 0.5,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceOverlay,
        contentTextStyle: TextStyle(color: textPrimary, fontSize: 13),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: borderSubtle, width: 0.5),
        ),
        elevation: 0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceElevated,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderSubtle, width: 0.5),
        ),
        titleTextStyle: TextStyle(color: textPrimary, fontSize: 17, fontWeight: FontWeight.w600),
        contentTextStyle: TextStyle(color: textSecondary, fontSize: 14, height: 1.5),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surfaceElevated,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: borderSubtle, width: 0.5),
        ),
        textStyle: TextStyle(color: textPrimary, fontSize: 13),
      ),
    );
  }
}
