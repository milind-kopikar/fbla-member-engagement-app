# Code Architecture — FBLA Future Engagement App

This document provides a detailed walkthrough of the application's architecture, design decisions, data flows, and component relationships.

---

## 1. Architectural Philosophy

The app is built on **Clean Architecture** combined with the **Feature-First** folder organisation. These two ideas work together:

- **Clean Architecture** enforces a strict boundary between _what the app does_ (business logic) and _how it does it_ (UI, storage, network). Each layer only depends on the layer inward — never outward.
- **Feature-First** groups code by product capability (e.g. `news_feed/`, `event_calendar/`) rather than by technical role (e.g. `models/`, `views/`). This keeps all related code co-located and makes it easy to reason about or extend a single feature without touching others.

---

## 2. Layer Overview

Every feature in the app is split into exactly three layers, always nested in the same order:

```
feature/
├── domain/          ← innermost: pure Dart, no dependencies
├── data/            ← middle: knows about storage and APIs
└── presentation/    ← outermost: knows about Flutter and the UI
```

The dependency rule is strict: arrows point inward only.

```
  Presentation  ──depends on──►  Domain  ◄──depends on──  Data
       │                            │                        │
   (Flutter UI)             (Pure Dart logic)        (SharedPrefs, API)
   BLoC, Widgets            Entities, UseCases       Repositories, Models
                            Repositories (abstract)
```

`Data` and `Presentation` both depend on `Domain`. They never depend on each other.

---

## 3. Directory Structure

```
lib/
├── main.dart                          Entry point — wires BLoCs into the widget tree
├── injection_container.dart           Dependency injection — registers all objects
│
├── core/
│   ├── error/
│   │   └── failures.dart              Shared failure types (not yet wired, extensible)
│   └── usecases/
│       └── usecase.dart               Abstract UseCase<Type, Params> base class
│
└── features/
    ├── dashboard/
    │   └── presentation/
    │       └── pages/
    │           └── dashboard_page.dart    Bottom nav shell, IndexedStack for tabs
    │
    ├── member_profile/
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   ├── member.dart            Member value object (Equatable)
    │   │   │   └── profile_validator.dart Syntactical + semantic validation rules
    │   │   ├── repositories/
    │   │   │   └── member_repository.dart Abstract interface
    │   │   └── usecases/
    │   │       ├── get_profile.dart
    │   │       └── update_profile.dart
    │   ├── data/
    │   │   ├── models/
    │   │   │   └── member_model.dart      JSON serialisation (extends Member)
    │   │   ├── datasources/
    │   │   │   ├── member_data_source.dart    Abstract interface
    │   │   │   └── member_local_data_source.dart  SharedPreferences implementation
    │   │   └── repositories/
    │   │       └── member_repository_impl.dart
    │   └── presentation/
    │       ├── bloc/
    │       │   ├── member_profile_bloc.dart
    │       │   ├── member_profile_event.dart
    │       │   └── member_profile_state.dart
    │       └── pages/
    │           └── member_profile_page.dart
    │
    ├── news_feed/           (same three-layer structure)
    ├── event_calendar/      (same three-layer structure)
    ├── resources/           (same three-layer structure)
    └── social/              (same three-layer structure)
```

---

## 4. The Domain Layer

The domain layer is the core of the application. It contains zero Flutter imports. It is pure Dart.

### 4a. Entities

Entities are immutable value objects representing the core business concepts. They use `Equatable` so that BLoC can detect real state changes by value, not by reference.

| Entity | Key Fields | Notes |
|---|---|---|
| `Member` | `id`, `firstName`, `lastName`, `email`, `chapter`, `gradeLevel` | Has `fullName` computed property |
| `EventEntity` | `id`, `title`, `startDate`, `endDate`, `location`, `category`, `notes` | `endDate` nullable for single-day events |
| `NewsEntry` | `id`, `title`, `summary`, `date`, `link`, `category` | `link` opens in external browser |
| `ResourceEntity` | `id`, `title`, `description`, `category`, `type`, `url` | `type` is PDF / Video / Link |
| `SocialPostEntity` | `id`, `authorName`, `authorHandle`, `content`, `timestamp`, `likes` | |

