import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/home/presentation/pages/home_page.dart';
import '../features/books/presentation/pages/book_detail_page.dart';
import '../features/books/presentation/pages/books_page.dart';
import '../features/library/presentation/pages/library_page.dart';
import '../features/search/presentation/pages/search_page.dart';
import '../features/auth/presentation/pages/auth_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../shared/widgets/main_scaffold.dart';

/// App router configuration using GoRouter
/// Matches the original web application's routing structure
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // Shell route for main navigation
      ShellRoute(
        builder: (context, state, child) {
          return MainScaffold(child: child);
        },
        routes: [
          // Home route
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomePage(),
          ),
          
          // Library route
          GoRoute(
            path: '/library',
            name: 'library',
            builder: (context, state) => const LibraryPage(),
          ),
          
          // Lists route
          GoRoute(
            path: '/lists',
            name: 'lists',
            builder: (context, state) => const BooksPage(
              title: 'Lists',
              category: 'lists',
            ),
            routes: [
              // Specific list route
              GoRoute(
                path: '/:listId',
                name: 'list-detail',
                builder: (context, state) {
                  final listId = state.pathParameters['listId']!;
                  return BooksPage(
                    title: _getListTitle(listId),
                    category: 'lists',
                    subcategory: listId,
                  );
                },
              ),
            ],
          ),
          
          // Trending route
          GoRoute(
            path: '/trending',
            name: 'trending',
            builder: (context, state) => const BooksPage(
              title: 'Trending',
              category: 'trending',
            ),
          ),
          
          // New books route
          GoRoute(
            path: '/new',
            name: 'new',
            builder: (context, state) => const BooksPage(
              title: 'New Books',
              category: 'new',
            ),
          ),
          
          // Search route
          GoRoute(
            path: '/search',
            name: 'search',
            builder: (context, state) {
              final query = state.uri.queryParameters['q'] ?? '';
              return SearchPage(initialQuery: query);
            },
          ),
          
          // Books routes
          GoRoute(
            path: '/books',
            name: 'books',
            builder: (context, state) => const BooksPage(
              title: 'All Books',
              category: 'all',
            ),
            routes: [
              // Individual book route
              GoRoute(
                path: '/:bookId',
                name: 'book-detail',
                builder: (context, state) {
                  final bookId = state.pathParameters['bookId']!;
                  return BookDetailPage(bookId: bookId);
                },
              ),
            ],
          ),
          
          // Authors routes
          GoRoute(
            path: '/authors',
            name: 'authors',
            builder: (context, state) => const BooksPage(
              title: 'Authors',
              category: 'authors',
            ),
            routes: [
              // Individual author route
              GoRoute(
                path: '/:authorId',
                name: 'author-detail',
                builder: (context, state) {
                  final authorId = state.pathParameters['authorId']!;
                  return BooksPage(
                    title: _getAuthorTitle(authorId),
                    category: 'authors',
                    subcategory: authorId,
                  );
                },
              ),
            ],
          ),
          
          // Genres routes
          GoRoute(
            path: '/genres',
            name: 'genres',
            builder: (context, state) => const BooksPage(
              title: 'Genres',
              category: 'genres',
            ),
            routes: [
              // Individual genre route
              GoRoute(
                path: '/:genreId',
                name: 'genre-detail',
                builder: (context, state) {
                  final genreId = state.pathParameters['genreId']!;
                  return BooksPage(
                    title: _getGenreTitle(genreId),
                    category: 'genres',
                    subcategory: genreId,
                  );
                },
              ),
            ],
          ),
          
          // Settings route
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
      
      // Auth routes (outside main scaffold)
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthPage(),
      ),
      
      // Static pages
      GoRoute(
        path: '/privacy',
        name: 'privacy',
        builder: (context, state) => const StaticPage(
          title: 'Privacy Policy',
          content: 'Privacy policy content...',
        ),
      ),
      
      GoRoute(
        path: '/terms',
        name: 'terms',
        builder: (context, state) => const StaticPage(
          title: 'Terms of Service',
          content: 'Terms of service content...',
        ),
      ),
      
      GoRoute(
        path: '/affiliate',
        name: 'affiliate',
        builder: (context, state) => const StaticPage(
          title: 'Affiliate Program',
          content: 'Affiliate program content...',
        ),
      ),
      
      GoRoute(
        path: '/pricing',
        name: 'pricing',
        builder: (context, state) => const StaticPage(
          title: 'Pricing',
          content: 'Pricing information...',
        ),
      ),
    ],
    
    // Error page
    errorBuilder: (context, state) => ErrorPage(error: state.error),
    
    // Redirect logic
    redirect: (context, state) {
      // Add authentication checks here if needed
      return null;
    },
  );

  /// Navigate to home page
  static void goHome(BuildContext context) {
    context.go('/');
  }

  /// Navigate to library page
  static void goLibrary(BuildContext context) {
    context.go('/library');
  }

  /// Navigate to search page with optional query
  static void goSearch(BuildContext context, {String? query}) {
    if (query != null && query.isNotEmpty) {
      context.go('/search?q=${Uri.encodeComponent(query)}');
    } else {
      context.go('/search');
    }
  }

  /// Navigate to book detail page
  static void goBookDetail(BuildContext context, String bookId) {
    context.go('/books/$bookId');
  }

  /// Navigate to author page
  static void goAuthor(BuildContext context, String authorId) {
    context.go('/authors/$authorId');
  }

  /// Navigate to genre page
  static void goGenre(BuildContext context, String genreId) {
    context.go('/genres/$genreId');
  }

  /// Navigate to list page
  static void goList(BuildContext context, String listId) {
    context.go('/lists/$listId');
  }

  /// Navigate to trending page
  static void goTrending(BuildContext context) {
    context.go('/trending');
  }

  /// Navigate to new books page
  static void goNew(BuildContext context) {
    context.go('/new');
  }

  /// Navigate to settings page
  static void goSettings(BuildContext context) {
    context.go('/settings');
  }

  /// Navigate to auth page
  static void goAuth(BuildContext context) {
    context.go('/auth');
  }

  /// Pop current route
  static void pop(BuildContext context) {
    context.pop();
  }

  /// Check if can pop
  static bool canPop(BuildContext context) {
    return context.canPop();
  }
}

/// Helper functions to format titles
String _getListTitle(String listId) {
  return listId
      .split('-')
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');
}

String _getAuthorTitle(String authorId) {
  return authorId
      .split('-')
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');
}

String _getGenreTitle(String genreId) {
  return genreId
      .split('-')
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');
}

/// Error page widget
class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key, this.error});

  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Page not found',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error?.toString() ?? 'The requested page could not be found.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => AppRouter.goHome(context),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Static page widget for simple content pages
class StaticPage extends StatelessWidget {
  const StaticPage({
    super.key,
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(
          content,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}