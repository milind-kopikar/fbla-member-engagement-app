import 'package:flutter/material.dart';
import '../controllers/news_controller.dart';
import '../models/news_item.dart';
import '../widgets/news_list_item.dart';

/// NewsFeedScreen - View component for displaying FBLA news and announcements
/// 
/// This screen demonstrates the View layer in the MVC pattern.
/// It displays news articles, announcements, and updates to keep members
/// informed and engaged with FBLA activities and achievements.
/// 
/// Features:
/// - Display news items in reverse chronological order
/// - Pinned/featured news at the top
/// - Category filtering for targeted content
/// - Like and view tracking for engagement
/// - Pull-to-refresh functionality
class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({Key? key}) : super(key: key);

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  /// Controller instance to manage news data
  final NewsController _controller = NewsController();
  
  /// Loading state
  bool _isLoading = false;
  
  /// Currently selected category filter
  String _selectedCategory = 'All';
  
  /// Available category filters
  final List<String> _categoryOptions = [
    'All',
    'Competition',
    'Achievement',
    'Announcement',
    'Chapter News',
    'Event Recap',
  ];

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  /// Loads news items from the controller
  Future<void> _loadNews() async {
    setState(() => _isLoading = true);
    await _controller.loadNews();
    setState(() => _isLoading = false);
  }

  /// Filters news items based on the selected category
  List<NewsItem> get _filteredNews {
    if (_selectedCategory == 'All') {
      return _controller.allNews;
    }
    return _controller.allNews
        .where((news) => news.category == _selectedCategory)
        .toList();
  }

  /// Handles liking/unliking a news item
  Future<void> _toggleLike(NewsItem newsItem) async {
    try {
      await _controller.toggleLike(newsItem.id);
      setState(() {}); // Refresh UI
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Opens the full news article in a detail view
  void _showNewsDetail(NewsItem newsItem) {
    // Increment view count
    _controller.incrementViewCount(newsItem.id);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewsDetailScreen(newsItem: newsItem),
      ),
    ).then((_) => setState(() {})); // Refresh on return
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News Feed'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNews,
            tooltip: 'Refresh News',
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter chips
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categoryOptions.length,
              itemBuilder: (context, index) {
                final category = _categoryOptions[index];
                final isSelected = _selectedCategory == category;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedCategory = category);
                    },
                    selectedColor: Theme.of(context).primaryColor.withOpacity(0.3),
                  ),
                );
              },
            ),
          ),
          
          // News list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredNews.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.article_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No news items found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadNews,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _filteredNews.length,
                          itemBuilder: (context, index) {
                            final newsItem = _filteredNews[index];
                            return NewsListItem(
                              newsItem: newsItem,
                              onTap: () => _showNewsDetail(newsItem),
                              onLike: () => _toggleLike(newsItem),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

/// NewsDetailScreen - Detailed view for a single news article
/// 
/// Displays the full content of a news article with engagement features.
class NewsDetailScreen extends StatelessWidget {
  final NewsItem newsItem;

  const NewsDetailScreen({
    Key? key,
    required this.newsItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Article Details'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image (if available)
            if (newsItem.imageUrl != null)
              Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey[300],
                child: const Icon(Icons.image, size: 64),
              ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    newsItem.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Metadata row
                  Row(
                    children: [
                      Chip(
                        label: Text(newsItem.category),
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        newsItem.timeAgo,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Author and engagement stats
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(newsItem.author),
                      const Spacer(),
                      Icon(Icons.visibility, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('${newsItem.viewCount} views'),
                      const SizedBox(width: 16),
                      Icon(Icons.favorite, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('${newsItem.likeCount} likes'),
                    ],
                  ),
                  const Divider(height: 32),
                  
                  // Full content
                  Text(
                    newsItem.content,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  
                  // Tags
                  if (newsItem.tags.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: newsItem.tags.map((tag) {
                        return Chip(
                          label: Text('#$tag'),
                          backgroundColor: Colors.grey[200],
                        );
                      }).toList(),
                    ),
                  ],
                  
                  // External link button
                  if (newsItem.externalLink != null) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.link),
                        label: const Text('Read More'),
                        onPressed: () {
                          // In a real app, launch the URL
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Open: ${newsItem.externalLink}')),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
