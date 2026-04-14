# User Journeys — FBLA Future Engagement App

This document maps out the step-by-step experience of key user personas as they move through the app. Each journey traces the UI flow, the underlying data and state changes, and the value delivered to the user.

---

## Journey 1: Student Checking Events and Setting Deadline Reminders

**Persona**: Alex, a 10th grade FBLA member who wants to stay on top of competition registration windows so they never miss an NLC or SLC deadline.

**Goal**: Find upcoming competition deadlines, understand what they are, and set a reminder for the most important one.

**Starting condition**: App is installed. Alex opens it fresh (or returns after time away).

---

### Step-by-Step Flow

#### Step 1 — App Launch
- App starts. `main.dart` initializes the dependency injection container and calls `EventBloc` with a `FetchEventsEvent`.
- The `EventBloc` hits `EventRepositoryImpl`, which checks `SharedPreferences` first (cache-first strategy). On first launch the cache is empty, so it fetches from `MockEventDataSourceImpl`.
- The `DashboardPage` loads with the **News tab** selected by default (`initialIndex: 1`).

#### Step 2 — Navigate to Events
- Alex taps the **Events** tab (calendar icon, index 0) in the bottom navigation bar.
- `DashboardPage._onItemTapped(0)` fires, calling `setState()` to switch `_selectedIndex` to 0.
- `IndexedStack` reveals the `EventCalendarTab` widget, which is already rendered and state-ready from the initial `FetchEventsEvent` at launch.
- Alex sees the full list of upcoming FBLA events, each shown as a card with a date badge, title, location, and category label.

```
Bottom Nav tap (Events)
        │
        ▼
DashboardPage._onItemTapped(0)
        │
        ▼
IndexedStack reveals EventCalendarTab
        │
        ▼
BlocBuilder reads EventLoaded state
        │
        ▼
_buildEventList() renders all events
```

#### Step 3 — Filter by "Competition Deadline"
- Alex wants to see only deadlines, not all events. They tap the **"Competition Deadline"** filter chip at the top of the screen.
- `FilterEventsEvent('Competition Deadline')` is dispatched to `EventBloc`.
- The BLoC performs client-side filtering on `allEvents` — no network call needed.
- `EventLoaded` is re-emitted with only matching events in `filteredEvents`.
- The chip highlights in FBLA Blue to confirm selection. Non-deadline events disappear from the list.

```
Tap "Competition Deadline" chip
        │
        ▼
FilterEventsEvent dispatched
        │
        ▼
EventBloc._onFilterEvents()
  allEvents.where(e.category == 'Competition Deadline')
        │
        ▼
New EventLoaded emitted (filteredEvents)
        │
        ▼
EventCalendarTab rebuilds — filtered list shown
```

#### Step 4 — Read Event Details
- Alex sees **"Membership Dues Deadline"** (March 1) and **"Spring Stock Market Game"** (Feb 3 – Apr 11) in the filtered list.
- Each card shows:
  - Month/day badge (visual calendar representation)
  - Event title (bold)
  - Location (`Online` / `Virtual`)
  - `Ends: Apr 11, 2026` for multi-day events
  - Category badge in red (Competition Deadline color)
  - Alarm bell icon (Set Reminder)

#### Step 5 — Set a Reminder
- Alex taps the **alarm bell** icon (`Icons.alarm_add`) on the "Membership Dues Deadline" card.
- `_showReminderDialog()` is called, opening an `AlertDialog`:
  - Title: "Set RSVP/Reminder"
  - Body: "Would you like to set a priority reminder for 'Membership Dues Deadline'?"
  - Actions: **Cancel** and **Confirm**
- Alex taps **Confirm**.
- `Navigator.pop()` closes the dialog.
- A `SnackBar` appears at the bottom: *"Reminder set for Membership Dues Deadline!"*
- In production, this step would trigger a device calendar entry or local push notification via the `add_to_calendar` or `flutter_local_notifications` package.

