import 'package:flutter/material.dart';
import '../models/news_item.dart';

/// NewsListItem - Reusable widget for displaying news in a list
/// 
/// This widget demonstrates proper component design and reusability,
/// following best practices for modular Flutter development.
/// 
/// Features:
/// - Clean, card-based news presentation
/// - Visual indicators for new/pinned content
/// - Engagement metrics display
/// - Interactive like functionality
/// - Responsive layout
/// 
/// Usage:
/// ```dart
/// NewsListItem(
///   newsItem: myNews,
///   onTap: () => showNewsDetail(myNews),
///   onLike: () => toggleLike(myNews),
/// )
/// ```
class NewsListItem extends StatelessWidget {
  /// The news item to display
  final NewsItem newsItem;
  
  /// Callback when the item is tapped
  final VoidCallback? onTap;
  
  /// Callback when the like button is tapped
  final VoidCallback? onLike;
  
  /// Whether to show a compact version
  final bool compact;
  
  /// Whether the current user has liked this item
  final bool isLiked;

  const NewsListItem({
    Key? key,
    required this.newsItem,
    this.onTap,
    this.onLike,
    this.compact = false,
    this.isLiked = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: newsItem.isPinned ? 4 : 2,
      color: newsItem.isPinned ? Colors.amber[50] : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: newsItem.isPinned
            ? BorderSide(color: Colors.amber.shade300, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: compact ? _buildCompactContent(context) : _buildFullContent(context),
        ),
      ),
    );
  }

  /// Builds the full content layout
  Widget _buildFullContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row with badges
        Row(
          children: [
            // Pinned badge
            if (newsItem.isPinned)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.push_pin, size: 12),
                    SizedBox(width: 4),
                    Text(
                      'PINNED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            
            if (newsItem.isPinned) const SizedBox(width: 8),
            
            // Category badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getCategoryColor(newsItem.category),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                newsItem.category,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            const Spacer(),
            
            // New indicator
            if (newsItem.isNew)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'NEW',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Title
        Text(
          newsItem.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Summary
        Text(
          newsItem.summary,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            height: 1.4,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Metadata and engagement row
        Row(
          children: [
            // Author
            Row(
              children: [
                Icon(Icons.person, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  newsItem.author,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            
            const SizedBox(width: 16),
            
            // Time ago
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  newsItem.timeAgo,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            
            const Spacer(),
            
            // View count
            Row(
              children: [
                Icon(Icons.visibility, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${newsItem.viewCount}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            
            const SizedBox(width: 16),
            
            // Like button
            InkWell(
              onTap: onLike,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 16,
                      color: isLiked ? Colors.red : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${newsItem.likeCount}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isLiked ? Colors.red : Colors.grey[600],
                        fontWeight: isLiked ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        
        // Tags (if available and space permits)
        if (newsItem.tags.isNotEmpty && !compact) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: newsItem.tags.take(3).map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '#$tag',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[700],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  /// Builds a compact content layout for dense lists
  Widget _buildCompactContent(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image placeholder or icon
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: _getCategoryColor(newsItem.category),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.article, size: 30),
        ),
        
        const SizedBox(width: 12),
        
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                newsItem.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              // Metadata
              Row(
                children: [
                  Text(
                    newsItem.timeAgo,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.visibility, size: 12, color: Colors.grey[600]),
                  const SizedBox(width: 2),
                  Text(
                    '${newsItem.viewCount}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Pinned indicator
        if (newsItem.isPinned)
          const Icon(
            Icons.push_pin,
            size: 16,
            color: Colors.amber,
          ),
      ],
    );
  }

  /// Gets a color associated with the news category
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'competition':
        return Colors.red.shade100;
      case 'achievement':
        return Colors.green.shade100;
      case 'announcement':
        return Colors.blue.shade100;
      case 'chapter news':
        return Colors.purple.shade100;
      case 'event recap':
        return Colors.orange.shade100;
      default:
        return Colors.grey.shade200;
    }
  }
}
