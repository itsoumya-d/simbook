import '../../../shared/models/book.dart';

/// Search state class
class SearchState {
  const SearchState({
    this.query = '',
    this.suggestions = const [],
    this.recentSearches = const [],
    this.searchResults = const [],
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage = '',
  });

  final String query;
  final List<String> suggestions;
  final List<String> recentSearches;
  final List<Book> searchResults;
  final bool isLoading;
  final bool hasError;
  final String errorMessage;

  SearchState copyWith({
    String? query,
    List<String>? suggestions,
    List<String>? recentSearches,
    List<Book>? searchResults,
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
  }) {
    return SearchState(
      query: query ?? this.query,
      suggestions: suggestions ?? this.suggestions,
      recentSearches: recentSearches ?? this.recentSearches,
      searchResults: searchResults ?? this.searchResults,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
