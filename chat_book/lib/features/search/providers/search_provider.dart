import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/book.dart';
import '../../../shared/models/mock_books_data.dart';
import '../../../shared/models/catalog_search.dart';
import '../domain/search_state.dart';

export '../domain/search_state.dart';

typedef CatalogLoader = Future<List<Book>> Function();

/// The bundled sample catalog is the only search source; no live API is used.
final searchCatalogProvider = Provider<CatalogLoader>((ref) {
  return () async => MockBooksData.getAllBooks();
});

class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier({CatalogLoader? loadCatalog})
    : _loadCatalog = loadCatalog ?? (() async => MockBooksData.getAllBooks()),
      super(const SearchState());

  final CatalogLoader _loadCatalog;
  int _request = 0;

  void updateQuery(String query) {
    // Invalidate even before a replacement search starts (or when cleared).
    _request++;
    state = state.copyWith(
      query: query,
      searchResults: [],
      suggestions: [],
      isLoading: false,
      hasError: false,
      errorMessage: '',
    );
  }

  Future<void> search(String query, {bool remember = true}) async {
    final normalized = CatalogSearch.normalize(query);
    if (normalized.isEmpty) {
      clearSearch();
      return;
    }
    final request = ++_request;
    state = state.copyWith(
      query: query,
      searchResults: [],
      suggestions: [],
      isLoading: true,
      hasError: false,
      errorMessage: '',
    );
    try {
      final catalog = await _loadCatalog();
      if (!mounted || request != _request) return;
      final recent = [...state.recentSearches];
      if (remember) {
        recent.removeWhere(
          (value) => CatalogSearch.normalize(value) == normalized,
        );
        recent.insert(0, query.trim().replaceAll(RegExp(r'\s+'), ' '));
      }
      state = state.copyWith(
        searchResults: CatalogSearch.filter(catalog, query),
        suggestions: CatalogSearch.suggestions(catalog, query),
        recentSearches: recent.take(10).toList(),
        isLoading: false,
      );
    } catch (_) {
      if (!mounted || request != _request) return;
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Could not load the sample catalog. Please try again.',
      );
    }
  }

  void clearSearch() => updateQuery('');

  void clearRecentSearches() {
    state = state.copyWith(recentSearches: []);
  }

  @override
  void dispose() {
    _request++;
    super.dispose();
  }
}

final searchProvider =
    StateNotifierProvider.autoDispose<SearchNotifier, SearchState>((ref) {
      return SearchNotifier(loadCatalog: ref.watch(searchCatalogProvider));
    });

final searchSuggestionsProvider = Provider.autoDispose<List<String>>((ref) {
  return ref.watch(searchProvider).suggestions;
});
final recentSearchesProvider = Provider.autoDispose<List<String>>((ref) {
  return ref.watch(searchProvider).recentSearches;
});
final searchResultsProvider = Provider.autoDispose<List<Book>>((ref) {
  return ref.watch(searchProvider).searchResults;
});