### 4b. Repository Interfaces

The domain layer defines the _contract_ for data access as abstract Dart classes. The data layer fulfils these contracts. The domain layer has no idea how or where data is stored.

```dart
// domain/repositories/news_repository.dart
abstract class NewsRepository {
  Future<List<NewsEntry>> getLatestNews();
  Future<List<NewsEntry>> searchNews(String query);
}
```

This means: if we swap from `SharedPreferences` to SQLite or a real REST API, the domain layer and presentation layer need zero changes.

### 4c. Use Cases

Each use case encapsulates exactly one business operation. They all extend the abstract `UseCase<ReturnType, Params>` base class.

```
UseCase<Type, Params>
    └── call(Params params) → Future<Type>
```

Use cases receive their repository through constructor injection. They never instantiate repositories directly.

| Feature | Use Case | Params |
|---|---|---|
| Member Profile | `GetProfile` | `NoParams` |
| Member Profile | `UpdateProfile` | `Member` |
| News Feed | `GetLatestNews` | `NoParams` |
| News Feed | `SearchNews` | `String` (query) |

The `Event Calendar` and `Resources` features call the repository directly from the BLoC (no dedicated use case class), which is acceptable for simpler read-only operations.

### 4d. Validation

`ProfileValidator` lives in the domain layer because validation is a business rule, not a UI rule. It provides two types of validation:

```
Syntactical validation  →  checks format
  validateEmail()       →  regex: ^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$

Semantic validation     →  checks business meaning
  validateGradeLevel()  →  grade must be 9–12 (FBLA high school range)
  validateChapter()     →  name must be ≥ 3 characters (not meaningless input)
```

By living in the domain layer, `ProfileValidator` is usable by both the UI (form field validators) and use cases (pre-save validation) without duplication.

---

## 5. The Data Layer

The data layer knows about storage mechanisms and (in production) external APIs. It implements the repository interfaces defined by the domain layer.

### 5a. Models vs Entities

Models extend their corresponding domain entities and add JSON serialisation logic. This keeps serialisation code out of the domain layer.

```
Member (domain entity)          ← pure business object
    ▲ extends
MemberModel (data model)        ← adds fromJson() / toJson()
```

### 5b. Data Sources

Each feature has one or more data source classes behind an abstract interface:

```
Abstract Interface              Concrete Implementation
──────────────────────────────────────────────────────
MemberDataSource          ←──  MemberLocalDataSourceImpl   (SharedPreferences)
NewsRemoteDataSource      ←──  MockNewsRemoteDataSource     (in-memory mock)
NewsLocalDataSource       ←──  NewsLocalDataSourceImpl      (SharedPreferences)
EventDataSource           ←──  MockEventDataSourceImpl      (in-memory mock)
EventLocalDataSource      ←──  EventLocalDataSourceImpl     (SharedPreferences)
ResourceRemoteDataSource  ←──  MockResourceRemoteDataSource (in-memory mock)
SocialRemoteDataSource    ←──  MockSocialRemoteDataSource   (in-memory mock)
```

Using interfaces here means the injection container can swap `MockNewsRemoteDataSource` for a real `NewsApiDataSource` without any other code changing.

### 5c. Repository Implementations

Repository implementations are where the caching strategy lives. For `NewsRepositoryImpl` and `EventRepositoryImpl`, the pattern is **Cache-First with Background Refresh**:

```
getEvents() / getLatestNews()
        │
        ▼
localDataSource.getCache()
        │
   cache empty?
   ┌────┴────┐
  YES       NO
   │         │
   ▼         ▼
remoteDataSource    Return cache immediately
   .get()           +
   │                remoteDataSource.get() [fire & forget]
   ▼                → localDataSource.cache(fresh) [non-blocking]
localDataSource
   .cache(result)
   │
   ▼
Return result
```

Benefits:
- **Instant load** if cache is warm (typical second+ open)
- **Offline capable** — cached data is always served if available
- **Always fresh** — background refresh updates the cache silently
- **Graceful degradation** — errors in background refresh are swallowed; cached data is still shown

For `MemberRepositoryImpl` (profile data), there is no remote source — it is purely local persistence via `SharedPreferences`. Profile data is written synchronously on save and read on load.

