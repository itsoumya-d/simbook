import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/models/book.dart';
import '../../providers/search_provider.dart';
import '../widgets/search_content.dart';

/// Local search over the same sample catalog used by the book detail pages.
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  late final TextEditingController _controller;
  bool _openingBook = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _searchInitialQuery();
  }

  @override
  void didUpdateWidget(covariant SearchPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialQuery != widget.initialQuery) {
      _controller.text = widget.initialQuery;
      _searchInitialQuery();
    }
  }

  void _searchInitialQuery() {
    final query = widget.initialQuery;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.initialQuery == query) {
        ref.read(searchProvider.notifier).search(query, remember: false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(String query) {
    _controller.text = query;
    FocusScope.of(context).unfocus();
    ref.read(searchProvider.notifier).search(query);
  }

  Future<void> _openBook(Book book) async {
    if (_openingBook) return;
    _openingBook = true;
    FocusScope.of(context).unfocus();
    try {
      await context.pushNamed(
        'book-detail',
        pathParameters: {'bookId': book.id},
      );
    } finally {
      _openingBook = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchProvider);
    final notifier = ref.read(searchProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
      ),
      body: SearchContent(
        controller: _controller,
        state: state,
        onChanged: (query) => notifier.search(query, remember: false),
        onSubmitted: _submit,
        onClear: () {
          _controller.clear();
          notifier.clearSearch();
        },
        onRetry: () => notifier.search(_controller.text, remember: false),
        onClearRecent: notifier.clearRecentSearches,
        onBookTap: _openBook,
      ),
    );
  }
}
