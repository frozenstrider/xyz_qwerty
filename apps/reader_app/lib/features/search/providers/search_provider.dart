import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reader_app/data/mock_repository.dart';
import 'package:reader_app/domain/models/library_models.dart';
import 'package:reader_app/features/library/providers/library_providers.dart';

final searchControllerProvider =
    StateNotifierProvider<SearchController, SearchState>((ref) {
  final repository = ref.watch(libraryRepositoryProvider);
  return SearchController(repository);
});

class SearchState {
  const SearchState({
    required this.query,
    required this.results,
    required this.selectedGenres,
    required this.selectedTags,
    this.isSearching = false,
  });

  final String query;
  final List<MangaSeries> results;
  final Set<String> selectedGenres;
  final Set<String> selectedTags;
  final bool isSearching;

  SearchState copyWith({
    String? query,
    List<MangaSeries>? results,
    Set<String>? selectedGenres,
    Set<String>? selectedTags,
    bool? isSearching,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      selectedGenres: selectedGenres ?? this.selectedGenres,
      selectedTags: selectedTags ?? this.selectedTags,
      isSearching: isSearching ?? this.isSearching,
    );
  }

  static SearchState initial() => const SearchState(
        query: '',
        results: <MangaSeries>[],
        selectedGenres: <String>{},
        selectedTags: <String>{},
        isSearching: false,
      );
}

class SearchController extends StateNotifier<SearchState> {
  SearchController(this._repository) : super(SearchState.initial());

  final MockLibraryRepository _repository;
  Timer? _debounce;
  List<MangaSeries> _latestResults = const [];

  void setQuery(String query) {
    state = state.copyWith(query: query, isSearching: true);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 320), () async {
      final results = await _repository.search(query);
      _latestResults = results;
      _applyFilters(base: results);
    });
  }

  void toggleGenre(String genre) {
    final updated = Set<String>.from(state.selectedGenres);
    if (!updated.add(genre)) {
      updated.remove(genre);
    }
    _applyFilters(genres: updated);
  }

  void toggleTag(String tag) {
    final updated = Set<String>.from(state.selectedTags);
    if (!updated.add(tag)) {
      updated.remove(tag);
    }
    _applyFilters(tags: updated);
  }

  void clearFilters() {
    _applyFilters(genres: <String>{}, tags: <String>{});
  }

  void _applyFilters(
      {List<MangaSeries>? base, Set<String>? genres, Set<String>? tags}) {
    final activeGenres = genres ?? state.selectedGenres;
    final activeTags = tags ?? state.selectedTags;
    final source = base ?? _latestResults;

    var filtered = source;
    if (activeGenres.isNotEmpty) {
      filtered = filtered
          .where((series) =>
              series.genres.any((genre) => activeGenres.contains(genre)))
          .toList(growable: false);
    }
    if (activeTags.isNotEmpty) {
      filtered = filtered
          .where((series) => series.tags.any((tag) => activeTags.contains(tag)))
          .toList(growable: false);
    }

    state = state.copyWith(
      results: filtered,
      selectedGenres: activeGenres,
      selectedTags: activeTags,
      isSearching: false,
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
