import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../design_system/tokens.dart';

const _kTitleBarHeight = 44.0;
const _kWindowRadius = 26.0;

class AppWindowFrame extends StatelessWidget {
  const AppWindowFrame({super.key, required this.child});

  final Widget child;

  static bool get _isDesktop => !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

  @override
  Widget build(BuildContext context) {
    if (!_isDesktop) {
      return child;
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: WindowBorder(
        color: Colors.white.withOpacity(0.08),
        width: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_kWindowRadius),
          child: Stack(
            alignment: Alignment.topLeft,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: _kTitleBarHeight),
                child: child,
              ),
              const _TitleBar(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TitleBar extends StatelessWidget {
  const _TitleBar();

  @override
  Widget build(BuildContext context) {
    return WindowTitleBarBox(
      child: SizedBox(
        height: _kTitleBarHeight,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.12),
                Colors.white.withOpacity(0.04),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: SpacingTokens.lg),
              Expanded(child: MoveWindow()),
              const _WindowButtons(),
            ],
          ),
        ),
      ),
    );
  }
}

class _WindowButtons extends StatelessWidget {
  const _WindowButtons();

  @override
  Widget build(BuildContext context) {
    final buttonColors = WindowButtonColors(
      iconNormal: Colors.white.withOpacity(0.85),
      mouseOver: Colors.white.withOpacity(0.18),
      mouseDown: Colors.white.withOpacity(0.26),
      iconMouseOver: Colors.white,
    );
    final closeButtonColors = WindowButtonColors(
      iconNormal: Colors.white.withOpacity(0.85),
      mouseOver: const Color(0xFFFF6B6B),
      mouseDown: const Color(0xFFE84040),
      iconMouseOver: Colors.white,
    );
    return Padding(
      padding: const EdgeInsets.only(right: SpacingTokens.md),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MinimizeWindowButton(colors: buttonColors),
          MaximizeWindowButton(colors: buttonColors),
          CloseWindowButton(colors: closeButtonColors),
        ],
      ),
    );
  }
}








