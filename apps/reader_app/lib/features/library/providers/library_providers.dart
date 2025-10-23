import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_app/data/mock_repository.dart';
import 'package:reader_app/domain/models/library_models.dart';
import 'package:reader_app/domain/models/reader_models.dart';

final libraryRepositoryProvider = Provider<MockLibraryRepository>((ref) => MockLibraryRepository());

final homeFeedProvider = FutureProvider<MangaHomeFeed>((ref) async {
  final repository = ref.watch(libraryRepositoryProvider);
  return repository.loadHomeFeed();
});

final libraryStateProvider = StateNotifierProvider<LibraryController, LibraryState>((ref) {
  final repository = ref.watch(libraryRepositoryProvider);
  return LibraryController(repository);
});

final purchasesProvider = StateNotifierProvider<PurchaseController, PurchaseState>((ref) {
  final repository = ref.watch(libraryRepositoryProvider);
  return PurchaseController(ref: ref, repository: repository);
});

class LibraryState {
  const LibraryState({
    required this.ownedSeries,
    required this.readingProgress,
    required this.downloadedChapterIds,
    required this.recentChapterIds,
  });

  final List<MangaSeries> ownedSeries;
  final Map<String, int> readingProgress;
  final Set<String> downloadedChapterIds;
  final List<String> recentChapterIds;

  LibraryState copyWith({
    List<MangaSeries>? ownedSeries,
    Map<String, int>? readingProgress,
    Set<String>? downloadedChapterIds,
    List<String>? recentChapterIds,
  }) {
    return LibraryState(
      ownedSeries: ownedSeries ?? this.ownedSeries,
      readingProgress: readingProgress ?? this.readingProgress,
      downloadedChapterIds: downloadedChapterIds ?? this.downloadedChapterIds,
      recentChapterIds: recentChapterIds ?? this.recentChapterIds,
    );
  }

  static LibraryState bootstrap(MockLibraryRepository repository) {
    final owned = repository.allSeries.where((series) => !series.isPremium || series.price == 0 || series.id == 'starlight-courier').toList();
    final downloadedIds = <String>{};
    final progress = <String, int>{};
    final recents = <String>[];

    for (final series in owned) {
      final firstChapter = series.chapters.first;
      progress[firstChapter.id] = firstChapter.lastReadPage.clamp(0, firstChapter.pages.length - 1);
      if (firstChapter.isDownloaded) {
        downloadedIds.add(firstChapter.id);
      }
      recents.add(firstChapter.id);
    }

    return LibraryState(
      ownedSeries: owned,
      readingProgress: progress,
      downloadedChapterIds: downloadedIds,
      recentChapterIds: recents,
    );
  }
}

class LibraryController extends StateNotifier<LibraryState> {
  LibraryController(this._repository) : super(LibraryState.bootstrap(_repository));

  final MockLibraryRepository _repository;

  void addSeries(MangaSeries series) {
    if (state.ownedSeries.any((element) => element.id == series.id)) return;
    state = state.copyWith(ownedSeries: [...state.ownedSeries, series]);
  }

  void onChapterPurchased(MangaChapter chapter) {
    final owned = state.ownedSeries.any((series) => series.id == chapter.seriesId)
        ? state.ownedSeries
        : [...state.ownedSeries, _repository.allSeries.firstWhere((series) => series.id == chapter.seriesId)];

    final progress = Map<String, int>.from(state.readingProgress)..putIfAbsent(chapter.id, () => 0);
    final recents = [chapter.id, ...state.recentChapterIds.where((id) => id != chapter.id)];

    state = state.copyWith(ownedSeries: owned, readingProgress: progress, recentChapterIds: recents);
  }

  void markChapterDownloaded(String chapterId, {required bool isDownloaded}) {
    final updated = Set<String>.from(state.downloadedChapterIds);
    if (isDownloaded) {
      updated.add(chapterId);
    } else {
      updated.remove(chapterId);
    }
    state = state.copyWith(downloadedChapterIds: updated);
  }

  void updateProgress(String chapterId, int pageIndex) {
    final progress = Map<String, int>.from(state.readingProgress);
    progress[chapterId] = pageIndex;
    final recents = [chapterId, ...state.recentChapterIds.where((id) => id != chapterId)];
    state = state.copyWith(readingProgress: progress, recentChapterIds: recents);
  }

  MangaChapter? findChapter(String chapterId) {
    for (final series in _repository.allSeries) {
      for (final chapter in series.chapters) {
        if (chapter.id == chapterId) return chapter;
      }
    }
    return null;
  }
}

class PurchaseState {
  const PurchaseState({required this.history, required this.ownedChapterIds});

  final List<PurchaseRecord> history;
  final Set<String> ownedChapterIds;

  PurchaseState copyWith({List<PurchaseRecord>? history, Set<String>? ownedChapterIds}) {
    return PurchaseState(
      history: history ?? this.history,
      ownedChapterIds: ownedChapterIds ?? this.ownedChapterIds,
    );
  }

  static PurchaseState initial(MockLibraryRepository repository) {
    final owned = <String>{};
    final history = <PurchaseRecord>[];
    for (final series in repository.allSeries.where((series) => !series.isPremium)) {
      for (final chapter in series.chapters) {
        if (!chapter.isLocked) {
          owned.add(chapter.id);
        }
      }
    }
    return PurchaseState(history: history, ownedChapterIds: owned);
  }
}

class PurchaseController extends StateNotifier<PurchaseState> {
  PurchaseController({required this.ref, required MockLibraryRepository repository})
      : _repository = repository,
        super(PurchaseState.initial(repository));

  final Ref ref;
  final MockLibraryRepository _repository;

  Future<PurchaseRecord> purchaseChapter(MangaChapter chapter) async {
    await Future.delayed(_repository.latency + const Duration(milliseconds: 160));
    final record = PurchaseRecord(
      id: '-',
      itemId: chapter.id,
      purchasedAt: DateTime.now(),
      price: chapter.price,
    );
    final history = [...state.history, record];
    final owned = {...state.ownedChapterIds, chapter.id};
    state = state.copyWith(history: history, ownedChapterIds: owned);
    ref.read(libraryStateProvider.notifier).onChapterPurchased(chapter);
    return record;
  }

  bool isOwned(String chapterId) => state.ownedChapterIds.contains(chapterId);
}
