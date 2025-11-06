import 'book.dart';

/// Mock data service providing sample books for development and testing
class MockBooksData {
  static final List<Book> _books = [
    // Popular Non-Fiction Books
    Book(
      id: 'atomic-habits',
      title: 'Atomic Habits',
      author: 'James Clear',
      subtitle: 'An Easy & Proven Way to Build Good Habits & Break Bad Ones',
      description: 'A comprehensive guide to building good habits and breaking bad ones through small, incremental changes.',
      coverImageUrl: 'https://images-na.ssl-images-amazon.com/images/I/51B7kuFwFML._SX329_BO1,204,203,200_.jpg',
      rating: 4.4,
      ratingsCount: 125000,
      audioUrl: 'https://example.com/audio/atomic-habits.mp3',
      duration: 12,
      genres: ['Self-Help', 'Psychology', 'Productivity'],
      tags: ['habits', 'productivity', 'self-improvement'],
      isTrending: true,
      summary: '''
Atomic Habits reveals how small changes can make a big difference. James Clear explains that success is not about making radical changes, but about making small improvements consistently over time.

The book introduces the concept of "atomic habits" - tiny changes that compound into remarkable results. Clear provides a proven framework for improving every day: the Four Laws of Behavior Change.

Key concepts include:
- The power of 1% improvements
- How habits shape your identity
- The importance of environment design
- Systems vs. goals thinking
      ''',
      keyTakeaways: [
        'Small habits compound into remarkable results over time',
        'Focus on systems, not goals, for lasting change',
        'Make good habits obvious, attractive, easy, and satisfying',
        'Make bad habits invisible, unattractive, hard, and unsatisfying',
        'Environment design is crucial for habit formation',
        'Identity change is the deepest level of change',
        'The plateau of latent potential explains why habits seem ineffective initially',
        'Habit stacking helps build new routines',
        'The two-minute rule makes habits easy to start',
        'Never miss twice to maintain momentum',
        'Track your habits to stay accountable',
        'Focus on the process, not the outcome'
      ],
      readingTime: 10,
      category: 'Self-Help',
      subcategory: 'Productivity',
      language: 'en',
      availableLanguages: ['en', 'es', 'fr', 'de'],
      audioLanguages: ['en', 'es'],
    ),
    
    Book(
      id: 'sapiens',
      title: 'Sapiens',
      author: 'Yuval Noah Harari',
      subtitle: 'A Brief History of Humankind',
      description: 'A thought-provoking exploration of how Homo sapiens came to dominate the world.',
      coverImageUrl: 'https://images-na.ssl-images-amazon.com/images/I/41QVihWXuqL._SX324_BO1,204,203,200_.jpg',
      rating: 4.3,
      ratingsCount: 89000,
      audioUrl: 'https://example.com/audio/sapiens.mp3',
      duration: 15,
      genres: ['History', 'Anthropology', 'Science'],
      tags: ['evolution', 'civilization', 'humanity'],
      isNew: true,
      summary: '''
Sapiens explores the journey of humanity from insignificant apes to rulers of the world. Harari examines three major revolutions that changed the course of history: the Cognitive Revolution, the Agricultural Revolution, and the Scientific Revolution.

The book challenges conventional wisdom about human development and asks fundamental questions about our species' future. Harari argues that Homo sapiens' success came from our ability to cooperate in large numbers through shared myths and stories.
      ''',
      keyTakeaways: [
        'Humans conquered the world through cooperation enabled by shared myths',
        'The Cognitive Revolution allowed humans to create complex societies',
        'Agriculture was a trap that made life harder for most people',
        'Money, empires, and religions are the three unifying forces of humanity',
        'The Scientific Revolution began only 500 years ago',
        'Capitalism and consumerism shape modern society',
        'Humans are becoming gods through technology',
        'We may be the last generation of Homo sapiens',
        'Happiness has not increased with progress',
        'Biological engineering will transform humanity',
        'The future may bring artificial intelligence and genetic modification',
        'We must consider the ethical implications of our power'
      ],
      readingTime: 12,
      category: 'History',
      subcategory: 'Anthropology',
    ),

    Book(
      id: 'thinking-fast-slow',
      title: 'Thinking, Fast and Slow',
      author: 'Daniel Kahneman',
      subtitle: 'The groundbreaking book on decision-making',
      description: 'A masterwork that explores the two systems that drive the way we think and make decisions.',
      coverImageUrl: 'https://images-na.ssl-images-amazon.com/images/I/41shZGS-G%2BL._SX324_BO1,204,203,200_.jpg',
      rating: 4.2,
      ratingsCount: 67000,
      audioUrl: 'https://example.com/audio/thinking-fast-slow.mp3',
      duration: 18,
      genres: ['Psychology', 'Behavioral Economics', 'Science'],
      tags: ['decision-making', 'cognitive-bias', 'psychology'],
      isPro: true,
      summary: '''
Nobel Prize winner Daniel Kahneman reveals the two systems that drive human thinking: System 1 (fast, intuitive) and System 2 (slow, deliberate). Understanding these systems helps us make better decisions and avoid cognitive biases.

The book explores how we make choices, form judgments, and assess risks. Kahneman shows how our minds are prone to overconfidence, loss aversion, and other systematic errors in thinking.
      ''',
      keyTakeaways: [
        'System 1 thinking is fast, automatic, and intuitive',
        'System 2 thinking is slow, effortful, and logical',
        'Most decisions are made by System 1, often incorrectly',
        'Cognitive biases systematically distort our judgment',
        'Loss aversion makes losses feel twice as powerful as gains',
        'The availability heuristic overweights recent or memorable events',
        'Anchoring bias influences all numerical estimates',
        'Overconfidence is a persistent human trait',
        'Framing effects change how we perceive identical options',
        'The planning fallacy causes systematic underestimation of time and costs',
        'Regression to the mean is often misunderstood',
        'Experienced utility differs from remembered utility'
      ],
      readingTime: 15,
      category: 'Psychology',
      subcategory: 'Behavioral Economics',
    ),

    // Fiction Books
    Book(
      id: '1984',
      title: '1984',
      author: 'George Orwell',
      subtitle: 'A dystopian social science fiction novel',
      description: 'A chilling prophecy about the future of society under totalitarian rule.',
      coverImageUrl: 'https://images-na.ssl-images-amazon.com/images/I/41E2UoSaP2L._SX324_BO1,204,203,200_.jpg',
      rating: 4.5,
      ratingsCount: 156000,
      duration: 14,
      genres: ['Fiction', 'Dystopian', 'Classics'],
      tags: ['totalitarianism', 'surveillance', 'freedom'],
      isTrending: true,
      summary: '''
1984 presents a terrifying vision of a totalitarian future where Big Brother watches everything. Winston Smith works for the Party, rewriting history, but begins to rebel against the oppressive system.

Orwell's masterpiece explores themes of surveillance, propaganda, and the manipulation of truth. The novel introduced concepts like "doublethink," "thoughtcrime," and "Big Brother" that remain relevant today.
      ''',
      keyTakeaways: [
        'Totalitarian governments control through surveillance and fear',
        'Language manipulation shapes thought and reality',
        'The past is constantly rewritten to serve the present',
        'Individual freedom requires constant vigilance',
        'Propaganda can make people believe contradictory things',
        'Technology can be used to oppress rather than liberate',
        'Love and human connection threaten authoritarian control',
        'Truth becomes subjective under totalitarian rule',
        'Resistance requires both courage and sacrifice',
        'The Party seeks power for its own sake',
        'Thoughtcrime is the ultimate form of control',
        'Freedom is the right to say two plus two equals four'
      ],
      readingTime: 11,
      category: 'Fiction',
      subcategory: 'Dystopian',
    ),

    Book(
      id: 'the-alchemist',
      title: 'The Alchemist',
      author: 'Paulo Coelho',
      subtitle: 'A fable about following your dream',
      description: 'The story of Santiago, a shepherd boy who travels from Spain to Egypt in search of treasure.',
      coverImageUrl: 'https://images-na.ssl-images-amazon.com/images/I/41VWiuHdKbL._SX324_BO1,204,203,200_.jpg',
      rating: 4.1,
      ratingsCount: 234000,
      duration: 8,
      genres: ['Fiction', 'Philosophy', 'Adventure'],
      tags: ['dreams', 'journey', 'self-discovery'],
      summary: '''
The Alchemist follows Santiago, a young shepherd who dreams of finding treasure near the Egyptian pyramids. His journey becomes a quest for self-discovery and understanding of life's purpose.

Coelho weaves a tale about listening to your heart, recognizing opportunity, and following your dreams. The book explores universal themes through Santiago's encounters with various characters who teach him about life.
      ''',
      keyTakeaways: [
        'Follow your Personal Legend (life\'s purpose)',
        'The universe conspires to help you achieve your dreams',
        'Listen to your heart and trust your intuition',
        'Every person has a treasure waiting to be discovered',
        'The journey is as important as the destination',
        'Fear is the greatest obstacle to pursuing dreams',
        'Love should not prevent you from following your path',
        'Learn to read the omens that guide your way',
        'The present moment is all we truly have',
        'Treasure often lies where you least expect it',
        'Persistence and courage are essential for success',
        'The Soul of the World connects all living things'
      ],
      readingTime: 6,
      category: 'Fiction',
      subcategory: 'Philosophy',
    ),

    // Business Books
    Book(
      id: 'good-to-great',
      title: 'Good to Great',
      author: 'Jim Collins',
      subtitle: 'Why Some Companies Make the Leap... and Others Don\'t',
      description: 'A comprehensive study of what makes companies transition from good performance to great results.',
      coverImageUrl: 'https://images-na.ssl-images-amazon.com/images/I/41DjrKmhWdL._SX324_BO1,204,203,200_.jpg',
      rating: 4.3,
      ratingsCount: 45000,
      audioUrl: 'https://example.com/audio/good-to-great.mp3',
      duration: 16,
      genres: ['Business', 'Leadership', 'Management'],
      tags: ['leadership', 'business-strategy', 'corporate-culture'],
      isPro: true,
      summary: '''
Good to Great examines companies that made the transition from good performance to great results and sustained those results for at least fifteen years. Collins and his team identified key factors that distinguish great companies from merely good ones.

The research reveals that great companies have Level 5 leaders, get the right people on the bus, confront brutal facts, and maintain unwavering faith in their ability to prevail.
      ''',
      keyTakeaways: [
        'Level 5 leaders combine humility with fierce resolve',
        'Get the right people on the bus before deciding where to go',
        'Confront the brutal facts while maintaining unwavering faith',
        'The Hedgehog Concept focuses on what you can be best at',
        'Culture of discipline eliminates the need for hierarchy',
        'Technology is an accelerator, not a creator of momentum',
        'The flywheel effect builds momentum through consistent effort',
        'Great companies focus on what they can be passionate about',
        'Economic engine drives sustainable profitability',
        'Good is the enemy of great',
        'Greatness is a choice, not a circumstance',
        'Sustained great results require disciplined people, thought, and action'
      ],
      readingTime: 13,
      category: 'Business',
      subcategory: 'Leadership',
    ),

    // More trending books
    Book(
      id: 'cant-hurt-me',
      title: 'Can\'t Hurt Me',
      author: 'David Goggins',
      subtitle: 'Master Your Mind and Defy the Odds',
      description: 'A memoir about overcoming obstacles and achieving the impossible through mental toughness.',
      coverImageUrl: 'https://images-na.ssl-images-amazon.com/images/I/41VWiuHdKbL._SX324_BO1,204,203,200_.jpg',
      rating: 4.6,
      ratingsCount: 78000,
      audioUrl: 'https://example.com/audio/cant-hurt-me.mp3',
      duration: 13,
      genres: ['Biography', 'Self-Help', 'Motivation'],
      tags: ['mental-toughness', 'resilience', 'motivation'],
      isTrending: true,
      isNew: true,
      summary: '''
David Goggins shares his incredible transformation from a depressed, overweight young man with no future into a U.S. Armed Forces icon and one of the world's top endurance athletes.

The book reveals the power of mental toughness and provides a blueprint for overcoming any obstacle. Goggins introduces the concept of the "accountability mirror" and challenges readers to embrace discomfort.
      ''',
      keyTakeaways: [
        'Mental toughness can overcome any physical limitation',
        'Embrace suffering to grow stronger',
        'The accountability mirror forces honest self-assessment',
        'Your mind will quit before your body does',
        'Callous your mind through deliberate hardship',
        'Take ownership of your failures and weaknesses',
        'The 40% rule: when you think you\'re done, you\'re only 40% done',
        'Visualization and preparation are crucial for success',
        'Stay hard and never settle for mediocrity',
        'Use negative experiences as fuel for growth',
        'Cookie jar: remember past victories during tough times',
        'Be uncommon amongst uncommon people'
      ],
      readingTime: 11,
      category: 'Biography',
      subcategory: 'Motivation',
    ),
  ];

