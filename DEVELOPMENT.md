# FBLA Member Engagement App - Development Guide

## Quick Start

### Running the App

```bash
# Get dependencies
flutter pub get

# Run on connected device or emulator
flutter run

# Run in release mode for better performance
flutter run --release
```

### Project Files Overview

- **lib/main.dart** - Entry point with bottom navigation
- **lib/models/** - Data classes (Member, Event, News, Resource)
- **lib/views/** - UI screens
- **lib/controllers/** - Business logic and validation
- **lib/services/** - Local data service (mock database)
- **lib/widgets/** - Reusable components

## Key Features to Demonstrate

1. **MVC Architecture**
   - Show how ProfileScreen (View) → ProfileController (Controller) → Member (Model)
   - Explain separation of concerns

2. **Input Validation**
   - Profile form demonstrates both syntactical and semantic validation
   - Check `profile_controller.dart` for validation methods

3. **Offline Functionality**
   - All data in `LocalDataService` is pre-loaded
   - No internet required

4. **Code Quality**
   - Every class and function has comprehensive comments
   - Modular, extensible design

## Testing Checklist

- [ ] Profile editing with validation
- [ ] Event registration and filtering
- [ ] News feed likes and views
- [ ] Resource browsing and search
- [ ] Bottom navigation between screens

## Technical Demonstration Tips

1. Start with README.md to show architecture
2. Navigate to a feature (e.g., Profile)
3. Show the MVC flow: View → Controller → Model → Service
4. Demonstrate validation with intentional errors
5. Highlight code comments and documentation
