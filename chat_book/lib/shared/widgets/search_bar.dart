import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/theme.dart';
import '../../core/constants/app_constants.dart';

/// A comprehensive search bar widget with suggestions and filtering
class AppSearchBar extends StatefulWidget {
  const AppSearchBar({
    super.key,
    this.onChanged,
    this.onSubmitted,
    this.onFilterTap,
    this.onScanTap,
    this.suggestions = const [],
    this.recentSearches = const [],
    this.hintText = 'Find a book...',
    this.showFilter = true,
    this.showScan = true,
    this.autofocus = false,
    this.enabled = true,
    this.controller,
  });

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFilterTap;
  final VoidCallback? onScanTap;
  final List<String> suggestions;
  final List<String> recentSearches;
  final String hintText;
  final bool showFilter;
  final bool showScan;
  final bool autofocus;
  final bool enabled;
  final TextEditingController? controller;

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _showSuggestions = false;
  List<String> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();
    
    _focusNode.addListener(_onFocusChanged);
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {
      _showSuggestions = _focusNode.hasFocus && 
          (_controller.text.isNotEmpty || widget.recentSearches.isNotEmpty);
    });
  }

  void _onTextChanged() {
    final query = _controller.text.toLowerCase();
    
    setState(() {
      if (query.isEmpty) {
        _filteredSuggestions = [];
        _showSuggestions = _focusNode.hasFocus && widget.recentSearches.isNotEmpty;
      } else {
        _filteredSuggestions = widget.suggestions
            .where((suggestion) => suggestion.toLowerCase().contains(query))
            .take(5)
            .toList();
        _showSuggestions = _focusNode.hasFocus && 
            (_filteredSuggestions.isNotEmpty || widget.recentSearches.isNotEmpty);
      }
    });
    
    widget.onChanged?.call(_controller.text);
  }

  void _onSuggestionTap(String suggestion) {
    _controller.text = suggestion;
    _focusNode.unfocus();
    widget.onSubmitted?.call(suggestion);
  }

  void _onSubmit() {
    if (_controller.text.isNotEmpty) {
      _focusNode.unfocus();
      widget.onSubmitted?.call(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchField(),
        if (_showSuggestions) _buildSuggestions(),
      ],
    );
  }

  Widget _buildSearchField() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.darkInput,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: _focusNode.hasFocus 
              ? AppColors.primaryOrange 
              : AppColors.darkBorder,
          width: _focusNode.hasFocus ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Search Icon
          Padding(
            padding: EdgeInsets.only(left: 16.w, right: 8.w),
            child: Icon(
              Icons.search,
              color: AppColors.darkTextTertiary,
              size: 20.sp,
            ),
          ),
          
          // Text Field
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: widget.autofocus,
              enabled: widget.enabled,
              style: AppTypography.bodyMedium.copyWith(fontSize: 16.sp),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: AppTypography.searchPlaceholder,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _onSubmit(),
              maxLength: AppConstants.maxSearchQueryLength,
              buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
            ),
          ),
          
          // Clear Button
          if (_controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _controller.clear();
                _focusNode.requestFocus();
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Icon(
                  Icons.clear,
                  color: AppColors.darkTextTertiary,
                  size: 20.sp,
                ),
              ),
            ),
          
          // Scan Button
          if (widget.showScan && widget.onScanTap != null)
            GestureDetector(
              onTap: widget.onScanTap,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Icon(
                  Icons.qr_code_scanner,
                  color: AppColors.primaryOrange,
                  size: 20.sp,
                ),
              ),
            ),
          
          // Filter Button
          if (widget.showFilter && widget.onFilterTap != null)
            GestureDetector(
              onTap: widget.onFilterTap,
              child: Padding(
                padding: EdgeInsets.only(left: 8.w, right: 16.w),
                child: Icon(
                  Icons.tune,
                  color: AppColors.primaryOrange,
                  size: 20.sp,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.darkBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.elevationShadow,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Suggestions
          if (_filteredSuggestions.isNotEmpty) ...[
            _buildSectionHeader('Suggestions'),
            ..._filteredSuggestions.map((suggestion) => 
                _buildSuggestionItem(suggestion, Icons.search)),
          ],
          
          // Recent Searches
          if (widget.recentSearches.isNotEmpty && _controller.text.isEmpty) ...[
            if (_filteredSuggestions.isNotEmpty) _buildDivider(),
            _buildSectionHeader('Recent Searches'),
            ...widget.recentSearches.take(5).map((search) => 
                _buildSuggestionItem(search, Icons.history)),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
      child: Text(
        title,
        style: AppTypography.labelMedium.copyWith(
          color: AppColors.darkTextSecondary,
          fontSize: 12.sp,
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(String text, IconData icon) {
    return InkWell(
      onTap: () => _onSuggestionTap(text),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.darkTextTertiary,
              size: 16.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                text,
                style: AppTypography.bodyMedium.copyWith(fontSize: 14.sp),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.north_west,
              color: AppColors.darkTextTertiary,
              size: 14.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: AppColors.darkDivider,
      height: 1.h,
      thickness: 1,
    );
  }
}

/// Search filter chip widget
class SearchFilterChip extends StatelessWidget {
  const SearchFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    this.onTap,
    this.count,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primaryOrange.withOpacity(0.2)
              : AppColors.darkSurfaceVariant,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected 
                ? AppColors.primaryOrange 
                : AppColors.darkBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected 
                    ? AppColors.primaryOrange 
                    : AppColors.darkTextPrimary,
                fontSize: 12.sp,
              ),
            ),
            if (count != null) ...[
              SizedBox(width: 4.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppColors.primaryOrange 
                      : AppColors.darkTextTertiary,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  count.toString(),
                  style: AppTypography.caption.copyWith(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Horizontal scrolling filter chips
class SearchFilterBar extends StatelessWidget {
  const SearchFilterBar({
    super.key,
    required this.filters,
    this.onFilterTap,
    this.padding,
  });

  final List<SearchFilter> filters;
  final Function(SearchFilter)? onFilterTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: padding ?? EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          return SearchFilterChip(
            label: filter.label,
            isSelected: filter.isSelected,
            count: filter.count,
            onTap: () => onFilterTap?.call(filter),
          );
        },
      ),
    );
  }
}

/// Search filter data model
class SearchFilter {
  const SearchFilter({
    required this.id,
    required this.label,
    this.isSelected = false,
    this.count,
  });

  final String id;
  final String label;
  final bool isSelected;
  final int? count;

  SearchFilter copyWith({
    String? id,
    String? label,
    bool? isSelected,
    int? count,
  }) {
    return SearchFilter(
      id: id ?? this.id,
      label: label ?? this.label,
      isSelected: isSelected ?? this.isSelected,
      count: count ?? this.count,
    );
  }
}