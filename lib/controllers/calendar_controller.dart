import 'package:flutter/material.dart';
import '../models/fbla_event.dart';
import '../services/local_data_service.dart';

/// CalendarController - Controller component for event calendar management
/// 
/// This controller demonstrates the Controller layer in the MVC pattern.
/// It manages the business logic for FBLA events including:
/// - Loading and filtering events
/// - Event registration handling
/// - Date and time formatting
/// - Category-based organization
class CalendarController {
  /// Data service instance for local data persistence
  final LocalDataService _dataService = LocalDataService();
  
  /// All loaded events
  List<FBLAEvent> allEvents = [];
  
  /// Currently logged-in member ID (hardcoded for demo)
  final String currentMemberId = 'member_1';

  /// Loads all events from the data service
  Future<void> loadEvents() async {
    allEvents = await _dataService.getEvents();
  }

  /// Gets all upcoming events (future events only)
  /// 
  /// Filters out past events and sorts by start date.
  List<FBLAEvent> get upcomingEvents {
    final now = DateTime.now();
    return allEvents
        .where((event) => event.startDate.isAfter(now))
        .toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
  }

  /// Gets events happening today
  List<FBLAEvent> get todayEvents {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    
    return allEvents.where((event) {
      return event.startDate.isAfter(today) &&
          event.startDate.isBefore(tomorrow);
    }).toList();
  }

  /// Gets events by category
  /// 
  /// Filters events based on the specified category.
  List<FBLAEvent> getEventsByCategory(String category) {
    return upcomingEvents
        .where((event) => event.category == category)
        .toList();
  }

  /// Gets competition events only
  List<FBLAEvent> get competitionEvents {
    return upcomingEvents
        .where((event) => event.isCompetition)
        .toList();
  }

  /// Registers the current member for an event
  /// 
  /// Validates that:
  /// - The event requires RSVP
  /// - The event is not full
  /// - The member is not already registered
  Future<void> registerForEvent(String eventId) async {
    final event = allEvents.firstWhere((e) => e.id == eventId);
    
    // Validation: Check if event requires RSVP
    if (!event.requiresRsvp) {
      throw Exception('This event does not require registration');
    }
    
    // Validation: Check if event is full
    if (event.isFull) {
      throw Exception('This event is at full capacity');
    }
    
    // Validation: Check if already registered
    if (event.registeredMemberIds.contains(currentMemberId)) {
      throw Exception('You are already registered for this event');
    }
    
    // Add member to registered list
    final updatedEvent = event.copyWith(
      registeredMemberIds: [...event.registeredMemberIds, currentMemberId],
    );
    
    // Update in data service
    await _dataService.updateEvent(updatedEvent);
    
    // Update local list
    final index = allEvents.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      allEvents[index] = updatedEvent;
    }
  }

  /// Unregisters the current member from an event
  Future<void> unregisterFromEvent(String eventId) async {
    final event = allEvents.firstWhere((e) => e.id == eventId);
    
    // Validation: Check if member is registered
    if (!event.registeredMemberIds.contains(currentMemberId)) {
      throw Exception('You are not registered for this event');
    }
    
    // Remove member from registered list
    final updatedEvent = event.copyWith(
      registeredMemberIds: event.registeredMemberIds
          .where((id) => id != currentMemberId)
          .toList(),
    );
    
    // Update in data service
    await _dataService.updateEvent(updatedEvent);
    
    // Update local list
    final index = allEvents.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      allEvents[index] = updatedEvent;
    }
  }

  /// Checks if the current member is registered for an event
  bool isRegistered(String eventId) {
    final event = allEvents.firstWhere((e) => e.id == eventId);
    return event.registeredMemberIds.contains(currentMemberId);
  }

  /// Formats an event's date in a user-friendly format
  /// 
  /// Example: "Monday, January 15, 2026"
  String formatEventDate(FBLAEvent event) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    
    final date = event.startDate;
    final dayOfWeek = days[(date.weekday - 1) % 7];
    final month = months[date.month - 1];
    
    return '$dayOfWeek, $month ${date.day}, ${date.year}';
  }

  /// Formats an event's time range
  /// 
  /// Example: "2:00 PM - 4:30 PM"
  String formatEventTime(FBLAEvent event) {
    return '${_formatTime(event.startDate)} - ${_formatTime(event.endDate)}';
  }

  /// Helper method to format a single time
  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    
    return '$hour:$minute $period';
  }

  /// Gets a color associated with an event category
  /// 
  /// Provides visual distinction between event types.
  Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'competition':
        return Colors.red.shade100;
      case 'meeting':
        return Colors.blue.shade100;
      case 'conference':
        return Colors.purple.shade100;
      case 'social':
        return Colors.green.shade100;
      case 'workshop':
        return Colors.orange.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  /// Gets an icon for an event category
  IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'competition':
        return Icons.emoji_events;
      case 'meeting':
        return Icons.group;
      case 'conference':
        return Icons.business_center;
      case 'social':
        return Icons.celebration;
      case 'workshop':
        return Icons.school;
      default:
        return Icons.event;
    }
  }

  /// Gets the number of days until an event
  int daysUntilEvent(FBLAEvent event) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(
      event.startDate.year,
      event.startDate.month,
      event.startDate.day,
    );
    
    return eventDay.difference(today).inDays;
  }

  /// Gets a human-readable countdown string for an event
  /// 
  /// Example: "In 5 days", "Tomorrow", "Today"
  String getEventCountdown(FBLAEvent event) {
    final days = daysUntilEvent(event);
    
    if (days == 0) {
      return 'Today';
    } else if (days == 1) {
      return 'Tomorrow';
    } else if (days < 7) {
      return 'In $days days';
    } else if (days < 14) {
      return 'Next week';
    } else if (days < 30) {
      final weeks = (days / 7).floor();
      return 'In $weeks ${weeks == 1 ? 'week' : 'weeks'}';
    } else {
      final months = (days / 30).floor();
      return 'In $months ${months == 1 ? 'month' : 'months'}';
    }
  }
}
