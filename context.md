# GitaPearls — Project Context

## Current Status (2026-04-05)
- **Code complete and App Store ready** — all 11 issues from independent review fixed and merged
- All 3 agent PRs merged to main (PR #1 privacy/config, PR #2 data/widget, PR #3 views/navigation)
- See `BUGFIX-PLAN.md` for full fix details
- **Next steps**: Screenshots → Archive & Upload → App Store Connect listing

## Project Overview
iOS app with **home screen and lock screen widgets** displaying Bhagavad Gita verses from Swami Sivananda's public domain translation. **Primary use case: Home screen widgets** (Small, Medium, Large). Lock screen widgets (Rectangular + Circular ॐ pair) also supported as secondary option. Free app, no monetization. **Xcode project created and building successfully.**

---

## Locked Decisions

| Aspect | Decision |
|--------|----------|
| **App Name** | GitaPearls |
| **Bundle ID** | `com.yourname.gitapearls` (update with your name) |
| **Translation** | Swami Sivananda (public domain, legally safe) |
| **Verse Count** | 30 curated essence verses |
| **Monetization** | Free app |
| **Publisher Type** | Individual (no company needed) |
| **Data Storage** | UserDefaults (favorites as ID array) + bundled JSON |
| **Widget Provider** | TimelineProvider — home screen widgets are primary, lock screen widgets secondary |
| **Refresh Expectation** | System-managed, best-effort, UI labels as "throughout the day" |
| **UI Structure** | Single scrollable list + favorites toggle + collections + reflections + settings sheet + widget setup onboarding (home screen focused) |
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
- **Search bar** at top — filters list in real-time (available on All, Favorites, Collections, and Reflections tabs)
- **Segmented toggle** — "All", "Favorites", "Collections", "Reflections"
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
│   ├── CollectionsView.swift       (themed verse collections)
│   ├── ReflectionsView.swift       (personal reflection journal)
│   ├── SettingsSheet.swift          (settings + about)
│   └── WidgetSetupSheet.swift       (onboarding instructions)
├── Models/
│   ├── Verse.swift                  (SINGLE shared model)
│   ├── Collection.swift            (collection model)
│   └── SeededRandom.swift           (SINGLE shared seeded RNG)
├── Data/
│   ├── verses.json                  (30 verse data)
│   ├── VerseStore.swift             (UserDefaults wrapper)
│   └── collections.json             (themed collections)
├── Widget/
│   ├── GitaPearlsWidget.swift       (widget configuration + supported families)
│   └── Views/
│       ├── InlineWidgetView.swift   (accessoryInline — reference only)
│       ├── RectangularWidgetView.swift (accessoryRectangular — full meaning)
│       ├── CircularWidgetView.swift  (accessoryCircular — "ॐ" glyph)
│       └── HomeWidgetView.swift      (systemSmall/Medium/Large — home screen)
├── Info.plist + Entitlements        (App Groups config + URL scheme)
└── Assets.xcassets                  (App icons + AccentColor)
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
- 30 curated essence verses from Swami Sivananda translation
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
| **11a** | Bundle ID updated to com.blizzardbase.gitapearls | ✅ Completed (2026-04-02) |
| **11b** | Verses expanded from 30 to 150 (all 18 chapters) | ✅ Completed (2026-04-02) |
| **11c** | Developer account activated | ✅ Completed (2026-04-02) |
| **12** | Update bundle ID in Xcode project settings (both targets + App Group) | ✅ Completed (2026-04-02) |
| **13a** | containerBackground API fix for iOS 17+ widgets | ✅ Completed (2026-04-02) |
| **13b** | Small widget font fix (callout → footnote to match medium) | ✅ Completed (2026-04-02) |
| **13c** | Large widget: favorite indicator, tags, collection names | ✅ Completed (2026-04-02) |
| **13d** | Collections expanded from 6 to 12, referencing all 150 verses | ✅ Completed (2026-04-02) |
| **13e** | Device testing on Harish's iPhone | ✅ Completed (2026-04-02) — app, widgets, search, favorites, collections, reflections, dark mode all working |
| **13f** | Privacy policy hosted on GitHub Pages | ✅ Completed (2026-04-03) — https://blizzardbase.github.io/GitaPearls/privacy.html |
| **13g** | Repo made public | ✅ Completed (2026-04-03) — https://github.com/blizzardbase/GitaPearls |
| **14a** | Privacy manifest (PrivacyInfo.xcprivacy) | ✅ Completed (2026-04-05, Agent 1 PR #1) |
| **14b** | iPad share sheet crash fix (ShareLink) | ✅ Completed (2026-04-05, Agent 2 PR #3) |
| **14c** | Widget deep link navigation | ✅ Completed (2026-04-05, Agent 2 PR #3) |
| **14d** | Reflection autosave on background | ✅ Completed (2026-04-05, Agent 2 PR #3) |
| **14e** | collections.json in widget target | ✅ Completed (2026-04-05, Agent 1 PR #1) |
| **14f** | Widget JSON caching + favorites order fix | ✅ Completed (2026-04-05, Agent 3 PR #2) |
| **14g** | Accessibility labels on toolbar buttons | ✅ Completed (2026-04-05, Agent 2 PR #3) |
| **14h** | Privacy policy updated (reflections) | ✅ Completed (2026-04-05, Agent 1 PR #1) |
| **14i** | Nav stack cleanup + dead code removal | ✅ Completed (2026-04-05, Agents 2+3) |
| **15** | App Store screenshots | ⏳ Pending |
| **16** | Archive and upload to App Store Connect | ⏳ Pending |
| **17** | App Store Connect listing + submit | ⏳ Pending |

**Current Status:** App is code-complete, all review issues fixed, tested on device. Ready for screenshots and App Store submission.

**Key facts:**
- Bundle ID: `com.blizzardbase.gitapearls`
- Team: Harish Vasudevan
- Contact email: contact@blizzardcollective.xyz
- GitHub: https://github.com/blizzardbase/GitaPearls (public)
- Privacy policy: https://blizzardbase.github.io/GitaPearls/privacy.html
- App Store checklist on Notion: https://www.notion.so/3327ed89602581f0bb5fd292dcf3e4c9

**All features implemented:**
- ✅ 150 verses across all 18 Gita chapters
- ✅ 12 thematic collections
- ✅ Seeded random for synchronized verse display across all widgets
- ✅ VerseDetailView with proper layout (Sanskrit → Meaning → Tags)
- ✅ Dark mode support throughout app and widgets
- ✅ Deep linking from all widget types
- ✅ Medium widget: reference + meaning only (no Sanskrit)
- ✅ Large widget: reference + Sanskrit + divider + meaning + favorite heart + tags + collection names
- ✅ App icon generated: glowing pearl with Om on saffron/gold gradient
- ✅ Widget setup onboarding: home screen focused instructions
- ✅ Verse-of-the-day with speaker and context card
- ✅ Personal reflection journal per verse
- ✅ SeededRandom unified across app and widget targets
- ✅ Search bar across all 4 tabs (All, Favorites, Collections, Reflections)
- ✅ containerBackground for iOS 17+ widget compatibility
- ✅ Small widget font matched to medium widget

**Next session — 3 steps to App Store:**
1. **Screenshots** — need 6.9" (iPhone 16 Pro Max, 1320x2868) and 5.5" (iPhone 8 Plus, 1242x2208). Use Simulator. Need: app list, verse detail, widget on home screen, widget on lock screen.
2. **Archive & Upload** — Xcode → Product → Archive → Distribute to App Store Connect
3. **App Store Connect listing** — fill in name, subtitle, description, keywords, screenshots, review notes, then submit. All details on the Notion checklist.

**Pre-archive checks:**
- Verify launch screen (no white flash)
- Confirm Version 1.0, Build 1
- Test on Simulator for SE and Pro Max sizes

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
