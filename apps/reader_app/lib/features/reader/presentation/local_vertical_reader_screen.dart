import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../domain/models/local_library_models.dart';
import '../../../ui/design_system/tokens.dart';

class LocalVerticalReaderScreen extends StatefulWidget {
  const LocalVerticalReaderScreen({super.key, required this.chapter});

  final LocalChapter chapter;

  @override
  State<LocalVerticalReaderScreen> createState() =>
      _LocalVerticalReaderScreenState();
}

class _LocalVerticalReaderScreenState extends State<LocalVerticalReaderScreen> {
  static const double _defaultScale = 0.7;
  static const double _minScale = 0.4;
  static const double _maxScale = 3.5;

  final ScrollController _scrollController = ScrollController();
  late Future<List<_LocalPageData>> _pagesFuture;

  double _scale = _defaultScale;

  Offset? _autoScrollAnchor;
  Offset? _autoScrollPointer;
  Timer? _autoScrollTimer;
  bool _autoScrollActive = false;

  @override
  void initState() {
    super.initState();
    _pagesFuture = _loadPages(widget.chapter);
  }

  @override
  void didUpdateWidget(covariant LocalVerticalReaderScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chapter != widget.chapter) {
      _pagesFuture = _loadPages(widget.chapter);
      _scrollController.jumpTo(0);
      _scale = _defaultScale;
    }
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<_LocalPageData>> _loadPages(LocalChapter chapter) async {
    final result = <_LocalPageData>[];
    for (final path in chapter.pages) {
      try {
        final file = File(path);
        if (!await file.exists()) continue;
        final bytes = await file.readAsBytes();
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        final size =
            Size(frame.image.width.toDouble(), frame.image.height.toDouble());
        frame.image.dispose();
        result.add(_LocalPageData(path: path, size: size));
      } catch (_) {
        // Skip unreadable pages.
      }
    }
    return result;
  }

