import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/search_bar.dart';

/// Search page with real-time search functionality
class SearchPage extends StatefulWidget {
  const SearchPage({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.darkTextPrimary,
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Search',
          style: AppTypography.headlineMedium.copyWith(fontSize: 18.sp),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          AppSearchBar(
            controller: _controller,
            autofocus: true,
            hintText: 'Search books, authors, topics...',
            suggestions: const [
              'Atomic Habits',
              'Sapiens',
              'The Subtle Art',
              'Thinking Fast and Slow',
              'Psychology',
              'Business',
            ],
            recentSearches: const [
              'productivity',
              'self help',
              'Mark Manson',
            ],
            onChanged: (query) {
              // TODO: Implement real-time search
            },
            onSubmitted: (query) {
              // TODO: Implement search
            },
          ),
          
          // Search Results
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search,
                    size: 64.sp,
                    color: AppColors.primaryOrange,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Search Books',
                    style: AppTypography.headlineMedium,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Search through 73,530+ book summaries',
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
          ),
        ],
      ),
    );
  }
}