```
Tap alarm_add icon
        │
        ▼
_showReminderDialog(context, event)
        │
        ▼
AlertDialog displayed
        │
  [Confirm tapped]
        │
        ▼
Navigator.pop() — dialog closes
ScaffoldMessenger.showSnackBar() — confirmation shown
```

#### Step 6 — Browse Remaining Events
- Alex taps **"All"** filter chip to reset to the full event list.
- `FilterEventsEvent('All')` is dispatched. `filteredEvents` is restored to `allEvents`.
- Alex scrolls through National events (NLC, FBLA Week) and Chapter Meetings.

---

### Value Delivered
- Alex found all competition deadlines in two taps (open app → filter)
- Confirmed a reminder without leaving the app
- Can return and re-check at any time — events are cached locally and load instantly even offline

---
---

## Journey 2: Student Reading News, Sharing with Friends, and Engaging on Chapter Social Media

**Persona**: Jordan, an 11th grade FBLA member and chapter social media officer who reads FBLA national updates and amplifies them to the chapter's Instagram and group chat.

**Goal**: Find a relevant FBLA news article, share it directly to social media, and also share a post from the social feed to the chapter's group chat.

**Starting condition**: App is open on the Dashboard. Jordan is on the default News tab.

---

### Step-by-Step Flow

#### Step 1 — Land on News Feed
- The app opens with the **News tab** active by default (`initialIndex: 1` in `DashboardPage`).
- `NewsBloc` was initialized at app launch with `FetchLatestNewsEvent`, which ran the cache-first strategy: cached articles are served instantly from `SharedPreferences`, while fresh data is fetched in the background.
- Jordan sees a scrollable list of FBLA news articles, each showing an article icon, bold title, publication date, and a 2-line summary.

#### Step 2 — Filter by Category
- Jordan wants only **"Chapter Spotlight"** articles. They tap the **Category** dropdown at the top of the news feed.
- Selecting "Chapter Spotlight" dispatches `FilterByCategoryEvent('Chapter Spotlight')` to `NewsBloc`.
- The BLoC filters `allNews` client-side (no network call) and emits a new `NewsLoaded` state with matching articles only.
- The list updates immediately. The search bar clears automatically.

```
Tap Category dropdown → select "Chapter Spotlight"
        │
        ▼
FilterByCategoryEvent('Chapter Spotlight') dispatched
        │
        ▼
NewsBloc._onFilterByCategory()
  allNews.where(n.category == 'Chapter Spotlight')
        │
        ▼
New NewsLoaded(filteredNews: [...], currentCategory: 'Chapter Spotlight') emitted
        │
        ▼
NewsFeedTab rebuilds — filtered articles shown
```

#### Step 3 — Search for a Specific Topic
- Jordan also wants to find something about "leadership". They type **"leader"** into the search bar.
- The `onChanged` handler fires. With `query.length > 2`, `SearchNewsEvent('leader')` is dispatched.
- `NewsBloc` calls the `SearchNews` use case → `NewsRepositoryImpl.searchNews()` → searches local cache with `title.contains()` and `summary.contains()` (case-insensitive).
- A `NewsLoaded` state is emitted with matching articles. The category dropdown resets to "All Categories".
- A clear button (X) appears in the search bar. Jordan can tap it to reset to all news and restore the full feed.

```
User types "leader" in search bar
        │
  query.length > 2 → true
        │
        ▼
SearchNewsEvent('leader') dispatched
        │
        ▼
NewsBloc._onSearchNews()
  → SearchNews use case
    → NewsRepositoryImpl.searchNews('leader')
      → filter cached articles by title/summary
        │
        ▼
NewsLoaded(filteredNews: [matching articles]) emitted
        │
        ▼
NewsFeedTab rebuilds — search results shown
```

#### Step 4 — Read the Full Article
- Jordan finds a relevant article: **"Chapter Spotlight: Blue Ridge HS Wins Regional Award"**.
- They tap the card. `_launchURL(entry.link)` is called.
- `url_launcher` opens the link in the device's **default external browser** (Chrome, Safari) using `LaunchMode.externalApplication`.
- Jordan reads the full article on the official FBLA website.
- They use the browser's native share button to share the URL directly from the browser if desired.

