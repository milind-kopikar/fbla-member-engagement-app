import '../models/news_item.dart';
import '../services/local_data_service.dart';

/// NewsController - Controller component for news feed management
/// 
/// This controller demonstrates the Controller layer in the MVC pattern.
/// It manages the business logic for news items including:
/// - Loading and filtering news
/// - Engagement tracking (likes, views)
/// - Sorting by priority and date
/// - Category-based organization
class NewsController {
  /// Data service instance for local data persistence
  final LocalDataService _dataService = LocalDataService();
  
  /// All loaded news items
  List<NewsItem> allNews = [];
  
  /// Currently logged-in member ID (hardcoded for demo)
  final String currentMemberId = 'member_1';

  /// Loads all news items from the data service
  Future<void> loadNews() async {
    allNews = await _dataService.getNews();
    _sortNews();
  }

  /// Sorts news items by priority and date
  /// 
  /// Pinned items appear first, then sorted by:
  /// 1. Priority (highest first)
  /// 2. Published date (newest first)
  void _sortNews() {
    allNews.sort((a, b) {
      // Pinned items always come first
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      
      // Then sort by priority
      if (a.priority != b.priority) {
        return b.priority.compareTo(a.priority);
      }
      
      // Finally sort by date (newest first)
      return b.publishedDate.compareTo(a.publishedDate);
    });
  }

  /// Gets pinned/featured news items
  List<NewsItem> get pinnedNews {
    return allNews.where((news) => news.isPinned).toList();
  }

  /// Gets news items by category
  List<NewsItem> getNewsByCategory(String category) {
    return allNews
        .where((news) => news.category == category)
        .toList();
  }

  /// Gets recent news (published within the last 7 days)
  List<NewsItem> get recentNews {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return allNews
        .where((news) => news.publishedDate.isAfter(weekAgo))
        .toList();
  }

  /// Gets trending news (high engagement within last 30 days)
  /// 
  /// Considers both likes and views to determine trending status.
  List<NewsItem> get trendingNews {
    final monthAgo = DateTime.now().subtract(const Duration(days: 30));
    return allNews
        .where((news) => news.publishedDate.isAfter(monthAgo))
        .where((news) => news.likeCount > 5 || news.viewCount > 50)
        .toList()
      ..sort((a, b) {
        // Sort by engagement score (likes * 2 + views)
        final scoreA = a.likeCount * 2 + a.viewCount;
        final scoreB = b.likeCount * 2 + b.viewCount;
        return scoreB.compareTo(scoreA);
      });
  }

  /// Toggles like status for a news item
  /// 
  /// If the current member has liked the item, removes the like.
  /// Otherwise, adds a like.
  Future<void> toggleLike(String newsId) async {
    final news = allNews.firstWhere((n) => n.id == newsId);
    final hasLiked = news.likedByMemberIds.contains(currentMemberId);
    
    List<String> updatedLikes;
    if (hasLiked) {
      // Remove like
      updatedLikes = news.likedByMemberIds
          .where((id) => id != currentMemberId)
          .toList();
    } else {
      // Add like
      updatedLikes = [...news.likedByMemberIds, currentMemberId];
    }
    
    final updatedNews = news.copyWith(
      likedByMemberIds: updatedLikes,
    );
    
    // Update in data service
    await _dataService.updateNewsItem(updatedNews);
    
    // Update local list
    final index = allNews.indexWhere((n) => n.id == newsId);
    if (index != -1) {
      allNews[index] = updatedNews;
    }
  }

  /// Increments the view count for a news item
  /// 
  /// Called when a user opens the full article.
  Future<void> incrementViewCount(String newsId) async {
    final news = allNews.firstWhere((n) => n.id == newsId);
    
    final updatedNews = news.copyWith(
      viewCount: news.viewCount + 1,
    );
    
    // Update in data service
    await _dataService.updateNewsItem(updatedNews);
    
    // Update local list
    final index = allNews.indexWhere((n) => n.id == newsId);
    if (index != -1) {
      allNews[index] = updatedNews;
    }
  }

  /// Checks if the current member has liked a news item
  bool hasLiked(String newsId) {
    final news = allNews.firstWhere((n) => n.id == newsId);
    return news.likedByMemberIds.contains(currentMemberId);
  }

  /// Searches news items by query string
  /// 
  /// Searches in title, content, summary, author, and tags.
  List<NewsItem> searchNews(String query) {
    if (query.trim().isEmpty) {
      return allNews;
    }
    
    final lowerQuery = query.toLowerCase();
    return allNews.where((news) {
      return news.title.toLowerCase().contains(lowerQuery) ||
          news.content.toLowerCase().contains(lowerQuery) ||
          news.summary.toLowerCase().contains(lowerQuery) ||
          news.author.toLowerCase().contains(lowerQuery) ||
          news.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  /// Gets news items with a specific tag
  List<NewsItem> getNewsByTag(String tag) {
    return allNews
        .where((news) => news.tags.contains(tag))
        .toList();
  }

  /// Gets all unique tags from all news items
  /// 
  /// Useful for creating tag clouds or filter options.
  List<String> getAllTags() {
    final tags = <String>{};
    for (final news in allNews) {
      tags.addAll(news.tags);
    }
    return tags.toList()..sort();
  }

  /// Gets engagement statistics for analytics
  /// 
  /// Returns a map with total views, likes, and articles.
  Map<String, int> getEngagementStats() {
    int totalViews = 0;
    int totalLikes = 0;
    
    for (final news in allNews) {
      totalViews += news.viewCount;
      totalLikes += news.likeCount;
    }
    
    return {
      'totalArticles': allNews.length,
      'totalViews': totalViews,
      'totalLikes': totalLikes,
      'averageViews': allNews.isNotEmpty ? (totalViews / allNews.length).round() : 0,
      'averageLikes': allNews.isNotEmpty ? (totalLikes / allNews.length).round() : 0,
    };
  }

  /// Gets the most popular news item (by combined engagement)
  NewsItem? get mostPopularNews {
    if (allNews.isEmpty) return null;
    
    return allNews.reduce((current, next) {
      final currentScore = current.viewCount + (current.likeCount * 2);
      final nextScore = next.viewCount + (next.likeCount * 2);
      return currentScore > nextScore ? current : next;
    });
  }
}
