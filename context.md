# GitaPearls — Project Context

## Project Overview
iOS app with **home screen and lock screen widgets** displaying Bhagavad Gita verses from Swami Sivananda's public domain translation. **Primary use case: Home screen widgets** (Small, Medium, Large). Lock screen widgets (Rectangular + Circular ॐ pair) also supported as secondary option. Free app, no monetization. **Xcode project created and building successfully.**

---

## Locked Decisions

| Aspect | Decision |
|--------|----------|
| **App Name** | GitaPearls |
| **Bundle ID** | `com.yourname.gitapearls` (update with your name) |
| **Translation** | Swami Sivananda (public domain, legally safe) |
| **Verse Count** | 150 curated essence verses (30 sample verses included) |
| **Monetization** | Free app |
| **Publisher Type** | Individual (no company needed) |
| **Data Storage** | UserDefaults (favorites as ID array) + bundled JSON |
| **Widget Provider** | TimelineProvider — home screen widgets are primary, lock screen widgets secondary |
| **Refresh Expectation** | System-managed, best-effort, UI labels as "throughout the day" |
| **UI Structure** | Single scrollable list + favorites toggle + settings sheet + widget setup onboarding (home screen focused) |
| **iOS Version** | iOS 16+ (for lock screen widget support) |

---

## Data Architecture

### JSON Schema (LOCKED)
```json
{
  "id": 1,
  "chapter": 2,
  "verse": 47,
  "text": "karmanye vadhikaraste ma phaleshu...",
  "meaning": "You have a right to perform your prescribed duties...",
  "reference": "BG 2.47",
  "tags": ["karma", "duty", "detachment"]
}
```

### Storage Strategy
| Data | Storage | Location |
|------|---------|----------|
| All verses | Bundled JSON file | `verses.json` with target membership on BOTH app and widget targets |
| Favorites | UserDefaults | `group.com.yourname.gitapearls` App Group |
| Last displayed | UserDefaults | Same App Group |

**Key:** `verses.json` is added to "Copy Bundle Resources" for both the app target and the widget extension target. Each process gets its own copy in its own bundle.

### UserDefaults Keys
```
- favoriteVerseIDs: [Int] (array of verse IDs)
- lastDisplayedVerseID: Int
- hasCompletedOnboarding: Bool
```

---

## Widget Architecture

### Provider Type
**TimelineProvider** — all configuration happens in main app, not on lock screen widget.

### Timeline Strategy
- Generate entries for next 24 hours
- **12-24 entries** (one every 1-2 hours)
- **Seeded random verse selection** — all widgets show the same verse at any given time (seed based on date/time)
- iOS controls actual refresh timing (best-effort)

### Synchronized Verse Display
All widget instances use a seeded random number generator based on the entry date (year/month/day/hour). This ensures:
- Lock screen and home screen widgets show the same verse simultaneously
- All users see the same verse at the same time of day
- 30% chance to pick from favorites (also seeded for consistency)

### Supported Widget Families
| Family | Content | Font Strategy |
|--------|---------|---------------|
| **accessoryInline** | Reference only — "BG 2.47" | `.caption` |
| **accessoryRectangular** | Full meaning text, 4 lines max | Reference: `.caption`, Meaning: `.caption2` |
| **accessoryCircular** | "ॐ" glyph | `.title` |
| **systemSmall** | Meaning text, top-aligned | Reference: `.caption`, Meaning: `.callout` |
| **systemMedium** | Reference + English meaning only | Reference: `.caption`, Meaning: `.footnote` |
| **systemLarge** | Reference + Sanskrit + divider + English meaning | Reference: `.subheadline`, Meaning: `.body`, Sanskrit: `.callout` |

**Note:** Medium widget intentionally omits Sanskrit text to maximize space for the English meaning. Sanskrit only appears in Large widget.

### Widget Font Hierarchy
- **Reference (BG X.Y)**: `.caption` (lock screen, small, medium), `.subheadline` (large)
- **Meaning text**: `.caption2` (lock screen), `.callout` (small), `.footnote` (medium), `.body` (large)
- **Sanskrit text**: `.callout` (large widget only)
- **ॐ symbol**: `.title` (circular lock screen widget)

### Layout Strategy
- All widgets use `.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)` or `.topLeading` to fill their containers
- Content is top-aligned to avoid empty space at bottom
- No arbitrary character truncation — let SwiftUI handle text flow with `.lineLimit()`

### Lock Screen Constraints
- No color — rendered with vibrant material (system-controlled)
- Minimal text — roughly 4 short lines max for rectangular
- Uses full available width with `.frame(maxWidth: .infinity)`

### Recommended Lock Screen Setup (Secondary)
While home screen widgets are the primary use case, the lock screen pair is also available:

