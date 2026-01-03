# FBLA Member Engagement App Implementation Plan

This plan outlines the architecture and expansion of the FBLA Member Engagement App, focusing on meeting competition criteria while allowing for future innovation.

## User Review Required

> [!IMPORTANT]
> The current codebase is "scaffolded" but untested. The first phase of development MUST be verification and stabilization of the existing MVC structure.

> [!TIP]
> To maximize "Creativity/Innovation" points, we propose adding a **Gamification Engine** and **Personalized Discovery** feature once the core functionality is stable.

## Proposed Architecture: Enhanced MVC

We will stick with the **MVC (Model-View-Controller)** pattern as it is explicitly requested and highly valued in FBLA rubrics for its clarity. To ensure extensibility, we will refine the **Service Layer** to act as a Repository.

### Architecture Components

| Layer | Responsibility | Why? |
|-------|----------------|------|
| **Model** | Data structures & JSON logic | Ensures type safety and easy persistence. |
| **View** | UI & User Interaction | Keeps logic out of the interface for easier testing. |
| **Controller** | Business Logic & Validation | Centralizes "how the app works" and validation rules. |
| **Service** | Data Persistence (Mock DB) | Allows swapping local storage for a cloud API later. |
| **Widgets** | Reusable UI Components | Reduces code duplication and ensures visual consistency. |

---

## Phase 1: Stabilization & Core Features (The "Basic" App)

1.  **Verification**: Fix all import/type errors in the scaffolded code.
2.  **Validation Demo**: Finalize the "Semantic Validation" for email/phone (the "wow" factor).
3.  **Offline-First**: Ensure `LocalDataService` correctly simulates async delays for a realistic feel.
4.  **UI Polish**: Apply Material Design 3 consistently across all 4 screens.

---

## Phase 2: Innovative Features (The "Points" Booster)

To differentiate the app and earn maximum creativity points, we will implement:

### 1. Gamification Engine (Engagement Dashboard)
- **Feature**: Members earn "Impact Points" for attending events, reading news, and completing their profiles.
- **Innovation**: A visual "Member Status" (Bronze, Silver, Gold) on the profile screen.
- **Benefit**: Directly addresses the "Engagement" theme of the competition.

### 2. Personalized "For You" Feed
- **Feature**: Filter news and resources based on the member's "Role" (e.g., Chapter President vs. New Member).
- **Innovation**: Uses simple logic to elevate relevant content.

### 3. Interactive Polls & Feedback
- **Feature**: Add quick 1-question polls to the News feed.
- **Innovation**: Demonstrates two-way engagement, not just passive consumption.

---

## Feedback-Driven Innovation (Addressing Real Issues)

Based on research into FBLA member feedback, we will add these features to solve common "pain points":

| Feedback/Complaint | Proposed Feature | Impact Point |
|--------------------|------------------|--------------|
| **"Opening ceremonies are loud/disorganized"** | **Ceremony Focus Mode** | App rewards members for being "in the zone" with a digital badge. |
| **"Judging is inconsistent"** | **Anonymous Judge Feedback** | Allow members to provide 1-5 star ratings on their judging experience for state level analysis. |
| **"Pin trading is chaotic/messy"** | **Digital Pin Trading** | A virtual marketplace to trade collectible chapter badges in-app. |
| **"Venues are far/confusing"** | **Venue Hub & Wayfinding** | Integrated maps with real-time "Walking Time" to competition rooms. |

---

## Verification Plan

### Automated Tests
- Since the environment is new, we will start with **Manual Verification** and then add logic tests for the Controllers.
- Run `flutter analyze` to ensure code quality.

### Manual Verification
1.  **Validation Demo**: 
    - Type `test@gmial.com` in Profile email. 
    - **Expected**: Suggests `Did you mean gmail.com?`.
2.  **Offline Demo**: 
    - Put device in Airplane Mode. 
    - **Expected**: All features (News, Events) load instantly from local service.
3.  **Registration Flow**: 
    - RSVP for an event. 
    - **Expected**: Counter increments and button state changes to "Registered".
4.  **Gamification Test**:
    - Update profile → Points increase.
    - **Expected**: Visual badge update.
