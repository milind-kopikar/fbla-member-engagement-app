import '../models/member.dart';
import '../models/fbla_event.dart';
import '../models/news_item.dart';
import '../models/resource.dart';

/// LocalDataService - Service layer for local data persistence
/// 
/// This service demonstrates a standalone data layer that doesn't require
/// internet connectivity, as required by FBLA competition guidelines.
/// 
/// In a production app, this would interface with:
/// - SQLite database for local persistence
/// - SharedPreferences for simple key-value storage
/// - File system for document storage
/// 
/// For this demo, it uses in-memory lists with mock data to simulate
/// a working database, ensuring the app runs completely offline.
/// 
/// Architecture Benefits:
/// - Separation of concerns (controllers don't handle data storage)
/// - Easy to swap with real database implementation later
/// - Testable and maintainable
/// - Demonstrates proper layered architecture for judges
class LocalDataService {
  /// Singleton instance to ensure consistent data across the app
  static final LocalDataService _instance = LocalDataService._internal();
  
  factory LocalDataService() {
    return _instance;
  }
  
  LocalDataService._internal() {
    _initializeMockData();
  }

  /// In-memory storage for members
  final List<Member> _members = [];
  
  /// In-memory storage for events
  final List<FBLAEvent> _events = [];
  
  /// In-memory storage for news items
  final List<NewsItem> _newsItems = [];
  
  /// In-memory storage for resources
  final List<Resource> _resources = [];

  /// Initializes the service with mock data
  /// 
  /// This simulates a pre-populated database and ensures the app
  /// has content to display without requiring API calls.
  void _initializeMockData() {
    if (_members.isEmpty) {
      _loadMockMembers();
      _loadMockEvents();
      _loadMockNews();
      _loadMockResources();
    }
  }

  /// Loads mock member data
  void _loadMockMembers() {
    _members.addAll([
      Member(
        id: 'member_1',
        name: 'Sarah Johnson',
        email: 'sarah.johnson@email.com',
        phone: '(555) 123-4567',
        chapter: 'Lincoln High School FBLA',
        role: 'President',
        gradeLevel: '12th Grade',
        interests: ['Leadership', 'Business Management', 'Public Speaking'],
        joinDate: DateTime(2023, 9, 1),
        profilePicture: null,
      ),
      Member(
        id: 'member_2',
        name: 'Michael Chen',
        email: 'michael.chen@email.com',
        phone: '(555) 234-5678',
        chapter: 'Lincoln High School FBLA',
        role: 'Vice President',
        gradeLevel: '11th Grade',
        interests: ['Finance', 'Economics', 'Entrepreneurship'],
        joinDate: DateTime(2024, 9, 1),
      ),
      Member(
        id: 'member_3',
        name: 'Emily Rodriguez',
        email: 'emily.r@email.com',
        phone: '(555) 345-6789',
        chapter: 'Lincoln High School FBLA',
        role: 'Secretary',
        gradeLevel: '10th Grade',
        interests: ['Marketing', 'Social Media', 'Event Planning'],
        joinDate: DateTime(2024, 9, 1),
      ),
    ]);
  }

