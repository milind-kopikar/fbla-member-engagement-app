# FBLA Member Engagement App
### 2025-2026 FBLA Mobile Application Development Competition

**Topic:** "Design the Future of Member Engagement"

---

## 📱 Project Overview

This Flutter application is designed to help FBLA (Future Business Leaders of America) students stay connected, informed, and engaged with their chapter activities. The app provides a comprehensive platform for member management, event coordination, news distribution, and resource sharing—all in a clean, professional mobile interface.

### Key Features
- **Member Profile Management**: Secure profile editing with comprehensive validation
- **Event Calendar**: View and register for competitions, meetings, and conferences
- **News Feed**: Stay updated with announcements, achievements, and chapter news
- **Resources Hub**: Access FBLA documents, guides, and social media channels
- **100% Offline Functionality**: No internet connection required

---

## 🏗️ Architecture: MVC Pattern

This application implements a **strict MVC (Model-View-Controller)** architectural pattern to demonstrate expert use of classes, modules, and architectural design—a key judging criterion for the FBLA competition.

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│                        VIEW LAYER                        │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐    │
│  │ProfileScreen │ │CalendarScreen│ │NewsFeedScreen│    │
│  └──────────────┘ └──────────────┘ └──────────────┘    │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐    │
│  │ResourceScreen│ │CustomWidgets │ │  Reusable    │    │
│  └──────────────┘ └──────────────┘ └──────────────┘    │
└─────────────────────────────────────────────────────────┘
                          ↕ (User Input/Display)
┌─────────────────────────────────────────────────────────┐
│                    CONTROLLER LAYER                      │
│  ┌─────────────────┐ ┌─────────────────┐               │
│  │ProfileController│ │CalendarController│              │
│  │  - Validation   │ │  - Event Logic   │              │
│  │  - User Input   │ │  - Registration  │              │
│  └─────────────────┘ └─────────────────┘               │
│  ┌─────────────────┐ ┌─────────────────┐               │
│  │ NewsController  │ │ResourcesCtrl    │               │
│  │  - Engagement   │ │  - Downloads    │               │
│  └─────────────────┘ └─────────────────┘               │
└─────────────────────────────────────────────────────────┘
                          ↕ (Business Logic)
┌─────────────────────────────────────────────────────────┐
│                      MODEL LAYER                         │
│  ┌────────┐ ┌──────────┐ ┌─────────┐ ┌──────────┐     │
│  │ Member │ │FBLAEvent │ │NewsItem │ │ Resource │     │
│  └────────┘ └──────────┘ └─────────┘ └──────────┘     │
│  - Data classes with validation                         │
│  - JSON serialization/deserialization                   │
│  - Immutable update patterns                            │
└─────────────────────────────────────────────────────────┘
                          ↕ (Data Access)
