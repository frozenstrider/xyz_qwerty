import 'dart:ui';

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
  final glassLight = _buildTheme(brightness: Brightness.light, settings: settings, liquid: true);
  final glassDark = _buildTheme(brightness: Brightness.dark, settings: settings, liquid: true);
  final solidLight = _buildTheme(brightness: Brightness.light, settings: settings, liquid: false);
  final solidDark = _buildTheme(brightness: Brightness.dark, settings: settings, liquid: false);

  return switch (settings.themeStyle) {
    AppThemeStyle.light => AppThemeBundle(light: solidLight, dark: solidDark),
    AppThemeStyle.dark => AppThemeBundle(light: solidLight, dark: solidDark),
    AppThemeStyle.liquid => AppThemeBundle(light: glassLight, dark: glassDark),
  };
});

final appThemeModeProvider = Provider<ThemeMode>((ref) {
  final style = ref.watch(settingsProvider.select((value) => value.themeStyle));
  return switch (style) {
    AppThemeStyle.light => ThemeMode.light,
    AppThemeStyle.dark => ThemeMode.dark,
    AppThemeStyle.liquid => ThemeMode.system,
  };
});

TextTheme _typography(Brightness brightness, String fontFamily) {
  final base = brightness == Brightness.dark ? ThemeData(brightness: Brightness.dark).textTheme : ThemeData(brightness: Brightness.light).textTheme;
  try {
    return GoogleFonts.getTextTheme(fontFamily, base);
  } catch (_) {
    return GoogleFonts.workSansTextTheme(base);
  }
}

ThemeData _buildTheme({required Brightness brightness, required AppSettings settings, required bool liquid}) {
  final seedColor = switch (brightness) {
    Brightness.light => const Color(0xFF5E7CE2),
    Brightness.dark => const Color(0xFF8AA9FF),
  };
  final scheme = ColorScheme.fromSeed(seedColor: seedColor, brightness: brightness);
  final textTheme = _typography(brightness, settings.fontFamily);
  final highContrast = settings.highContrast;

  final surfaceBlend = liquid
      ? scheme.surface.withOpacity(brightness == Brightness.dark ? 0.28 : 0.18)
      : scheme.surface;

  final cardColor = liquid
      ? scheme.surface.withOpacity(brightness == Brightness.dark ? 0.24 : 0.16)
      : scheme.surface;

  final dividerColor = scheme.outlineVariant.withOpacity(highContrast ? 0.8 : 0.25);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: liquid ? Colors.transparent : surfaceBlend,
    canvasColor: liquid ? Colors.transparent : surfaceBlend,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    typography: Typography.material2021(platform: defaultTargetPlatform),
    textTheme: textTheme,
    fontFamily: settings.fontFamily,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: RadiusTokens.md)),
        elevation: MaterialStateProperty.all(liquid ? 0 : 2),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: liquid ? Colors.transparent : scheme.surface,
      elevation: liquid ? 0 : 1,
      scrolledUnderElevation: liquid ? 0 : 2,
      shadowColor: liquid ? Colors.black.withOpacity(0.12) : null,
      centerTitle: true,
      titleTextStyle: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: scheme.onSurface),
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardTheme(
      color: cardColor,
      elevation: liquid ? 0 : 1,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: RadiusTokens.lg,
        side: BorderSide(color: Colors.white.withOpacity(liquid ? 0.18 : (highContrast ? 0.45 : 0.12))),
      ),
      shadowColor: liquid ? Colors.black.withOpacity(0.25) : Colors.black.withOpacity(0.15),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: cardColor,
      shape: RoundedRectangleBorder(borderRadius: RadiusTokens.lg),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      showDragHandle: true,
      backgroundColor: liquid ? cardColor : scheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: scheme.surfaceVariant.withOpacity(liquid ? 0.85 : 0.98),
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
      behavior: SnackBarBehavior.floating,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: scheme.surfaceVariant.withOpacity(liquid ? 0.45 : 0.9),
      side: BorderSide(color: dividerColor),
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm, vertical: SpacingTokens.xxxs),
      shape: RoundedRectangleBorder(borderRadius: RadiusTokens.pill),
      labelStyle: textTheme.labelLarge,
      selectedColor: scheme.primary.withOpacity(0.2),
    ),
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(borderRadius: RadiusTokens.md),
      selectedColor: scheme.primary,
      iconColor: scheme.onSurfaceVariant,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: liquid ? scheme.surface.withOpacity(0.2) : scheme.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: scheme.primary.withOpacity(0.2),
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      elevation: liquid ? 0 : 2,
      iconTheme: MaterialStateProperty.resolveWith((states) {
        final color = states.contains(MaterialState.selected) ? scheme.primary : scheme.onSurfaceVariant;
        return IconThemeData(color: color);
      }),
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        final weight = states.contains(MaterialState.selected) ? FontWeight.w600 : FontWeight.w500;
        return textTheme.labelMedium?.copyWith(fontWeight: weight);
      }),
    ),
    dividerColor: dividerColor,
    splashFactory: liquid ? InkSparkle.splashFactory : InkRipple.splashFactory,
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: MaterialStateProperty.all(scheme.primary.withOpacity(0.45)),
      thickness: MaterialStateProperty.all(4.5),
      radius: const Radius.circular(999),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: scheme.primary,
      linearTrackColor: scheme.primary.withOpacity(0.1),
      circularTrackColor: scheme.primary.withOpacity(0.15),
    ),
  );
}

