import 'package:flutter_test/flutter_test.dart';
import 'package:chat_book/shared/models/mock_books_data.dart';
import 'package:chat_book/shared/models/catalog_search.dart';
import 'package:chat_book/shared/models/book.dart';

void main() {
  test('catalog search normalizes case and surrounding whitespace', () {
    expect(MockBooksData.searchBooks('  ATOMIC   HABITS ').map((b) => b.id), [
      'atomic-habits',
    ]);
  });
  test('catalog search includes existing tags', () {
    expect(MockBooksData.searchBooks('surveillance').map((b) => b.id), [
      '1984',
    ]);
  });
  test('catalog search matches words across title and author', () {
    expect(MockBooksData.searchBooks('atomic clear').map((b) => b.id), [
      'atomic-habits',
    ]);
  });
  test('blank search does not return the entire catalog', () {
    expect(CatalogSearch.filter(MockBooksData.getAllBooks(), '  '), isEmpty);
    expect(
      MockBooksData.searchBooks(''),
      hasLength(MockBooksData.getAllBooks().length),
    );
  });
  test('unknown query is empty and existing author search still works', () {
    expect(MockBooksData.searchBooks('no-such-catalog-entry'), isEmpty);
    expect(MockBooksData.searchBooks('Orwell').map((b) => b.id), ['1984']);
  });
  test(
    'matches subtitle, category and subcategory without inventing results',
    () {
      const books = [
        Book(
          id: 'a',
          title: 'A',
          author: 'Ada',
          coverImageUrl: '',
          subtitle: 'Hidden Trail',
          category: 'Craft',
          subcategory: 'Knitting',
        ),
        Book(
          id: 'b',
          title: 'B',
          author: 'Ben',
          coverImageUrl: '',
          genres: ['Craft'],
          tags: ['trail'],
        ),
      ];
      expect(CatalogSearch.filter(books, 'hidden').map((book) => book.id), [
        'a',
      ]);
      expect(CatalogSearch.filter(books, 'knitting').map((book) => book.id), [
        'a',
      ]);
      expect(
        CatalogSearch.filter(books, 'craft trail').map((book) => book.id),
        ['a', 'b'],
      );
      expect(CatalogSearch.filter(books, 'trail absent'), isEmpty);
      expect(CatalogSearch.filter([], 'trail'), isEmpty);
      expect(CatalogSearch.suggestions(books, 'trail'), ['A', 'B']);
    },
  );
}