┌─────────────────────────────────────────────────────────┐
│                     SERVICE LAYER                        │
│              ┌──────────────────────┐                   │
│              │ LocalDataService     │                   │
│              │  - Mock Database     │                   │
│              │  - CRUD Operations   │                   │
│              │  - Offline Storage   │                   │
│              └──────────────────────┘                   │
└─────────────────────────────────────────────────────────┘
```

### Layer Responsibilities

#### 1. **Model Layer** (`/lib/models/`)
- **Purpose**: Defines data structures and business entities
- **Files**:
  - `member.dart` - User profile data
  - `fbla_event.dart` - Event and competition information
  - `news_item.dart` - News articles and announcements
  - `resource.dart` - Documents and learning materials

**Key Features**:
- Immutable data classes with proper encapsulation
- JSON serialization for data persistence
- Computed properties for derived data
- Type-safe field definitions

#### 2. **View Layer** (`/lib/views/`)
- **Purpose**: Presents UI and handles user interactions
- **Files**:
  - `profile_screen.dart` - Member profile management
  - `calendar_screen.dart` - Event browsing and registration
  - `news_feed_screen.dart` - News consumption
  - `resources_screen.dart` - Resource access and downloads

**Key Features**:
- Separation of presentation from business logic
- Responsive layouts
- Reusable widget components
- Clean, professional UI following Material Design

#### 3. **Controller Layer** (`/lib/controllers/`)
- **Purpose**: Manages business logic and data flow
- **Files**:
  - `profile_controller.dart` - Profile validation and updates
  - `calendar_controller.dart` - Event management logic
  - `news_controller.dart` - News filtering and engagement
  - `resources_controller.dart` - Resource organization

**Key Features**:
- **Input Validation**: Both syntactical and semantic validation
- **Business Rules**: Enforces application logic
- **State Management**: Coordinates between views and models
- **Error Handling**: Graceful error recovery

#### 4. **Service Layer** (`/lib/services/`)
- **Purpose**: Handles data persistence and external operations
- **Files**:
  - `local_data_service.dart` - Local database simulation

**Key Features**:
- Singleton pattern for consistent data access
- Async operations mimicking real database calls
- Mock data for standalone operation
- Extensible design for future API integration

#### 5. **Widget Layer** (`/lib/widgets/`)
- **Purpose**: Reusable UI components
- **Files**:
  - `custom_event_card.dart` - Event display component
  - `news_list_item.dart` - News article component

**Key Features**:
- Modular, reusable components
- Consistent styling
- Configurable behavior through parameters

---

## 🎯 Input Validation

The app implements **comprehensive input validation** as required by FBLA competition guidelines, demonstrating both syntactical and semantic validation:

### Syntactical Validation
- **Format Checking**: Ensures inputs match expected patterns (e.g., email format, phone number structure)
- **Type Validation**: Verifies data types are correct
- **Length Constraints**: Enforces minimum and maximum lengths

### Semantic Validation
- **Meaning Verification**: Ensures inputs make sense in context
- **Common Error Detection**: Catches typos (e.g., "gmial.com" → "gmail.com")
- **Business Rule Enforcement**: Validates against domain-specific rules

### Example: Email Validation (`profile_controller.dart`)

```dart
String? validateEmail(String? value) {
  // Syntactical: Check format
  final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  if (!emailRegex.hasMatch(value)) {
    return 'Please enter a valid email address';
  }
  
  // Semantic: Check for common typos
  if (value.endsWith('gmial.com')) {
    return 'Did you mean gmail.com?';
  }
  
  return null; // Valid
}
```

---

## 📂 Project Structure

```
lib/
├── main.dart                      # App entry point and navigation
├── models/                        # Data models
│   ├── member.dart               # Member profile data class
│   ├── fbla_event.dart           # Event data class
│   ├── news_item.dart            # News article data class
│   └── resource.dart             # Resource data class
├── views/                         # UI screens
│   ├── profile_screen.dart       # Member profile UI
│   ├── calendar_screen.dart      # Event calendar UI
│   ├── news_feed_screen.dart     # News feed UI
│   └── resources_screen.dart     # Resources UI
├── controllers/                   # Business logic
│   ├── profile_controller.dart   # Profile logic & validation
│   ├── calendar_controller.dart  # Event management logic
│   ├── news_controller.dart      # News filtering & engagement
│   └── resources_controller.dart # Resource management
├── services/                      # Data services
│   └── local_data_service.dart   # Mock database service
└── widgets/                       # Reusable components
    ├── custom_event_card.dart    # Event card widget
    └── news_list_item.dart       # News item widget
```

---

## 💾 Data Handling

### Local Data Service

The app uses a **LocalDataService** to simulate a database without requiring internet connectivity. This demonstrates:

1. **Offline-First Architecture**: All data is stored locally
2. **Mock Data Population**: Pre-loaded with sample FBLA content
3. **CRUD Operations**: Create, Read, Update, Delete functionality
4. **Async Patterns**: Simulates real database latency

### Data Flow Example

```
User Input (View) 
    ↓
Validation (Controller) 
    ↓
Update Model 
    ↓
Save to Service 
    ↓
Update Local Storage 
    ↓
