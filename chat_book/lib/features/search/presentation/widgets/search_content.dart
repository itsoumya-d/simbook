import 'package:flutter/material.dart';

import '../../../../shared/models/book.dart';
import '../../domain/search_state.dart';

/// Network-free search content, styled by the application's Material theme.
class SearchContent extends StatelessWidget {
  const SearchContent({
    super.key,
    required this.controller,
    required this.state,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
    required this.onRetry,
    required this.onClearRecent,
    required this.onBookTap,
  });

  final TextEditingController controller;
  final SearchState state;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final VoidCallback onRetry;
  final VoidCallback onClearRecent;
  final ValueChanged<Book> onBookTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: TextField(
                    controller: controller,
                    autofocus: false,
                    maxLength: 200,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      labelText: 'Search books, authors, topics',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: state.query.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Clear search',
                              onPressed: onClear,
                              icon: const Icon(Icons.clear),
                            ),
                      counterText: '',
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: onChanged,
                    onSubmitted: onSubmitted,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text(
                    'Searching the bundled sample catalog. No live search.',
                  ),
                ),
              ],
            ),
          ),
          _buildResults(context),
        ],
      ),
    );
  }

  Widget _buildResults(BuildContext context) {
    if (state.isLoading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: CircularProgressIndicator(
              semanticsLabel: 'Searching catalog',
            ),
          ),
        ),
      );
    }
    if (state.hasError) {
      return _message(
        children: [
          Text(state.errorMessage, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Center(
            child: FilledButton(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ),
        ],
      );
    }
    if (state.query.trim().isEmpty) {
      return _message(
        children: [
          Text('Search Books', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text('Enter a title, author or topic to find a sample book.'),
          if (state.recentSearches.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Recent searches in this session'),
            ...state.recentSearches.map(
              (query) => ListTile(
                leading: const Icon(Icons.history),
                title: Text(query),
                onTap: () => onSubmitted(query),
              ),
            ),
            TextButton(
              onPressed: onClearRecent,
              child: const Text('Clear recent searches'),
            ),
          ],
        ],
      );
    }
    if (state.searchResults.isEmpty) {
      return _message(
        children: const [
          Text('No books found', textAlign: TextAlign.center),
          SizedBox(height: 8),
          Text(
            'Try another title, author or topic in the sample catalog.',
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
    return SliverList.builder(
      itemCount: state.searchResults.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          final count = state.searchResults.length;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '$count ${count == 1 ? 'book' : 'books'} found',
              semanticsLabel: '$count search results',
            ),
          );
        }
        final book = state.searchResults[index - 1];
        return ListTile(
          key: ValueKey('search-result-${book.id}'),
          leading: const Icon(Icons.menu_book),
          title: Text(book.title),
          subtitle: Text(book.author),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => onBookTap(book),
        );
      },
    );
  }

  Widget _message({required List<Widget> children}) => SliverPadding(
    padding: const EdgeInsets.all(24),
    sliver: SliverList.list(children: children),
  );
}
