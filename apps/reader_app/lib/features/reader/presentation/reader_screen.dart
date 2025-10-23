import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reader_app/core/feature_flags.dart';
import 'package:reader_app/domain/models/library_models.dart';
import 'package:reader_app/domain/models/reader_models.dart';
import 'package:reader_app/domain/models/settings_models.dart';
import 'package:reader_app/features/library/providers/library_providers.dart';
import 'package:reader_app/features/reader/providers/reader_providers.dart';
import 'package:reader_app/features/settings/providers/settings_provider.dart';
import 'package:reader_app/features/shared/widgets/async_value_widget.dart';
import 'package:reader_app/ui/design_system/tokens.dart';
import 'package:reader_app/ui/design_system/widgets/glass_sheet.dart';

import '../widgets/reader_page_canvas.dart';
import '../widgets/sakura_layer.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({super.key, required this.chapterId});

  final String chapterId;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  late final PageController _singleController;
  late final PageController _doubleController;
  late final ScrollController _verticalController;

  @override
  void initState() {
    super.initState();
    _singleController = PageController();
    _doubleController = PageController();
    _verticalController = ScrollController();
  }

  @override
  void dispose() {
    _singleController.dispose();
    _doubleController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chapterValue = ref.watch(readerChapterProvider(widget.chapterId));
    final viewState = ref.watch(readerViewStateProvider(widget.chapterId));
    final flags = ref.watch(featureFlagsProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        top: false,
        bottom: false,
        child: AsyncValueWidget(
          value: chapterValue,
          builder: (chapter) {
            _syncControllers(viewState, chapter.pages.length, flags.reduceMotion, settings.pageTurnAnimation);
            return Stack(
              fit: StackFit.expand,
              children: [
                _buildReaderBody(chapter, viewState),
                SakuraLayer(enabled: flags.animeThemesEnabled && !flags.reduceMotion),
                _TapZones(
                  onPrevious: () => _navigateBy(viewState, chapter.pages.length, -1, flags.reduceMotion, settings.pageTurnAnimation),
                  onNext: () => _navigateBy(viewState, chapter.pages.length, 1, flags.reduceMotion, settings.pageTurnAnimation),
                  onToggle: () => ref.read(readerViewStateProvider(widget.chapterId).notifier).toggleUi(),
                ),
                _ReaderOverlay(
                  chapter: chapter,
                  state: viewState,
                  onBack: () => context.pop(),
                  onModeChanged: (mode) => ref.read(readerViewStateProvider(widget.chapterId).notifier).setMode(mode, chapter.pages.length),
                  onSliderChanged: (value) {
                    final max = chapter.pages.length;
                    final target = (value * (max - 1)).round();
                    ref.read(readerViewStateProvider(widget.chapterId).notifier).setPage(target, max);
                    _animateToPage(viewState.mode, target, flags.reduceMotion, settings.pageTurnAnimation, max);
                  },
                  onOptions: () => _showOptions(context, viewState),
                  onTranslation: () => _showTranslationSheet(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildReaderBody(MangaChapter chapter, ReaderViewState state) {
    final pages = chapter.pages;
    switch (state.mode) {
      case ReaderMode.vertical:
        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (_verticalController.hasClients && notification.metrics.maxScrollExtent > 0) {
              final ratio = (notification.metrics.pixels / notification.metrics.maxScrollExtent).clamp(0.0, 1.0);
              final target = (ratio * (pages.length - 1)).round();
              ref.read(readerViewStateProvider(widget.chapterId).notifier).setPage(target, pages.length);
            }
            return false;
          },
          child: ListView.builder(
            controller: _verticalController,
            padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.xl, SpacingTokens.lg, SpacingTokens.xl),
            itemCount: pages.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: SpacingTokens.lg),
              child: _PageShell(page: pages[index], state: state),
            ),
          ),
        );
      case ReaderMode.single:
        return PageView.builder(
          controller: _singleController,
          onPageChanged: (index) => ref.read(readerViewStateProvider(widget.chapterId).notifier).setPage(index, pages.length),
          itemCount: pages.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.xl, SpacingTokens.lg, SpacingTokens.xl),
            child: _PageShell(page: pages[index], state: state),
          ),
        );
      case ReaderMode.double:
        final spreadCount = (pages.length / 2).ceil();
        return PageView.builder(
          controller: _doubleController,
          onPageChanged: (index) => ref.read(readerViewStateProvider(widget.chapterId).notifier).setPage(index * 2, pages.length),
          itemCount: spreadCount,
          itemBuilder: (context, spreadIndex) {
            final left = spreadIndex * 2;
            final right = left + 1;
            return Padding(
              padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.xl, SpacingTokens.lg, SpacingTokens.xl),
              child: Row(
                children: [
                  Expanded(child: _PageShell(page: pages[left], state: state)),
                  const SizedBox(width: SpacingTokens.md),
                  Expanded(
                    child: right < pages.length
                        ? _PageShell(page: pages[right], state: state)
                        : const _EmptyPagePlaceholder(),
                  ),
                ],
              ),
            );
          },
        );
    }
  }

  void _navigateBy(ReaderViewState state, int pageCount, int delta, bool reduceMotion, PageTurnAnimation animation) {
    final notifier = ref.read(readerViewStateProvider(widget.chapterId).notifier);
    final step = state.mode == ReaderMode.double ? 2 : 1;
    notifier.setPage(state.pageIndex + delta * step, pageCount);
    _animateToPage(state.mode, notifier.state.pageIndex, reduceMotion, animation, pageCount);
  }

  void _syncControllers(ReaderViewState state, int pageCount, bool reduceMotion, PageTurnAnimation animation) {
    if (!mounted || pageCount <= 0) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      switch (state.mode) {
        case ReaderMode.single:
          if (_singleController.hasClients && _singleController.page?.round() != state.pageIndex) {
            _animateController(_singleController, state.pageIndex, reduceMotion, animation);
          }
          break;
        case ReaderMode.double:
          final target = (state.pageIndex / 2).floor();
          if (_doubleController.hasClients && _doubleController.page?.round() != target) {
            _animateController(_doubleController, target, reduceMotion, animation);
          }
          break;
        case ReaderMode.vertical:
          if (_verticalController.hasClients) {
            final maxScroll = _verticalController.position.maxScrollExtent;
            if (maxScroll > 0) {
              final offset = (state.pageIndex / max(pageCount - 1, 1)) * maxScroll;
              if ((offset - _verticalController.offset).abs() > 48) {
                final config = _animationConfig(animation, reduceMotion);
                _verticalController.animateTo(offset, duration: config.duration, curve: config.curve);
              }
            }
          }
          break;
      }
    });
  }

  void _animateController(PageController controller, int page, bool reduceMotion, PageTurnAnimation animation) {
    if (!controller.hasClients) return;
    final config = _animationConfig(animation, reduceMotion);
    if (config.duration == Duration.zero) {
      controller.jumpToPage(page);
    } else {
      controller.animateToPage(page, duration: config.duration, curve: config.curve);
    }
  }

  void _animateToPage(ReaderMode mode, int page, bool reduceMotion, PageTurnAnimation animation, int pageCount) {
    switch (mode) {
      case ReaderMode.single:
        _animateController(_singleController, page, reduceMotion, animation);
        break;
      case ReaderMode.double:
        _animateController(_doubleController, (page / 2).floor(), reduceMotion, animation);
        break;
      case ReaderMode.vertical:
        if (_verticalController.hasClients) {
          final maxScroll = _verticalController.position.maxScrollExtent;
          if (maxScroll > 0) {
            final offset = (page / max(pageCount - 1, 1)) * maxScroll;
            final config = _animationConfig(animation, reduceMotion);
            _verticalController.animateTo(offset, duration: config.duration, curve: config.curve);
          }
        }
        break;
    }
  }

  void _showOptions(BuildContext context, ReaderViewState state) {
    final notifier = ref.read(readerViewStateProvider(widget.chapterId).notifier);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassSheet(
        title: 'Reader options',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Brightness', style: Theme.of(context).textTheme.titleSmall),
            Slider(value: state.brightness, min: 0.6, max: 1.4, onChanged: notifier.setBrightness),
            const SizedBox(height: SpacingTokens.sm),
            Text('Contrast', style: Theme.of(context).textTheme.titleSmall),
            Slider(value: state.contrast, min: 0.8, max: 1.4, onChanged: notifier.setContrast),
            const SizedBox(height: SpacingTokens.sm),
            Text('Color filter', style: Theme.of(context).textTheme.titleSmall),
            Wrap(
              spacing: 8,
              children: ReaderColorFilter.values
                  .map((filter) => ChoiceChip(
                        label: Text(filter.name),
                        selected: state.colorFilter == filter,
                        onSelected: (_) => notifier.setColorFilter(filter),
                      ))
                  .toList(),
            ),
            const SizedBox(height: SpacingTokens.sm),
            Text('Font scale', style: Theme.of(context).textTheme.titleSmall),
            Slider(value: state.fontScale, min: 0.8, max: 1.4, onChanged: notifier.setFontScale),
          ],
        ),
      ),
    );
  }

  void _showTranslationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const GlassSheet(
        title: 'Translation coming soon',
        child: Text('Translation overlays will appear here once the pipeline is wired in. Re-run this chapter after launch to see progress indicators.'),
      ),
    );
  }
}

