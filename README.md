# 🐾 Focus Pet

> **A retro pixel companion that punishes your bad app habits.**  
> Open a distracting app — your pet attacks you. Stay focused — it thrives.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat-square&logo=flutter&logoColor=white)
![Kotlin](https://img.shields.io/badge/Kotlin-Android-7F52FF?style=flat-square&logo=kotlin&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?style=flat-square&logo=android&logoColor=white)
![Architecture](https://img.shields.io/badge/Architecture-MVVM-FF6B35?style=flat-square)

---

## 📖 What Is This?

Focus Pet is an Android app built with Flutter that helps you stay off distracting apps by giving you a virtual pixel pet that **reacts to your behavior**. Monitored apps are selected by you — whenever you open one, your pet interrupts you with an overlay animation. Stay disciplined and your pet stays happy.

It combines a Flutter UI frontend with native Android services (Kotlin) for overlay rendering and accessibility-based app monitoring.

---

## ✨ Features

- 🐶 **Pixel Pet Companions** — Choose from dogs, cats, rats, and birds with idle, walk, and attack animations
- 📱 **App Usage Monitoring** — Uses Android Accessibility Service to detect when monitored apps are opened
- 🪟 **System Overlay** — Pet appears on top of any app via `SYSTEM_ALERT_WINDOW`
- 🔥 **Focus Stats** — Tracks streaks, sessions, and time saved
- ⏱️ **Customizable Timers** — Set interrupt delay, walk delay, and reaction delay per pet
- 🌙 **Always-Active Mode** — Optional continuous monitoring toggle
- 🎨 **Retro Pixel UI** — Full 8-bit theme with Press Start 2P font and chunky pixel widgets
- 🔌 **Platform Channel Bridge** — Clean Flutter ↔ Kotlin communication layer

---


## 🏗️ Architecture

Focus Pet follows **MVVM** with a clear separation between Flutter UI and native Android logic.

```
┌──────────────────────────────────────────┐
│             Flutter (Dart)               │
│                                          │
│   Screens  →  ViewModels  →  Services   │
│   (UI)       (Business)    (Channels)   │
└─────────────────────┬────────────────────┘
                      │  Method Channel
                      │  com.project.focuspet/native
┌─────────────────────▼────────────────────┐
│             Android (Kotlin)             │
│                                          │
│   MainActivity  →  PetOverlayService    │
│                 →  AppMonitorService    │
└──────────────────────────────────────────┘
```

### Layer Breakdown

| Layer | Location | Responsibility |
|-------|----------|----------------|
| **UI** | `lib/ui/screens/` | Screens and widgets |
| **ViewModel** | `lib/viewmodels/` | Business logic, state |
| **Data** | `lib/data/` | SharedPreferences wrapper |
| **Domain** | `lib/domain/` | Pet models and enums |
| **Platform** | `lib/services/` | Flutter side of channel |
| **Native** | `android/.../kotlin/` | Overlay + monitoring services |

---

## 📁 Project Structure

```
focus_pet/
├── lib/
│   ├── main.dart
│   ├── data/
│   │   └── app_preferences.dart        # Local storage
│   ├── domain/
│   │   └── pet_type.dart               # Pet enums & models
│   ├── services/
│   │   └── platform_service.dart       # Android method channel
│   ├── viewmodels/
│   │   ├── home_viewmodel.dart
│   │   ├── pet_select_viewmodel.dart
│   │   └── app_select_viewmodel.dart
│   └── ui/
│       ├── theme/
│       │   └── pixel_theme.dart        # Retro 8-bit theme system
│       ├── widgets/
│       │   └── pet_sprite_widget.dart  # Sprite sheet renderer
│       └── screens/
│           ├── main_screen.dart
│           ├── home_screen.dart
│           ├── pet_select_screen.dart
│           └── app_select_screen.dart
│
└── android/app/src/main/kotlin/com/project/focuspet/
    ├── MainActivity.kt                 # Platform channel handler
    ├── service/
    │   ├── PetOverlayService.kt
    │   └── AppMonitorService.kt
    ├── overlay/
    │   └── PetSpriteView.kt
    └── domain/
        ├── PetType.kt
        └── PetAnimState.kt
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter 3.x — [Install Flutter](https://flutter.dev/docs/get-started/install)
- Android Studio or VS Code with Flutter plugin
- Physical Android device (overlay + accessibility don't work on emulator)

### 1. Clone the repo

```bash
git clone https://github.com/yourusername/focus-pet.git
cd focus-pet
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Add sprite assets

Place your sprite sheets in `assets/sprites/`:

```
assets/sprites/
├── dog1_idle.png   dog1_walk.png   dog1_attack.png
├── dog2_idle.png   dog2_walk.png   dog2_attack.png
├── cat1_idle.png   cat1_walk.png   cat1_attack.png
├── cat2_idle.png   cat2_walk.png   cat2_attack.png
├── rat1_idle.png   rat1_walk.png
├── rat2_idle.png   rat2_walk.png
├── bird1_idle.png  bird1_walk.png
└── bird2_idle.png  bird2_walk.png
```

### 4. Run

```bash
flutter run
```

---

## 🔒 Required Permissions

| Permission | Purpose |
|---|---|
| `SYSTEM_ALERT_WINDOW` | Draw pet overlay on top of other apps |
| `FOREGROUND_SERVICE` | Keep pet service alive in background |
| `POST_NOTIFICATIONS` | Show foreground service notification |
| Accessibility Service | Detect which app is currently in focus |

> Both overlay and accessibility permissions must be manually granted by the user on first launch. The app will guide them through this.

---

## 🔌 Platform Channel API

All native Android functionality is exposed to Flutter through a single method channel (`com.project.focuspet/native`).

```dart
// Permissions
await platform.canDrawOverlays()              // → bool
await platform.requestOverlayPermission()     // → void
await platform.isAccessibilityEnabled()       // → bool

// Service control
await platform.startPetService()              // → void
await platform.stopPetService()               // → void
await platform.isPetServiceRunning()          // → bool

// Pet visibility
await platform.showPet()
await platform.hidePet()

// App monitoring
await platform.getInstalledApps()             // → List<InstalledApp>
await platform.updateMonitoredApps(appSet)    // → void
await platform.updatePetSettings(...)         // → void
```

---

## 🎨 Pixel UI System

The `PixelTheme` class provides a full retro widget toolkit:

```dart
// Chunky bordered card
PixelCard(
  borderColor: PixelTheme.accent,
  selected: true,
  child: Text('content'),
)

// 3D press-effect button
PixelButton(
  label: '[ START ]',
  onPressed: () {},
)

// Section header, big stat, divider, checkbox, progress bar
PixelSectionLabel('STATS')
PixelBigValue('🔥 5', color: PixelTheme.accent)
PixelDivider()
PixelCheckbox(checked: true)
PixelProgressBar(value: 0.72)
```

### Swap the color palette

Edit `lib/ui/theme/pixel_theme.dart`:

```dart
// Gameboy Green
static const Color bg     = Color(0xFF0F380F);
static const Color accent = Color(0xFF9BBC0F);

// Cyberpunk
static const Color bg     = Color(0xFF0F0F23);
static const Color accent = Color(0xFF00F0FF);
```

---

## 📦 Dependencies

| Package | Version | Purpose |
|---|---|---|
| `provider` | ^6.1.1 | State management (MVVM) |
| `google_fonts` | ^6.1.0 | Press Start 2P pixel font |
| `shared_preferences` | ^2.2.2 | Local settings storage |
| `permission_handler` | ^11.0.1 | Android runtime permissions |

---

## 🏗️ Building a Release APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`
