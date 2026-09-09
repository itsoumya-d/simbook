import 'package:flutter_test/flutter_test.dart';

import 'package:chat_book/core/constants/app_constants.dart';
import 'package:chat_book/shared/models/book.dart';
import 'package:chat_book/shared/models/mock_books_data.dart';

Book _book({
  String id = 'id-1',
  String title = 'Title',
  String author = 'Author',
  String cover = 'https://example.com/cover.png',
  String? audioUrl,
  String? pdfUrl,
  String? epubUrl,
  double? rating,
  int? ratingsCount,
  int? duration,
  List<String> genres = const [],
  double readingProgress = 0.0,
}) {
  return Book(
    id: id,
    title: title,
    author: author,
    coverImageUrl: cover,
    audioUrl: audioUrl,
    pdfUrl: pdfUrl,
    epubUrl: epubUrl,
    rating: rating,
    ratingsCount: ratingsCount,
    duration: duration,
    genres: genres,
    readingProgress: readingProgress,
  );
}

void main() {
  group('Book.formattedRating', () {
    test('returns empty string when rating is null', () {
      expect(_book().formattedRating, '');
    });

    test('formats to two decimal places', () {
      expect(_book(rating: 4.4).formattedRating, '4.40');
      expect(_book(rating: 3.14159).formattedRating, '3.14');
      expect(_book(rating: 5).formattedRating, '5.00');
    });
  });

  group('Book.formattedRatingsCount', () {
    test('returns empty string when null', () {
      expect(_book().formattedRatingsCount, '');
    });

    test('formats thousands with K', () {
      expect(_book(ratingsCount: 999).formattedRatingsCount, '999');
      expect(_book(ratingsCount: 1000).formattedRatingsCount, '1.0K');
      expect(_book(ratingsCount: 125000).formattedRatingsCount, '125.0K');
    });

    test('formats millions with M', () {
      expect(_book(ratingsCount: 1500000).formattedRatingsCount, '1.5M');
    });
  });

  group('Book.formattedDuration', () {
    test('returns empty string when null', () {
      expect(_book().formattedDuration, '');
    });

    test('formats minutes', () {
      expect(_book(duration: 12).formattedDuration, '12m');
      expect(_book(duration: 59).formattedDuration, '59m');
    });

    test('formats hours and minutes', () {
      expect(_book(duration: 60).formattedDuration, '1h 0m');
      expect(_book(duration: 90).formattedDuration, '1h 30m');
      expect(_book(duration: 125).formattedDuration, '2h 5m');
    });
  });

  group('Book media helpers', () {
    test('hasAudio is false when url is null or empty', () {
      expect(_book().hasAudio, isFalse);
      expect(_book(audioUrl: '').hasAudio, isFalse);
      expect(_book(audioUrl: 'https://a.mp3').hasAudio, isTrue);
    });

    test('hasPdf and hasEpub reflect url presence', () {
      expect(_book().hasPdf, isFalse);
      expect(_book(pdfUrl: 'https://a.pdf').hasPdf, isTrue);
      expect(_book().hasEpub, isFalse);
      expect(_book(epubUrl: 'https://a.epub').hasEpub, isTrue);
    });
  });

  group('Book genres and progress', () {
    test('primaryGenre returns first genre or null', () {
      expect(_book().primaryGenre, isNull);
      expect(_book(genres: ['A', 'B']).primaryGenre, 'A');
    });

    test('isStarted and isCompleted track reading progress', () {
      expect(_book().isStarted, isFalse);
      expect(_book(readingProgress: 0.5).isStarted, isTrue);
      expect(_book(readingProgress: 0.99).isCompleted, isFalse);
      expect(_book(readingProgress: 1.0).isCompleted, isTrue);
      expect(_book(readingProgress: 1.2).isCompleted, isTrue);
    });
  });

  group('Book equality', () {
    test('equality is based on id only', () {
      expect(_book(id: 'x', title: 'A'), _book(id: 'x', title: 'B'));
      expect(_book(id: 'x'), isNot(_book(id: 'y')));
    });

    test('hashCode matches for equal ids', () {
      expect(_book(id: 'x').hashCode, _book(id: 'x').hashCode);
    });

    test('toString includes id, title and author', () {
      final book = _book(id: 'x', title: 'T', author: 'A');
      expect(book.toString(), contains('id: x'));
      expect(book.toString(), contains('title: T'));
      expect(book.toString(), contains('author: A'));
    });
  });

  group('Book.copyWith', () {
    test('overrides provided fields and preserves the rest', () {
      final original = _book(id: 'x', title: 'Old', rating: 3.0, genres: ['A']);
      final updated = original.copyWith(title: 'New', rating: 5.0);
      expect(updated.id, 'x');
      expect(updated.title, 'New');
      expect(updated.rating, 5.0);
      expect(updated.genres, ['A']);
    });
  });

  group('Book JSON', () {
    test('fromJson parses required and optional fields', () {
      final book = Book.fromJson({
        'id': 'x',
        'title': 'T',
        'author': 'A',
        'coverImageUrl': 'https://c',
        'rating': 4,
        'ratingsCount': 10,
        'publishedDate': '2024-01-02T00:00:00.000',
        'genres': ['G'],
        'tags': ['t'],
      });
      expect(book.rating, 4.0);
      expect(book.ratingsCount, 10);
      expect(book.publishedDate, DateTime.parse('2024-01-02T00:00:00.000'));
      expect(book.genres, ['G']);
      expect(book.tags, ['t']);
    });

    test('fromJson applies defaults for missing optional fields', () {
      final book = Book.fromJson({
        'id': 'x',
        'title': 'T',
        'author': 'A',
        'coverImageUrl': 'c',
      });
      expect(book.genres, isEmpty);
      expect(book.isBookmarked, isFalse);
      expect(book.readingProgress, 0.0);
      expect(book.publishedDate, isNull);
    });

    test('toJson round-trips core fields', () {
      final original = _book(
        id: 'x',
        title: 'T',
        author: 'A',
        rating: 4.5,
        ratingsCount: 100,
        duration: 30,
      );
      final restored = Book.fromJson(original.toJson());
      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.author, original.author);
      expect(restored.rating, original.rating);
      expect(restored.ratingsCount, original.ratingsCount);
      expect(restored.duration, original.duration);
    });
  });

  group('MockBooksData', () {
    test('getAllBooks returns a defensive copy', () {
      final first = MockBooksData.getAllBooks();
      expect(first, isNotEmpty);
      first.clear();
      expect(MockBooksData.getAllBooks(), isNotEmpty);
    });

    test('getTrendingBooks only returns trending books', () {
      final trending = MockBooksData.getTrendingBooks();
      expect(trending, isNotEmpty);
      expect(trending.every((book) => book.isTrending), isTrue);
    });

    test('getNewBooks only returns new books', () {
      final newBooks = MockBooksData.getNewBooks();
      expect(newBooks, isNotEmpty);
      expect(newBooks.every((book) => book.isNew), isTrue);
    });

    test('getBookById returns a known book and null otherwise', () {
      expect(MockBooksData.getBookById('atomic-habits')?.title, 'Atomic Habits');
      expect(MockBooksData.getBookById('does-not-exist'), isNull);
    });

    test('searchBooks is case-insensitive across title, author and genre', () {
      expect(MockBooksData.searchBooks('atomic').map((b) => b.id),
          contains('atomic-habits'));
      expect(MockBooksData.searchBooks('ATOMIC').map((b) => b.id),
          contains('atomic-habits'));
      expect(MockBooksData.searchBooks('james clear').map((b) => b.id),
          contains('atomic-habits'));
      expect(MockBooksData.searchBooks('psychology').map((b) => b.id),
          contains('atomic-habits'));
      expect(MockBooksData.searchBooks(''),
          hasLength(MockBooksData.getAllBooks().length));
    });

    test('getBooksByCategory filters by category', () {
      final books = MockBooksData.getBooksByCategory('Self-Help');
      expect(books, isNotEmpty);
      expect(books.every((book) => book.category == 'Self-Help'), isTrue);
    });

    test('getBooksByGenre filters by genre', () {
      final books = MockBooksData.getBooksByGenre('Psychology');
      expect(books, isNotEmpty);
      expect(books.every((book) => book.genres.contains('Psychology')), isTrue);
    });

    test('getRecommendedBooks excludes the seed book and shares a genre', () {
      final seed = MockBooksData.getBookById('atomic-habits')!;
      final recommendations = MockBooksData.getRecommendedBooks('atomic-habits');
      expect(recommendations, isNotEmpty);
      expect(recommendations.any((book) => book.id == seed.id), isFalse);
      expect(
        recommendations.every((book) => book.genres.any(seed.genres.contains)),
        isTrue,
      );
    });

    test('getRecommendedBooks returns empty for an unknown book', () {
      expect(MockBooksData.getRecommendedBooks('nope'), isEmpty);
    });

    test('getFeaturedBooks includes every trending book', () {
      final featured = MockBooksData.getFeaturedBooks();
      final trending = MockBooksData.getTrendingBooks();
      expect(featured.length, greaterThanOrEqualTo(trending.length));
      for (final book in trending) {
        expect(featured.map((b) => b.id), contains(book.id));
      }
    });

    test('getFilteredBooks applies rating, audio and pro filters', () {
      final rated = MockBooksData.getFilteredBooks(minRating: 4.5);
      expect(rated.every((book) => (book.rating ?? 0) >= 4.5), isTrue);

      final withAudio = MockBooksData.getFilteredBooks(hasAudio: true);
      expect(withAudio, isNotEmpty);
      expect(withAudio.every((book) => book.hasAudio), isTrue);

      final pro = MockBooksData.getFilteredBooks(isPro: true);
      expect(pro, isNotEmpty);
      expect(pro.every((book) => book.isPro), isTrue);
    });

    test('popular categories and genres are sorted and unique', () {
      final categories = MockBooksData.getPopularCategories();
      final genres = MockBooksData.getPopularGenres();
      expect(categories, isNotEmpty);
      expect(genres, isNotEmpty);
      expect(categories, equals([...categories]..sort()));
      expect(genres, equals([...genres]..sort()));
      expect(categories.toSet().length, categories.length);
      expect(genres.toSet().length, genres.length);
    });
  });

  group('AppConstants', () {
    test('exposes non-empty core metadata', () {
      expect(AppConstants.appName, isNotEmpty);
      expect(AppConstants.appVersion, isNotEmpty);
      expect(AppConstants.baseUrl, startsWith('https://'));
    });

    test('endpoints are absolute paths', () {
      for (final endpoint in [
        AppConstants.booksEndpoint,
        AppConstants.authorsEndpoint,
        AppConstants.searchEndpoint,
        AppConstants.userEndpoint,
      ]) {
        expect(endpoint, startsWith('/'));
      }
    });

    test('dimensions and limits are positive', () {
      expect(AppConstants.booksPerPage, greaterThan(0));
      expect(AppConstants.coverImageWidth, greaterThan(0));
      expect(AppConstants.defaultPadding, greaterThan(0));
      expect(AppConstants.maxCacheSize, greaterThan(0));
    });
  });
}
