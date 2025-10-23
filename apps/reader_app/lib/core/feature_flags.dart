import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_app/domain/models/settings_models.dart';
import 'package:reader_app/features/settings/providers/settings_provider.dart';

class FeatureFlags {
  const FeatureFlags({required this.liquidGlassEnabled, required this.reduceMotion, required this.animeThemesEnabled});

  final bool liquidGlassEnabled;
  final bool reduceMotion;
  final bool animeThemesEnabled;

  static FeatureFlags fromSettings(AppSettings settings) => FeatureFlags(
        liquidGlassEnabled: settings.liquidGlassEnabled,
        reduceMotion: settings.reduceMotion,
        animeThemesEnabled: settings.animeThemesEnabled,
      );
}

final featureFlagsProvider = Provider<FeatureFlags>((ref) {
  final settings = ref.watch(settingsProvider);
  return FeatureFlags.fromSettings(settings);
});
