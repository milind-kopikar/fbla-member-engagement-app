/// Model class representing an FBLA resource or document.
/// 
/// This class supports the Resources feature, providing members access to
/// important FBLA documents, guides, social media links, and educational materials.
class Resource {
  /// Unique identifier for the resource
  final String id;
  
  /// Title/name of the resource
  String title;
  
  /// Description of what the resource contains
  String description;
  
  /// Type of resource (e.g., Document, Video, Link, Social Media, Guide)
  String type;
  
  /// Category for organization (e.g., Competition Prep, Leadership, Business)
  String category;
  
  /// URL or file path to the resource
  String url;
  
  /// File format (e.g., PDF, DOCX, MP4, URL) if applicable
  String? fileFormat;
  
  /// Size of the file in bytes (if applicable)
  int? fileSize;
  
  /// Thumbnail image URL for visual preview
  String? thumbnailUrl;
  
  /// Date when the resource was added
  DateTime dateAdded;
  
  /// Date when the resource was last updated
  DateTime? lastUpdated;
  
  /// Tags for search and categorization
  List<String> tags;
  
  /// Whether the resource is featured/recommended
  bool isFeatured;
  
  /// Download count for tracking popularity
  int downloadCount;
  
  /// Whether the resource is available offline
  bool isOfflineAvailable;
  
  /// Author or source of the resource
  String? author;
  
  /// Estimated time to consume the resource (in minutes)
  int? estimatedTime;

  /// Constructor for creating a new Resource instance
  Resource({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.url,
    this.fileFormat,
    this.fileSize,
    this.thumbnailUrl,
    required this.dateAdded,
    this.lastUpdated,
    this.tags = const [],
    this.isFeatured = false,
    this.downloadCount = 0,
    this.isOfflineAvailable = false,
    this.author,
    this.estimatedTime,
  });

  /// Factory constructor to create a Resource from JSON data
  /// 
  /// Supports deserialization from the LocalDataService mock database.
  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      category: json['category'] as String,
      url: json['url'] as String,
      fileFormat: json['fileFormat'] as String?,
      fileSize: json['fileSize'] as int?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      dateAdded: DateTime.parse(json['dateAdded'] as String),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : [],
      isFeatured: json['isFeatured'] as bool? ?? false,
      downloadCount: json['downloadCount'] as int? ?? 0,
      isOfflineAvailable: json['isOfflineAvailable'] as bool? ?? false,
      author: json['author'] as String?,
      estimatedTime: json['estimatedTime'] as int?,
    );
  }

  /// Converts the Resource instance to a JSON map
  /// 
  /// Used for serializing data to the LocalDataService.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'category': category,
      'url': url,
      'fileFormat': fileFormat,
      'fileSize': fileSize,
      'thumbnailUrl': thumbnailUrl,
      'dateAdded': dateAdded.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
      'tags': tags,
      'isFeatured': isFeatured,
      'downloadCount': downloadCount,
      'isOfflineAvailable': isOfflineAvailable,
      'author': author,
      'estimatedTime': estimatedTime,
    };
  }

  /// Gets a human-readable file size string
  String get fileSizeFormatted {
    if (fileSize == null) return 'Unknown size';
    
    if (fileSize! < 1024) {
      return '$fileSize B';
    } else if (fileSize! < 1024 * 1024) {
      return '${(fileSize! / 1024).toStringAsFixed(2)} KB';
    } else if (fileSize! < 1024 * 1024 * 1024) {
      return '${(fileSize! / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(fileSize! / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  /// Checks if the resource is a social media link
  bool get isSocialMedia {
    return type.toLowerCase() == 'social media' ||
        url.contains('facebook.com') ||
        url.contains('twitter.com') ||
        url.contains('instagram.com') ||
        url.contains('linkedin.com') ||
        url.contains('youtube.com');
  }

  /// Gets the estimated time in a human-readable format
  String get estimatedTimeFormatted {
    if (estimatedTime == null) return 'N/A';
    
    if (estimatedTime! < 60) {
      return '$estimatedTime min';
    } else {
      final hours = estimatedTime! ~/ 60;
      final minutes = estimatedTime! % 60;
      return minutes > 0 ? '$hours hr $minutes min' : '$hours hr';
    }
  }

  /// Creates a copy of this Resource with optional field updates
  Resource copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    String? category,
    String? url,
    String? fileFormat,
    int? fileSize,
    String? thumbnailUrl,
    DateTime? dateAdded,
    DateTime? lastUpdated,
    List<String>? tags,
    bool? isFeatured,
    int? downloadCount,
    bool? isOfflineAvailable,
    String? author,
    int? estimatedTime,
  }) {
    return Resource(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      category: category ?? this.category,
      url: url ?? this.url,
      fileFormat: fileFormat ?? this.fileFormat,
      fileSize: fileSize ?? this.fileSize,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      dateAdded: dateAdded ?? this.dateAdded,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      tags: tags ?? this.tags,
      isFeatured: isFeatured ?? this.isFeatured,
      downloadCount: downloadCount ?? this.downloadCount,
      isOfflineAvailable: isOfflineAvailable ?? this.isOfflineAvailable,
      author: author ?? this.author,
      estimatedTime: estimatedTime ?? this.estimatedTime,
    );
  }

  @override
  String toString() {
    return 'Resource(id: $id, title: $title, type: $type, category: $category)';
  }
}
