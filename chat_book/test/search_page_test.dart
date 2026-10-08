import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:chat_book/features/search/presentation/pages/search_page.dart';
import 'package:chat_book/features/search/providers/search_provider.dart';
import 'package:chat_book/shared/models/book.dart';
import 'package:chat_book/shared/models/mock_books_data.dart';

void main() {
  Future<GoRouter> show(
    WidgetTester tester, {
    String location = '/search',
    CatalogLoader? loader,
  }) async {
    final router = GoRouter(
      initialLocation: location,
      routes: [
        ShellRoute(
          builder: (_, _, child) => child,
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => const Scaffold(body: Text('Home')),
            ),
            GoRoute(
              path: '/search',
              builder: (_, state) => SearchPage(
                initialQuery: state.uri.queryParameters['q'] ?? '',
              ),
            ),
            GoRoute(
              path: '/books',
              builder: (_, _) => const Scaffold(body: Text('Books')),
              routes: [
                GoRoute(
                  path: '/:bookId',
                  name: 'book-detail',
                  builder: (_, state) {
                    final book = MockBooksData.getBookById(
                      state.pathParameters['bookId']!,
                    );
                    return Scaffold(
                      appBar: AppBar(title: const Text('Detail route')),
                      body: Text(book?.id ?? 'Book not found'),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          if (loader != null) searchCatalogProvider.overrideWithValue(loader),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  testWidgets('typing filters, submit records history, clear restores idle', (
    tester,
  ) async {
    await show(tester);
    await tester.enterText(find.byType(TextField), 'orwell');
    await tester.pumpAndSettle();
    expect(find.text('1984'), findsOneWidget);
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();
    expect(find.text('Search Books'), findsOneWidget);
    expect(find.text('orwell'), findsOneWidget);
    await tester.tap(find.text('orwell'));
    await tester.pumpAndSettle();
    expect(find.text('1984'), findsOneWidget);
  });

  testWidgets('initial query and route replacement use latest query', (
    tester,
  ) async {
    final router = await show(tester, location: '/search?q=atomic');
    expect(find.text('Atomic Habits'), findsOneWidget);
    router.go('/search?q=orwell');
    await tester.pumpAndSettle();
    expect(find.text('1984'), findsOneWidget);
    expect(find.text('Atomic Habits'), findsNothing);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'orwell',
    );
  });

  testWidgets('result pushes canonical detail route and back preserves query', (
    tester,
  ) async {
    final router = await show(tester, location: '/search?q=orwell');
    await tester.tap(find.byKey(const ValueKey('search-result-1984')));
    // Repeated taps before navigation paints must not push duplicate details.
    await tester.tap(find.byKey(const ValueKey('search-result-1984')));
    await tester.pumpAndSettle();
    expect(find.text('Detail route'), findsOneWidget);
    expect(find.text('Book not found'), findsNothing);
    expect(find.text('1984'), findsOneWidget);
    router.pop();
    await tester.pumpAndSettle();
    expect(find.text('1 book found'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'orwell',
    );
  });

  testWidgets('cold search back goes home without popping an empty stack', (
    tester,
  ) async {
    await show(tester);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('page displays loader failure and recovers on retry', (
    tester,
  ) async {
    var calls = 0;
    await show(
      tester,
      location: '/search?q=orwell',
      loader: () async {
        if (calls++ == 0) throw StateError('test failure');
        return MockBooksData.getAllBooks();
      },
    );
    expect(find.text('Try again'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('1984'), findsOneWidget);
  });

  testWidgets('leaving during a search ignores late completion', (
    tester,
  ) async {
    final pending = Completer<List<Book>>();
    final router = await show(tester, loader: () => pending.future);
    await tester.enterText(find.byType(TextField), 'orwell');
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    router.go('/');
    await tester.pumpAndSettle();
    pending.complete(MockBooksData.getAllBooks());
    await tester.pump();
    expect(find.text('Home'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
