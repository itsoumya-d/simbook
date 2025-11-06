/// Book model representing a book summary in the application
class Book {
  const Book({
    required this.id,
    required this.title,
    required this.author,
    this.subtitle,
    this.description,
    required this.coverImageUrl,
    this.thumbnailUrl,
    this.rating,
    this.ratingsCount,
    this.audioUrl,
    this.pdfUrl,
    this.epubUrl,
    this.duration,
    this.publishedDate,
    this.genres = const [],
    this.tags = const [],
    this.isBookmarked = false,
    this.readingProgress = 0.0,
    this.isNew = false,
    this.isTrending = false,
    this.isPro = false,
    // Enhanced fields for SoBrief functionality
    this.summary,
    this.keyTakeaways = const [],
    this.isbn,
    this.pageCount,
    this.language = 'en',
    this.availableLanguages = const ['en'],
    this.audioLanguages = const [],
    this.readingTime,
    this.difficulty,
    this.category,
    this.subcategory,
    this.authorBio,
    this.authorImageUrl,
    this.bookUrl,
    this.amazonUrl,
    this.goodreadsUrl,
    this.isRequested = false,
    this.requestCount = 0,
    this.lastUpdated,
    this.viewCount = 0,
    this.downloadCount = 0,
    this.shareCount = 0,
  });

  /// Unique identifier for the book
  final String id;

  /// Book title
  final String title;

  /// Author name
  final String author;

  /// Book subtitle (optional)
  final String? subtitle;

  /// Book description/summary
  final String? description;

  /// URL for the book cover image
  final String coverImageUrl;

  /// URL for thumbnail image (smaller version)
  final String? thumbnailUrl;

  /// Average rating (0.0 to 5.0)
  final double? rating;

  /// Number of ratings
  final int? ratingsCount;

  /// URL for audio summary
  final String? audioUrl;

  /// URL for PDF download
  final String? pdfUrl;

  /// URL for EPUB download
  final String? epubUrl;

  /// Audio duration in minutes
  final int? duration;

  /// Publication date
  final DateTime? publishedDate;

  /// List of genres
  final List<String> genres;

  /// List of tags
  final List<String> tags;

  /// Whether the book is bookmarked by the user
  final bool isBookmarked;

  /// Reading progress (0.0 to 1.0)
  final double readingProgress;

  /// Whether the book is newly added
  final bool isNew;

  /// Whether the book is trending
  final bool isTrending;

  /// Whether the book requires Pro subscription
  final bool isPro;

  // Enhanced fields for SoBrief functionality

  /// Full text summary content
  final String? summary;

  /// List of key takeaways (12 main points)
  final List<String> keyTakeaways;

  /// ISBN number
  final String? isbn;

  /// Number of pages in original book
  final int? pageCount;

  /// Primary language of the summary
  final String language;

  /// List of available languages for this summary
  final List<String> availableLanguages;

  /// List of languages with audio narration
  final List<String> audioLanguages;

  /// Estimated reading time in minutes
  final int? readingTime;

  /// Difficulty level (beginner, intermediate, advanced)
  final String? difficulty;

  /// Main category
  final String? category;

  /// Subcategory
  final String? subcategory;

  /// Author biography
  final String? authorBio;

  /// Author profile image URL
  final String? authorImageUrl;

  /// Original book purchase URL
  final String? bookUrl;

  /// Amazon purchase URL
  final String? amazonUrl;

  /// Goodreads URL
  final String? goodreadsUrl;

  /// Whether this book was requested by users
  final bool isRequested;

  /// Number of user requests for this book
  final int requestCount;

  /// Last update timestamp
  final DateTime? lastUpdated;

  /// Number of views
  final int viewCount;

  /// Number of downloads
  final int downloadCount;

  /// Number of shares
  final int shareCount;

