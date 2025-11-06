import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/theme.dart';
import '../../config/app_router.dart';

/// Main scaffold with bottom navigation for the app
class MainScaffold extends StatefulWidget {
  const MainScaffold({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
      route: '/',
    ),
    NavigationItem(
      icon: Icons.search_outlined,
      selectedIcon: Icons.search,
      label: 'Search',
      route: '/search',
    ),
    NavigationItem(
      icon: Icons.trending_up_outlined,
      selectedIcon: Icons.trending_up,
      label: 'Trending',
      route: '/trending',
    ),
    NavigationItem(
      icon: Icons.library_books_outlined,
      selectedIcon: Icons.library_books,
      label: 'Library',
      route: '/library',
    ),
    NavigationItem(
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: 'Profile',
      route: '/settings',
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateCurrentIndex();
  }

  void _updateCurrentIndex() {
    final location = GoRouterState.of(context).uri.path;
    
    for (int i = 0; i < _navigationItems.length; i++) {
      final item = _navigationItems[i];
      if (location == item.route || 
          (item.route != '/' && location.startsWith(item.route))) {
        if (_currentIndex != i) {
          setState(() {
            _currentIndex = i;
          });
        }
        break;
      }
    }
  }

  void _onItemTapped(int index) {
    if (index != _currentIndex) {
      final route = _navigationItems[index].route;
      context.go(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        boxShadow: [
          BoxShadow(
            color: AppColors.elevationShadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 60.h,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _navigationItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == _currentIndex;
              
              return _buildNavigationItem(item, isSelected, index);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationItem(NavigationItem item, bool isSelected, int index) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with animation
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(isSelected ? 4.w : 0),
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppColors.primaryOrange.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                isSelected ? item.selectedIcon : item.icon,
                color: isSelected 
                    ? AppColors.primaryOrange 
                    : AppColors.darkTextSecondary,
                size: 24.sp,
              ),
            ),
            
            SizedBox(height: 2.h),
            
            // Label
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: AppTypography.labelSmall.copyWith(
                color: isSelected 
                    ? AppColors.primaryOrange 
                    : AppColors.darkTextSecondary,
                fontSize: 10.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}

/// Navigation item data class
class NavigationItem {
  const NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;
}

/// Custom app bar for consistent styling
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.backgroundColor,
    this.elevation = 0,
    this.centerTitle = true,
    this.showBackButton = true,
  });

  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final Color? backgroundColor;
  final double elevation;
  final bool centerTitle;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title != null 
          ? Text(
              title!,
              style: AppTypography.headlineMedium.copyWith(fontSize: 18.sp),
            )
          : null,
      actions: actions,
      leading: leading ?? (showBackButton && Navigator.canPop(context)
          ? IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: AppColors.darkTextPrimary,
                size: 20.sp,
              ),
              onPressed: () => Navigator.pop(context),
            )
          : null),
      backgroundColor: backgroundColor ?? AppColors.darkSurface,
      elevation: elevation,
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

/// Floating action button for quick actions
class QuickActionFAB extends StatelessWidget {
  const QuickActionFAB({
    super.key,
    this.onPressed,
    this.icon = Icons.add,
    this.tooltip = 'Quick Action',
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: AppColors.primaryOrange,
      foregroundColor: Colors.white,
      elevation: 4,
      child: Icon(
        icon,
        size: 24.sp,
      ),
    );
  }
}

/// Search app bar for search functionality
class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SearchAppBar({
    super.key,
    this.onChanged,
    this.onSubmitted,
    this.hintText = 'Search books...',
    this.autofocus = false,
    this.controller,
  });

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String hintText;
  final bool autofocus;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return AppBar(
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
      title: TextField(
        controller: controller,
        autofocus: autofocus,
        style: AppTypography.bodyMedium.copyWith(fontSize: 16.sp),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTypography.searchPlaceholder,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        textInputAction: TextInputAction.search,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.clear,
            color: AppColors.darkTextSecondary,
            size: 20.sp,
          ),
          onPressed: () {
            controller?.clear();
            onChanged?.call('');
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}