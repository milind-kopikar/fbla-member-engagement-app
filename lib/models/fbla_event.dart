/// Model class representing an FBLA event or competition.
/// 
/// This class encapsulates all data related to FBLA events, competitions,
/// meetings, and other calendar items. Designed to support the Event Calendar
/// feature requirement for member engagement.
class FBLAEvent {
  /// Unique identifier for the event
  final String id;
  
  /// Event title/name
  String title;
  
  /// Detailed description of the event
  String description;
  
  /// Event start date and time
  DateTime startDate;
  
  /// Event end date and time
  DateTime endDate;
  
  /// Physical or virtual location of the event
  String location;
  
  /// Category of the event (e.g., Competition, Meeting, Conference, Social)
  String category;
  
  /// Whether the event is a competition
  bool isCompetition;
  
  /// List of members registered for the event
  List<String> registeredMemberIds;
  
  /// Maximum number of participants (null if unlimited)
  int? maxParticipants;
  
  /// Contact person for the event
  String? organizer;
  
  /// Additional notes or requirements for the event
  String? notes;
  
  /// Whether the event requires RSVP
  bool requiresRsvp;

  /// Constructor for creating a new FBLAEvent instance
  FBLAEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.category,
    this.isCompetition = false,
    this.registeredMemberIds = const [],
    this.maxParticipants,
    this.organizer,
    this.notes,
    this.requiresRsvp = false,
  });

  /// Factory constructor to create an FBLAEvent from JSON data
  /// 
  /// Supports deserialization from the LocalDataService mock database.
  factory FBLAEvent.fromJson(Map<String, dynamic> json) {
    return FBLAEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      location: json['location'] as String,
      category: json['category'] as String,
      isCompetition: json['isCompetition'] as bool? ?? false,
      registeredMemberIds: json['registeredMemberIds'] != null
          ? List<String>.from(json['registeredMemberIds'] as List)
          : [],
      maxParticipants: json['maxParticipants'] as int?,
      organizer: json['organizer'] as String?,
      notes: json['notes'] as String?,
      requiresRsvp: json['requiresRsvp'] as bool? ?? false,
    );
  }

  /// Converts the FBLAEvent instance to a JSON map
  /// 
  /// Used for serializing data to the LocalDataService.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'location': location,
      'category': category,
      'isCompetition': isCompetition,
      'registeredMemberIds': registeredMemberIds,
      'maxParticipants': maxParticipants,
      'organizer': organizer,
      'notes': notes,
      'requiresRsvp': requiresRsvp,
    };
  }

  /// Checks if the event is currently happening
  bool get isOngoing {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  /// Checks if the event is in the future
  bool get isUpcoming {
    return DateTime.now().isBefore(startDate);
  }

  /// Checks if the event has passed
  bool get isPast {
    return DateTime.now().isAfter(endDate);
  }

  /// Checks if the event is at full capacity
  bool get isFull {
    if (maxParticipants == null) return false;
    return registeredMemberIds.length >= maxParticipants!;
  }

  /// Gets the duration of the event in hours
  double get durationInHours {
    return endDate.difference(startDate).inMinutes / 60.0;
  }

  /// Creates a copy of this FBLAEvent with optional field updates
  FBLAEvent copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    String? category,
    bool? isCompetition,
    List<String>? registeredMemberIds,
    int? maxParticipants,
    String? organizer,
    String? notes,
    bool? requiresRsvp,
  }) {
    return FBLAEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      category: category ?? this.category,
      isCompetition: isCompetition ?? this.isCompetition,
      registeredMemberIds: registeredMemberIds ?? this.registeredMemberIds,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      organizer: organizer ?? this.organizer,
      notes: notes ?? this.notes,
      requiresRsvp: requiresRsvp ?? this.requiresRsvp,
    );
  }

  @override
  String toString() {
    return 'FBLAEvent(id: $id, title: $title, startDate: $startDate, category: $category)';
  }
}
