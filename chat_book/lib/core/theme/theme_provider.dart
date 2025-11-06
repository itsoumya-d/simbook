import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app_theme.dart';

/// Theme mode enumeration
enum AppThemeMode {
  light,
  dark,
  system,
}

/// Theme state class
class ThemeState {
  const ThemeState({
    required this.themeMode,
    required this.isDarkMode,
  });

  final AppThemeMode themeMode;
  final bool isDarkMode;

  ThemeState copyWith({
    AppThemeMode? themeMode,
    bool? isDarkMode,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

/// Theme notifier class
class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier() : super(const ThemeState(
    themeMode: AppThemeMode.dark, // Default to dark mode like reference
    isDarkMode: true,
  )) {
    _loadThemeFromStorage();
  }

  static const String _themeKey = 'app_theme_mode';
  Box? _settingsBox;

  /// Initialize Hive box for theme persistence
  Future<void> _initHive() async {
    if (_settingsBox == null) {
      _settingsBox = await Hive.openBox('settings');
    }
  }

  /// Load theme from storage
  Future<void> _loadThemeFromStorage() async {
    await _initHive();
    final savedTheme = _settingsBox?.get(_themeKey, defaultValue: 'dark') as String;
    
    final themeMode = AppThemeMode.values.firstWhere(
      (mode) => mode.name == savedTheme,
      orElse: () => AppThemeMode.dark,
    );
    
    _updateTheme(themeMode);
  }

  /// Save theme to storage
  Future<void> _saveThemeToStorage(AppThemeMode themeMode) async {
    await _initHive();
    await _settingsBox?.put(_themeKey, themeMode.name);
  }

  /// Update theme mode
  void _updateTheme(AppThemeMode themeMode) {
    bool isDarkMode;
    
    switch (themeMode) {
      case AppThemeMode.light:
        isDarkMode = false;
        break;
      case AppThemeMode.dark:
        isDarkMode = true;
        break;
      case AppThemeMode.system:
        // For now, default to dark mode
        // In a real app, you'd check system theme
        isDarkMode = true;
        break;
    }
    
    state = ThemeState(
      themeMode: themeMode,
      isDarkMode: isDarkMode,
    );
  }

  /// Set theme mode
  Future<void> setThemeMode(AppThemeMode themeMode) async {
    _updateTheme(themeMode);
    await _saveThemeToStorage(themeMode);
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    final newMode = state.isDarkMode ? AppThemeMode.light : AppThemeMode.dark;
    await setThemeMode(newMode);
  }

  /// Get current theme data
  ThemeData get currentTheme {
    return state.isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;
  }

  /// Get current theme mode for MaterialApp
  ThemeMode get materialThemeMode {
    switch (state.themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}

/// Theme provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

/// Current theme data provider
final currentThemeProvider = Provider<ThemeData>((ref) {
  final themeNotifier = ref.watch(themeProvider.notifier);
  return themeNotifier.currentTheme;
});

/// Current theme mode provider
final currentThemeModeProvider = Provider<ThemeMode>((ref) {
  final themeNotifier = ref.watch(themeProvider.notifier);
  return themeNotifier.materialThemeMode;
});