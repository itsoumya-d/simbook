# chat_book

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


## Sample catalog search

`/search` now searches the same seven bundled sample books used by the book
pages. This is a local demo catalog, not a live book service or a claim to cover
73,530 titles. Existing sample summaries, ratings, covers and placeholder media
URLs are unchanged.

- Type a title, author, subtitle or topic (genre, tag, category or subcategory).
  Matching is case-insensitive; whitespace is normalized and all query words
  must match a catalog field. Results retain catalog order.
- Open a result to push its canonical book detail route; Back keeps the query.
- Clear returns to the initial prompt. Only submitted searches become recent
  searches, held in memory while the search page remains active.
- A loader error offers retry. Replaced/cleared queries and disposed pages ignore
  late success or failure from earlier requests. No artificial delay or new API
  is involved.

Run the complete project checks from `chat_book`:

```sh
flutter pub get
flutter analyze --no-fatal-warnings --no-fatal-infos
flutter test
```

The search regressions cover normalization and topic fields, canonical IDs,
loading/error/retry, request ordering and disposal, empty/clear/history behavior,
query route changes, detail-route push/Back and small-viewport large-text layout.
They use existing local catalog entries and synthetic test fixtures, without
live book or image requests. These are logic/widget checks, not native-device or
live-provider validation.
