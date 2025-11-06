import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/theme.dart';
import '../../../../shared/models/book.dart';
import '../../../../shared/models/mock_books_data.dart';

/// Comprehensive book detail page with summaries and features
class BookDetailPage extends ConsumerStatefulWidget {
  const BookDetailPage({super.key, required this.bookId});

  final String bookId;

  @override
  ConsumerState<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends ConsumerState<BookDetailPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isBookmarked = false;
  bool _isPlaying = false;
  Book? _book;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBook();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadBook() {
    _book = MockBooksData.getBookById(widget.bookId);
    if (_book != null) {
      _isBookmarked = _book!.isBookmarked;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_book == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.darkBackground,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.darkTextPrimary),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64.sp,
                color: AppColors.darkTextSecondary,
              ),
              SizedBox(height: 16.h),
              Text(
                'Book not found',
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.darkTextPrimary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with book cover
          _buildSliverAppBar(),
          
          // Book info section
          SliverToBoxAdapter(
            child: _buildBookInfoSection(),
          ),
          
          // Action buttons
          SliverToBoxAdapter(
            child: _buildActionButtons(),
          ),
          
          // Tab bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              tabBar: _buildTabBar(),
            ),
          ),
          
          // Tab content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSummaryTab(),
                _buildKeyTakeawaysTab(),
                _buildDetailsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300.h,
      pinned: true,
      backgroundColor: AppColors.darkBackground,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.darkTextPrimary),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.share_outlined,
            color: AppColors.darkTextPrimary,
          ),
          onPressed: _shareBook,
        ),
        IconButton(
          icon: Icon(
            _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            color: _isBookmarked ? AppColors.primaryOrange : AppColors.darkTextPrimary,
          ),
          onPressed: _toggleBookmark,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.darkBackground,
                AppColors.darkBackground.withOpacity(0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 60.h), // Account for app bar
                
                // Book cover
                Container(
                  width: 120.w,
                  height: 160.h,
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.darkBorder,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.book,
                    size: 48.sp,
                    color: AppColors.primaryOrange,
                  ),
                ),
                
                SizedBox(height: 16.h),
                
                // Book title
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Text(
                    _book!.title,
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.darkTextPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                SizedBox(height: 4.h),
                
                // Author
                Text(
                  _book!.author,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.darkTextSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookInfoSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rating and stats
          Row(
            children: [
              if (_book!.rating != null) ...[
                Icon(
                  Icons.star,
                  color: AppColors.primaryOrange,
                  size: 20.sp,
                ),
                SizedBox(width: 4.w),
                Text(
                  _book!.formattedRating,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.darkTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  '(${_book!.formattedRatingsCount} ratings)',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.darkTextSecondary,
                  ),
                ),
              ],
              const Spacer(),
              if (_book!.duration != null) ...[
                Icon(
                  Icons.access_time,
                  color: AppColors.darkTextSecondary,
                  size: 16.sp,
                ),
                SizedBox(width: 4.w),
                Text(
                  _book!.formattedDuration,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.darkTextSecondary,
                  ),
                ),
              ],
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // Genres
          if (_book!.genres.isNotEmpty) ...[
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: _book!.genres.map((genre) => _buildGenreChip(genre)).toList(),
            ),
            SizedBox(height: 16.h),
          ],
          
          // Description
          if (_book!.description != null) ...[
            Text(
              _book!.description!,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.darkTextSecondary,
                height: 1.5,
              ),
            ),
            SizedBox(height: 16.h),
          ],
          
          // Premium badge
          if (_book!.isPro)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: AppColors.primaryOrange.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    color: AppColors.primaryOrange,
                    size: 16.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Premium Content',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primaryOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGenreChip(String genre) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.darkBorder,
          width: 1,
        ),
      ),
      child: Text(
        genre,
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.darkTextSecondary,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        children: [
          // Read button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _startReading(),
              icon: Icon(Icons.auto_stories, size: 20.sp),
              label: Text('Read Summary'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
          
          SizedBox(width: 12.w),
          
          // Audio button
          if (_book!.hasAudio)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _toggleAudio(),
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 20.sp,
                ),
                label: Text(_isPlaying ? 'Pause' : 'Listen'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryOrange,
                  side: BorderSide(color: AppColors.primaryOrange),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  TabBar _buildTabBar() {
    return TabBar(
      controller: _tabController,
      indicatorColor: AppColors.primaryOrange,
      labelColor: AppColors.primaryOrange,
      unselectedLabelColor: AppColors.darkTextSecondary,
      labelStyle: AppTypography.labelLarge.copyWith(
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: AppTypography.labelLarge,
      tabs: const [
        Tab(text: 'Summary'),
        Tab(text: 'Key Points'),
        Tab(text: 'Details'),
      ],
    );
  }

  Widget _buildSummaryTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_book!.summary != null) ...[
            Text(
              'Book Summary',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.darkTextPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              _book!.summary!,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.darkTextPrimary,
                height: 1.6,
              ),
            ),
          ] else ...[
            Center(
              child: Column(
                children: [
                  SizedBox(height: 60.h),
                  Icon(
                    Icons.auto_stories_outlined,
                    size: 64.sp,
                    color: AppColors.darkTextSecondary,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Summary Coming Soon',
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.darkTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildKeyTakeawaysTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Key Takeaways',
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.darkTextPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'The most important insights from this book',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.darkTextSecondary,
            ),
          ),
          SizedBox(height: 24.h),
          
          if (_book!.keyTakeaways.isNotEmpty) ...[
            ...List.generate(_book!.keyTakeaways.length, (index) {
              return _buildTakeawayItem(index + 1, _book!.keyTakeaways[index]);
            }),
          ] else ...[
            Center(
              child: Column(
                children: [
                  SizedBox(height: 60.h),
                  Icon(
                    Icons.lightbulb_outline,
                    size: 64.sp,
                    color: AppColors.darkTextSecondary,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Key Takeaways Coming Soon',
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.darkTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTakeawayItem(int number, String takeaway) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: AppColors.primaryOrange,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: AppTypography.labelLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              takeaway,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.darkTextPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Book Details',
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.darkTextPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24.h),
          
          // Book info
          _buildDetailRow('Author', _book!.author),
          if (_book!.subtitle != null)
            _buildDetailRow('Subtitle', _book!.subtitle!),
          if (_book!.publishedDate != null)
            _buildDetailRow('Published', _formatDate(_book!.publishedDate!)),
          if (_book!.pageCount != null)
            _buildDetailRow('Pages', _book!.pageCount.toString()),
          if (_book!.isbn != null)
            _buildDetailRow('ISBN', _book!.isbn!),
          if (_book!.language != 'en')
            _buildDetailRow('Language', _book!.language.toUpperCase()),
          if (_book!.readingTime != null)
            _buildDetailRow('Reading Time', '${_book!.readingTime} minutes'),
          
          SizedBox(height: 24.h),
          
          // Available formats
          Text(
            'Available Formats',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.darkTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16.h),
          
          Row(
            children: [
              _buildFormatChip('Text', Icons.article, true),
              SizedBox(width: 12.w),
              _buildFormatChip('Audio', Icons.headphones, _book!.hasAudio),
              SizedBox(width: 12.w),
              _buildFormatChip('PDF', Icons.picture_as_pdf, _book!.hasPdf),
            ],
          ),
          
          SizedBox(height: 24.h),
          
          // Recommended books
          Text(
            'You Might Also Like',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.darkTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16.h),
          
          ...MockBooksData.getRecommendedBooks(_book!.id, limit: 3)
              .map((book) => _buildRecommendedBookItem(book)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.darkTextSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.darkTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatChip(String label, IconData icon, bool available) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: available ? AppColors.primaryOrange.withOpacity(0.1) : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: available ? AppColors.primaryOrange.withOpacity(0.3) : AppColors.darkBorder,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16.sp,
            color: available ? AppColors.primaryOrange : AppColors.darkTextSecondary,
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: available ? AppColors.primaryOrange : AppColors.darkTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedBookItem(Book book) {
    return GestureDetector(
      onTap: () => context.go('/books/${book.id}'),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: AppColors.darkBorder,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 56.h,
              decoration: BoxDecoration(
                color: AppColors.darkBackground,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Icon(
                Icons.book,
                color: AppColors.primaryOrange,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.darkTextPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    book.author,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.darkTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: AppColors.darkTextSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isBookmarked ? 'Added to library' : 'Removed from library',
        ),
        backgroundColor: AppColors.darkSurface,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _shareBook() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing "${_book!.title}"'),
        backgroundColor: AppColors.darkSurface,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _startReading() {
    // Navigate to reading view or show summary
    _tabController.animateTo(0); // Go to summary tab
  }

  void _toggleAudio() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isPlaying ? 'Playing audio summary' : 'Audio paused',
        ),
        backgroundColor: AppColors.darkSurface,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate({required this.tabBar});

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.darkBackground,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}