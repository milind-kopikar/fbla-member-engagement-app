import 'package:flutter/material.dart';
import '../controllers/resources_controller.dart';
import '../models/resource.dart';

/// ResourcesScreen - View component for FBLA resources and documents
/// 
/// This screen demonstrates the View layer in the MVC pattern.
/// It provides access to important FBLA documents, guides, educational
/// materials, and social media channels to support member engagement.
/// 
/// Features:
/// - Browse resources by category
/// - Search functionality for finding specific resources
/// - Integration with social media channels
/// - Download tracking and offline availability indicators
/// - Featured resources section
class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({Key? key}) : super(key: key);

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  /// Controller instance to manage resource data
  final ResourcesController _controller = ResourcesController();
  
  /// Loading state
  bool _isLoading = false;
  
  /// Search query
  String _searchQuery = '';
  
  /// Currently selected category filter
  String _selectedCategory = 'All';
  
  /// Available category filters
  final List<String> _categoryOptions = [
    'All',
    'Competition Prep',
    'Leadership',
    'Business',
    'Social Media',
    'Chapter Management',
    'Guides & Tutorials',
  ];

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  /// Loads resources from the controller
  Future<void> _loadResources() async {
    setState(() => _isLoading = true);
    await _controller.loadResources();
    setState(() => _isLoading = false);
  }

  /// Filters resources based on search query and category
  List<Resource> get _filteredResources {
    var resources = _controller.allResources;
    
    // Apply category filter
    if (_selectedCategory != 'All') {
      resources = resources
          .where((r) => r.category == _selectedCategory)
          .toList();
    }
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      resources = resources.where((r) {
        return r.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            r.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            r.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));
      }).toList();
    }
    
    return resources;
  }

  /// Gets featured resources
  List<Resource> get _featuredResources {
    return _controller.allResources.where((r) => r.isFeatured).take(3).toList();
  }

  /// Handles resource access (download/open)
  Future<void> _accessResource(Resource resource) async {
    setState(() => _isLoading = true);
    
    try {
      await _controller.accessResource(resource.id);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening ${resource.title}...'),
          action: SnackBarAction(
            label: 'View',
            onPressed: () {
              // In a real app, this would open the resource
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error accessing resource: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Shows detailed resource information in a dialog
  void _showResourceDetails(Resource resource) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(resource.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(resource.description),
              const SizedBox(height: 16),
              _buildInfoRow('Type', resource.type),
              _buildInfoRow('Category', resource.category),
              if (resource.author != null)
                _buildInfoRow('Author', resource.author!),
              if (resource.fileFormat != null)
                _buildInfoRow('Format', resource.fileFormat!),
              if (resource.fileSize != null)
                _buildInfoRow('Size', resource.fileSizeFormatted),
              if (resource.estimatedTime != null)
                _buildInfoRow('Est. Time', resource.estimatedTimeFormatted),
              _buildInfoRow('Downloads', '${resource.downloadCount}'),
              if (resource.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: resource.tags.map((tag) {
                    return Chip(
                      label: Text(tag, style: const TextStyle(fontSize: 12)),
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _accessResource(resource);
            },
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resources'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadResources,
            tooltip: 'Refresh Resources',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search resources...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          
          // Category filter chips
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            height: 50,
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
          
          // Resources list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredResources.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.folder_open,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No resources found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadResources,
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            // Featured section
                            if (_searchQuery.isEmpty &&
                                _selectedCategory == 'All' &&
                                _featuredResources.isNotEmpty) ...[
                              Text(
                                'Featured Resources',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 12),
                              ..._featuredResources.map((resource) =>
                                  _buildResourceCard(resource, isFeatured: true)),
                              const SizedBox(height: 24),
                              Text(
                                'All Resources',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 12),
                            ],
                            
                            // All resources
                            ..._filteredResources.map((resource) =>
                                _buildResourceCard(resource)),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  /// Builds a resource card widget
  Widget _buildResourceCard(Resource resource, {bool isFeatured = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isFeatured ? 4 : 2,
      color: isFeatured ? Colors.amber[50] : null,
      child: InkWell(
        onTap: () => _showResourceDetails(resource),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Resource icon based on type
                  Icon(
                    _controller.getResourceIcon(resource.type),
                    color: Theme.of(context).primaryColor,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  
                  // Title and metadata
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resource.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          resource.type,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Featured badge
                  if (isFeatured)
                    const Chip(
                      label: Text('Featured', style: TextStyle(fontSize: 10)),
                      backgroundColor: Colors.amber,
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Description
              Text(
                resource.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 12),
              
              // Additional metadata
              Row(
                children: [
                  if (resource.isOfflineAvailable)
                    const Icon(Icons.offline_pin, size: 16, color: Colors.green),
                  if (resource.isOfflineAvailable) const SizedBox(width: 4),
                  if (resource.isOfflineAvailable)
                    const Text('Offline', style: TextStyle(fontSize: 12)),
                  
                  const Spacer(),
                  
                  Icon(Icons.download, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${resource.downloadCount}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  
                  if (resource.fileSize != null) ...[
                    const SizedBox(width: 16),
                    Text(
                      resource.fileSizeFormatted,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