Refresh View
```

---

## 🔧 Technical Implementation

### Technologies Used
- **Framework**: Flutter 3.x
- **Language**: Dart 3.x
- **Architecture**: MVC Pattern
- **State Management**: StatefulWidget with setState
- **Navigation**: Bottom Navigation Bar with IndexedStack
- **Styling**: Material Design 3

### Code Quality Standards

All code follows professional standards:

✅ **Comprehensive Comments**: Every class and function is thoroughly documented  
✅ **Descriptive Naming**: Clear, self-documenting variable and function names  
✅ **Modular Design**: Small, focused functions with single responsibilities  
✅ **Error Handling**: Graceful error management with user feedback  
✅ **Type Safety**: Strong typing throughout the codebase  
✅ **Extensibility**: Easy to add new features without modifying existing code

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Android Studio / VS Code with Flutter extensions

### Installation

1. **Clone or extract the project**
   ```bash
   cd mobile_app
   ```

2. **Get dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Testing
The app runs completely offline and doesn't require any external setup. All data is pre-loaded in the `LocalDataService`.

---

## 📊 Features Demonstration

### 1. Member Profile
- **Input Validation**: 
  - Name: Letters, spaces, hyphens, apostrophes only
  - Email: Valid format with typo detection
  - Phone: US format (XXX) XXX-XXXX with semantic checks
  - Chapter: Minimum 3 characters
- **Role Selection**: Dropdown with predefined FBLA roles
- **Grade Level**: 9-12 or College
- **Edit Mode**: Toggle between view and edit states

### 2. Event Calendar
- **Event Categories**: Competition, Meeting, Conference, Social, Workshop
- **Registration System**: RSVP with capacity limits
- **Visual Indicators**: Color-coded by category
- **Countdown Timers**: Shows days until events
- **Detailed Views**: Full event information in bottom sheet

### 3. News Feed
- **Content Types**: Achievements, Announcements, Chapter News, Event Recaps
- **Engagement**: Like and view tracking
- **Priority System**: Pinned items appear first
- **Search & Filter**: By category and tags
- **Rich Content**: Full articles with metadata

### 4. Resources
- **Categories**: Competition Prep, Leadership, Business, Social Media
- **Resource Types**: Documents, Videos, Links, Guides
- **Download Tracking**: Usage analytics
- **Social Media Integration**: Direct links to FBLA channels
- **Offline Availability**: Indicators for offline resources

---

## 🏆 Competition Requirements Met

### ✅ Topic Alignment: "Design the Future of Member Engagement"
- Multiple engagement touchpoints (News, Events, Resources)
- Social features (likes, comments, registrations)
- Personalized profiles
- Community connection through shared resources

### ✅ Expert Use of Classes, Modules, and Architectural Patterns
- Strict MVC architecture with clear separation of concerns
- 13+ well-designed classes across layers
- Reusable widget components
- Service layer abstraction

### ✅ Input Validation
- Comprehensive syntactical validation (format, type, length)
- Semantic validation (meaning, context, common errors)
- Real-time feedback to users
- Graceful error handling

### ✅ Code Quality
- Extensive commenting on every class and function
- Professional naming conventions
- Modular, maintainable code structure
- Extensible design for future enhancements

### ✅ Standalone Operation
- No internet required
- Mock database with sample data
- Fully functional offline
- Local data persistence

---

## 🔮 Future Enhancements

This architecture is designed to be easily extended with:

- **Real Backend Integration**: Replace LocalDataService with API calls
- **Push Notifications**: Event reminders and news alerts
- **User Authentication**: Secure login and user management
- **Cloud Sync**: Multi-device synchronization
- **Advanced Features**: Chat, polls, achievement badges
- **Analytics Dashboard**: Engagement metrics and reports

---

## 👨‍💻 Development Notes for Judges

### Architectural Decisions

1. **MVC Pattern Choice**: 
   - Provides clear separation of concerns
   - Makes code testable and maintainable
   - Industry-standard pattern that scales well
   - Demonstrates understanding of software architecture

2. **Local-First Approach**:
   - Ensures app works without internet (competition requirement)
   - Faster user experience (no network latency)
   - Easier to demonstrate and test
   - Foundation for future offline-first sync

3. **Validation Strategy**:
   - Implemented at controller layer (business logic)
   - Reusable across different views
   - Comprehensive error messages
   - Both syntactical and semantic checks

4. **Widget Reusability**:
   - Custom components reduce code duplication
   - Consistent UI/UX across the app
   - Easy to modify styling globally
   - Demonstrates component-based thinking

### Code Navigation Guide

- **Start here**: `main.dart` - App entry point and navigation
- **See MVC in action**: `profile_screen.dart` (View) → `profile_controller.dart` (Controller) → `member.dart` (Model)
- **Validation examples**: `profile_controller.dart` lines 65-185
- **Data persistence**: `local_data_service.dart`
- **Reusable components**: `widgets/` directory

---

## 📄 License

This project was created for the 2025-2026 FBLA Mobile Application Development competition.

---

## 🙏 Acknowledgments

- **FBLA National**: For providing the competition framework and topic
- **Flutter Team**: For the excellent framework and documentation
- **Material Design**: For UI/UX guidelines and components

---

## 📞 Technical Demonstration Support

For questions during the technical demonstration:

1. **Architecture Questions**: Refer to the Architecture Diagram and Layer Responsibilities sections
2. **Validation Examples**: See `profile_controller.dart` for comprehensive validation code
3. **MVC Pattern**: Each feature demonstrates the full MVC flow (e.g., Profile management)
4. **Data Flow**: See the Data Handling section for complete flow diagrams

---

**Built with ❤️ for FBLA Member Engagement**