  /// Get all books
  static List<Book> getAllBooks() => List.from(_books);

  /// Get trending books
  static List<Book> getTrendingBooks() => 
      _books.where((book) => book.isTrending).toList();

  /// Get new books
  static List<Book> getNewBooks() => 
      _books.where((book) => book.isNew).toList();

  /// Get books by category
  static List<Book> getBooksByCategory(String category) =>
      _books.where((book) => book.category == category).toList();

  /// Get books by genre
  static List<Book> getBooksByGenre(String genre) =>
      _books.where((book) => book.genres.contains(genre)).toList();

  /// Get featured books (mix of trending and highly rated)
  static List<Book> getFeaturedBooks() {
    final featured = <Book>[];
    
    // Add trending books
    featured.addAll(getTrendingBooks());
    
    // Add highly rated books that aren't already trending
    final highlyRated = _books
        .where((book) => !book.isTrending && (book.rating ?? 0) >= 4.3)
        .take(3)
        .toList();
    featured.addAll(highlyRated);
    
    return featured;
  }

  /// Search books by title or author
  static List<Book> searchBooks(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _books.where((book) =>
        book.title.toLowerCase().contains(lowercaseQuery) ||
        book.author.toLowerCase().contains(lowercaseQuery) ||
        book.genres.any((genre) => genre.toLowerCase().contains(lowercaseQuery))
    ).toList();
  }

