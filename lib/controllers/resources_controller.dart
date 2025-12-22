import 'package:flutter/material.dart';
import '../models/resource.dart';
import '../services/local_data_service.dart';

/// ResourcesController - Controller component for resource management
/// 
/// This controller demonstrates the Controller layer in the MVC pattern.
/// It manages the business logic for FBLA resources including:
/// - Loading and filtering resources
/// - Download tracking
/// - Category and type organization
/// - Social media integration logic
class ResourcesController {
  /// Data service instance for local data persistence
  final LocalDataService _dataService = LocalDataService();
  
  /// All loaded resources
  List<Resource> allResources = [];

  /// Loads all resources from the data service
  Future<void> loadResources() async {
    allResources = await _dataService.getResources();
    _sortResources();
  }

  /// Sorts resources by featured status and date added
  /// 
  /// Featured resources appear first, then sorted by:
  /// 1. Featured status
  /// 2. Date added (newest first)
  void _sortResources() {
    allResources.sort((a, b) {
      // Featured items come first
      if (a.isFeatured && !b.isFeatured) return -1;
      if (!a.isFeatured && b.isFeatured) return 1;
      
      // Then sort by date added (newest first)
      return b.dateAdded.compareTo(a.dateAdded);
    });
  }

  /// Gets featured resources
  List<Resource> get featuredResources {
    return allResources.where((r) => r.isFeatured).toList();
  }

  /// Gets resources by category
  List<Resource> getResourcesByCategory(String category) {
    return allResources
        .where((r) => r.category == category)
        .toList();
  }

  /// Gets resources by type
  List<Resource> getResourcesByType(String type) {
    return allResources
        .where((r) => r.type == type)
        .toList();
  }

  /// Gets social media resources
  /// 
  /// Returns all resources that link to FBLA social media channels.
  List<Resource> get socialMediaResources {
    return allResources
        .where((r) => r.isSocialMedia)
        .toList();
  }

  /// Gets offline-available resources
  List<Resource> get offlineResources {
    return allResources
        .where((r) => r.isOfflineAvailable)
        .toList();
  }

  /// Gets recently added resources (within last 30 days)
  List<Resource> get recentResources {
    final monthAgo = DateTime.now().subtract(const Duration(days: 30));
    return allResources
        .where((r) => r.dateAdded.isAfter(monthAgo))
        .toList();
  }

  /// Gets popular resources (high download count)
  List<Resource> get popularResources {
    return allResources
        .where((r) => r.downloadCount > 10)
        .toList()
      ..sort((a, b) => b.downloadCount.compareTo(a.downloadCount));
  }

  /// Increments the download count when a resource is accessed
  /// 
  /// Tracks resource usage for analytics and popularity.
  Future<void> accessResource(String resourceId) async {
    final resource = allResources.firstWhere((r) => r.id == resourceId);
    
    final updatedResource = resource.copyWith(
      downloadCount: resource.downloadCount + 1,
    );
    
    // Update in data service
    await _dataService.updateResource(updatedResource);
    
    // Update local list
    final index = allResources.indexWhere((r) => r.id == resourceId);
    if (index != -1) {
      allResources[index] = updatedResource;
    }
  }

  /// Searches resources by query string
  /// 
  /// Searches in title, description, author, and tags.
  List<Resource> searchResources(String query) {
    if (query.trim().isEmpty) {
      return allResources;
    }
    
    final lowerQuery = query.toLowerCase();
    return allResources.where((resource) {
      return resource.title.toLowerCase().contains(lowerQuery) ||
          resource.description.toLowerCase().contains(lowerQuery) ||
          (resource.author?.toLowerCase().contains(lowerQuery) ?? false) ||
          resource.tags.any((tag) => tag.toLowerCase().contains(lowerQuery)) ||
          resource.category.toLowerCase().contains(lowerQuery) ||
          resource.type.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Gets resources with a specific tag
  List<Resource> getResourcesByTag(String tag) {
    return allResources
        .where((r) => r.tags.contains(tag))
        .toList();
  }

  /// Gets all unique tags from all resources
  List<String> getAllTags() {
    final tags = <String>{};
    for (final resource in allResources) {
      tags.addAll(resource.tags);
    }
    return tags.toList()..sort();
  }

  /// Gets all unique categories
  List<String> getAllCategories() {
    final categories = allResources
        .map((r) => r.category)
        .toSet()
        .toList()
      ..sort();
    return categories;
  }

  /// Gets an icon for a resource type
  /// 
  /// Provides visual distinction between resource types.
  IconData getResourceIcon(String type) {
    switch (type.toLowerCase()) {
      case 'document':
        return Icons.description;
      case 'video':
        return Icons.video_library;
      case 'link':
      case 'url':
        return Icons.link;
      case 'social media':
        return Icons.share;
      case 'guide':
        return Icons.menu_book;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'presentation':
        return Icons.slideshow;
      case 'spreadsheet':
        return Icons.table_chart;
      default:
        return Icons.insert_drive_file;
    }
  }

  /// Gets usage statistics for analytics
  /// 
  /// Returns total resources, downloads, and average downloads.
  Map<String, dynamic> getUsageStats() {
    int totalDownloads = 0;
    int offlineCount = 0;
    int featuredCount = 0;
    
    for (final resource in allResources) {
      totalDownloads += resource.downloadCount;
      if (resource.isOfflineAvailable) offlineCount++;
      if (resource.isFeatured) featuredCount++;
    }
    
    return {
      'totalResources': allResources.length,
      'totalDownloads': totalDownloads,
      'averageDownloads': allResources.isNotEmpty
          ? (totalDownloads / allResources.length).round()
          : 0,
      'offlineAvailable': offlineCount,
      'featured': featuredCount,
    };
  }

  /// Gets the most downloaded resource
  Resource? get mostDownloadedResource {
    if (allResources.isEmpty) return null;
    
    return allResources.reduce((current, next) =>
        current.downloadCount > next.downloadCount ? current : next);
  }

  /// Filters resources for competition preparation
  /// 
  /// Returns resources specifically tagged for competition prep.
  List<Resource> get competitionPrepResources {
    return allResources.where((r) {
      return r.category.toLowerCase().contains('competition') ||
          r.tags.any((tag) => tag.toLowerCase().contains('competition'));
    }).toList();
  }

  /// Gets social media platform-specific resources
  /// 
  /// Organizes social media links by platform.
  Map<String, List<Resource>> getSocialMediaByPlatform() {
    final platforms = <String, List<Resource>>{
      'Facebook': [],
      'Twitter': [],
      'Instagram': [],
      'LinkedIn': [],
      'YouTube': [],
      'Other': [],
    };
    
    for (final resource in socialMediaResources) {
      final url = resource.url.toLowerCase();
      
      if (url.contains('facebook.com')) {
        platforms['Facebook']!.add(resource);
      } else if (url.contains('twitter.com') || url.contains('x.com')) {
        platforms['Twitter']!.add(resource);
      } else if (url.contains('instagram.com')) {
        platforms['Instagram']!.add(resource);
      } else if (url.contains('linkedin.com')) {
        platforms['LinkedIn']!.add(resource);
      } else if (url.contains('youtube.com')) {
        platforms['YouTube']!.add(resource);
      } else {
        platforms['Other']!.add(resource);
      }
    }
    
    // Remove empty platforms
    platforms.removeWhere((key, value) => value.isEmpty);
    
    return platforms;
  }
}
