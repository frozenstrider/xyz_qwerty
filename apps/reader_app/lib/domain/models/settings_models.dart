import '../models/reader_models.dart';

enum AppThemeStyle { light, dark }

enum PageTurnAnimation { slide, fade, curl }

class AppSettings {
  const AppSettings({
    required this.themeStyle,
    required this.reduceMotion,
    required this.animeThemesEnabled,
    required this.defaultReaderMode,
    required this.languageCode,
    required this.isRtl,
    required this.fontFamily,
    required this.highContrast,
    required this.pageTurnAnimation,
  });

  final AppThemeStyle themeStyle;
  final bool reduceMotion;
  final bool animeThemesEnabled;
  final ReaderMode defaultReaderMode;
  final String languageCode;
  final bool isRtl;
  final String fontFamily;
  final bool highContrast;
  final PageTurnAnimation pageTurnAnimation;

  AppSettings copyWith({
    AppThemeStyle? themeStyle,
    bool? reduceMotion,
    bool? animeThemesEnabled,
    ReaderMode? defaultReaderMode,
    String? languageCode,
    bool? isRtl,
    String? fontFamily,
    bool? highContrast,
    PageTurnAnimation? pageTurnAnimation,
  }) {
    return AppSettings(
      themeStyle: themeStyle ?? this.themeStyle,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      animeThemesEnabled: animeThemesEnabled ?? this.animeThemesEnabled,
      defaultReaderMode: defaultReaderMode ?? this.defaultReaderMode,
      languageCode: languageCode ?? this.languageCode,
      isRtl: isRtl ?? this.isRtl,
      fontFamily: fontFamily ?? this.fontFamily,
      highContrast: highContrast ?? this.highContrast,
      pageTurnAnimation: pageTurnAnimation ?? this.pageTurnAnimation,
    );
  }

  static AppSettings defaults() => const AppSettings(
        themeStyle: AppThemeStyle.light,
        reduceMotion: false,
        animeThemesEnabled: false,
        defaultReaderMode: ReaderMode.vertical,
        languageCode: 'en',
        isRtl: false,
        fontFamily: 'WorkSans',
        highContrast: false,
        pageTurnAnimation: PageTurnAnimation.slide,
      );
}
