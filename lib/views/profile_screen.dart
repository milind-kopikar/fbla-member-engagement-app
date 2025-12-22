import 'package:flutter/material.dart';
import '../controllers/profile_controller.dart';
import '../models/member.dart';

/// ProfileScreen - View component for member profile management
/// 
/// This screen demonstrates the View layer in the MVC pattern.
/// It displays the member's profile information and provides a form
/// for editing profile details with comprehensive input validation.
/// 
/// Features:
/// - Display current member information
/// - Edit profile with validated input fields
/// - Syntactical and semantic validation (as required for FBLA competition)
/// - Clean separation between UI and business logic
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  /// Controller instance to manage profile data and validation
  final ProfileController _controller = ProfileController();
  
  /// Form key for validation
  final _formKey = GlobalKey<FormState>();
  
  /// Text editing controllers for form fields
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _chapterController;
  
  /// Currently selected values for dropdowns
  String? _selectedRole;
  String? _selectedGradeLevel;
  
  /// Loading state
  bool _isLoading = false;
  
  /// Edit mode flag
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _loadMemberData();
  }

  /// Loads the current member's profile data from the controller
  Future<void> _loadMemberData() async {
    setState(() => _isLoading = true);
    
    await _controller.loadCurrentMember();
    
    final member = _controller.currentMember;
    if (member != null) {
      _nameController = TextEditingController(text: member.name);
      _emailController = TextEditingController(text: member.email);
      _phoneController = TextEditingController(text: member.phone);
      _chapterController = TextEditingController(text: member.chapter);
      _selectedRole = member.role;
      _selectedGradeLevel = member.gradeLevel;
    } else {
      _nameController = TextEditingController();
      _emailController = TextEditingController();
      _phoneController = TextEditingController();
      _chapterController = TextEditingController();
    }
    
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _chapterController.dispose();
    super.dispose();
  }

  /// Handles form submission with validation
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _controller.updateMemberProfile(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        chapter: _chapterController.text,
        role: _selectedRole!,
        gradeLevel: _selectedGradeLevel!,
      );

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      setState(() => _isEditMode = false);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (!_isEditMode)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditMode = true),
              tooltip: 'Edit Profile',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _controller.currentMember == null
              ? const Center(child: Text('No profile data available'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Picture Section
                        Center(
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.blue.shade100,
                                child: Text(
                                  _controller.currentMember!.name.isNotEmpty
                                      ? _controller.currentMember!.name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (_isEditMode)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: CircleAvatar(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    radius: 20,
                                    child: const Icon(
                                      Icons.camera_alt,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Name Field with syntactical validation
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                          enabled: _isEditMode,
                          validator: _controller.validateName,
                        ),
                        const SizedBox(height: 16),
                        
                        // Email Field with syntactical and semantic validation
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email Address',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                          ),
                          enabled: _isEditMode,
                          keyboardType: TextInputType.emailAddress,
                          validator: _controller.validateEmail,
                        ),
                        const SizedBox(height: 16),
                        
                        // Phone Field with syntactical and semantic validation
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            prefixIcon: Icon(Icons.phone),
                            border: OutlineInputBorder(),
                            helperText: 'Format: (XXX) XXX-XXXX',
                          ),
                          enabled: _isEditMode,
                          keyboardType: TextInputType.phone,
                          validator: _controller.validatePhone,
                        ),
                        const SizedBox(height: 16),
                        
                        // Chapter Field
                        TextFormField(
                          controller: _chapterController,
                          decoration: const InputDecoration(
                            labelText: 'FBLA Chapter',
                            prefixIcon: Icon(Icons.school),
                            border: OutlineInputBorder(),
                          ),
                          enabled: _isEditMode,
                          validator: _controller.validateChapter,
                        ),
                        const SizedBox(height: 16),
                        
                        // Role Dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedRole,
                          decoration: const InputDecoration(
                            labelText: 'Role',
                            prefixIcon: Icon(Icons.badge),
                            border: OutlineInputBorder(),
                          ),
                          items: _controller.roleOptions.map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(role),
                            );
                          }).toList(),
                          onChanged: _isEditMode
                              ? (value) => setState(() => _selectedRole = value)
                              : null,
                          validator: (value) =>
                              value == null ? 'Please select a role' : null,
                        ),
                        const SizedBox(height: 16),
                        
                        // Grade Level Dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedGradeLevel,
                          decoration: const InputDecoration(
                            labelText: 'Grade Level',
                            prefixIcon: Icon(Icons.grade),
                            border: OutlineInputBorder(),
                          ),
                          items: _controller.gradeLevelOptions.map((grade) {
                            return DropdownMenuItem(
                              value: grade,
                              child: Text(grade),
                            );
                          }).toList(),
                          onChanged: _isEditMode
                              ? (value) => setState(() => _selectedGradeLevel = value)
                              : null,
                          validator: (value) =>
                              value == null ? 'Please select a grade level' : null,
                        ),
                        const SizedBox(height: 32),
                        
                        // Action Buttons
                        if (_isEditMode)
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _saveProfile,
                                  child: const Text('Save Changes'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () {
                                          _loadMemberData();
                                          setState(() => _isEditMode = false);
                                        },
                                  child: const Text('Cancel'),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
