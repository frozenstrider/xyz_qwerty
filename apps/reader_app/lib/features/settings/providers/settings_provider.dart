import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/settings_models.dart';
import '../../../domain/models/reader_models.dart';

final settingsProvider =
    StateNotifierProvider<SettingsController, AppSettings>((ref) {
  return SettingsController();
});

class SettingsController extends StateNotifier<AppSettings> {
  SettingsController() : super(AppSettings.defaults());

  void setThemeStyle(AppThemeStyle style) {
    state = state.copyWith(themeStyle: style);
  }

  void toggleReduceMotion(bool enabled) {
    state = state.copyWith(reduceMotion: enabled);
  }

  void toggleAnimeThemes(bool enabled) {
    state = state.copyWith(animeThemesEnabled: enabled);
  }

  void setLanguage(String code) {
    state = state.copyWith(languageCode: code);
  }

  void setRtl(bool isRtl) {
    state = state.copyWith(isRtl: isRtl);
  }

  void setFontFamily(String fontFamily) {
    state = state.copyWith(fontFamily: fontFamily);
  }

  void toggleHighContrast(bool enabled) {
    state = state.copyWith(highContrast: enabled);
  }

  void setPageTurnAnimation(PageTurnAnimation animation) {
    state = state.copyWith(pageTurnAnimation: animation);
  }

  void setDefaultReaderMode(ReaderMode mode) {
    state = state.copyWith(defaultReaderMode: mode);
  }
}
