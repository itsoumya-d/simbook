/// Application constants and configuration values
class AppConstants {
  AppConstants._();

  // App Information
  static const String appName = 'ChatBook';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Read any book in 10 minutes';

  // API Configuration
  static const String baseUrl = 'https://api.sobrief.com';
  static const String filesBaseUrl = 'https://files.sobrief.com';
  static const String socialBaseUrl = 'https://files.sobrief.com/social';
  
  // API Endpoints
  static const String booksEndpoint = '/books';
  static const String authorsEndpoint = '/authors';
  static const String genresEndpoint = '/genres';
  static const String searchEndpoint = '/search';
  static const String userEndpoint = '/user';
  static const String libraryEndpoint = '/library';
  static const String audioEndpoint = '/audio';

  // Image Dimensions
  static const int coverImageWidth = 360;
  static const int coverImageHeight = 540;
  static const int thumbnailWidth = 120;
  static const int thumbnailHeight = 180;

  // UI Dimensions
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;

  static const double defaultRadius = 8.0;
  static const double smallRadius = 4.0;
  static const double largeRadius = 12.0;
  static const double extraLargeRadius = 16.0;

  static const double defaultElevation = 2.0;
  static const double mediumElevation = 4.0;
  static const double highElevation = 8.0;

  // Book List Configuration
  static const int booksPerPage = 20;
  static const int maxSearchResults = 50;
  static const int recentBooksLimit = 10;
  static const int recommendedBooksLimit = 15;

  // Audio Configuration
  static const int audioQualityBitrate = 128; // kbps
  static const Duration audioSeekDuration = Duration(seconds: 15);
  static const Duration audioUpdateInterval = Duration(milliseconds: 100);

  // Cache Configuration
  static const Duration imageCacheDuration = Duration(days: 7);
  static const Duration dataCacheDuration = Duration(hours: 1);
  static const int maxCacheSize = 100; // MB

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Breakpoints for Responsive Design
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // Grid Configuration
  static const int mobileGridColumns = 2;
  static const int tabletGridColumns = 3;
  static const int desktopGridColumns = 4;

  // Rating Configuration
  static const int maxRating = 5;
  static const double minRatingToShow = 3.0;

  // Text Limits
  static const int maxBookTitleLength = 100;
  static const int maxAuthorNameLength = 50;
  static const int maxSearchQueryLength = 100;
  static const int maxReviewLength = 500;

  // Storage Keys
  static const String themeKey = 'theme_mode';
  static const String userKey = 'user_data';
  static const String libraryKey = 'user_library';
  static const String settingsKey = 'app_settings';
  static const String audioSettingsKey = 'audio_settings';
  static const String searchHistoryKey = 'search_history';

  // Default Values
  static const String defaultCoverImage = 'assets/images/no-cover.jpg';
  static const String defaultAuthorImage = 'assets/images/default-author.jpg';
  static const String placeholderText = 'Loading...';

  // External URLs
  static const String privacyPolicyUrl = 'https://sobrief.com/privacy';
  static const String termsOfServiceUrl = 'https://sobrief.com/terms';
  static const String supportUrl = 'https://sobrief.com/support';
  static const String affiliateUrl = 'https://sobrief.com/affiliate';

  // Social Media
  static const String twitterUrl = 'https://twitter.com/sobrief';
  static const String facebookUrl = 'https://facebook.com/sobrief';
  static const String instagramUrl = 'https://instagram.com/sobrief';

  // App Store URLs
  static const String iosAppStoreUrl = 'https://apps.apple.com/app/sobrief';
  static const String androidPlayStoreUrl = 'https://play.google.com/store/apps/details?id=com.sobrief.app';

  // Feature Flags
  static const bool enableAudioFeature = true;
  static const bool enableOfflineMode = true;
  static const bool enablePushNotifications = true;
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;

  // Error Messages
  static const String networkErrorMessage = 'Please check your internet connection and try again.';
  static const String serverErrorMessage = 'Something went wrong. Please try again later.';
  static const String notFoundErrorMessage = 'The requested content was not found.';
  static const String unauthorizedErrorMessage = 'Please sign in to continue.';
  static const String genericErrorMessage = 'An unexpected error occurred.';

  // Success Messages
  static const String bookAddedToLibraryMessage = 'Book added to your library!';
  static const String bookRemovedFromLibraryMessage = 'Book removed from your library.';
  static const String settingsSavedMessage = 'Settings saved successfully!';

  // Audio Player Messages
  static const String audioLoadingMessage = 'Loading audio...';
  static const String audioErrorMessage = 'Unable to play audio. Please try again.';
  static const String audioCompletedMessage = 'Audio completed!';

  // Validation Rules
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const String emailRegexPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  // Subscription Plans
  static const String freePlanName = 'Free';
  static const String proPlanName = 'Pro';
  static const String lifetimePlanName = 'Lifetime';

  // Pro Features
  static const List<String> proFeatures = [
    'Unlimited audio summaries',
    'Download PDF/EPUB',
    'Bookmark unlimited books',
    'Personalized recommendations',
    'Ad-free experience',
    'Priority support',
  ];
}