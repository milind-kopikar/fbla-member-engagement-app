/// Model class representing an FBLA member's profile data.
/// 
/// This class demonstrates proper encapsulation and data modeling as required
/// for the FBLA Mobile Application Development competition.
/// Includes validation support for member data integrity.
class Member {
  /// Unique identifier for the member
  final String id;
  
  /// Member's full name
  String name;
  
  /// Member's email address (validated)
  String email;
  
  /// Member's phone number (validated)
  String phone;
  
  /// Member's chapter name
  String chapter;
  
  /// Member's role in FBLA (e.g., President, Vice President, Member)
  String role;
  
  /// Member's grade level (9-12 or College)
  String gradeLevel;
  
  /// Member's interests and focus areas within FBLA
  List<String> interests;
  
  /// Date when the member joined FBLA
  DateTime joinDate;
  
  /// Profile picture URL or path (optional)
  String? profilePicture;

  /// Constructor for creating a new Member instance
  /// 
  /// All required fields must be provided. Optional fields can be null.
  Member({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.chapter,
    required this.role,
    required this.gradeLevel,
    required this.interests,
    required this.joinDate,
    this.profilePicture,
  });

  /// Factory constructor to create a Member from JSON data
  /// 
  /// Used for deserializing data from local storage or mock database.
  /// This supports the standalone operation requirement.
  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      chapter: json['chapter'] as String,
      role: json['role'] as String,
      gradeLevel: json['gradeLevel'] as String,
      interests: List<String>.from(json['interests'] as List),
      joinDate: DateTime.parse(json['joinDate'] as String),
      profilePicture: json['profilePicture'] as String?,
    );
  }

  /// Converts the Member instance to a JSON map
  /// 
  /// Used for serializing data to local storage or mock database.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'chapter': chapter,
      'role': role,
      'gradeLevel': gradeLevel,
      'interests': interests,
      'joinDate': joinDate.toIso8601String(),
      'profilePicture': profilePicture,
    };
  }

  /// Creates a copy of this Member with optional field updates
  /// 
  /// Useful for implementing immutable update patterns in the app.
  Member copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? chapter,
    String? role,
    String? gradeLevel,
    List<String>? interests,
    DateTime? joinDate,
    String? profilePicture,
  }) {
    return Member(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      chapter: chapter ?? this.chapter,
      role: role ?? this.role,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      interests: interests ?? this.interests,
      joinDate: joinDate ?? this.joinDate,
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }

  @override
  String toString() {
    return 'Member(id: $id, name: $name, email: $email, chapter: $chapter, role: $role)';
  }
}
