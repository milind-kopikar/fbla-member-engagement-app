import 'package:flutter/material.dart';
import 'views/profile_screen.dart';
import 'views/calendar_screen.dart';
import 'views/news_feed_screen.dart';
import 'views/resources_screen.dart';

/// Main entry point for the FBLA Mobile Application
/// 
/// This app is designed for the 2025-2026 FBLA Mobile Application Development
/// competition with the topic "Design the Future of Member Engagement."
/// 
/// Architecture: Strict MVC (Model-View-Controller) Pattern
/// - Models: Data classes (Member, FBLAEvent, NewsItem, Resource)
/// - Views: UI screens (ProfileScreen, CalendarScreen, etc.)
/// - Controllers: Business logic and validation
/// - Services: Data persistence layer (LocalDataService)
/// 
/// Key Features:
/// - Member Profile Management with comprehensive validation
/// - Event Calendar for competitions and meetings
/// - News Feed for announcements and updates
/// - Resources section with FBLA documents and social media integration
/// - Fully functional offline (no internet required)
void main() {
  runApp(const FBLAMemberEngagementApp());
}

/// Root application widget
class FBLAMemberEngagementApp extends StatelessWidget {
  const FBLAMemberEngagementApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FBLA Member Engagement',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // FBLA brand colors: Blue and Gold
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          secondary: Colors.amber,
        ),
        useMaterial3: true,
        
        // Typography
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          headlineSmall: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        
        // Card theme for consistent styling
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        
        // Input decoration theme for forms
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        
        // Button themes
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

/// MainNavigationScreen - Primary navigation hub for the app
/// 
/// Uses a bottom navigation bar to provide quick access to all main features.
/// This follows mobile UX best practices for easy thumb navigation.
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  /// Current selected tab index
  int _currentIndex = 0;
  
  /// List of screens corresponding to navigation tabs
  final List<Widget> _screens = const [
    NewsFeedScreen(),
    CalendarScreen(),
    ResourcesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.article_outlined),
            selectedIcon: Icon(Icons.article),
            label: 'News',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder),
            label: 'Resources',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
