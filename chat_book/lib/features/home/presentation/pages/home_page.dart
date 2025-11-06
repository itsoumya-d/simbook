import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/book.dart';
import '../../../../shared/models/mock_books_data.dart';
import '../../../../shared/widgets/book_list.dart';
import '../../../../shared/widgets/search_bar.dart';
import '../../../../config/app_router.dart';
import '../../../search/providers/search_provider.dart';

/// Home page with book recommendations and featured content
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ScrollController _scrollController = ScrollController();
  bool _showSearchBar = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final showSearchBar = _scrollController.offset < 100;
    if (showSearchBar != _showSearchBar) {
      setState(() {
        _showSearchBar = showSearchBar;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header with search
          _buildHeader(),
          
          // Main content
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              color: AppColors.primaryOrange,
              backgroundColor: AppColors.darkSurface,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // Welcome section
                  SliverToBoxAdapter(
                    child: _buildWelcomeSection(),
                  ),
                  
                  // Featured books carousel
                  SliverToBoxAdapter(
                    child: _buildFeaturedSection(),
                  ),
                  
                  // Trending books
                  SliverToBoxAdapter(
                    child: _buildTrendingSection(),
                  ),
                  
                  // Categories grid
                  SliverToBoxAdapter(
                    child: _buildCategoriesSection(),
                  ),
                  
                  // New releases
                  SliverToBoxAdapter(
                    child: _buildNewReleasesSection(),
                  ),
                  
                  // Bottom padding
                  SliverToBoxAdapter(
                    child: SizedBox(height: 100.h),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 50.h, 20.w, 16.h),
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App title and profile
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SoBrief',
                    style: AppTypography.headlineLarge.copyWith(
                      color: AppColors.primaryOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Read any book in 10 minutes',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.darkTextSecondary,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => context.go('/settings'),
                child: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: AppColors.primaryOrange.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.person_outline,
                    color: AppColors.primaryOrange,
                    size: 20.sp,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // Search bar
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _showSearchBar ? 48.h : 0,
            child: _showSearchBar
                ? GestureDetector(
                    onTap: () => context.go('/search'),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: AppColors.darkSurface,
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(
                          color: AppColors.darkBorder,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: AppColors.darkTextSecondary,
                            size: 20.sp,
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            'Search 73,530+ book summaries...',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.darkTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryOrange.withOpacity(0.1),
            AppColors.primaryOrange.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.primaryOrange.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: AppColors.primaryOrange,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Discover Your Next Read',
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.darkTextPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Explore our AI-powered recommendations and discover books tailored to your interests.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.darkTextSecondary,
            ),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () => context.go('/search'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.r),
              ),
            ),
            child: Text(
              'Start Exploring',
              style: AppTypography.labelLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedSection() {
    final featuredBooks = MockBooksData.getFeaturedBooks();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Featured Books',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.darkTextPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => context.go('/trending'),
                child: Text(
                  'See All',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.primaryOrange,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 280.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: featuredBooks.length,
            itemBuilder: (context, index) {
              final book = featuredBooks[index];
              return _buildFeaturedBookCard(book);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedBookCard(Book book) {
    return GestureDetector(
      onTap: () => context.go('/books/${book.id}'),
      child: Container(
        width: 200.w,
        margin: EdgeInsets.only(right: 16.w),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.darkBorder,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book cover
            Container(
              height: 160.h,
              decoration: BoxDecoration(
                color: AppColors.darkBackground,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              ),
              child: Center(
                child: Icon(
                  Icons.book,
                  size: 48.sp,
                  color: AppColors.primaryOrange,
                ),
              ),
            ),
            
            // Book info
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.darkTextPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      book.author,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.darkTextSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        if (book.rating != null) ...[
                          Icon(
                            Icons.star,
                            size: 14.sp,
                            color: AppColors.primaryOrange,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            book.formattedRating,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.darkTextSecondary,
                            ),
                          ),
                        ],
                        const Spacer(),
                        if (book.duration != null)
                          Text(
                            book.formattedDuration,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.primaryOrange,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingSection() {
    final trendingBooks = MockBooksData.getTrendingBooks();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 16.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    color: AppColors.primaryOrange,
                    size: 24.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Trending Now',
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.darkTextPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => context.go('/trending'),
                child: Text(
                  'View All',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.primaryOrange,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...trendingBooks.take(3).map((book) => _buildBookListItem(book)),
      ],
    );
  }

  Widget _buildBookListItem(Book book) {
    return GestureDetector(
      onTap: () => context.go('/books/${book.id}'),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.darkBorder,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Book cover placeholder
            Container(
              width: 60.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: AppColors.darkBackground,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.book,
                color: AppColors.primaryOrange,
                size: 24.sp,
              ),
            ),
            
            SizedBox(width: 16.w),
            
            // Book info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.darkTextPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    book.author,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.darkTextSecondary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      if (book.rating != null) ...[
                        Icon(
                          Icons.star,
                          size: 16.sp,
                          color: AppColors.primaryOrange,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          book.formattedRating,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.darkTextSecondary,
                          ),
                        ),
                        SizedBox(width: 16.w),
                      ],
                      if (book.duration != null) ...[
                        Icon(
                          Icons.access_time,
                          size: 16.sp,
                          color: AppColors.darkTextSecondary,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          book.formattedDuration,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.darkTextSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            
            // Action button
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.darkTextSecondary,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    final categories = MockBooksData.getPopularCategories();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 16.h),
          child: Text(
            'Browse Categories',
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.darkTextPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 120.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _buildCategoryCard(category);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(String category) {
    final icons = {
      'Self-Help': Icons.psychology,
      'Business': Icons.business,
      'History': Icons.history_edu,
      'Psychology': Icons.psychology_alt,
      'Fiction': Icons.auto_stories,
      'Biography': Icons.person,
    };
    
    return GestureDetector(
      onTap: () => context.go('/books?category=$category'),
      child: Container(
        width: 100.w,
        margin: EdgeInsets.only(right: 16.w),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.darkBorder,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icons[category] ?? Icons.category,
              color: AppColors.primaryOrange,
              size: 32.sp,
            ),
            SizedBox(height: 8.h),
            Text(
              category,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.darkTextPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewReleasesSection() {
    final newBooks = MockBooksData.getNewBooks();
    
    if (newBooks.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 16.h),
          child: Row(
            children: [
              Icon(
                Icons.fiber_new,
                color: AppColors.primaryOrange,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'New Releases',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.darkTextPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        ...newBooks.map((book) => _buildBookListItem(book)),
      ],
    );
  }

  Future<void> _onRefresh() async {
    // Simulate refresh delay
    await Future.delayed(const Duration(seconds: 1));
    
    // In a real app, this would refresh data from the API
    if (mounted) {
      setState(() {});
    }
  }
}

/// Category item data class
class CategoryItem {
  const CategoryItem(this.name, this.icon, this.id);
  
  final String name;
  final IconData icon;
  final String id;
}