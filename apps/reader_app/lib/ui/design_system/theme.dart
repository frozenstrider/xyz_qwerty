import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/models/settings_models.dart';
import '../../features/settings/providers/settings_provider.dart';
import 'tokens.dart';

class AppThemeBundle {
  const AppThemeBundle({required this.light, required this.dark});

  final ThemeData light;
  final ThemeData dark;
}

final appThemeBundleProvider = Provider<AppThemeBundle>((ref) {
  final settings = ref.watch(settingsProvider);
  final light = _buildComicTheme(
    brightness: Brightness.light,
    settings: settings,
  );
  final dark = _buildComicTheme(
    brightness: Brightness.dark,
    settings: settings,
  );
  return AppThemeBundle(light: light, dark: dark);
});

final appThemeModeProvider = Provider<ThemeMode>((ref) {
  final style = ref.watch(settingsProvider.select((value) => value.themeStyle));
  return style == AppThemeStyle.dark ? ThemeMode.dark : ThemeMode.light;
});

ThemeData _buildComicTheme({
  required Brightness brightness,
  required AppSettings settings,
}) {
  final isDark = brightness == Brightness.dark;
  final baseBackground =
      isDark ? const Color(0xFF111016) : const Color(0xFFFDF9F3);
  final surface = isDark ? const Color(0xFF17171F) : Colors.white;
  final surfaceAlt = isDark ? const Color(0xFF1F1F29) : const Color(0xFFF2EDE4);
  final borderColor =
      isDark ? const Color(0xFF3C3C48) : const Color(0xFF101014);
  final primarySeed =
      isDark ? const Color(0xFFFF9E3D) : const Color(0xFF4C4AE6);

  final scheme = ColorScheme.fromSeed(
    seedColor: primarySeed,
    brightness: brightness,
    surfaceTint: Colors.transparent,
  ).copyWith(
    background: baseBackground,
    surface: surface,
    surfaceVariant: surfaceAlt,
    outline: borderColor,
    outlineVariant: borderColor.withOpacity(isDark ? 0.4 : 0.2),
    onSurface: isDark ? Colors.white : const Color(0xFF18181D),
    onBackground: isDark ? Colors.white : const Color(0xFF18181D),
  );

  final textTheme = _typography(brightness, settings.fontFamily);
  final labelBase = textTheme.labelMedium ??
      const TextStyle(fontSize: 13, fontWeight: FontWeight.w600);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: baseBackground,
    canvasColor: baseBackground,
    typography: Typography.material2021(platform: defaultTargetPlatform),
    textTheme: textTheme,
    fontFamily: settings.fontFamily,
    appBarTheme: AppBarTheme(
      backgroundColor: baseBackground,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: scheme.onBackground,
      ),
      foregroundColor: scheme.onBackground,
    ),
    cardTheme: CardTheme(
      color: surface,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: RadiusTokens.lg,
        side: BorderSide(color: borderColor, width: 1.6),
      ),
      shadowColor: isDark
          ? Colors.black.withOpacity(0.35)
          : Colors.black.withOpacity(0.08),
      elevation: 4,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      showDragHandle: true,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: surface,
      shape: RoundedRectangleBorder(
        borderRadius: RadiusTokens.lg,
        side: BorderSide(color: borderColor, width: 1.6),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceAlt,
      side: BorderSide(color: borderColor.withOpacity(isDark ? 0.5 : 0.35)),
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.sm,
        vertical: SpacingTokens.xxxs,
      ),
      shape: RoundedRectangleBorder(borderRadius: RadiusTokens.pill),
      labelStyle: labelBase,
    ),
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: RadiusTokens.md,
        side: BorderSide(color: borderColor.withOpacity(0.3)),
      ),
      selectedColor: scheme.primary,
      iconColor: scheme.onSurface,
      textColor: scheme.onSurface,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: scheme.primary,
        textStyle: labelBase.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: RadiusTokens.md,
          side: BorderSide(color: borderColor, width: 1.4),
        ),
        textStyle: labelBase.copyWith(
          color: scheme.onPrimary,
          letterSpacing: 0.2,
        ),
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        ),
        textStyle: MaterialStateProperty.all(labelBase),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(borderRadius: RadiusTokens.md),
        ),
        side: MaterialStateProperty.resolveWith(
          (states) => BorderSide(
            color: states.contains(MaterialState.selected)
                ? borderColor
                : borderColor.withOpacity(0.4),
            width: 1.4,
          ),
        ),
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return surfaceAlt;
          }
          return surface;
        }),
        foregroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return scheme.onSurface;
          }
          return scheme.onSurface.withOpacity(0.8);
        }),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      elevation: 6,
      indicatorColor: scheme.primary.withOpacity(0.15),
      iconTheme: MaterialStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(MaterialState.selected)
              ? scheme.primary
              : scheme.onSurface.withOpacity(0.7),
        ),
      ),
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      labelTextStyle: MaterialStateProperty.all(
        labelBase.copyWith(letterSpacing: 0.2),
      ),
    ),
    dividerColor: borderColor.withOpacity(0.35),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: scheme.surface,
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: scheme.onSurface,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: RadiusTokens.md,
        side: BorderSide(color: borderColor.withOpacity(0.6)),
      ),
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbVisibility: MaterialStateProperty.all(true),
      thickness: MaterialStateProperty.all(6),
      thumbColor: MaterialStateProperty.all(
        scheme.primary.withOpacity(isDark ? 0.4 : 0.35),
      ),
      radius: const Radius.circular(999),
    ),
  );
}

TextTheme _typography(Brightness brightness, String fontFamily) {
  final base = brightness == Brightness.dark
      ? ThemeData(brightness: Brightness.dark).textTheme
      : ThemeData(brightness: Brightness.light).textTheme;
  try {
    return GoogleFonts.getTextTheme(fontFamily, base);
  } catch (_) {
    return GoogleFonts.workSansTextTheme(base);
  }
}