  /// Get book by ID
  static Book? getBookById(String id) {
    try {
      return _books.firstWhere((book) => book.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get recommended books based on a book
  static List<Book> getRecommendedBooks(String bookId, {int limit = 5}) {
    final book = getBookById(bookId);
    if (book == null) return [];

    // Find books with similar genres
    final recommended = _books
        .where((b) => b.id != bookId)
        .where((b) => b.genres.any((genre) => book.genres.contains(genre)))
        .take(limit)
        .toList();

    return recommended;
  }

  /// Get books by multiple filters
  static List<Book> getFilteredBooks({
    String? category,
    String? genre,
    double? minRating,
    bool? hasAudio,
    bool? isPro,
  }) {
    var filtered = _books.asMap().values;

    if (category != null) {
      filtered = filtered.where((book) => book.category == category);
    }

    if (genre != null) {
      filtered = filtered.where((book) => book.genres.contains(genre));
    }

    if (minRating != null) {
      filtered = filtered.where((book) => (book.rating ?? 0) >= minRating);
    }

    if (hasAudio != null) {
      filtered = filtered.where((book) => book.hasAudio == hasAudio);
    }

    if (isPro != null) {
      filtered = filtered.where((book) => book.isPro == isPro);
    }

    return filtered.toList();
  }

  /// Get popular categories
  static List<String> getPopularCategories() {
    final categories = <String>{};
    for (final book in _books) {
      if (book.category != null) {
        categories.add(book.category!);
      }
    }
    return categories.toList()..sort();
  }

  /// Get popular genres
  static List<String> getPopularGenres() {
    final genres = <String>{};
    for (final book in _books) {
      genres.addAll(book.genres);
    }
    return genres.toList()..sort();
  }
}