| Position | Widget | Content |
|----------|--------|---------|
| **Left (inline/above clock)** | `accessoryRectangular` | Full verse meaning text |
| **Right (below clock)** | `accessoryCircular` | "ॐ" symbol |

This creates a balanced spiritual aesthetic — the verse text on one side and the sacred Om symbol on the other. Both widgets are deep-linked and will open the app to the same verse when tapped.

### Dark Mode Support
All app views and widgets support dark mode:
- **App views**: ContentView, VerseDetailView, SettingsSheet, WidgetSetupSheet use system colors (`.primary`, `.secondary`, `.secondarySystemBackground`)
- **Home screen widgets**: Use `.primary`/`.secondary` for automatic adaptation
- **Lock screen widgets**: Use system vibrancy (automatically adapts)
- **Previews**: All PreviewProviders include both light and dark mode variants for testing

**Dark Mode Audit Results:**
| View | Status | Notes |
|------|--------|-------|
| ContentView | ✅ | Uses `.secondarySystemBackground` for search bar |
| VerseRowView | ✅ | Uses `.primary`/`.secondary` |
| VerseDetailView | ✅ | Uses `.secondary` for Sanskrit text |
| SettingsSheet | ✅ | Uses system List with default styling |
| WidgetSetupSheet | ✅ | Uses `.secondary` for descriptions |
| Home widgets | ✅ | Uses `.primary`/`.secondary` (changed from `.orange` for better dark mode) |
| Lock screen widgets | ✅ | System vibrancy handles automatically |

### Deep Linking
- Widget tap opens main app to specific verse via `widgetURL`
- URL format: `gitapearls://verse/47`
- `GitaPearlsApp.swift` handles `.onOpenURL` and navigates to `VerseDetailView`
- **All widgets include deep links:** Rectangular, Circular, Inline, Small, Medium, and Large

### Entry Structure
```swift
struct GitaEntry: TimelineEntry {
    let date: Date
    let verse: Verse
}
```

---

## Main App UI

### Single Main View Layout
- **Search bar** at top — filters list in real-time
- **Segmented toggle** — "All" vs "Favorites Only"
- **Gear icon** (toolbar trailing) — opens Settings sheet
- **Question mark icon** (toolbar leading) — opens Widget Setup onboarding

### Verse Detail View
- Layout order: Sanskrit text → English meaning → Tags (at bottom)
- Tags have 12pt top padding to prevent crowding
- 8pt top padding on scroll view to prevent navigation bar overlap
- Full verse text (italic, secondary color)
- Full meaning/translation with line spacing
- Favorite toggle (heart button in toolbar)
- Share button in toolbar
- **Share format (LOCKED):**
  ```
  "BG 2.47 — You have a right to perform your duty... — Bhagavad Gita (Sivananda translation) via GitaPearls"
  ```
- Reference (BG X.Y) shown in navigation title only (not duplicated in content)

### Settings Sheet Contents
- About GitaPearls
- How to add widget (onboarding replay) — **Home screen focused**, with lock screen as secondary option
- Open source credits (Sivananda, JSON source)
- Version info

---

## File Structure

```
GitaPearls/
├── GitaPearlsApp.swift              (app entry point + deep link handling)
├── ContentView.swift                (main list view)
├── Views/
│   ├── VerseRowView.swift           (list row component)
│   ├── VerseDetailView.swift        (full verse view)
│   ├── SettingsSheet.swift          (settings + about)
│   └── WidgetSetupSheet.swift       (onboarding instructions)
├── Models/
│   └── Verse.swift                  (SINGLE shared model)
├── Data/
│   ├── verses.json                  (30 sample verses)
│   └── VerseStore.swift             (UserDefaults wrapper)
├── Widget/
│   ├── GitaPearlsWidget.swift       (widget configuration + supported families)
│   └── Views/
│       ├── InlineWidgetView.swift   (accessoryInline — reference only)
│       ├── RectangularWidgetView.swift (accessoryRectangular — full meaning)
│       ├── CircularWidgetView.swift  (accessoryCircular — "ॐ" glyph)
│       └── HomeWidgetView.swift      (systemSmall/Medium/Large — home screen)
├── Info.plist + Entitlements        (App Groups config + URL scheme)
└── Assets.xcassets                  (App icons)
```

**Key point:** `Verse.swift` is in the `Models/` folder with "Target Membership" set to both app and widget targets. No duplicate files.

---

## Xcode Project Configuration

### Project Created
- **Location**: `~/VibeCoding/Gitapearls/GitaPearls.xcodeproj`
- **Targets**: GitaPearls (app) + GitaPearlsWidgetExtension (widget)
- **Build Status**: ✅ Building successfully for iOS Simulator

### App Group Entitlement (both targets)
```
com.apple.security.application-groups: group.com.yourname.gitapearls
```

