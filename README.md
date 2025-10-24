# 🌿 DailyPulse – A Personal Wellness Tracker App

DailyPulse is a beautifully minimal Flutter mobile app designed to help users stay mindful of their emotional well-being.  
In a world full of noise, deadlines, and digital distractions, DailyPulse encourages users to pause for a moment and reflect on how they’re truly feeling each day.

With a simple and intuitive interface, users can **log their mood with an emoji**, **add personal notes**, and **view their emotional journey** over time.  
DailyPulse not only helps users track emotions but also offers **visual insights and trends**, encouraging self-awareness and a balanced mindset.  


## Features

- 📝 Daily mood logging with emoji selection and optional notes
- 📊 Visual mood trends across week, month and year views  
- 📅 Calendar view for reviewing past entries
- 📈 Summary statistics and mood distribution analysis
- 🌓 Dark/Light theme support
- 🔐 User authentication and cloud data sync
- 📱 Cross-platform support (iOS, Android, Web)

## Getting Started

### Prerequisites

- Flutter 3.35.5 or higher
- Dart SDK ^3.9.2
- Firebase project setup

### Installation

1. Clone the repository:
```bash
git clone https://github.com/tushar11kh/dailypulse.git
cd DailyPulse
```

2. Install dependencies:
```bash 
flutter pub get
```

3. Setup Firebase:
   Go to [Firebase Console](https://console.firebase.google.com/).
Create a new project → Add Android app (use your app’s applicationId from build.gradle.kts).
Download google-services.json and place it inside:
android/app/google-services.json

Enable:
Email/Password Authentication
Cloud Firestore in test mode

4. Install Dependencies

```bash
flutter pub get
```

5. Run the app:
```bash
flutter run
```

## Core Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.5+1
  firebase_auth: ^6.1.1
  cloud_firestore: ^6.0.3
  fl_chart: ^1.1.1
  google_fonts: ^6.3.2
```

## Architecture

The app follows a provider-based architecture with clear separation of concerns:

- `models/` - Data models
- `providers/` - State management using Provider pattern
- `pages/` - UI screens and layouts
- `services/` - Business logic and external services
- `widgets/` - Reusable UI components

## 🎨 Emotion Logic \& UI Design Choices

### 💬 Emotion Scoring

Each mood entry consists of:
Emoji → representing emotion visually.
Score → numerical mapping for analytics:
😄 → +1 (Positive)
😐 → 0 (Neutral)
😔 → -1 (Negative)

This mapping powers all insights, including:

- The Summary Page statistics.
- The Mood Trends Chart.
- The Color-coded Mood Balance Bar:
    - 🟢 Green → Mostly positive days (≥ 66%)
    - 🟡 Yellow → Mixed/neutral mood (33–65%)
    - 🔴 Red → Mostly negative days (≤ 32%)

### 🎨 UI/UX Design Principles

- Calm, minimalist design with whitespace and rounded components for mental clarity.
- Consistent typography using [Google Fonts: Poppins](https://fonts.google.com/specimen/Poppins).
- Soft color palette (lavender, pastel green, and muted purple) to evoke emotional calmness.
- Bottom navigation for intuitive multi-page flow (Calendar -  Trends -  Summary -  Profile).
- Dark mode support for late-night journaling comfort.
- Smooth transitions to create a mindful, non-intrusive user experience.

## Screenshots

Click [here](https://www.youtube.com/shorts/PWNZmKvaUx8) to see video demo.

***

## 🔒 Data Handling

- Local Storage: All entries are cached using SharedPreferences for offline access.
- Cloud Sync: On login, entries are fetched from Firestore and stored locally.
- Security: Each user’s data is isolated under their Firebase UID.
- Logout: Clears local cache and restores app to a fresh state.

***

## 🧑‍💻 Tech Stack

```
Category        Tool
Framework       Flutter 3.x
Language        Dart
State Management Provider
Backend         Firebase Auth + Cloud Firestore
Local Storage   SharedPreferences
Charts          fl_chart
Fonts           Google Fonts (Poppins)
```


***


## Acknowledgments

- [Flutter](https://flutter.dev) for the SDK
- [Firebase](https://firebase.google.com) for backend services
- [fl_chart](https://pub.dev/packages/fl_chart) for data visualization