```
Tap article card
        │
        ▼
_launchURL(entry.link)
        │
        ▼
launchUrl(uri, mode: LaunchMode.externalApplication)
        │
        ▼
Device opens default browser → fbla.org article
```

#### Step 5 — Navigate to the Social Tab
- Jordan returns to the app and taps the **Social** tab (share icon, index 3) in the bottom navigation bar.
- `DashboardPage._onItemTapped(3)` fires. `SocialFeedTab` is revealed via `IndexedStack`.
- The social feed loads posts from `MockSocialRemoteDataSource` through `SocialBloc`.
- Jordan sees posts from FBLA National, FBLA Collegiate, and other members — each with author, handle, timestamp, like count, and a share button.

#### Step 6 — Invite Friends via the Header Share Button
- At the top of the Social tab, Jordan taps the **"Invite"** button (`TextButton.icon`).
- This calls `Share.share()` from the `share_plus` package with the text:
  > *"Join me in FBLA! 🚀 Check out the official Future of Member Engagement app: https://fbla.org"*
- The **iOS Share Sheet** (or Android Share Intent) opens natively.
- Jordan selects **Instagram Stories**, **iMessage**, or their chapter's **WhatsApp group** — whichever social platform is installed on their device.
- The app integrates directly with all installed social media applications via the platform's native sharing layer.

```
Tap "Invite" button
        │
        ▼
Share.share('Join me in FBLA! ...')
        │
        ▼
iOS Share Sheet / Android Share Intent opens
        │
        ▼
Jordan selects: Instagram / iMessage / WhatsApp / etc.
        │
        ▼
Content posted to chosen platform
```

#### Step 7 — Share a Specific Post to Chapter Social Media
- Jordan sees the FBLA National post: *"Registration for NLC 2025 in San Antonio is now OPEN!"*
- They tap the **share icon** on that post card (`Icons.share_outlined`).
- `Share.share()` is called with:
  > *"Check out this FBLA update: 'Registration for NLC 2025 in San Antonio is now OPEN!' - shared via FBLA Member App"*
- The native Share Sheet appears again. Jordan selects their **chapter Instagram account**, drafts a caption in the Instagram app, and posts it.
- For the chapter's local group chat, Jordan selects **Messages** or **GroupMe** from the same Share Sheet and sends it there — completing the social amplification loop.

```
Tap share icon on a post card
        │
        ▼
Share.share('Check out this FBLA update: "..." - shared via FBLA Member App')
        │
        ▼
iOS Share Sheet opens
        │
  Jordan selects chapter Instagram → posts to feed
  Jordan selects GroupMe/Messages → sends to chapter chat
```

---

### Value Delivered
- Jordan discovered relevant chapter news in two interactions (category filter → search)
- Read the full article on the official FBLA source without leaving a trusted context
- Shared a standing invite to the app with friends using their preferred platform
- Shared a specific breaking FBLA update directly to chapter Instagram and group chat — all without copying links manually or switching apps to find content

---

## Summary Table

| Step | Journey 1 (Events) | Journey 2 (News & Social) |
|---|---|---|
| Entry point | Dashboard → Events tab | Dashboard → News tab (default) |
| Core interaction | Filter chips → Event cards | Category dropdown + Search bar |
| Deep action | Alarm bell → Reminder dialog | Article tap → External browser |
| Social action | — | Share Sheet → Instagram / iMessage |
| Offline capable | Yes (cached events) | Yes (cached news articles) |
| Key BLoC events | `FetchEventsEvent`, `FilterEventsEvent` | `FetchLatestNewsEvent`, `SearchNewsEvent`, `FilterByCategoryEvent` |
| Persistence layer | `EventLocalDataSourceImpl` (SharedPreferences) | `NewsLocalDataSourceImpl` (SharedPreferences) |
