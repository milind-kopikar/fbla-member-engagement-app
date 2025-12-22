import 'package:flutter/material.dart';
import '../models/fbla_event.dart';
import '../controllers/calendar_controller.dart';

/// CustomEventCard - Reusable widget for displaying event information
/// 
/// This widget demonstrates proper component design and reusability,
/// a key requirement for the FBLA competition's emphasis on modularity.
/// 
/// Features:
/// - Clean, consistent event presentation
/// - Visual indicators for event status and category
/// - Tap handling for detailed views
/// - Responsive design that adapts to content
/// 
/// Usage:
/// ```dart
/// CustomEventCard(
///   event: myEvent,
///   onTap: () => showEventDetails(myEvent),
/// )
/// ```
class CustomEventCard extends StatelessWidget {
  /// The event to display
  final FBLAEvent event;
  
  /// Callback when the card is tapped
  final VoidCallback? onTap;
  
  /// Optional controller for additional functionality
  final CalendarController? controller;
  
  /// Whether to show a compact version of the card
  final bool compact;

  const CustomEventCard({
    Key? key,
    required this.event,
    this.onTap,
    this.controller,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ctrl = controller ?? CalendarController();
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: event.isCompetition
              ? Colors.red.shade200
              : Colors.grey.shade200,
          width: event.isCompetition ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: compact ? _buildCompactContent(ctrl) : _buildFullContent(ctrl),
        ),
      ),
    );
  }

  /// Builds the full card content with all details
  Widget _buildFullContent(CalendarController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row with category badge and countdown
        Row(
          children: [
            // Category icon and badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: ctrl.getCategoryColor(event.category),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    ctrl.getCategoryIcon(event.category),
                    size: 16,
                    color: Colors.black87,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    event.category,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Countdown chip
            Chip(
              label: Text(
                ctrl.getEventCountdown(event),
                style: const TextStyle(fontSize: 11),
              ),
              visualDensity: VisualDensity.compact,
              backgroundColor: Colors.blue.shade50,
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Event title
        Text(
          event.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Event description (truncated)
        Text(
          event.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.grey[700],
            height: 1.4,
          ),
        ),
        
        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 12),
        
        // Event metadata row
        Row(
          children: [
            // Date and time
            Expanded(
              child: _buildInfoItem(
                Icons.calendar_today,
                ctrl.formatEventDate(event),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Location
        _buildInfoItem(Icons.location_on, event.location),
        
        // Registration info if applicable
        if (event.requiresRsvp) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.people,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                '${event.registeredMemberIds.length} registered',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
              ),
              if (event.maxParticipants != null) ...[
                Text(
                  ' / ${event.maxParticipants}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 8),
                if (event.isFull)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'FULL',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ],
        
        // Competition badge if applicable
        if (event.isCompetition)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.red.shade300),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.emoji_events,
                    size: 14,
                    color: Colors.red,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'COMPETITION',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// Builds a compact version of the card for list views
  Widget _buildCompactContent(CalendarController ctrl) {
    return Row(
      children: [
        // Category icon
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ctrl.getCategoryColor(event.category),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            ctrl.getCategoryIcon(event.category),
            size: 24,
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Event info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                ctrl.getEventCountdown(event),
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        
        // Arrow indicator
        Icon(
          Icons.chevron_right,
          color: Colors.grey[400],
        ),
      ],
    );
  }

  /// Helper widget to build info items with icons
  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }
}
