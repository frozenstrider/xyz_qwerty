import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_app/data/mock_repository.dart';
import 'package:reader_app/domain/models/library_models.dart';

import '../../library/providers/library_providers.dart';

final seriesProvider = FutureProvider.family<MangaSeries, String>((ref, id) async {
  final repository = ref.watch(libraryRepositoryProvider);
  return repository.fetchSeries(id);
});

final chapterByIdProvider = FutureProvider.family<MangaChapter, String>((ref, id) async {
  final repository = ref.watch(libraryRepositoryProvider);
  return repository.fetchChapter(id);
});

final relatedSeriesProvider = Provider.family<List<MangaSeries>, String>((ref, id) {
  final repository = ref.watch(libraryRepositoryProvider);
  final target = repository.allSeries.firstWhere((series) => series.id == id, orElse: () => repository.allSeries.first);
  return repository.allSeries
      .where((series) => series.id != target.id && series.genres.any(target.genres.toSet().contains))
      .take(4)
      .toList(growable: false);
});