  /// Loads mock event data
  void _loadMockEvents() {
    final now = DateTime.now();
    
    _events.addAll([
      FBLAEvent(
        id: 'event_1',
        title: 'Regional Leadership Conference',
        description: 'Join us for a day of leadership development, networking, and skill-building workshops. This conference brings together FBLA members from across the region to learn from industry professionals and develop essential business leadership skills.',
        startDate: now.add(const Duration(days: 15)),
        endDate: now.add(const Duration(days: 15, hours: 8)),
        location: 'Downtown Convention Center',
        category: 'Conference',
        isCompetition: false,
        requiresRsvp: true,
        maxParticipants: 200,
        organizer: 'State FBLA Office',
        notes: 'Lunch will be provided. Business casual attire recommended.',
        registeredMemberIds: ['member_2'],
      ),
      FBLAEvent(
        id: 'event_2',
        title: 'State Business Plan Competition',
        description: 'Compete with your innovative business ideas! Present your comprehensive business plan to a panel of judges including entrepreneurs and business executives. Top winners advance to nationals.',
        startDate: now.add(const Duration(days: 45)),
        endDate: now.add(const Duration(days: 45, hours: 6)),
        location: 'State Capitol Building',
        category: 'Competition',
        isCompetition: true,
        requiresRsvp: true,
        maxParticipants: 50,
        organizer: 'Competition Committee',
        notes: 'Teams of 1-3 members. Written plans due 2 weeks prior.',
        registeredMemberIds: ['member_1', 'member_2'],
      ),
      FBLAEvent(
        id: 'event_3',
        title: 'Chapter Officer Meeting',
        description: 'Monthly meeting for chapter officers to discuss upcoming events, budget, and member engagement strategies.',
        startDate: now.add(const Duration(days: 7)),
        endDate: now.add(const Duration(days: 7, hours: 2)),
        location: 'Room 215, Lincoln High School',
        category: 'Meeting',
        requiresRsvp: false,
        organizer: 'Sarah Johnson',
      ),
      FBLAEvent(
        id: 'event_4',
        title: 'Professional Networking Social',
        description: 'Network with local business professionals and alumni. Casual event with refreshments, perfect for building connections and learning about career opportunities.',
        startDate: now.add(const Duration(days: 30)),
        endDate: now.add(const Duration(days: 30, hours: 3)),
        location: 'City Business Park - Main Hall',
        category: 'Social',
        requiresRsvp: true,
        maxParticipants: 75,
        notes: 'Bring business cards if you have them!',
        registeredMemberIds: [],
      ),
      FBLAEvent(
        id: 'event_5',
        title: 'Public Speaking Workshop',
        description: 'Improve your presentation and public speaking skills with expert coaching. Interactive workshop covering speech writing, delivery techniques, and handling Q&A sessions.',
        startDate: now.add(const Duration(days: 21)),
        endDate: now.add(const Duration(days: 21, hours: 4)),
        location: 'Community College - Theater',
        category: 'Workshop',
        requiresRsvp: true,
        maxParticipants: 30,
        organizer: 'Dr. Amanda White',
        notes: 'Materials provided. Dress comfortably.',
        registeredMemberIds: ['member_3'],
      ),
    ]);
  }

