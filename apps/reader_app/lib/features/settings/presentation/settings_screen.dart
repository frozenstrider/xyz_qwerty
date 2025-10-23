import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_app/domain/models/reader_models.dart';
import 'package:reader_app/domain/models/settings_models.dart';
import 'package:reader_app/features/settings/providers/settings_provider.dart';
import 'package:reader_app/ui/design_system/tokens.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.lg,
            SpacingTokens.lg, SpacingTokens.xl),
        children: [
          Text('Appearance',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: SpacingTokens.md),
          SegmentedButton<AppThemeStyle>(
            segments: const [
              ButtonSegment(
                  value: AppThemeStyle.light,
                  icon: Icon(Icons.light_mode_rounded),
                  label: Text('Light')),
              ButtonSegment(
                  value: AppThemeStyle.dark,
                  icon: Icon(Icons.dark_mode_rounded),
                  label: Text('Dark')),
            ],
            selected: {settings.themeStyle},
            onSelectionChanged: (s) => controller.setThemeStyle(s.first),
          ),
          SwitchListTile.adaptive(
            value: settings.reduceMotion,
            onChanged: controller.toggleReduceMotion,
            title: const Text('Reduce motion'),
            subtitle: const Text('Minimise animations and seasonal effects'),
          ),
          SwitchListTile.adaptive(
            value: settings.animeThemesEnabled,
            onChanged: controller.toggleAnimeThemes,
            title: const Text('Anime seasonal themes'),
            subtitle: const Text('Enable sakura and special event layers'),
          ),
          const Divider(height: SpacingTokens.xl),
          Text('Reader',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: SpacingTokens.md),
          ListTile(
            title: const Text('Default reading mode'),
            subtitle: Text(settings.defaultReaderMode.name),
            trailing: DropdownButton<ReaderMode>(
              value: settings.defaultReaderMode,
              onChanged: (mode) {
                if (mode != null) controller.setDefaultReaderMode(mode);
              },
              items: const [
                DropdownMenuItem(
                    value: ReaderMode.vertical, child: Text('Vertical scroll')),
                DropdownMenuItem(
                    value: ReaderMode.single, child: Text('Page by page')),
                DropdownMenuItem(
                    value: ReaderMode.double, child: Text('Two-page spread')),
              ],
            ),
          ),
          SwitchListTile.adaptive(
            value: settings.isRtl,
            onChanged: controller.setRtl,
            title: const Text('Right-to-left reading'),
          ),
          ListTile(
            title: const Text('Page turn animation'),
            subtitle: Text(settings.pageTurnAnimation.name),
            trailing: DropdownButton<PageTurnAnimation>(
              value: settings.pageTurnAnimation,
              onChanged: (animation) => controller.setPageTurnAnimation(
                  animation ?? settings.pageTurnAnimation),
              items: const [
                DropdownMenuItem(
                    value: PageTurnAnimation.slide, child: Text('Slide')),
                DropdownMenuItem(
                    value: PageTurnAnimation.fade, child: Text('Fade')),
                DropdownMenuItem(
                    value: PageTurnAnimation.curl, child: Text('Curl preview')),
              ],
            ),
          ),
          const Divider(height: SpacingTokens.xl),
          Text('Typography',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: SpacingTokens.md),
          ListTile(
            title: const Text('Dialogue font'),
            subtitle: Text(settings.fontFamily),
            trailing: DropdownButton<String>(
              value: settings.fontFamily,
              onChanged: (value) {
                if (value != null) controller.setFontFamily(value);
              },
              items: const [
                DropdownMenuItem(value: 'WorkSans', child: Text('Work Sans')),
                DropdownMenuItem(
                    value: 'SourceSans3', child: Text('Source Sans 3')),
                DropdownMenuItem(
                    value: 'M PLUS Rounded 1c', child: Text('M PLUS Rounded')),
              ],
            ),
          ),
          SwitchListTile.adaptive(
            value: settings.highContrast,
            onChanged: controller.toggleHighContrast,
            title: const Text('High contrast surfaces'),
          ),
          ListTile(
            title: const Text('Language'),
            subtitle: Text(settings.languageCode.toUpperCase()),
            trailing: DropdownButton<String>(
              value: settings.languageCode,
              onChanged: (value) {
                if (value != null) controller.setLanguage(value);
              },
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'ja', child: Text('Japanese')),
                DropdownMenuItem(value: 'es', child: Text('Spanish')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