class _PageShell extends StatelessWidget {
  const _PageShell({required this.page, required this.state});

  final ReaderPage page;
  final ReaderViewState state;

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 1,
      maxScale: 3,
      clipBehavior: Clip.none,
      child: Center(
        child: AspectRatio(
          aspectRatio: page.aspectRatio,
          child: ReaderPageCanvas(
            page: page,
            brightness: state.brightness,
            contrast: state.contrast,
            colorFilter: state.colorFilter,
            fontScale: state.fontScale,
          ),
        ),
      ),
    );
  }
}

class _EmptyPagePlaceholder extends StatelessWidget {
  const _EmptyPagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      alignment: Alignment.center,
      child: Text('—', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
    );
  }
}

class _TapZones extends StatelessWidget {
  const _TapZones({required this.onPrevious, required this.onNext, required this.onToggle});

  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: GestureDetector(onTap: onPrevious)),
        Expanded(child: GestureDetector(onTap: onToggle)),
        Expanded(child: GestureDetector(onTap: onNext)),
      ],
    );
  }
}

class _ReaderOverlay extends ConsumerWidget {
  const _ReaderOverlay({required this.chapter, required this.state, required this.onBack, required this.onModeChanged, required this.onSliderChanged, required this.onOptions, required this.onTranslation});