  /// Create a copy of this book with updated fields
  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? subtitle,
    String? description,
    String? coverImageUrl,
    String? thumbnailUrl,
    double? rating,
    int? ratingsCount,
    String? audioUrl,
    String? pdfUrl,
    String? epubUrl,
    int? duration,
    DateTime? publishedDate,
    List<String>? genres,
    List<String>? tags,
    bool? isBookmarked,
    double? readingProgress,
    bool? isNew,
    bool? isTrending,
    bool? isPro,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      rating: rating ?? this.rating,
      ratingsCount: ratingsCount ?? this.ratingsCount,
      audioUrl: audioUrl ?? this.audioUrl,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      epubUrl: epubUrl ?? this.epubUrl,
      duration: duration ?? this.duration,
      publishedDate: publishedDate ?? this.publishedDate,
      genres: genres ?? this.genres,
      tags: tags ?? this.tags,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      readingProgress: readingProgress ?? this.readingProgress,
      isNew: isNew ?? this.isNew,
      isTrending: isTrending ?? this.isTrending,
      isPro: isPro ?? this.isPro,
    );
  }

  /// Create Book from JSON (simplified implementation)
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      subtitle: json['subtitle'] as String?,
      description: json['description'] as String?,
      coverImageUrl: json['coverImageUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      ratingsCount: json['ratingsCount'] as int?,
      audioUrl: json['audioUrl'] as String?,
      pdfUrl: json['pdfUrl'] as String?,
      epubUrl: json['epubUrl'] as String?,
      duration: json['duration'] as int?,
      publishedDate: json['publishedDate'] != null 
          ? DateTime.parse(json['publishedDate'] as String)
          : null,
      genres: (json['genres'] as List<dynamic>?)?.cast<String>() ?? [],
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      isBookmarked: json['isBookmarked'] as bool? ?? false,
      readingProgress: (json['readingProgress'] as num?)?.toDouble() ?? 0.0,
      isNew: json['isNew'] as bool? ?? false,
      isTrending: json['isTrending'] as bool? ?? false,
      isPro: json['isPro'] as bool? ?? false,
    );
  }

  /// Convert Book to JSON (simplified implementation)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'subtitle': subtitle,
      'description': description,
      'coverImageUrl': coverImageUrl,
      'thumbnailUrl': thumbnailUrl,
      'rating': rating,
      'ratingsCount': ratingsCount,
      'audioUrl': audioUrl,
      'pdfUrl': pdfUrl,
      'epubUrl': epubUrl,
      'duration': duration,
      'publishedDate': publishedDate?.toIso8601String(),
      'genres': genres,
      'tags': tags,
      'isBookmarked': isBookmarked,
      'readingProgress': readingProgress,
      'isNew': isNew,
      'isTrending': isTrending,
      'isPro': isPro,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Book && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Book(id: $id, title: $title, author: $author)';

  /// Get formatted rating string
  String get formattedRating {
    if (rating == null) return '';
    return rating!.toStringAsFixed(2);
  }

  /// Get formatted ratings count string
  String get formattedRatingsCount {
    if (ratingsCount == null) return '';
    
    final count = ratingsCount!;
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  /// Get formatted duration string
  String get formattedDuration {
    if (duration == null) return '';
    
    final minutes = duration!;
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '${hours}h ${remainingMinutes}m';
    }
    return '${minutes}m';
  }

  /// Check if book has audio
  bool get hasAudio => audioUrl != null && audioUrl!.isNotEmpty;

  /// Check if book has PDF
  bool get hasPdf => pdfUrl != null && pdfUrl!.isNotEmpty;

  /// Check if book has EPUB
  bool get hasEpub => epubUrl != null && epubUrl!.isNotEmpty;

  /// Get primary genre
  String? get primaryGenre => genres.isNotEmpty ? genres.first : null;

  /// Check if book is completed (reading progress is 100%)
  bool get isCompleted => readingProgress >= 1.0;

  /// Check if book is started (reading progress > 0%)
  bool get isStarted => readingProgress > 0.0;
}