### URL Scheme (deep linking)
```
URL Scheme: gitapearls
Format: gitapearls://verse/{id}
```

### App Privacy & Compliance
- **Data collected:** None. No analytics, no tracking, no network calls, no accounts.
- **Third-party SDKs:** None.
- **App Store Privacy Nutrition Label:** Select "Data Not Collected" for all categories.
- **Attribution:** Settings screen credits Swami Sivananda translation + JSON source repo URL.

---

## SwiftUI Previews

All widget views include `PreviewProvider` implementations for testing in Xcode canvas:

| View | Preview Families |
|------|-------------------|
| `InlineWidgetView` | `.accessoryInline` |
| `RectangularWidgetView` | `.accessoryRectangular` |
| `CircularWidgetView` | `.accessoryCircular` |
| `HomeWidgetView` | `.systemSmall`, `.systemMedium`, `.systemLarge` |
| `GitaWidgetEntryView` | All 6 families in one preview group |

---

## Development Notes

### Why Not SwiftData?
- Widget extensions have unreliable SwiftData support on older iOS versions
- UserDefaults is bulletproof for simple ID arrays
- JSON loads instantly for 150 items (no database overhead)
- Simpler code, fewer bugs, faster iteration

### Why TimelineProvider (not IntentTimelineProvider)?
- No user configuration needed on the lock screen widget itself
- All settings managed in main app
- Simpler implementation

### Content Strategy
- 150 curated essence verses from Swami Sivananda translation
- If curated list not found: use full ~700 verse JSON and select most well-known
- Hard cutoff: 2 hours max for content sourcing

---

## Implementation Status

| Phase | Task | Status |
|-------|------|--------|
| **0** | Source files created in ~/Vibecoding/GitaPearls/ | ✅ Completed |
| **1** | Xcode project setup and configuration | ✅ Completed |
| **2** | Data layer code implemented | ✅ Completed |
| **3** | Main app UI code implemented | ✅ Completed |
| **4** | Widget extension code implemented | ✅ Completed |
| **5** | Widget layout refinements (fonts, alignment, sizing) | ✅ Completed |
| **6** | Same verse across all widgets (seeded random) | ✅ Completed |
| **7** | Widget deep linking verified | ✅ Completed |
| **8** | VerseDetailView layout fix (tags at bottom, no overlap) | ✅ Completed |
| **9** | Dark mode audit and fixes | ✅ Completed |
| **10** | App icon design and generation | ✅ Completed |
| **11** | Testing on device, bug fixes | ⏳ Pending |
| **12** | App Store prep (screenshots, privacy policy) | ⏳ Pending |
| **13** | Submission | ⏳ Pending |

**Current Status:** All Swift source code is complete. Key features implemented:
- ✅ Seeded random for synchronized verse display across all widgets
- ✅ VerseDetailView with proper layout (Sanskrit → Meaning → Tags)
- ✅ Dark mode support throughout app and widgets
- ✅ Deep linking from all widget types
- ✅ Medium widget: reference + meaning only (no Sanskrit)
- ✅ Large widget: reference + Sanskrit + divider + meaning
- ✅ App icon generated: glowing pearl with Om on saffron/gold gradient
- ✅ Widget setup onboarding: home screen focused instructions

**Next Steps:**
1. Build and test on physical device
2. Verify dark mode appearance on device
3. Take App Store screenshots (light/dark mode, all widget sizes)
4. Host privacy policy on GitHub Pages (`docs/privacy.html` ready)
5. Configure App Store listing with privacy policy URL
6. Submit to App Store

---

## Quick Reference for AI Agents

**When picking up this project cold:**

1. Read `verses.json` to understand the data structure
2. Check `Verse.swift` for the model definition
3. `VerseStore.swift` handles all UserDefaults operations
4. Widget views are in `Widget/Views/` — separate files for each widget family
5. Deep linking is handled in `GitaPearlsApp.swift` via `.onOpenURL`
6. Both app and widget share `Verse.swift` via target membership (not copying)
7. `verses.json` must be in "Copy Bundle Resources" for BOTH targets

**Common gotchas:**
- Widget can't access main app bundle directly — that's why JSON is in both
- Lock screen widgets are grayscale (vibrant material)
- UserDefaults uses App Group, not standard suite
- widgetURL is the only way to handle taps from lock screen widget
- Home screen widgets use `.body`/`.callout` for meaning, lock screen uses `.caption2`
- All widgets show same verse at same time via seeded random (year/month/day/hour seed)
- VerseDetailView layout order: Sanskrit → Meaning → Tags (with padding)
- Medium widget intentionally excludes Sanskrit (maximize English meaning space)
- Large widget includes Sanskrit + Divider + English meaning
- Dark mode: use `.primary`/`.secondary` not hardcoded colors like `.orange`
