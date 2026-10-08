import 'book.dart';

/// Deterministic, local matching over the existing catalog in catalog order.
class CatalogSearch {
  static String normalize(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  /// Every query word must occur in a title, author, subtitle or topic field.
  static List<Book> filter(Iterable<Book> books, String query) {
    final normalized = normalize(query);
    if (normalized.isEmpty) return [];
    final words = normalized.split(' ');
    return books.where((book) {
      final fields = [
        book.title,
        book.author,
        book.subtitle ?? '',
        ...book.genres,
        ...book.tags,
        book.category ?? '',
        book.subcategory ?? '',
      ].map(normalize);
      return words.every((word) => fields.any((field) => field.contains(word)));
    }).toList();
  }

  static List<String> suggestions(Iterable<Book> books, String query) {
    return filter(
      books,
      query,
    ).map((book) => book.title).toSet().take(8).toList();
  }
}
