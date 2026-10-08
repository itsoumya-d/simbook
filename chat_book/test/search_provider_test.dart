import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:chat_book/features/search/providers/search_provider.dart';
import 'package:chat_book/shared/models/book.dart';
import 'package:chat_book/shared/models/mock_books_data.dart';

const alpha = Book(
  id: 'alpha',
  title: 'Alpha Atlas',
  author: 'Ada Example',
  coverImageUrl: '',
  tags: ['maps'],
);
const beta = Book(
  id: 'beta',
  title: 'Beta Book',
  author: 'Ben Example',
  coverImageUrl: '',
);

void main() {
  test(
    'default loader uses canonical catalog IDs and genuine session history',
    () async {
      final notifier = SearchNotifier();
      addTearDown(notifier.dispose);
      expect(notifier.state.recentSearches, isEmpty);
      await notifier.search('Orwell');
      expect(notifier.state.searchResults.single.id, '1984');
      expect(
        MockBooksData.getBookById(notifier.state.searchResults.single.id),
        isNotNull,
      );
      expect(notifier.state.suggestions, ['1984']);
    },
  );

  test(
    'loading clears stale results, then resolves the matching catalog',
    () async {
      final pending = Completer<List<Book>>();
      final notifier = SearchNotifier(loadCatalog: () => pending.future);
      addTearDown(notifier.dispose);
      final search = notifier.search('maps');
      expect(notifier.state.isLoading, isTrue);
      expect(notifier.state.searchResults, isEmpty);
      pending.complete([alpha, beta]);
      await search;
      expect(notifier.state.searchResults, [alpha]);
      expect(notifier.state.isLoading, isFalse);
    },
  );

  test('latest query wins when older success arrives last', () async {
    final old = Completer<List<Book>>();
    final latest = Completer<List<Book>>();
    var calls = 0;
    final notifier = SearchNotifier(
      loadCatalog: () => calls++ == 0 ? old.future : latest.future,
    );
    addTearDown(notifier.dispose);
    final first = notifier.search('alpha');
    final second = notifier.search('beta');
    latest.complete([alpha, beta]);
    await second;
    old.complete([alpha, beta]);
    await first;
    expect(notifier.state.query, 'beta');
    expect(notifier.state.searchResults, [beta]);
    expect(notifier.state.recentSearches, ['beta']);
  });

  test('clear during pending request ignores late success and error', () async {
    for (final error in [false, true]) {
      final pending = Completer<List<Book>>();
      final notifier = SearchNotifier(loadCatalog: () => pending.future);
      final search = notifier.search('alpha');
      notifier.clearSearch();
      if (error) {
        pending.completeError(StateError('private implementation detail'));
      } else {
        pending.complete([alpha]);
      }
      await search;
      expect(notifier.state.query, '');
      expect(notifier.state.searchResults, isEmpty);
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.hasError, isFalse);
      notifier.dispose();
    }
  });

  test('old failure does not overwrite latest successful results', () async {
    final old = Completer<List<Book>>();
    var calls = 0;
    final notifier = SearchNotifier(
      loadCatalog: () => calls++ == 0 ? old.future : Future.value([beta]),
    );
    addTearDown(notifier.dispose);
    final first = notifier.search('alpha');
    await notifier.search('beta');
    old.completeError(StateError('old failure'));
    await first;
    expect(notifier.state.searchResults, [beta]);
    expect(notifier.state.hasError, isFalse);
  });

  test('failure is safe, retry succeeds and resets the error', () async {
    var calls = 0;
    final notifier = SearchNotifier(
      loadCatalog: () async {
        if (calls++ == 0) throw StateError('secret loader detail');
        return [alpha];
      },
    );
    addTearDown(notifier.dispose);
    await notifier.search('alpha');
    expect(notifier.state.hasError, isTrue);
    expect(notifier.state.errorMessage, isNot(contains('secret')));
    expect(notifier.state.recentSearches, isEmpty);
    await notifier.search('alpha');
    expect(notifier.state.searchResults, [alpha]);
    expect(notifier.state.hasError, isFalse);
    expect(notifier.state.errorMessage, '');
  });

  test(
    'whitespace never loads and typing does not fabricate search history',
    () async {
      var calls = 0;
      final notifier = SearchNotifier(
        loadCatalog: () async {
          calls++;
          return [alpha];
        },
      );
      addTearDown(notifier.dispose);
      await notifier.search('  \n  ');
      expect(calls, 0);
      await notifier.search('a', remember: false);
      expect(notifier.state.recentSearches, isEmpty);
      await notifier.search(' Alpha ');
      await notifier.search('ALPHA');
      expect(notifier.state.recentSearches, ['ALPHA']);
      notifier.clearRecentSearches();
      expect(notifier.state.recentSearches, isEmpty);
    },
  );

  test('history stays bounded to ten submitted queries', () async {
    final notifier = SearchNotifier(loadCatalog: () async => []);
    addTearDown(notifier.dispose);
    for (var i = 0; i < 12; i++) {
      await notifier.search('query $i');
    }
    expect(notifier.state.recentSearches.length, 10);
    expect(notifier.state.recentSearches.first, 'query 11');
  });

  test('disposing while loading ignores completion', () async {
    final pending = Completer<List<Book>>();
    final notifier = SearchNotifier(loadCatalog: () => pending.future);
    final search = notifier.search('alpha');
    notifier.dispose();
    pending.complete([alpha]);
    await expectLater(search, completes);
  });
}
