import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/theme.dart';
import '../../core/constants/app_constants.dart';
import '../models/book.dart';

/// A responsive book card widget that displays book information
/// Supports both grid and list layouts with interactive elements
class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.book,
    this.onTap,
    this.onBookmarkTap,
    this.onAudioTap,
    this.layout = BookCardLayout.grid,
    this.showProgress = false,
    this.showBadges = true,
  });

  final Book book;
  final VoidCallback? onTap;
  final VoidCallback? onBookmarkTap;
  final VoidCallback? onAudioTap;
  final BookCardLayout layout;
  final bool showProgress;
  final bool showBadges;

  @override
  Widget build(BuildContext context) {
    switch (layout) {
      case BookCardLayout.grid:
        return _buildGridCard(context);
      case BookCardLayout.list:
        return _buildListCard(context);
      case BookCardLayout.horizontal:
        return _buildHorizontalCard(context);
    }
  }

  Widget _buildGridCard(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.w),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Image with Badges
              Expanded(
                flex: 3,
                child: _buildCoverImage(context),
              ),
              
              SizedBox(height: 8.h),
              
              // Book Information
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      book.title,
                      style: AppTypography.bookTitle.copyWith(fontSize: 14.sp),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    SizedBox(height: 4.h),
                    
                    // Author
                    Text(
                      book.author,
                      style: AppTypography.bookAuthor.copyWith(fontSize: 12.sp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const Spacer(),
                    
                    // Rating and Actions
                    Row(
                      children: [
                        if (book.rating != null) ...[
                          _buildRating(context),
                          const Spacer(),
                        ],
                        _buildActionButtons(context),
                      ],
                    ),
                    
                    // Progress Bar
                    if (showProgress && book.isStarted) ...[
                      SizedBox(height: 4.h),
                      _buildProgressBar(context),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListCard(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              // Cover Image
              SizedBox(
                width: 60.w,
                height: 90.h,
                child: _buildCoverImage(context),
              ),
              
              SizedBox(width: 12.w),
              
              // Book Information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      book.title,
                      style: AppTypography.bookTitle.copyWith(fontSize: 16.sp),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    SizedBox(height: 4.h),
                    
                    // Author
                    Text(
                      book.author,
                      style: AppTypography.bookAuthor.copyWith(fontSize: 14.sp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    if (book.subtitle != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        book.subtitle!,
                        style: AppTypography.bookSubtitle.copyWith(fontSize: 12.sp),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    
                    SizedBox(height: 8.h),
                    
                    // Rating and Duration
                    Row(
                      children: [
                        if (book.rating != null) _buildRating(context),
                        if (book.rating != null && book.duration != null) 
                          SizedBox(width: 12.w),
                        if (book.duration != null) _buildDuration(context),
                        const Spacer(),
                        _buildActionButtons(context),
                      ],
                    ),
                    
                    // Progress Bar
                    if (showProgress && book.isStarted) ...[
                      SizedBox(height: 8.h),
                      _buildProgressBar(context),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalCard(BuildContext context) {
    return Container(
      width: 140.w,
      margin: EdgeInsets.only(right: 12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cover Image
          Expanded(
            flex: 3,
            child: _buildCoverImage(context),
          ),
          
          SizedBox(height: 8.h),
          
          // Book Info Container with fixed height
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Flexible(
                  child: Text(
                    book.title,
                    style: AppTypography.bookTitle.copyWith(fontSize: 13.sp),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                SizedBox(height: 2.h),
                
                // Author
                Text(
                  book.author,
                  style: AppTypography.bookAuthor.copyWith(fontSize: 11.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                // Rating (only if space allows)
                if (book.rating != null) ...[
                  SizedBox(height: 2.h),
                  _buildCompactRating(context),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverImage(BuildContext context) {
    return Stack(
      children: [
        // Cover Image
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: CachedNetworkImage(
            imageUrl: book.coverImageUrl,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => _buildImagePlaceholder(),
            errorWidget: (context, url, error) => _buildImageError(),
          ),
        ),
        
        // Badges
        if (showBadges) _buildBadges(context),
        
        // Bookmark Button (Grid layout only)
        if (layout == BookCardLayout.grid && onBookmarkTap != null)
          Positioned(
            top: 4.w,
            right: 4.w,
            child: _buildBookmarkButton(context),
          ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Shimmer.fromColors(
      baseColor: AppColors.darkSurfaceVariant,
      highlightColor: AppColors.darkSurface,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.coverPlaceholder,
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }

  Widget _buildImageError() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.coverPlaceholder,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(
        Icons.book,
        color: AppColors.darkTextTertiary,
        size: 32.sp,
      ),
    );
  }

  Widget _buildBadges(BuildContext context) {
    return Positioned(
      top: 4.w,
      left: 4.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (book.isNew) _buildBadge('NEW', AppColors.primaryOrange),
          if (book.isTrending) ...[
            if (book.isNew) SizedBox(height: 4.h),
            _buildBadge('TRENDING', AppColors.successColor),
          ],
          if (book.isPro) ...[
            if (book.isNew || book.isTrending) SizedBox(height: 4.h),
            _buildBadge('PRO', AppColors.warningColor),
          ],
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        style: AppTypography.overline.copyWith(
          color: Colors.white,
          fontSize: 8.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBookmarkButton(BuildContext context) {
    return GestureDetector(
      onTap: onBookmarkTap,
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppColors.darkBackground.withOpacity(0.8),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Icon(
          book.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
          color: book.isBookmarked ? AppColors.primaryOrange : AppColors.darkTextSecondary,
          size: 16.sp,
        ),
      ),
    );
  }

  Widget _buildRating(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star,
          color: AppColors.starFilled,
          size: 14.sp,
        ),
        SizedBox(width: 2.w),
        Text(
          book.formattedRating,
          style: AppTypography.rating.copyWith(fontSize: 12.sp),
        ),
        if (book.ratingsCount != null) ...[
          SizedBox(width: 4.w),
          Text(
            '(${book.formattedRatingsCount})',
            style: AppTypography.ratingCount.copyWith(fontSize: 10.sp),
          ),
        ],
      ],
    );
  }

  Widget _buildCompactRating(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star,
          color: AppColors.starFilled,
          size: 12.sp,
        ),
        SizedBox(width: 2.w),
        Text(
          book.formattedRating,
          style: AppTypography.rating.copyWith(fontSize: 10.sp),
        ),
      ],
    );
  }

  Widget _buildDuration(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.access_time,
          color: AppColors.darkTextTertiary,
          size: 12.sp,
        ),
        SizedBox(width: 2.w),
        Text(
          book.formattedDuration,
          style: AppTypography.caption.copyWith(fontSize: 10.sp),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (book.hasAudio && onAudioTap != null) ...[
          GestureDetector(
            onTap: onAudioTap,
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Icon(
                Icons.play_arrow,
                color: AppColors.primaryOrange,
                size: 16.sp,
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
        if (layout != BookCardLayout.grid && onBookmarkTap != null)
          GestureDetector(
            onTap: onBookmarkTap,
            child: Icon(
              book.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: book.isBookmarked ? AppColors.primaryOrange : AppColors.darkTextSecondary,
              size: 20.sp,
            ),
          ),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: AppTypography.caption.copyWith(fontSize: 10.sp),
            ),
            Text(
              '${(book.readingProgress * 100).toInt()}%',
              style: AppTypography.caption.copyWith(fontSize: 10.sp),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        LinearProgressIndicator(
          value: book.readingProgress,
          backgroundColor: AppColors.progressBackground,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryOrange),
          minHeight: 2.h,
        ),
      ],
    );
  }
}

/// Layout options for the book card
enum BookCardLayout {
  /// Grid layout for grid views
  grid,
  
  /// List layout for list views
  list,
  
  /// Horizontal layout for horizontal scrolling
  horizontal,
}