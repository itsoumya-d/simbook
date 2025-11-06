import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/theme.dart';
import '../../../../shared/models/book.dart';
import '../../../../shared/widgets/book_list.dart';
import '../../../../shared/widgets/search_bar.dart';
import '../../../../shared/widgets/main_scaffold.dart';
import '../../../../config/app_router.dart';

/// Books page for displaying books in different categories
class BooksPage extends StatefulWidget {
  const BooksPage({
    super.key,
    required this.title,
    required this.category,
    this.subcategory,
  });

  final String title;
  final String category;
  final String? subcategory;

  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  BookListLayout _layout = BookListLayout.grid;
  List<Book> _books = [];
  List<SearchFilter> _filters = [];
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _initializeFilters();
    _loadBooks();
  }

  void _initializeFilters() {
    _filters = [
      const SearchFilter(id: 'all', label: 'All', isSelected: true),
      const SearchFilter(id: 'fiction', label: 'Fiction'),
      const SearchFilter(id: 'non-fiction', label: 'Non-Fiction'),
      const SearchFilter(id: 'business', label: 'Business'),
      const SearchFilter(id: 'self-help', label: 'Self-Help'),
      const SearchFilter(id: 'science', label: 'Science'),
    ];
  }

  Future<void> _loadBooks() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _books = _getMockBooks();
      _isLoading = false;
    });
  }

  Future<void> _loadMoreBooks() async {
    // Simulate loading more books
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _books.addAll(_getMockBooks());
      _hasMore = _books.length < 50; // Simulate pagination limit
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.title,
        actions: [
          // Layout Toggle
          IconButton(
            onPressed: _toggleLayout,
            icon: Icon(
              _layout == BookListLayout.grid 
                  ? Icons.view_list 
                  : Icons.grid_view,
              color: AppColors.darkTextPrimary,
              size: 24.sp,
            ),
          ),
          
          // Sort Button
          IconButton(
            onPressed: _showSortDialog,
            icon: Icon(
              Icons.sort,
              color: AppColors.darkTextPrimary,
              size: 24.sp,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          SearchFilterBar(
            filters: _filters,
            onFilterTap: _onFilterTap,
          ),
          
          SizedBox(height: 8.h),
          
          // Books List
          Expanded(
            child: BookList(
              books: _books,
              layout: _layout,
              isLoading: _isLoading,
              hasMore: _hasMore,
              onBookTap: (book) => AppRouter.goBookDetail(context, book.id),
              onBookmarkTap: _toggleBookmark,
              onAudioTap: _playAudio,
              onRefresh: _loadBooks,
              onLoadMore: _loadMoreBooks,
              showProgress: true,
              showBadges: true,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleLayout() {
    setState(() {
      _layout = _layout == BookListLayout.grid 
          ? BookListLayout.list 
          : BookListLayout.grid;
    });
  }

  void _onFilterTap(SearchFilter filter) {
    setState(() {
      _filters = _filters.map((f) => f.copyWith(
        isSelected: f.id == filter.id,
      )).toList();
    });
    
    // TODO: Filter books based on selected filter
    _loadBooks();
  }

  void _showSortDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) => _buildSortBottomSheet(),
    );
  }

  Widget _buildSortBottomSheet() {
    final sortOptions = [
      'Relevance',
      'Title A-Z',
      'Title Z-A',
      'Author A-Z',
      'Author Z-A',
      'Rating High to Low',
      'Rating Low to High',
      'Newest First',
      'Oldest First',
    ];

    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'Sort by',
                style: AppTypography.headlineSmall.copyWith(fontSize: 18.sp),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.close,
                  color: AppColors.darkTextSecondary,
                  size: 24.sp,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // Sort Options
          ...sortOptions.map((option) => ListTile(
            title: Text(
              option,
              style: AppTypography.bodyMedium.copyWith(fontSize: 16.sp),
            ),
            trailing: option == 'Relevance' 
                ? Icon(
                    Icons.check,
                    color: AppColors.primaryOrange,
                    size: 20.sp,
                  )
                : null,
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement sorting
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Sorted by $option')),
              );
            },
          )),
          
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  void _toggleBookmark(Book book) {
    // TODO: Implement bookmark functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          book.isBookmarked 
              ? 'Removed from library' 
              : 'Added to library',
        ),
      ),
    );
  }

  void _playAudio(Book book) {
    // TODO: Implement audio player
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Playing ${book.title}'),
      ),
    );
  }

  List<Book> _getMockBooks() {
    return [
      const Book(
        id: '1',
        title: 'The Subtle Art of Not Giving a F*ck',
        author: 'Mark Manson',
        subtitle: 'A Counterintuitive Approach to Living a Good Life',
        coverImageUrl: 'https://files.sobrief.com/social/cover_the-subtle-art-of-not-giving-a-fuck_360px_1747127884.jpg',
        rating: 3.87,
        ratingsCount: 1300000,
        duration: 15,
        isNew: true,
      ),
      const Book(
        id: '2',
        title: 'Sapiens',
        author: 'Yuval Noah Harari',
        subtitle: 'A Brief History of Humankind',
        coverImageUrl: 'https://files.sobrief.com/social/cover_sapiens_360px_1747127935.jpg',
        rating: 4.34,
        ratingsCount: 1200000,
        duration: 22,
        isTrending: true,
      ),
      const Book(
        id: '3',
        title: 'Atomic Habits',
        author: 'James Clear',
        subtitle: 'An Easy & Proven Way to Build Good Habits & Break Bad Ones',
        coverImageUrl: 'https://files.sobrief.com/social/cover_atomic-habits_360px_1747125904.jpg',
        rating: 4.33,
        ratingsCount: 1100000,
        duration: 18,
        isPro: true,
      ),
      const Book(
        id: '4',
        title: 'Thinking, Fast and Slow',
        author: 'Daniel Kahneman',
        coverImageUrl: 'https://files.sobrief.com/social/cover_thinking-fast-and-slow_360px_1747127983.jpg',
        rating: 4.17,
        ratingsCount: 554800,
        duration: 25,
      ),
      const Book(
        id: '5',
        title: 'The Power of Habit',
        author: 'Charles Duhigg',
        subtitle: 'Why We Do What We Do in Life and Business',
        coverImageUrl: 'https://files.sobrief.com/social/cover_the-power-of-habit_360px_1747128013.jpg',
        rating: 4.13,
        ratingsCount: 543400,
        duration: 20,
      ),
    ];
  }
}