  /// Loads mock news data
  void _loadMockNews() {
    final now = DateTime.now();
    
    _newsItems.addAll([
      NewsItem(
        id: 'news_1',
        title: 'Lincoln FBLA Wins National Championship!',
        summary: 'Our chapter took first place in the Business Plan competition at the National Leadership Conference.',
        content: '''
We are thrilled to announce that Lincoln High School FBLA has won the National Championship in the Business Plan competition! 

Our team, consisting of seniors Sarah Johnson and Michael Chen, presented their innovative sustainable fashion startup idea to a panel of distinguished judges at the National Leadership Conference in Atlanta.

The winning business plan, "EcoThreads," proposes a clothing rental subscription service focused on sustainable and ethically-sourced fashion. The judges praised the comprehensive market analysis, innovative revenue model, and strong commitment to environmental responsibility.

"This victory is the result of months of hard work, research, and dedication," said Sarah Johnson, team leader. "We're honored to represent our chapter and our school at the national level."

The team will receive a $5,000 scholarship and mentoring from successful entrepreneurs. Congratulations to our champions!
        ''',
        author: 'Lincoln FBLA Communications Team',
        publishedDate: now.subtract(const Duration(days: 2)),
        category: 'Achievement',
        tags: ['Competition', 'National', 'Business Plan', 'Award'],
        isPinned: true,
        priority: 5,
        viewCount: 127,
        likedByMemberIds: ['member_2', 'member_3'],
      ),
      NewsItem(
        id: 'news_2',
        title: 'Upcoming Regional Conference Registration Now Open',
        summary: 'Register now for the Regional Leadership Conference on March 15th. Early bird pricing ends next week!',
        content: '''
The Regional Leadership Conference is just around the corner, and we're excited to invite all members to participate in this incredible opportunity for growth and networking.

Conference Highlights:
• Keynote speech from Fortune 500 CEO Jennifer Martinez
• 15+ workshop sessions on leadership, entrepreneurship, and career development
• Networking lunch with local business professionals
• Awards ceremony recognizing chapter achievements
• College and career fair

Early Bird Special: Register by next Friday to save \$20 on admission. The conference fee includes all workshop materials, lunch, and a conference t-shirt.

Don't miss this chance to connect with FBLA members from across the region and gain valuable skills for your future career!

Visit our chapter website to register today.
        ''',
        author: 'Events Committee',
        publishedDate: now.subtract(const Duration(days: 5)),
        category: 'Announcement',
        tags: ['Conference', 'Registration', 'Leadership'],
        isPinned: true,
        priority: 4,
        viewCount: 89,
        likedByMemberIds: ['member_1'],
      ),
      NewsItem(
        id: 'news_3',
        title: 'Member Spotlight: Emily Rodriguez',
        summary: 'Get to know our outstanding member who is making a difference through her community service project.',
        content: '''
This month's member spotlight features Emily Rodriguez, a sophomore who has demonstrated exceptional leadership and commitment to community service.

Emily recently launched "Business Basics for Youth," a free program teaching elementary students fundamental business concepts through fun, interactive activities. The program has already reached over 50 students across three local elementary schools.

"I wanted to share my passion for business with younger students and show them that entrepreneurship can be fun and accessible," Emily explained. "Seeing their excitement when they create their first business plan or learn about marketing is incredibly rewarding."

Her initiative has garnered attention from local media and earned her the Community Service Award from our chapter. Emily plans to expand the program to more schools next semester.

Thank you, Emily, for representing FBLA values and inspiring the next generation of business leaders!
        ''',
        author: 'Sarah Johnson',
        publishedDate: now.subtract(const Duration(days: 10)),
        category: 'Chapter News',
        tags: ['Member Spotlight', 'Community Service', 'Education'],
        priority: 3,
        viewCount: 64,
        likedByMemberIds: ['member_1', 'member_2', 'member_3'],
      ),
      NewsItem(
        id: 'news_4',
        title: 'Competition Prep Sessions Starting Next Week',
        summary: 'Join our weekly competition preparation sessions to sharpen your skills and get ready for state competitions.',
        content: '''
Attention all members interested in competing at the state level! We're launching weekly competition prep sessions starting next Tuesday.

Sessions will cover:
• Business Plan Development
• Parliamentary Procedure
• Public Speaking and Presentation Skills
• Accounting and Financial Analysis
• Marketing and Social Media Strategy

Each session runs from 3:30-5:00 PM in the library. Led by experienced members who have competed at state and national levels, these sessions are designed to give you the tools and confidence you need to succeed.

Whether you're a first-time competitor or a seasoned participant, everyone is welcome. No prior experience necessary!

See you there!
        ''',
        author: 'Competition Committee',
        publishedDate: now.subtract(const Duration(days: 3)),
        category: 'Announcement',
        tags: ['Competition', 'Training', 'Skills Development'],
        priority: 4,
        viewCount: 52,
        likedByMemberIds: [],
      ),
      NewsItem(
        id: 'news_5',
        title: 'Successful Fundraiser Recap: Business Expo Night',
        summary: 'Our chapter raised $3,500 at the annual Business Expo Night. Thank you to everyone who participated!',
        content: '''
What an amazing turnout for our annual Business Expo Night! Thanks to the hard work of our members and support from the community, we raised $3,500 to fund chapter activities and competition travel.

The event featured:
• 20+ student-run business booths showcasing products and services
• Food trucks and live entertainment
• Raffle prizes donated by local businesses
• Professional networking opportunities

Special thanks to our sponsors: Downtown Chamber of Commerce, Smith & Associates, and TechStart Inc. Your support makes our programs possible.

The funds raised will support:
• Travel to state and national conferences
• Competition registration fees
• Leadership training materials
• Community service projects

Thank you to everyone who attended, volunteered, and supported our event. Your engagement makes our chapter thrive!
        ''',
        author: 'Fundraising Team',
        publishedDate: now.subtract(const Duration(days: 15)),
        category: 'Event Recap',
        tags: ['Fundraiser', 'Community', 'Success'],
        priority: 2,
        viewCount: 78,
        likedByMemberIds: ['member_2'],
      ),
    ]);
  }

