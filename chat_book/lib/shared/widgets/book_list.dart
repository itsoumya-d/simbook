import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../core/theme/theme.dart';
import '../../core/constants/app_constants.dart';
import '../models/book.dart';
import 'book_card.dart';

/// A flexible book list widget that supports different layouts and interactions
class BookList extends StatefulWidget {
  const BookList({
    super.key,
    required this.books,
    this.onBookTap,
    this.onBookmarkTap,
    this.onAudioTap,
    this.onRefresh,
    this.onLoadMore,
    this.layout = BookListLayout.grid,
    this.showProgress = false,
    this.showBadges = true,
    this.isLoading = false,
    this.hasMore = true,
    this.emptyMessage = 'No books found',
    this.emptyIcon = Icons.book_outlined,
    this.crossAxisCount,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
  });

  final List<Book> books;
  final Function(Book)? onBookTap;
  final Function(Book)? onBookmarkTap;
  final Function(Book)? onAudioTap;
  final Future<void> Function()? onRefresh;
  final Future<void> Function()? onLoadMore;
  final BookListLayout layout;
  final bool showProgress;
  final bool showBadges;
  final bool isLoading;
  final bool hasMore;
  final String emptyMessage;
  final IconData emptyIcon;
  final int? crossAxisCount;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;

  @override
  State<BookList> createState() => _BookListState();
}