  final MangaChapter chapter;
  final ReaderViewState state;
  final VoidCallback onBack;
  final ValueChanged<ReaderMode> onModeChanged;
  final ValueChanged<double> onSliderChanged;
  final VoidCallback onOptions;
  final VoidCallback onTranslation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showUi = state.showUi;
    final pageCount = chapter.pages.length;
    final sliderValue = pageCount <= 1 ? 0.0 : state.pageIndex / (pageCount - 1);

    return AnimatedOpacity(
      opacity: showUi ? 1 : 0,
      duration: const Duration(milliseconds: 200),
      child: IgnorePointer(
        ignoring: !showUi,
        child: Column(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.lg, SpacingTokens.lg, SpacingTokens.md),
                child: Row(
                  children: [
                    IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back_ios_new_rounded)),
                    const SizedBox(width: SpacingTokens.sm),
                    Expanded(
                      child: SegmentedButton<ReaderMode>(
                        segments: const [
                          ButtonSegment(value: ReaderMode.vertical, icon: Icon(Icons.view_agenda_rounded)),
                          ButtonSegment(value: ReaderMode.single, icon: Icon(Icons.chrome_reader_mode_rounded)),
                          ButtonSegment(value: ReaderMode.double, icon: Icon(Icons.view_week_rounded)),
                        ],
                        selected: {state.mode},
                        onSelectionChanged: (selection) => onModeChanged(selection.first),
                      ),
                    ),
                    const SizedBox(width: SpacingTokens.sm),
                    IconButton(onPressed: onTranslation, icon: const Icon(Icons.translate_rounded)),
                    const SizedBox(width: SpacingTokens.sm),
                    IconButton(onPressed: onOptions, icon: const Icon(Icons.tune_rounded)),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SafeArea(
              minimum: const EdgeInsets.fromLTRB(SpacingTokens.lg, 0, SpacingTokens.lg, SpacingTokens.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Slider(value: sliderValue, onChanged: onSliderChanged),
                  const SizedBox(height: SpacingTokens.sm),
                  Text('Page ${state.pageIndex + 1} of $pageCount'),
                  const SizedBox(height: SpacingTokens.sm),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

_ReaderAnimationConfig _animationConfig(PageTurnAnimation style, bool reduceMotion) {
  if (reduceMotion) {
    return const _ReaderAnimationConfig(Duration.zero, Curves.linear);
  }
  switch (style) {
    case PageTurnAnimation.slide:
      return const _ReaderAnimationConfig(Duration(milliseconds: 280), Curves.easeOutCubic);
    case PageTurnAnimation.fade:
      return const _ReaderAnimationConfig(Duration(milliseconds: 220), Curves.easeInOutQuad);
    case PageTurnAnimation.curl:
      return const _ReaderAnimationConfig(Duration(milliseconds: 420), Curves.easeInOutBack);
  }
}

class _ReaderAnimationConfig {
  const _ReaderAnimationConfig(this.duration, this.curve);
  final Duration duration;
  final Curve curve;
}