  /// Loads mock resource data
  void _loadMockResources() {
    final now = DateTime.now();
    
    _resources.addAll([
      Resource(
        id: 'resource_1',
        title: 'FBLA Competitive Events Guide 2025-2026',
        description: 'Comprehensive guide covering all competitive events, rules, and judging criteria for this year\'s competitions.',
        type: 'Document',
        category: 'Competition Prep',
        url: 'https://fbla.org/competitive-events-guide.pdf',
        fileFormat: 'PDF',
        fileSize: 2457600, // ~2.4 MB
        dateAdded: now.subtract(const Duration(days: 30)),
        tags: ['Competition', 'Rules', 'Official'],
        isFeatured: true,
        downloadCount: 45,
        isOfflineAvailable: true,
        author: 'FBLA National',
        estimatedTime: 30,
      ),
      Resource(
        id: 'resource_2',
        title: 'Business Plan Template',
        description: 'Professional business plan template with sections for executive summary, market analysis, financial projections, and more.',
        type: 'Document',
        category: 'Competition Prep',
        url: 'https://fbla.org/business-plan-template.docx',
        fileFormat: 'DOCX',
        fileSize: 156800, // ~157 KB
        dateAdded: now.subtract(const Duration(days: 45)),
        tags: ['Business Plan', 'Template', 'Competition'],
        isFeatured: true,
        downloadCount: 67,
        isOfflineAvailable: true,
        estimatedTime: 120,
      ),
      Resource(
        id: 'resource_3',
        title: 'Leadership Skills Workshop Video',
        description: 'Recording of the national leadership workshop covering effective communication, team building, and decision making.',
        type: 'Video',
        category: 'Leadership',
        url: 'https://youtube.com/watch?v=example123',
        fileFormat: 'MP4',
        dateAdded: now.subtract(const Duration(days: 20)),
        tags: ['Leadership', 'Workshop', 'Video'],
        downloadCount: 23,
        author: 'FBLA National Speakers',
        estimatedTime: 45,
      ),
      Resource(
        id: 'resource_4',
        title: 'FBLA National Facebook Page',
        description: 'Stay connected with FBLA members nationwide. Get updates on events, competitions, and success stories.',
        type: 'Social Media',
        category: 'Social Media',
        url: 'https://facebook.com/fbla',
        dateAdded: now.subtract(const Duration(days: 365)),
        tags: ['Social Media', 'Facebook', 'Community'],
        isFeatured: false,
        downloadCount: 156,
      ),
      Resource(
        id: 'resource_5',
        title: 'FBLA Official Instagram',
        description: 'Follow @fbla_national for daily inspiration, member spotlights, and behind-the-scenes content from conferences.',
        type: 'Social Media',
        category: 'Social Media',
        url: 'https://instagram.com/fbla_national',
        dateAdded: now.subtract(const Duration(days: 365)),
        tags: ['Social Media', 'Instagram', 'Updates'],
        downloadCount: 142,
      ),
      Resource(
        id: 'resource_6',
        title: 'Elevator Pitch Guide',
        description: 'Learn how to craft and deliver a compelling 30-second elevator pitch. Includes examples and practice exercises.',
        type: 'Guide',
        category: 'Business',
        url: 'https://fbla.org/elevator-pitch-guide.pdf',
        fileFormat: 'PDF',
        fileSize: 524288, // 512 KB
        dateAdded: now.subtract(const Duration(days: 60)),
        tags: ['Public Speaking', 'Networking', 'Guide'],
        downloadCount: 34,
        isOfflineAvailable: true,
        estimatedTime: 15,
      ),
      Resource(
        id: 'resource_7',
        title: 'Financial Literacy Handbook',
        description: 'Essential financial concepts for business students including budgeting, investing, and financial statement analysis.',
        type: 'Document',
        category: 'Business',
        url: 'https://fbla.org/financial-literacy.pdf',
        fileFormat: 'PDF',
        fileSize: 3145728, // 3 MB
        dateAdded: now.subtract(const Duration(days: 90)),
        tags: ['Finance', 'Education', 'Business'],
        isFeatured: true,
        downloadCount: 51,
        isOfflineAvailable: true,
        author: 'Business Education Foundation',
        estimatedTime: 60,
      ),
      Resource(
        id: 'resource_8',
        title: 'Chapter Management Best Practices',
        description: 'Guide for chapter officers on effective chapter management, member engagement, and event planning.',
        type: 'Guide',
        category: 'Chapter Management',
        url: 'https://fbla.org/chapter-management.pdf',
        fileFormat: 'PDF',
        fileSize: 1048576, // 1 MB
        dateAdded: now.subtract(const Duration(days: 15)),
        tags: ['Leadership', 'Chapter', 'Officers'],
        downloadCount: 28,
        isOfflineAvailable: true,
        estimatedTime: 45,
      ),
      Resource(
        id: 'resource_9',
        title: 'Marketing Fundamentals Presentation',
        description: 'Comprehensive presentation covering the 4 Ps of marketing, target audience analysis, and digital marketing strategies.',
        type: 'Presentation',
        category: 'Business',
        url: 'https://fbla.org/marketing-fundamentals.pptx',
        fileFormat: 'PPTX',
        fileSize: 2097152, // 2 MB
        dateAdded: now.subtract(const Duration(days: 50)),
        tags: ['Marketing', 'Business', 'Education'],
        downloadCount: 39,
        estimatedTime: 30,
      ),
      Resource(
        id: 'resource_10',
        title: 'FBLA LinkedIn Group',
        description: 'Professional networking group for FBLA members and alumni. Share opportunities, ask questions, and build your network.',
        type: 'Social Media',
        category: 'Social Media',
        url: 'https://linkedin.com/groups/fbla',
        dateAdded: now.subtract(const Duration(days: 365)),
        tags: ['Social Media', 'LinkedIn', 'Networking'],
        downloadCount: 87,
      ),
    ]);
  }

