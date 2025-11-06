import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/main_scaffold.dart';

/// Library page placeholder
class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Your Library',
        showBackButton: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_books,
              size: 64.sp,
              color: AppColors.primaryOrange,
            ),
            SizedBox(height: 16.h),
            Text(
              'Your Library',
              style: AppTypography.headlineMedium,
            ),
            SizedBox(height: 8.h),
            Text(
              'Your bookmarked books will appear here',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.darkTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            Text(
              'Coming Soon!',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.primaryOrange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}