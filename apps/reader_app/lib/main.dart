import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'ui/window/app_window_frame.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MangaDesktopApp()));

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    doWhenWindowReady(() {
      const initialSize = Size(1380, 920);
      appWindow.minSize = const Size(1200, 780);
      appWindow.size = initialSize;
      appWindow.alignment = Alignment.center;
      appWindow.show();
    });
  }
}

class MangaDesktopApp extends StatelessWidget {
  const MangaDesktopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppWindowFrame(
      child: const MangaApp(),
    );
  }
}
