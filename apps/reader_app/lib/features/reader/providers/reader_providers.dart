import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_app/data/mock_repository.dart';
import 'package:reader_app/domain/models/library_models.dart';
import 'package:reader_app/domain/models/reader_models.dart';
import 'package:reader_app/features/settings/providers/settings_provider.dart';

import '../../library/providers/library_providers.dart';

final readerChapterProvider =
    FutureProvider.family<MangaChapter, String>((ref, id) async {
  final repository = ref.watch(libraryRepositoryProvider);
  return repository.fetchChapter(id);
});

final readerViewStateProvider =
    StateNotifierProvider.family<ReaderController, ReaderViewState, String>(
        (ref, chapterId) {
  final settings = ref.watch(settingsProvider);
  return ReaderController(initialMode: settings.defaultReaderMode);
});

class ReaderViewState {
  const ReaderViewState({
    required this.mode,
    required this.pageIndex,
    required this.showUi,
    required this.brightness,
    required this.contrast,
    required this.colorFilter,
    required this.fontScale,
  });

  final ReaderMode mode;
  final int pageIndex;
  final bool showUi;
  final double brightness;
  final double contrast;
  final ReaderColorFilter colorFilter;
  final double fontScale;

  ReaderViewState copyWith({
    ReaderMode? mode,
    int? pageIndex,
    bool? showUi,
    double? brightness,
    double? contrast,
    ReaderColorFilter? colorFilter,
    double? fontScale,
  }) {
    return ReaderViewState(
      mode: mode ?? this.mode,
      pageIndex: pageIndex ?? this.pageIndex,
      showUi: showUi ?? this.showUi,
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
      colorFilter: colorFilter ?? this.colorFilter,
      fontScale: fontScale ?? this.fontScale,
    );
  }

  static ReaderViewState initial({required ReaderMode mode}) => ReaderViewState(
        mode: mode,
        pageIndex: 0,
        showUi: true,
        brightness: 1,
        contrast: 1,
        colorFilter: ReaderColorFilter.neutral,
        fontScale: 1,
      );
}

enum ReaderColorFilter { neutral, sepia, dusk, midnight }

class ReaderController extends StateNotifier<ReaderViewState> {
  ReaderController({required ReaderMode initialMode})
      : super(ReaderViewState.initial(mode: initialMode));

  void setMode(ReaderMode mode, int maxPages) {
    if (maxPages <= 0) {
      state = state.copyWith(mode: mode);
      return;
    }
    final clampedPage = switch (mode) {
      ReaderMode.vertical => state.pageIndex,
      ReaderMode.single => state.pageIndex.clamp(0, maxPages - 1).toInt(),
      ReaderMode.double =>
        ((state.pageIndex ~/ 2) * 2).clamp(0, maxPages - 1).toInt(),
    };
    state = state.copyWith(mode: mode, pageIndex: clampedPage);
  }

  void setPage(int index, int maxPages) {
    if (maxPages <= 0) return;
    final clamped = index.clamp(0, maxPages - 1).toInt();
    state = state.copyWith(pageIndex: clamped);
  }

  void toggleUi() => state = state.copyWith(showUi: !state.showUi);

  void setBrightness(double value) => state = state.copyWith(brightness: value);

  void setContrast(double value) => state = state.copyWith(contrast: value);

  void setColorFilter(ReaderColorFilter filter) =>
      state = state.copyWith(colorFilter: filter);

  void setFontScale(double value) => state = state.copyWith(fontScale: value);
}
