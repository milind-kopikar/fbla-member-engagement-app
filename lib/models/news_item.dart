/// Model class representing a news article or announcement.
/// 
/// This class supports the News Feed feature requirement, enabling members
/// to stay informed about FBLA updates, announcements, and important information.
class NewsItem {
  /// Unique identifier for the news item
  final String id;
  
  /// Headline/title of the news article
  String title;
  
  /// Full content of the news article
  String content;
  
  /// Brief summary or excerpt of the article
  String summary;
  
  /// Author of the news article
  String author;
  
  /// Publication date and time
  DateTime publishedDate;
  
  /// Category of the news (e.g., Competition, Achievement, Announcement, Chapter News)
  String category;
  
  /// URL to a cover image for the article (optional)
  String? imageUrl;
  
  /// Tags for categorization and search
  List<String> tags;
  
  /// Whether the news item is pinned/featured
  bool isPinned;
  
  /// Number of views (for engagement tracking)
  int viewCount;
  
  /// List of member IDs who have liked this news item
  List<String> likedByMemberIds;
  
  /// External URL for more information (optional)
  String? externalLink;
  
  /// Priority level (1-5, with 5 being highest priority)
  int priority;

  /// Constructor for creating a new NewsItem instance
  NewsItem({
    required this.id,
    required this.title,
    required this.content,
    required this.summary,
    required this.author,
    required this.publishedDate,
    required this.category,
    this.imageUrl,
    this.tags = const [],
    this.isPinned = false,
    this.viewCount = 0,
    this.likedByMemberIds = const [],
    this.externalLink,
    this.priority = 1,
  });

  /// Factory constructor to create a NewsItem from JSON data
  /// 
  /// Supports deserialization from the LocalDataService mock database.
  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      summary: json['summary'] as String,
      author: json['author'] as String,
      publishedDate: DateTime.parse(json['publishedDate'] as String),
      category: json['category'] as String,
      imageUrl: json['imageUrl'] as String?,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : [],
      isPinned: json['isPinned'] as bool? ?? false,
      viewCount: json['viewCount'] as int? ?? 0,
      likedByMemberIds: json['likedByMemberIds'] != null
          ? List<String>.from(json['likedByMemberIds'] as List)
          : [],
      externalLink: json['externalLink'] as String?,
      priority: json['priority'] as int? ?? 1,
    );
  }

  /// Converts the NewsItem instance to a JSON map
  /// 
  /// Used for serializing data to the LocalDataService.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'summary': summary,
      'author': author,
      'publishedDate': publishedDate.toIso8601String(),
      'category': category,
      'imageUrl': imageUrl,
      'tags': tags,
      'isPinned': isPinned,
      'viewCount': viewCount,
      'likedByMemberIds': likedByMemberIds,
      'externalLink': externalLink,
      'priority': priority,
    };
  }

  /// Gets the number of likes for this news item
  int get likeCount => likedByMemberIds.length;

  /// Checks if the news item was published today
  bool get isNew {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final publishDay = DateTime(
      publishedDate.year,
      publishedDate.month,
      publishedDate.day,
    );
    return today == publishDay;
  }

  /// Gets a human-readable time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(publishedDate);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  /// Creates a copy of this NewsItem with optional field updates
  NewsItem copyWith({
    String? id,
    String? title,
    String? content,
    String? summary,
    String? author,
    DateTime? publishedDate,
    String? category,
    String? imageUrl,
    List<String>? tags,
    bool? isPinned,
    int? viewCount,
    List<String>? likedByMemberIds,
    String? externalLink,
    int? priority,
  }) {
    return NewsItem(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      summary: summary ?? this.summary,
      author: author ?? this.author,
      publishedDate: publishedDate ?? this.publishedDate,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      isPinned: isPinned ?? this.isPinned,
      viewCount: viewCount ?? this.viewCount,
      likedByMemberIds: likedByMemberIds ?? this.likedByMemberIds,
      externalLink: externalLink ?? this.externalLink,
      priority: priority ?? this.priority,
    );
  }

  @override
  String toString() {
    return 'NewsItem(id: $id, title: $title, author: $author, publishedDate: $publishedDate)';
  }
}