---

## 6. The Presentation Layer — BLoC Pattern

All state management uses the **BLoC (Business Logic Component)** pattern via the `flutter_bloc` package.

### 6a. BLoC Structure

Every feature's BLoC follows the same structure:

```
Events (user actions)    →    BLoC    →    States (UI snapshots)
```

```
Abstract NewsEvent
├── FetchLatestNewsEvent
├── SearchNewsEvent(query)
└── FilterByCategoryEvent(category)

Abstract NewsState
├── NewsInitial
├── NewsLoading
├── NewsLoaded(allNews, filteredNews, currentCategory)
└── NewsError(message)
```

Events and states all extend `Equatable`. This means BLoC only triggers a rebuild when the state _value_ actually changes, preventing unnecessary renders.

### 6b. State Flow Example — News Search

```
User types "leader" in search bar
        │
        ▼
TextField.onChanged fires (query.length > 2)
        │
        ▼
context.read<NewsBloc>().add(SearchNewsEvent('leader'))
        │
        ▼
NewsBloc._onSearchNews() handler runs
  emit(NewsLoading())           ← spinner shown in UI
        │
        ▼
  searchNews('leader')          ← use case called
        │
        ▼
  NewsRepositoryImpl.searchNews()
    → check SharedPreferences cache
    → filter by title/summary contains 'leader'
        │
        ▼
  emit(NewsLoaded(filteredNews: [...]))
        │
        ▼
BlocBuilder<NewsBloc, NewsState> rebuilds
  → ListView shows filtered results
```

### 6c. BLoC Registration

All BLoCs are registered at the root of the widget tree in `main.dart` via `MultiBlocProvider`. This means every widget in the tree can access any BLoC with `context.read<XBloc>()` or `context.watch<XBloc>()` without manual passing.

```dart
MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => sl<NewsBloc>()..add(FetchLatestNewsEvent())),
    BlocProvider(create: (_) => sl<EventBloc>()..add(FetchEventsEvent())),
    BlocProvider(create: (_) => sl<ResourceBloc>()..add(FetchResourcesEvent())),
    BlocProvider(create: (_) => sl<SocialBloc>()..add(FetchSocialFeedEvent())),
  ],
  child: MaterialApp(home: DashboardPage()),
)
```

The `MemberProfileBloc` is the exception — it is scoped to the `MemberProfilePage` only (created with a local `BlocProvider`) since profile data is not needed globally.

### 6d. BLoC Summary Table

| BLoC | Events | States | Use Cases Called |
|---|---|---|---|
| `NewsBloc` | Fetch, Search, FilterByCategory | Initial, Loading, Loaded, Error | `GetLatestNews`, `SearchNews` |
| `EventBloc` | Fetch, Filter | Initial, Loading, Loaded, Error | — (calls repo directly) |
| `ResourceBloc` | Fetch, Search | Initial, Loading, Loaded, Error | — (calls repo directly) |
| `SocialBloc` | FetchFeed | Initial, Loading, Loaded, Error | — (calls repo directly) |
| `MemberProfileBloc` | GetProfile, UpdateProfile | Initial, Loading, Loaded, Error | `GetProfile`, `UpdateProfile` |

---

## 7. Dependency Injection

The app uses **GetIt** as a service locator. All wiring lives in `injection_container.dart` (`init()` function, called before `runApp()`).

### 7a. Registration Types

| Type | When Used | Examples |
|---|---|---|
| `registerFactory` | Creates a new instance every call | BLoCs, Use Cases |
| `registerLazySingleton` | Creates once, reuses forever | Repositories, Data Sources, SharedPreferences |

BLoCs are factories because each `BlocProvider.create` call should get a fresh BLoC with a clean initial state. Repositories and data sources are singletons because they are stateless infrastructure that is expensive to create and safe to share.

### 7b. Registration Order

Dependencies are registered in **reverse dependency order** — leaf nodes first, then the things that depend on them:

```
1. External (SharedPreferences)          ← no dependencies
2. Data Sources                          ← depend on SharedPreferences
3. Repositories                          ← depend on Data Sources
4. Use Cases                             ← depend on Repositories
5. BLoCs                                 ← depend on Use Cases / Repositories
```

