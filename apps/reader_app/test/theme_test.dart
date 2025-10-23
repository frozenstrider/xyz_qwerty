import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reader_app/domain/models/settings_models.dart';
import 'package:reader_app/features/settings/providers/settings_provider.dart';
import 'package:reader_app/ui/design_system/theme.dart';

void main() {
  test('settings controller toggles theme style', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(settingsProvider).themeStyle, AppThemeStyle.light);
    expect(container.read(appThemeModeProvider), ThemeMode.light);

    container.read(settingsProvider.notifier).setThemeStyle(AppThemeStyle.dark);
    expect(container.read(appThemeModeProvider), ThemeMode.dark);

    container
        .read(settingsProvider.notifier)
        .setThemeStyle(AppThemeStyle.light);
    expect(container.read(appThemeModeProvider), ThemeMode.light);
  });
}
