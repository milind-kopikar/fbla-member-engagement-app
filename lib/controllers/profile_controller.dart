import '../models/member.dart';
import '../services/local_data_service.dart';

/// ProfileController - Controller component for member profile management
/// 
/// This controller demonstrates the Controller layer in the MVC pattern.
/// It manages the business logic for member profile data, including:
/// - Data validation (syntactical and semantic)
/// - Communication with the data service layer
/// - Profile update operations
/// 
/// Validation Requirements (FBLA Competition):
/// - Syntactical validation: Checks format and structure of input
/// - Semantic validation: Checks meaning and context of input
class ProfileController {
  /// Data service instance for local data persistence
  final LocalDataService _dataService = LocalDataService();
  
  /// Currently loaded member profile
  Member? currentMember;
  
  /// Available role options for FBLA members
  final List<String> roleOptions = [
    'President',
    'Vice President',
    'Secretary',
    'Treasurer',
    'Historian',
    'Reporter',
    'Parliamentarian',
    'Member',
  ];
  
  /// Available grade level options
  final List<String> gradeLevelOptions = [
    '9th Grade',
    '10th Grade',
    '11th Grade',
    '12th Grade',
    'College',
  ];

  /// Loads the current member's profile data
  /// 
  /// In a real application, this would identify the logged-in user.
  /// For this demo, we load the first member from the service.
  Future<void> loadCurrentMember() async {
    final members = await _dataService.getMembers();
    if (members.isNotEmpty) {
      currentMember = members.first;
    }
  }

  /// Updates the member's profile with new information
  /// 
  /// Validates all inputs before saving to ensure data integrity.
  /// Throws an exception if validation fails.
  Future<void> updateMemberProfile({
    required String name,
    required String email,
    required String phone,
    required String chapter,
    required String role,
    required String gradeLevel,
  }) async {
    // Perform validation before updating
    final nameError = validateName(name);
    if (nameError != null) throw Exception(nameError);
    
    final emailError = validateEmail(email);
    if (emailError != null) throw Exception(emailError);
    
    final phoneError = validatePhone(phone);
    if (phoneError != null) throw Exception(phoneError);
    
    final chapterError = validateChapter(chapter);
    if (chapterError != null) throw Exception(chapterError);

    // Create updated member object
    if (currentMember != null) {
      currentMember = currentMember!.copyWith(
        name: name,
        email: email,
        phone: phone,
        chapter: chapter,
        role: role,
        gradeLevel: gradeLevel,
      );
      
      // Save to data service
      await _dataService.updateMember(currentMember!);
    }
  }

  /// Validates the member's name
  /// 
  /// Syntactical validation: Checks for proper format
  /// Semantic validation: Ensures name is meaningful
  /// 
  /// Returns null if valid, error message if invalid.
  String? validateName(String? value) {
    // Syntactical validation: Check if empty
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    
    // Syntactical validation: Check minimum length
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    // Syntactical validation: Check for valid characters (letters, spaces, hyphens, apostrophes)
    final nameRegex = RegExp(r"^[a-zA-Z\s\-']+$");
    if (!nameRegex.hasMatch(value)) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }
    
    // Semantic validation: Ensure it's not just whitespace or special characters
    if (value.trim().replaceAll(RegExp(r'[\s\-\']'), '').isEmpty) {
      return 'Please enter a valid name';
    }
    
    // Semantic validation: Check for reasonable name length
    if (value.length > 100) {
      return 'Name is too long (maximum 100 characters)';
    }
    
    return null;
  }

  /// Validates the member's email address
  /// 
  /// Syntactical validation: Checks email format and structure
  /// Semantic validation: Verifies it's a valid email domain
  /// 
  /// Returns null if valid, error message if invalid.
  String? validateEmail(String? value) {
    // Syntactical validation: Check if empty
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    
    // Syntactical validation: Check email format using regex
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    
    // Semantic validation: Check for common typos in domain
    final lowercaseEmail = value.toLowerCase();
    final commonTypos = {
      'gmial.com': 'gmail.com',
      'gmai.com': 'gmail.com',
      'yahooo.com': 'yahoo.com',
      'yaho.com': 'yahoo.com',
      'outlok.com': 'outlook.com',
    };
    
    for (final typo in commonTypos.keys) {
      if (lowercaseEmail.endsWith(typo)) {
        return 'Did you mean ${commonTypos[typo]}?';
      }
    }
    
    // Semantic validation: Check for reasonable length
    if (value.length > 254) {
      return 'Email address is too long';
    }
    
    // Semantic validation: Ensure local part isn't too long
    final parts = value.split('@');
    if (parts[0].length > 64) {
      return 'Email address local part is too long';
    }
    
    return null;
  }

  /// Validates the member's phone number
  /// 
  /// Syntactical validation: Checks phone number format
  /// Semantic validation: Verifies it's a valid US phone number
  /// 
  /// Returns null if valid, error message if invalid.
  String? validatePhone(String? value) {
    // Syntactical validation: Check if empty
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove all non-digit characters for validation
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    
    // Syntactical validation: Check for correct number of digits (US format)
    if (digitsOnly.length != 10) {
      return 'Phone number must be 10 digits';
    }
    
    // Semantic validation: Check if area code is valid (not starting with 0 or 1)
    if (digitsOnly[0] == '0' || digitsOnly[0] == '1') {
      return 'Area code cannot start with 0 or 1';
    }
    
    // Semantic validation: Check for invalid patterns (all same digit)
    if (RegExp(r'^(\d)\1{9}$').hasMatch(digitsOnly)) {
      return 'Please enter a valid phone number';
    }
    
    // Semantic validation: Check for sequential numbers
    if (digitsOnly == '1234567890' || digitsOnly == '0123456789') {
      return 'Please enter a valid phone number';
    }
    
    // Syntactical validation: Verify format matches (XXX) XXX-XXXX pattern if formatted
    if (value.contains('(') || value.contains(')') || value.contains('-')) {
      final formattedRegex = RegExp(r'^\(\d{3}\)\s?\d{3}-\d{4}$');
      if (!formattedRegex.hasMatch(value)) {
        return 'Use format: (XXX) XXX-XXXX';
      }
    }
    
    return null;
  }

  /// Validates the chapter name
  /// 
  /// Syntactical validation: Checks for proper format
  /// Semantic validation: Ensures chapter name is meaningful
  /// 
  /// Returns null if valid, error message if invalid.
  String? validateChapter(String? value) {
    // Syntactical validation: Check if empty
    if (value == null || value.trim().isEmpty) {
      return 'Chapter name is required';
    }
    
    // Syntactical validation: Check minimum length
    if (value.trim().length < 3) {
      return 'Chapter name must be at least 3 characters';
    }
    
    // Semantic validation: Check for reasonable maximum length
    if (value.length > 100) {
      return 'Chapter name is too long (maximum 100 characters)';
    }
    
    // Syntactical validation: Must contain at least one letter
    if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
      return 'Chapter name must contain letters';
    }
    
    return null;
  }

  /// Formats a phone number to the standard (XXX) XXX-XXXX format
  /// 
  /// Utility method for consistent phone number display.
  String formatPhoneNumber(String phone) {
    final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length != 10) return phone;
    
    return '(${digitsOnly.substring(0, 3)}) ${digitsOnly.substring(3, 6)}-${digitsOnly.substring(6)}';
  }
}