### 7c. Dependency Graph

```
SharedPreferences (singleton)
        │
        ├──► MemberLocalDataSourceImpl
        │         │
        │         └──► MemberRepositoryImpl ──► GetProfile ──► MemberProfileBloc
        │                                   └──► UpdateProfile ─┘
        │
        ├──► NewsLocalDataSourceImpl ──┐
        │                              ├──► NewsRepositoryImpl ──► GetLatestNews ──► NewsBloc
        MockNewsRemoteDataSource ──────┘                       └──► SearchNews ──────┘
        │
        ├──► EventLocalDataSourceImpl ──┐
        │                               ├──► EventRepositoryImpl ──► EventBloc
        MockEventDataSourceImpl ────────┘
        │
        MockResourceRemoteDataSource ──► ResourceRepositoryImpl ──► ResourceBloc
        │
        MockSocialRemoteDataSource ──► SocialRepositoryImpl ──► SocialBloc
```

---

## 8. Navigation Architecture

The app has a simple two-level navigation structure:

```
Level 1: DashboardPage (always present)
    └── IndexedStack (4 tabs, all rendered, none destroyed on switch)
         ├── [0] EventCalendarTab
         ├── [1] NewsFeedTab
         ├── [2] ResourceListTab
         └── [3] SocialFeedTab

Level 2: MemberProfilePage (pushed modally via Navigator.push)
    └── Returns selected tab index via Navigator.pop(index)
         └── DashboardPage receives result and updates _selectedIndex
```

`IndexedStack` is used instead of `PageView` or rebuilding widgets on tab switch. This preserves the scroll position, BLoC state, and loaded data for every tab across the entire session — switching tabs is instantaneous with no re-fetching.

### Profile Navigation Return Protocol

When a user navigates from the Profile page back to the dashboard, they can select which tab to land on. This is handled via the Navigator return value pattern:

```
DashboardPage                           MemberProfilePage
──────────────                         ──────────────────
Navigator.push<int>()        ──────►
    await result                        _ProfileBottomNavigationBar
                                            onTap(index) → Navigator.pop(index)
    result = 2 (Resources)  ◄──────
setState(_selectedIndex = 2)
```

---

## 9. Theme and Accessibility Architecture

The global `ThemeData` is defined once in `main.dart` and propagated to all widgets via Flutter's `InheritedWidget` mechanism.

### Color Scheme (WCAG AA Compliant)

```
Primary:    #003366  (FBLA Blue)   — used on headers, icons, selected states
onPrimary:  #FFFFFF  (White)       — text on blue backgrounds
Secondary:  #D4AF37  (FBLA Gold)   — accent highlights
Surface:    #FFFFFF  (White)       — card backgrounds
onSurface:  #003366  (FBLA Blue)   — body text on white
Error:      #FF0000  (Red)         — validation error messages
```

Blue on white achieves a **contrast ratio of 10.7:1**, well above the WCAG AA minimum of 4.5:1.

### Accessibility Hooks

| Mechanism | Where Used | Purpose |
|---|---|---|
| `Semantics(header: true, label: ...)` | `DashboardPage` AppBar title | Screen reader landmark |
| `IconButton(tooltip: ...)` | All icon buttons | VoiceOver / TalkBack description |
| `minimumSize: Size.fromHeight(50)` | Edit Profile button | 44pt minimum touch target |
| `TextFormField(keyboardType: ...)` | Email, Grade inputs | Correct keyboard type for input |
| `visualDensity: adaptivePlatformDensity` | Global theme | Adapts spacing per platform |
| System text scale | Respected globally | `TextStyle` uses `sp`-equivalent Flutter sizing |

---

## 10. Caching Architecture

Two features (News and Events) use a local cache backed by `SharedPreferences`. The cache stores JSON-serialised arrays.

### Storage Keys

| Key | Feature | Content |
|---|---|---|
| `CACHED_NEWS` | News Feed | JSON array of `NewsModel` objects |
| `CACHED_EVENTS` | Event Calendar | JSON array of `EventModel` objects |
| `member_profile` | Member Profile | JSON object of `MemberModel` |

### Cache Lifecycle