  void _setScale(double value) {
    setState(() {
      _scale = value.clamp(_minScale, _maxScale);
    });
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      final keysPressed = HardwareKeyboard.instance.logicalKeysPressed;
      final isCtrlHeld = keysPressed.contains(LogicalKeyboardKey.controlLeft) ||
          keysPressed.contains(LogicalKeyboardKey.controlRight);
      if (isCtrlHeld) {
        final delta = -event.scrollDelta.dy / 400;
        if (delta.abs() > 0.0) {
          _setScale(_scale + delta);
        }
      } else if (_scrollController.hasClients) {
        final metrics = _scrollController.position;
        final target = (metrics.pixels + event.scrollDelta.dy * 1.4)
            .clamp(metrics.minScrollExtent, metrics.maxScrollExtent);
        _scrollController.jumpTo(target);
      }
    }
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (event.kind == PointerDeviceKind.mouse &&
        event.buttons & kMiddleMouseButton != 0) {
      final box = context.findRenderObject() as RenderBox?;
      if (box != null) {
        final local = box.globalToLocal(event.position);
        if (_autoScrollActive) {
          _stopAutoScroll();
        } else {
          _startAutoScroll(local);
        }
      }
    }
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (_autoScrollActive) {
      final box = context.findRenderObject() as RenderBox?;
      if (box != null) {
        _autoScrollPointer = box.globalToLocal(event.position);
      }
    }
  }

  void _handlePointerUp(PointerUpEvent event) {}

  void _handlePointerCancel(PointerCancelEvent event) {}

  void _startAutoScroll(Offset position) {
    _autoScrollAnchor = position;
    _autoScrollPointer = position;
    _autoScrollTimer?.cancel();
    _autoScrollTimer =
        Timer.periodic(const Duration(milliseconds: 16), _tickAutoScroll);
    _autoScrollActive = true;
    setState(() {});
  }

  void _stopAutoScroll() {
    if (!_autoScrollActive) return;
    _autoScrollAnchor = null;
    _autoScrollPointer = null;
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
    _autoScrollActive = false;
    setState(() {});
  }

  void _tickAutoScroll(Timer timer) {
    if (_autoScrollAnchor == null ||
        _autoScrollPointer == null ||
        !_scrollController.hasClients) {
      return;
    }

    final metrics = _scrollController.position;
    final dy = _autoScrollPointer!.dy - _autoScrollAnchor!.dy;
    const deadZone = 12.0;
    double velocity = 0;
    if (dy.abs() > deadZone) {
      final direction = dy.sign;
      final magnitude = (dy.abs() - deadZone) * 0.14;
      velocity = direction * magnitude;
    }

    if (velocity != 0) {
      final target = (metrics.pixels + velocity)
          .clamp(metrics.minScrollExtent, metrics.maxScrollExtent);
      _scrollController.jumpTo(target);
    }
  }

  void _scrollByPage(int direction) {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final viewport = position.viewportDimension * 0.9;
    final target = (position.pixels + viewport * direction)
        .clamp(position.minScrollExtent, position.maxScrollExtent);
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.chapter.name)),
      body: FutureBuilder<List<_LocalPageData>>(
        future: _pagesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return const Center(child: Text('Unable to load pages.'));
          }

          final pages = snapshot.data!;

          final totalPages = pages.length;
          final theme = Theme.of(context);

          return Stack(
            fit: StackFit.expand,
            children: [
              Listener(
                behavior: HitTestBehavior.translucent,
                onPointerSignal: _handlePointerSignal,
                onPointerDown: _handlePointerDown,
                onPointerMove: _handlePointerMove,
                onPointerUp: _handlePointerUp,
                onPointerCancel: _handlePointerCancel,
                child: ScrollConfiguration(
                  behavior: const _ReaderScrollBehavior(),
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const _AcceleratedScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      vertical: 2,
                    ),
                    itemCount: totalPages,
                    itemBuilder: (context, index) {
                      final page = pages[index];
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                            alignment: Alignment.topCenter,
                            child: _ScaledPage(
                              data: page,
                              scale: _scale,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${index + 1}/$totalPages',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.7),
                              letterSpacing: 0.4,
                            ),
                          ),
                          if (index < totalPages - 1) const SizedBox(height: 2),
                        ],
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                right: 24,
                bottom: 24,
                child: _ZoomOverlay(
                  scale: _scale,
                  minScale: _minScale,
                  maxScale: _maxScale,
                  onScaleChanged: _setScale,
                  onReset: () => _setScale(_defaultScale),
                ),
              ),
              Positioned(
                left: 12,
                top: MediaQuery.of(context).size.height * 0.5 - 32,
                child: _ScrollArrow(
                  icon: Icons.arrow_upward_rounded,
                  onPressed: () => _scrollByPage(-1),
                ),
              ),
              Positioned(
                right: 12,
                top: MediaQuery.of(context).size.height * 0.5 - 32,
                child: _ScrollArrow(
                  icon: Icons.arrow_downward_rounded,
                  onPressed: () => _scrollByPage(1),
                ),
              ),
              if (_autoScrollAnchor != null)
                Positioned(
                  left: _autoScrollAnchor!.dx - 16,
                  top: _autoScrollAnchor!.dy - 16,
                  child: IgnorePointer(
                    child: Icon(
                      Icons.unfold_more,
                      size: 32,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.75),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ZoomOverlay extends StatelessWidget {
  const _ZoomOverlay({
    required this.scale,
    required this.minScale,
    required this.maxScale,
    required this.onScaleChanged,
    required this.onReset,
  });

  final double scale;
  final double minScale;
  final double maxScale;
  final ValueChanged<double> onScaleChanged;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 6,
      borderRadius: RadiusTokens.md,
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.sm,
          vertical: 2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${(scale * 100).round()}%',
                style: theme.textTheme.labelLarge),
            const SizedBox(width: SpacingTokens.sm),
            SizedBox(
              width: 160,
              child: Slider(
                value: scale,
                min: minScale,
                max: maxScale,
                divisions: 50,
                label: '${(scale * 100).round()}%',
                onChanged: onScaleChanged,
              ),
            ),
            const SizedBox(width: SpacingTokens.xxxs),
            IconButton(
              tooltip: 'Reset zoom',
              icon: const Icon(Icons.center_focus_strong),
              onPressed: onReset,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScaledPage extends StatelessWidget {
  const _ScaledPage({required this.data, required this.scale});

  final _LocalPageData data;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final width = data.size.width * scale;
    final height = data.size.height * scale;
    return RepaintBoundary(
      child: SizedBox(
        width: width,
        height: height,
        child: Image.file(
          File(data.path),
          width: width,
          height: height,
          fit: BoxFit.fill,
          filterQuality: FilterQuality.high,
          alignment: Alignment.topCenter,
        ),
      ),
    );
  }
}

class _LocalPageData {
  const _LocalPageData({required this.path, required this.size});

  final String path;
  final Size size;
}

class _AcceleratedScrollPhysics extends ScrollPhysics {
  const _AcceleratedScrollPhysics({ScrollPhysics? parent})
      : super(parent: parent);

  @override
  _AcceleratedScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _AcceleratedScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    final parentValue = super.applyPhysicsToUserOffset(position, offset);
    return parentValue * 1.5;
  }
}

class _ReaderScrollBehavior extends MaterialScrollBehavior {
  const _ReaderScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
      };
}

class _ScrollArrow extends StatelessWidget {
  const _ScrollArrow({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface.withOpacity(0.95),
      shape: const CircleBorder(),
      elevation: 6,
      child: IconButton(
        icon: Icon(icon, size: 28),
        onPressed: onPressed,
        splashRadius: 28,
      ),
    );
  }
}
