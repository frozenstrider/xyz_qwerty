import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';
import 'ui/design_system/theme.dart';

class MangaApp extends ConsumerWidget {
  const MangaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeBundle = ref.watch(appThemeBundleProvider);
    final themeMode = ref.watch(appThemeModeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Manga App',
      theme: themeBundle.light,
      darkTheme: themeBundle.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