```
First launch:
  cache empty → fetch from MockDataSource → write to SharedPreferences → display

Subsequent launches:
  cache hit → display immediately → fetch in background → overwrite cache silently

Offline:
  cache hit → display immediately → background fetch fails silently → still works
  cache empty → fetch fails → EventError/NewsError state shown
```

---

## 11. Testing Architecture

Tests are organised to mirror the `lib/` structure:

```
test/
├── fbla_suite_test.dart            Aggregator — runs all tests as one suite
├── demo_script_integration_test.dart  End-to-end flow mimicking demo script
│
├── core/
│   └── accessibility_test.dart    Validates Semantics tree and contrast
│
└── features/
    ├── member_profile/
    │   ├── data/datasources/member_local_data_source_test.dart
    │   └── presentation/pages/member_profile_page_test.dart
    ├── news_feed/
    │   ├── data/datasources/news_local_data_source_test.dart
    │   ├── data/repositories/news_repository_cache_test.dart
    │   └── presentation/widgets/news_feed_tab_test.dart
    ├── event_calendar/
    │   ├── data/datasources/event_local_data_source_test.dart
    │   └── presentation/widgets/event_calendar_tab_test.dart
    ├── resources/
    │   └── presentation/widgets/resource_list_tab_test.dart
    ├── social/
    │   └── presentation/widgets/social_feed_tab_test.dart
    └── dashboard/
        └── presentation/pages/dashboard_page_test.dart
```

### Test Strategy

| Test Type | Tool | What it covers |
|---|---|---|
| Unit tests | `flutter_test` + `mocktail` | Data sources, repositories, BLoC event/state transitions |
| Widget tests | `flutter_test` | Widget rendering, BLoC integration in UI, accessibility Semantics |
| Integration tests | `flutter_test` | Complete user flows (demo script replay) |

BLoC tests use `bloc_test` conventions: emit an event, assert on the sequence of emitted states. Data source tests inject `SharedPreferences.setMockInitialValues()` to control storage state without touching real device storage.

---

## 12. Full Data Flow — End to End

The following shows the complete path from a user action to a UI update, using the news search as the example:

```
┌─────────────────────────────────────────────────────────────────────┐
│  PRESENTATION LAYER                                                   │
│                                                                       │
│  NewsFeedTab (StatefulWidget)                                         │
│    TextField.onChanged('leader')                                      │
│      └─► context.read<NewsBloc>().add(SearchNewsEvent('leader'))      │
│                                                                       │
│  BlocBuilder<NewsBloc, NewsState>                                     │
│    └─► rebuilds when state changes                                    │
└──────────────────────────┬──────────────────────────────────────────┘
                           │ event dispatched
                           ▼
┌─────────────────────────────────────────────────────────────────────┐
│  PRESENTATION LAYER — BLoC                                            │
│                                                                       │
│  NewsBloc._onSearchNews()                                             │
│    emit(NewsLoading())                                                │
│    result = await searchNews('leader')   ← use case call             │
│    emit(NewsLoaded(filteredNews: result))                             │
└──────────────────────────┬──────────────────────────────────────────┘
                           │ use case call
                           ▼
┌─────────────────────────────────────────────────────────────────────┐
│  DOMAIN LAYER                                                         │
│                                                                       │
│  SearchNews.call('leader')                                            │
│    └─► repository.searchNews('leader')   ← repository interface call │
└──────────────────────────┬──────────────────────────────────────────┘
                           │ repository call
                           ▼
┌─────────────────────────────────────────────────────────────────────┐
│  DATA LAYER                                                           │
│                                                                       │
│  NewsRepositoryImpl.searchNews('leader')                              │
│    └─► NewsLocalDataSourceImpl.getCachedNews()                        │
│          └─► SharedPreferences.getString('CACHED_NEWS')              │
│                └─► JSON.decode → List<NewsModel>                      │
│    filter: title/summary contains 'leader'                            │
│    return List<NewsEntry> (domain entity)                             │
└─────────────────────────────────────────────────────────────────────┘
```

This flow repeats in the same shape for every feature. The layers are completely decoupled — you can replace SharedPreferences with SQLite or swap mock data for a real API without touching a single line of BLoC or widget code.
