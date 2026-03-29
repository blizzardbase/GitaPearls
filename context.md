# GitaPearls — Project Context

## Project Overview
iOS app with lock screen widget displaying Bhagavad Gita verses from Swami Sivananda's public domain translation. Free app, no monetization.

---

## Locked Decisions

| Aspect | Decision |
|--------|----------|
| **App Name** | GitaPearls |
| **Bundle ID** | `com.yourname.gitapearls` (update with your name) |
| **Translation** | Swami Sivananda (public domain, legally safe) |
| **Verse Count** | 150 curated essence verses |
| **Monetization** | Free app |
| **Publisher Type** | Individual (no company needed) |
| **Data Storage** | UserDefaults (favorites as ID array) + bundled JSON |
| **Widget Provider** | TimelineProvider (simpler, no lock-screen config) |
| **Refresh Expectation** | System-managed, best-effort, UI labels as "throughout the day" |
| **UI Structure** | Single scrollable list + favorites toggle + settings sheet |
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
- Random verse selection per entry
- iOS controls actual refresh timing (best-effort)

### Lock Screen Widget Families
| Family | Content |
|--------|---------|
| **accessoryInline** | Reference only — "BG 2.47" (single line) |
| **accessoryRectangular** | 2-3 lines of verse text + reference (grayscale) |
| **accessoryCircular** | Chapter number or "ॐ" glyph (optional, low priority) |

### Lock Screen Constraints
- No color — rendered with vibrant material (system-controlled)
- Minimal text — roughly 4 short lines max for rectangular
- Use `ViewThatFits` or manual truncation

### Deep Linking
- Widget tap opens main app to specific verse
- Implement via `widgetURL` encoding verse ID: `gitapearls://verse/47`
- `GitaPearlsApp.swift` handles `.onOpenURL` and navigates to `VerseDetailView`

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
- Full verse text
- Full meaning/translation
- Favorite toggle (heart button)
- **Share format (LOCKED):**
  ```
  "BG 2.47 — You have a right to perform your duty... — Bhagavad Gita (Sivananda translation) via GitaPearls"
  ```
- Reference (BG X.Y)

### Settings Sheet Contents
- About GitaPearls
- How to add widget (onboarding replay)
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
│   ├── verses.json                  (150 curated verses)
│   └── VerseStore.swift             (UserDefaults wrapper)
├── Widget/
│   ├── GitaPearlsWidget.swift       (widget configuration + supported families)
│   ├── Provider.swift               (TimelineProvider implementation)
│   └── Views/
│       ├── InlineWidgetView.swift   (accessoryInline — reference only)
│       ├── RectangularWidgetView.swift (accessoryRectangular — verse snippet)
│       └── HomeWidgetView.swift     (small/medium — richer layout, v1 optional)
└── Info.plist + Entitlements        (App Groups config)
```

**Key point:** `Verse.swift` is in the `Models/` folder with "Target Membership" set to both app and widget targets. No duplicate files.

---

## App Configuration

### App Group Entitlement (both targets)
```
com.apple.security.application-groups: group.com.yourname.gitapearls
```

### App Privacy & Compliance
- **Data collected:** None. No analytics, no tracking, no network calls, no accounts.
- **Third-party SDKs:** None.
- **App Store Privacy Nutrition Label:** Select "Data Not Collected" for all categories.
- **Attribution:** Settings screen credits Swami Sivananda translation + JSON source repo URL.

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
| **1** | Xcode project setup required (see SETUP.md) | ⏳ Ready to start |
| **2** | Data layer code implemented | ✅ Completed |
| **3** | Main app UI code implemented | ✅ Completed |
| **4** | Widget extension code implemented | ✅ Completed |
| **5** | Testing on device, bug fixes | ⏳ Pending |
| **6** | App Store prep (icons, screenshots, privacy policy) | ⏳ Pending |
| **7** | Submission | ⏳ Pending |

**Current Status:** All Swift source code is written and ready. Next step is to create the Xcode project and configure it following SETUP.md.

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