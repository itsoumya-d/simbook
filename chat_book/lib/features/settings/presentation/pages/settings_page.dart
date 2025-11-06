import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/main_scaffold.dart';

/// Settings page placeholder
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Settings',
        showBackButton: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.settings,
              size: 64.sp,
              color: AppColors.primaryOrange,
            ),
            SizedBox(height: 16.h),
            Text(
              'Settings',
              style: AppTypography.headlineMedium,
            ),
            SizedBox(height: 8.h),
            Text(
              'App settings and preferences',
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