class _BookListState extends State<BookList> {
  late RefreshController _refreshController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(initialRefresh: false);
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.books.isEmpty && !widget.isLoading) {
      return _buildEmptyState();
    }

    return SmartRefresher(
      controller: _refreshController,
      enablePullDown: widget.onRefresh != null,
      enablePullUp: widget.onLoadMore != null && widget.hasMore,
      onRefresh: _onRefresh,
      onLoading: _onLoadMore,
      header: WaterDropMaterialHeader(
        backgroundColor: AppColors.primaryOrange,
        color: Colors.white,
      ),
      footer: CustomFooter(
        builder: (context, mode) {
          return _buildLoadingFooter(mode ?? LoadStatus.idle);
        },
      ),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    switch (widget.layout) {
      case BookListLayout.grid:
        return _buildGridView();
      case BookListLayout.list:
        return _buildListView();
      case BookListLayout.staggered:
        return _buildStaggeredGridView();
    }
  }

  Widget _buildGridView() {
    final crossAxisCount = widget.crossAxisCount ?? _getDefaultCrossAxisCount();
    
    return GridView.builder(
      controller: _scrollController,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      padding: widget.padding ?? EdgeInsets.all(8.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.65,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
      ),
      itemCount: widget.books.length + (widget.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= widget.books.length) {
          return _buildLoadingCard();
        }
        
        final book = widget.books[index];
        return BookCard(
          book: book,
          layout: BookCardLayout.grid,
          onTap: () => widget.onBookTap?.call(book),
          onBookmarkTap: () => widget.onBookmarkTap?.call(book),
          onAudioTap: () => widget.onAudioTap?.call(book),
          showProgress: widget.showProgress,
          showBadges: widget.showBadges,
        );
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      controller: _scrollController,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      padding: widget.padding ?? EdgeInsets.symmetric(vertical: 8.h),
      itemCount: widget.books.length + (widget.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= widget.books.length) {
          return _buildLoadingCard();
        }
        
        final book = widget.books[index];
        return BookCard(
          book: book,
          layout: BookCardLayout.list,
          onTap: () => widget.onBookTap?.call(book),
          onBookmarkTap: () => widget.onBookmarkTap?.call(book),
          onAudioTap: () => widget.onAudioTap?.call(book),
          showProgress: widget.showProgress,
          showBadges: widget.showBadges,
        );
      },
    );
  }

  Widget _buildStaggeredGridView() {
    final crossAxisCount = widget.crossAxisCount ?? _getDefaultCrossAxisCount();
    
    return MasonryGridView.builder(
      controller: _scrollController,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      padding: widget.padding ?? EdgeInsets.all(8.w),
      gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
      ),
      crossAxisSpacing: 8.w,
      mainAxisSpacing: 8.h,
      itemCount: widget.books.length + (widget.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= widget.books.length) {
          return _buildLoadingCard();
        }
        
        final book = widget.books[index];
        return BookCard(
          book: book,
          layout: BookCardLayout.grid,
          onTap: () => widget.onBookTap?.call(book),
          onBookmarkTap: () => widget.onBookmarkTap?.call(book),
          onAudioTap: () => widget.onAudioTap?.call(book),
          showProgress: widget.showProgress,
          showBadges: widget.showBadges,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.emptyIcon,
              size: 64.sp,
              color: AppColors.darkTextTertiary,
            ),
            SizedBox(height: 16.h),
            Text(
              widget.emptyMessage,
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.darkTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'Try adjusting your filters or search terms',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.darkTextTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      margin: EdgeInsets.all(8.w),
      child: Container(
        height: widget.layout == BookListLayout.list ? 120.h : 200.h,
        decoration: BoxDecoration(
          color: AppColors.darkSurfaceVariant,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryOrange,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingFooter(LoadStatus mode) {
    Widget body;
    
    switch (mode) {
      case LoadStatus.idle:
        body = Text(
          'Pull up to load more',
          style: AppTypography.caption,
        );
        break;
      case LoadStatus.loading:
        body = const CircularProgressIndicator(
          color: AppColors.primaryOrange,
        );
        break;
      case LoadStatus.failed:
        body = Text(
          'Load failed! Click retry!',
          style: AppTypography.caption.copyWith(
            color: AppColors.errorColor,
          ),
        );
        break;
      case LoadStatus.canLoading:
        body = Text(
          'Release to load more',
          style: AppTypography.caption,
        );
        break;
      case LoadStatus.noMore:
        body = Text(
          'No more books',
          style: AppTypography.caption.copyWith(
            color: AppColors.darkTextTertiary,
          ),
        );
        break;
    }
    
    return Container(
      height: 55.h,
      child: Center(child: body),
    );
  }

  int _getDefaultCrossAxisCount() {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth >= AppConstants.desktopBreakpoint) {
      return AppConstants.desktopGridColumns;
    } else if (screenWidth >= AppConstants.tabletBreakpoint) {
      return AppConstants.tabletGridColumns;
    } else {
      return AppConstants.mobileGridColumns;
    }
  }

  void _onRefresh() async {
    try {
      await widget.onRefresh?.call();
      _refreshController.refreshCompleted();
    } catch (e) {
      _refreshController.refreshFailed();
    }
  }

  void _onLoadMore() async {
    try {
      await widget.onLoadMore?.call();
      if (widget.hasMore) {
        _refreshController.loadComplete();
      } else {
        _refreshController.loadNoData();
      }
    } catch (e) {
      _refreshController.loadFailed();
    }
  }
}

/// Layout options for the book list
enum BookListLayout {
  /// Grid layout with fixed aspect ratio
  grid,
  
  /// List layout with horizontal cards
  list,
  
  /// Staggered grid layout with variable heights
  staggered,
}

/// Horizontal scrolling book list widget
class HorizontalBookList extends StatelessWidget {
  const HorizontalBookList({
    super.key,
    required this.books,
    this.onBookTap,
    this.onBookmarkTap,
    this.onAudioTap,
    this.showProgress = false,
    this.showBadges = true,
    this.height = 220,
    this.padding,
  });

  final List<Book> books;
  final Function(Book)? onBookTap;
  final Function(Book)? onBookmarkTap;
  final Function(Book)? onAudioTap;
  final bool showProgress;
  final bool showBadges;
  final double height;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) {
      return SizedBox(height: height.h);
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: height.h,
        minHeight: height.h,
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: padding ?? EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 140.w + 12.w, // Card width + margin
            ),
            child: GestureDetector(
              onTap: () => onBookTap?.call(book),
              child: BookCard(
                book: book,
                layout: BookCardLayout.horizontal,
                onTap: () => onBookTap?.call(book),
                onBookmarkTap: () => onBookmarkTap?.call(book),
                onAudioTap: () => onAudioTap?.call(book),
                showProgress: showProgress,
                showBadges: showBadges,
              ),
            ),
          );
        },
      ),
    );
  }
}