  // ==================== Member Operations ====================

  /// Retrieves all members
  Future<List<Member>> getMembers() async {
    // Simulate async database call
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_members);
  }

  /// Retrieves a specific member by ID
  Future<Member?> getMemberById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _members.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Updates an existing member
  Future<void> updateMember(Member member) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _members.indexWhere((m) => m.id == member.id);
    if (index != -1) {
      _members[index] = member;
    }
  }

  /// Adds a new member
  Future<void> addMember(Member member) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _members.add(member);
  }

  // ==================== Event Operations ====================

  /// Retrieves all events
  Future<List<FBLAEvent>> getEvents() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_events);
  }

  /// Retrieves a specific event by ID
  Future<FBLAEvent?> getEventById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _events.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Updates an existing event
  Future<void> updateEvent(FBLAEvent event) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      _events[index] = event;
    }
  }

  /// Adds a new event
  Future<void> addEvent(FBLAEvent event) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _events.add(event);
  }

  // ==================== News Operations ====================

  /// Retrieves all news items
  Future<List<NewsItem>> getNews() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_newsItems);
  }

  /// Retrieves a specific news item by ID
  Future<NewsItem?> getNewsById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _newsItems.firstWhere((n) => n.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Updates an existing news item
  Future<void> updateNewsItem(NewsItem newsItem) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _newsItems.indexWhere((n) => n.id == newsItem.id);
    if (index != -1) {
      _newsItems[index] = newsItem;
    }
  }

  /// Adds a new news item
  Future<void> addNewsItem(NewsItem newsItem) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _newsItems.add(newsItem);
  }

  // ==================== Resource Operations ====================

  /// Retrieves all resources
  Future<List<Resource>> getResources() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_resources);
  }

  /// Retrieves a specific resource by ID
  Future<Resource?> getResourceById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _resources.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Updates an existing resource
  Future<void> updateResource(Resource resource) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _resources.indexWhere((r) => r.id == resource.id);
    if (index != -1) {
      _resources[index] = resource;
    }
  }

  /// Adds a new resource
  Future<void> addResource(Resource resource) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _resources.add(resource);
  }

  // ==================== Utility Methods ====================

  /// Clears all data (useful for testing or reset functionality)
  Future<void> clearAllData() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _members.clear();
    _events.clear();
    _newsItems.clear();
    _resources.clear();
  }

  /// Resets data to initial mock state
  Future<void> resetToMockData() async {
    await clearAllData();
    _initializeMockData();
  }
}
