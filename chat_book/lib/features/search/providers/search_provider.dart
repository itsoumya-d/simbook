import 'package:flutter_riverpod/flutter_riverpod.dart';

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

/// Search notifier class
class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier() : super(const SearchState()) {
    _loadRecentSearches();
    _initializeSuggestions();
  }

  /// Mock book database for suggestions
  static const List<String> _mockBookTitles = [
    'The Subtle Art of Not Giving a F*ck',
    'Sapiens: A Brief History of Humankind',
    'Atomic Habits',
    'Homo Deus: A Brief History of Tomorrow',
    'The Power of Habit',
    'Thinking, Fast and Slow',
    'The 7 Habits of Highly Effective People',
    'Rich Dad Poor Dad',
    'The Lean Startup',
    'Good to Great',
    'The Intelligent Investor',
    'Zero to One',
    'The Art of War',
    'How to Win Friends and Influence People',
    'The 4-Hour Workweek',
    'Outliers: The Story of Success',
    'The Tipping Point',
    'Blink: The Power of Thinking Without Thinking',
    'Freakonomics',
    'The Black Swan',
    'Nudge',
    'Predictably Irrational',
    'The Paradox of Choice',
    'Drive: The Surprising Truth About What Motivates Us',
    'Flow: The Psychology of Optimal Experience',
    'Mindset: The New Psychology of Success',
    'Grit: The Power of Passion and Perseverance',
    'The Happiness Hypothesis',
    'Stumbling on Happiness',
    'The Righteous Mind',
  ];

  static const List<String> _mockAuthors = [
    'Mark Manson',
    'Yuval Noah Harari',
    'James Clear',
    'Charles Duhigg',
    'Daniel Kahneman',
    'Stephen R. Covey',
    'Robert Kiyosaki',
    'Eric Ries',
    'Jim Collins',
    'Benjamin Graham',
    'Peter Thiel',
    'Sun Tzu',
    'Dale Carnegie',
    'Timothy Ferriss',
    'Malcolm Gladwell',
    'Steven D. Levitt',
    'Nassim Nicholas Taleb',
    'Richard H. Thaler',
    'Dan Ariely',
    'Barry Schwartz',
    'Daniel H. Pink',
    'Mihaly Csikszentmihalyi',
    'Carol S. Dweck',
    'Angela Duckworth',
    'Jonathan Haidt',
    'Daniel Gilbert',
  ];

  /// Initialize suggestions with popular books and authors
  void _initializeSuggestions() {
    final allSuggestions = [..._mockBookTitles, ..._mockAuthors];
    state = state.copyWith(suggestions: allSuggestions);
  }

  /// Load recent searches from storage (mock implementation)
  void _loadRecentSearches() {
    // In a real app, this would load from Hive or SharedPreferences
    const mockRecentSearches = [
      'Atomic Habits',
      'Sapiens',
      'The Power of Habit',
      'Thinking Fast and Slow',
      'Zero to One',
    ];
    
    state = state.copyWith(recentSearches: mockRecentSearches);
  }

  /// Update search query and get suggestions
  void updateQuery(String query) {
    state = state.copyWith(query: query);
    
    if (query.isEmpty) {
      return;
    }
    
    // Get filtered suggestions
    final filteredSuggestions = _getFilteredSuggestions(query);
    state = state.copyWith(suggestions: filteredSuggestions);
  }

  /// Get filtered suggestions based on query
  List<String> _getFilteredSuggestions(String query) {
    if (query.isEmpty) return [];
    
    final lowerQuery = query.toLowerCase();
    final allSuggestions = [..._mockBookTitles, ..._mockAuthors];
    
    // Prioritize exact matches, then starts with, then contains
    final exactMatches = <String>[];
    final startsWithMatches = <String>[];
    final containsMatches = <String>[];
    
    for (final suggestion in allSuggestions) {
      final lowerSuggestion = suggestion.toLowerCase();
      
      if (lowerSuggestion == lowerQuery) {
        exactMatches.add(suggestion);
      } else if (lowerSuggestion.startsWith(lowerQuery)) {
        startsWithMatches.add(suggestion);
      } else if (lowerSuggestion.contains(lowerQuery)) {
        containsMatches.add(suggestion);
      }
    }
    
    // Combine results with priority order
    final results = [
      ...exactMatches,
      ...startsWithMatches.take(3),
      ...containsMatches.take(2),
    ];
    
    return results.take(8).toList();
  }

  /// Perform search
  Future<void> search(String query) async {
    if (query.isEmpty) return;
    
    state = state.copyWith(
      query: query,
      isLoading: true,
      hasError: false,
    );
    
    try {
      // Add to recent searches
      _addToRecentSearches(query);
      
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Mock search results
      final results = _getMockSearchResults(query);
      
      state = state.copyWith(
        searchResults: results,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Failed to search: ${e.toString()}',
      );
    }
  }

  /// Add query to recent searches
  void _addToRecentSearches(String query) {
    final recentSearches = List<String>.from(state.recentSearches);
    
    // Remove if already exists
    recentSearches.remove(query);
    
    // Add to beginning
    recentSearches.insert(0, query);
    
    // Keep only last 10
    if (recentSearches.length > 10) {
      recentSearches.removeRange(10, recentSearches.length);
    }
    
    state = state.copyWith(recentSearches: recentSearches);
  }

  /// Get mock search results
  List<Book> _getMockSearchResults(String query) {
    // This would normally call an API
    // For now, return mock results based on query
    
    final mockBooks = [
      const Book(
        id: '1',
        title: 'The Subtle Art of Not Giving a F*ck',
        author: 'Mark Manson',
        subtitle: 'A Counterintuitive Approach to Living a Good Life',
        coverImageUrl: 'https://files.sobrief.com/social/cover_the-subtle-art-of-not-giving-a-fuck_360px_1747127884.jpg',
        rating: 3.87,
        ratingsCount: 1300000,
        duration: 15,
        isNew: true,
      ),
      const Book(
        id: '2',
        title: 'Sapiens',
        author: 'Yuval Noah Harari',
        subtitle: 'A Brief History of Humankind',
        coverImageUrl: 'https://files.sobrief.com/social/cover_sapiens_360px_1747127935.jpg',
        rating: 4.34,
        ratingsCount: 1200000,
        duration: 22,
        isTrending: true,
      ),
      const Book(
        id: '3',
        title: 'Atomic Habits',
        author: 'James Clear',
        subtitle: 'An Easy & Proven Way to Build Good Habits & Break Bad Ones',
        coverImageUrl: 'https://files.sobrief.com/social/cover_atomic-habits_360px_1747125904.jpg',
        rating: 4.33,
        ratingsCount: 1100000,
        duration: 18,
        isPro: true,
      ),
    ];
    
    // Filter based on query
    final lowerQuery = query.toLowerCase();
    return mockBooks.where((book) {
      return book.title.toLowerCase().contains(lowerQuery) ||
             book.author.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Clear search
  void clearSearch() {
    state = state.copyWith(
      query: '',
      searchResults: [],
      hasError: false,
      errorMessage: '',
    );
  }

  /// Clear recent searches
  void clearRecentSearches() {
    state = state.copyWith(recentSearches: []);
  }
}

/// Search provider
final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier();
});

/// Search suggestions provider
final searchSuggestionsProvider = Provider<List<String>>((ref) {
  final searchState = ref.watch(searchProvider);
  return searchState.suggestions;
});

/// Recent searches provider
final recentSearchesProvider = Provider<List<String>>((ref) {
  final searchState = ref.watch(searchProvider);
  return searchState.recentSearches;
});

/// Search results provider
final searchResultsProvider = Provider<List<Book>>((ref) {
  final searchState = ref.watch(searchProvider);
  return searchState.searchResults;
});