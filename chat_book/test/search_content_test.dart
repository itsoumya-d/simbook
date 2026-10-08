import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chat_book/features/search/domain/search_state.dart';
import 'package:chat_book/features/search/presentation/widgets/search_content.dart';
import 'package:chat_book/shared/models/book.dart';

const fixture = Book(
  id: 'fixture',
  title: 'Fixture Atlas',
  author: 'Test Author',
  coverImageUrl: '',
);

void main() {
  Future<void> show(
    WidgetTester tester,
    SearchState state, {
    VoidCallback? retry,
    ValueChanged<Book>? select,
    ValueChanged<String>? submit,
    VoidCallback? clear,
  }) async {
    final controller = TextEditingController(text: state.query);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Search')),
          body: SearchContent(
            controller: controller,
            state: state,
            onChanged: (_) {},
            onSubmitted: submit ?? (_) {},
            onClear: clear ?? () {},
            onRetry: retry ?? () {},
            onClearRecent: () {},
            onBookTap: select ?? (_) {},
          ),
        ),
      ),
    );
  }

  testWidgets(
    'idle discloses sample scope without fabricated history or size',
    (tester) async {
      await show(tester, const SearchState());
      expect(find.text('Search Books'), findsOneWidget);
      expect(find.textContaining('bundled sample catalog'), findsOneWidget);
      expect(find.textContaining('Recent searches'), findsNothing);
      expect(find.textContaining('73,530'), findsNothing);
      expect(find.text('Coming Soon!'), findsNothing);
    },
  );
  testWidgets('loading state is labeled and hides stale books', (tester) async {
    await show(
      tester,
      const SearchState(
        query: 'fixture',
        isLoading: true,
        searchResults: [fixture],
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text(fixture.title), findsNothing);
  });
  testWidgets('failure exposes a working retry', (tester) async {
    var retried = false;
    await show(
      tester,
      const SearchState(
        query: 'fixture',
        hasError: true,
        errorMessage: 'Could not load catalog',
      ),
      retry: () => retried = true,
    );
    await tester.tap(find.text('Try again'));
    expect(retried, isTrue);
  });
  testWidgets('empty results offer useful recovery', (tester) async {
    await show(tester, const SearchState(query: 'missing'));
    expect(find.text('No books found'), findsOneWidget);
    expect(find.textContaining('Try another'), findsOneWidget);
  });
  testWidgets('result count and tap preserve the exact book', (tester) async {
    Book? selected;
    await show(
      tester,
      const SearchState(query: 'fixture', searchResults: [fixture]),
      select: (book) => selected = book,
    );
    expect(find.text('1 book found'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('search-result-fixture')));
    expect(identical(selected, fixture), isTrue);
  });
  testWidgets('recent search and clear actions are wired', (tester) async {
    String? submitted;
    await show(
      tester,
      const SearchState(recentSearches: ['Fixture Atlas']),
      submit: (query) => submitted = query,
    );
    await tester.tap(find.text('Fixture Atlas'));
    expect(submitted, 'Fixture Atlas');
    var cleared = false;
    await show(
      tester,
      const SearchState(query: 'fixture'),
      clear: () => cleared = true,
    );
    await tester.tap(find.byTooltip('Clear search'));
    expect(cleared, isTrue);
  });
  testWidgets(
    'small viewport and large text keep idle and results scrollable',
    (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1;
      tester.view.viewInsets = const FakeViewPadding(bottom: 220);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await show(
        tester,
        const SearchState(recentSearches: ['a', 'b', 'c', 'd', 'e', 'f']),
      );
      expect(tester.takeException(), isNull);
      await show(
        tester,
        const SearchState(query: 'fixture', searchResults: [fixture]),
      );
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -200));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
