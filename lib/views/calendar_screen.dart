import 'package:flutter/material.dart';
import '../controllers/calendar_controller.dart';
import '../models/fbla_event.dart';
import '../widgets/custom_event_card.dart';

/// CalendarScreen - View component for displaying FBLA events and competitions
/// 
/// This screen demonstrates the View layer in the MVC pattern.
/// It displays a list of upcoming FBLA events, competitions, and meetings,
/// allowing members to stay informed and engaged with chapter activities.
/// 
/// Features:
/// - Display upcoming events in chronological order
/// - Filter events by category (All, Competitions, Meetings, etc.)
/// - Event registration/RSVP functionality
/// - Visual distinction for different event types
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  /// Controller instance to manage event data
  final CalendarController _controller = CalendarController();
  
  /// Loading state
  bool _isLoading = false;
  
  /// Currently selected filter category
  String _selectedFilter = 'All';
  
  /// Available filter options
  final List<String> _filterOptions = [
    'All',
    'Competition',
    'Meeting',
    'Conference',
    'Social',
    'Workshop',
  ];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  /// Loads events from the controller
  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    await _controller.loadEvents();
    setState(() => _isLoading = false);
  }

  /// Filters events based on the selected category
  List<FBLAEvent> get _filteredEvents {
    if (_selectedFilter == 'All') {
      return _controller.upcomingEvents;
    }
    return _controller.upcomingEvents
        .where((event) => event.category == _selectedFilter)
        .toList();
  }

  /// Handles event registration/RSVP
  Future<void> _registerForEvent(FBLAEvent event) async {
    setState(() => _isLoading = true);
    
    try {
      await _controller.registerForEvent(event.id);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully registered for ${event.title}!'),
          backgroundColor: Colors.green,
        ),
      );
      
      await _loadEvents();
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error registering for event: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Shows detailed event information in a bottom sheet
  void _showEventDetails(FBLAEvent event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event title with category badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      event.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  Chip(
                    label: Text(event.category),
                    backgroundColor: _controller.getCategoryColor(event.category),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Event details
              _buildDetailRow(Icons.calendar_today, 'Date', 
                  _controller.formatEventDate(event)),
              _buildDetailRow(Icons.access_time, 'Time', 
                  _controller.formatEventTime(event)),
              _buildDetailRow(Icons.location_on, 'Location', event.location),
              if (event.organizer != null)
                _buildDetailRow(Icons.person, 'Organizer', event.organizer!),
              
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              
              // Description
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(event.description),
              
              if (event.notes != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Additional Notes',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(event.notes!),
              ],
              
              const SizedBox(height: 24),
              
              // Registration info
              if (event.requiresRsvp) ...[
                Row(
                  children: [
                    Icon(Icons.people, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      '${event.registeredMemberIds.length} registered',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (event.maxParticipants != null) ...[
                      Text(
                        ' / ${event.maxParticipants} max',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
              ],
              
              // Register button
              if (event.requiresRsvp)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: event.isFull
                        ? null
                        : () {
                            Navigator.pop(context);
                            _registerForEvent(event);
                          },
                    child: Text(event.isFull ? 'Event Full' : 'Register for Event'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper widget to build detail rows
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Calendar'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEvents,
            tooltip: 'Refresh Events',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filterOptions.length,
              itemBuilder: (context, index) {
                final filter = _filterOptions[index];
                final isSelected = _selectedFilter == filter;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedFilter = filter);
                    },
                    selectedColor: Theme.of(context).primaryColor.withOpacity(0.3),
                  ),
                );
              },
            ),
          ),
          
          // Events list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredEvents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No events found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadEvents,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredEvents.length,
                          itemBuilder: (context, index) {
                            final event = _filteredEvents[index];
                            return CustomEventCard(
                              event: event,
                              onTap: () => _showEventDetails(event),
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
