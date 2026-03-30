# GitaPearls

A free iOS app that brings the timeless wisdom of the Bhagavad Gita to your **home screen and lock screen**. Each time you glance at your phone or unlock it, discover a new verse from Swami Sivananda's respected public domain translation.

**Primary use case: Home screen widgets** (Small, Medium, Large). Lock screen widgets (Rectangular verse + ॐ symbol pair) also supported.

## Features

- **Home Screen Widgets** (Primary): Three sizes — Small, Medium (reference + meaning only), and Large (with Sanskrit)
- **Lock Screen Widgets** (Secondary): Rectangular verse text + Circular ॐ symbol as a complementary pair
- **Synchronized Display**: All widgets show the same verse at any given time (seeded random based on time of day)
- **150 Curated Verses**: Essential teachings from the Bhagavad Gita (30 sample verses included, expandable)
- **Browse & Search**: Explore all verses with keyword search
- **Favorites**: Save verses that resonate with you
- **Deep Linking**: Tap any widget to open that verse in the app
- **Free Forever**: No ads, no subscriptions, no tracking

## Technical Details

- **Translation**: Swami Sivananda (public domain)
- **Platform**: iOS 16+ (for lock screen widget support)
- **Architecture**: SwiftUI + WidgetKit + App Groups
- **Data Storage**: UserDefaults (favorites) + Bundled JSON (verses)
- **Xcode Project**: Created and building successfully ✅

## Project Structure

```
GitaPearls/
├── GitaPearlsApp.swift              # App entry point + deep link handling
├── ContentView.swift                # Main list view
├── Views/
│   ├── VerseRowView.swift           # List row component
│   ├── VerseDetailView.swift        # Full verse view
│   ├── SettingsSheet.swift          # Settings + about
│   └── WidgetSetupSheet.swift       # Onboarding instructions
├── Models/
│   └── Verse.swift                  # Shared verse model
├── Data/
│   ├── verses.json                  # 30 sample verses (ready for 150)
│   └── VerseStore.swift             # UserDefaults wrapper
├── Widget/
│   ├── GitaPearlsWidget.swift       # Widget configuration
│   └── Views/
│       ├── InlineWidgetView.swift    # accessoryInline (reference only)
│       ├── RectangularWidgetView.swift # accessoryRectangular (full verse)
│       ├── CircularWidgetView.swift  # accessoryCircular (ॐ symbol)
│       └── HomeWidgetView.swift      # systemSmall/Medium/Large
├── GitaPearls.xcodeproj             # ✅ Xcode project (building)
├── Info.plist + Entitlements        # App Groups + URL scheme config
└── Assets.xcassets                  # App icons
```

## Widget Specifications

| Widget | Size | Content | Font |
|--------|------|---------|------|
| Small | Home | Meaning, top-aligned | Reference: `.caption`, Meaning: `.callout` |
| Medium | Home | **Reference + English meaning only** | Reference: `.caption`, Meaning: `.footnote` |
| Large | Home | Reference + Sanskrit + Divider + Meaning | Reference: `.subheadline`, Meaning: `.body`, Sanskrit: `.callout` |
| Inline | Lock Screen | Reference only (BG 2.47) | `.caption` |
| Rectangular | Lock Screen | Full meaning, 4 lines | Reference: `.caption`, Meaning: `.caption2` |
| Circular | Lock Screen | ॐ symbol | `.title` |

**Note:** Medium widget intentionally omits Sanskrit to maximize English meaning space. Sanskrit only appears in Large widget.

## Development Setup

### ✅ Quick Start (Xcode Project Ready)

The Xcode project has been created and is building successfully:

```bash
open ~/VibeCoding/Gitapearls/GitaPearls.xcodeproj
```

1. **Update Bundle ID**: Change `com.yourname.gitapearls` to your identifier
2. **Add Team ID**: In Signing & Capabilities, select your Apple Developer team
3. **Configure App Group**: Update `group.com.yourname.gitapearls` to match your team prefix
4. **Build & Run**: Select iPhone simulator or device (iOS 16+)
5. **Test Widgets**: Add widgets to lock screen and home screen

### Manual Setup (if needed)

1. Create new iOS app project in Xcode 15+
2. Add Widget Extension target
3. Copy all Swift files from this folder
4. Configure App Groups for both targets
5. Add `verses.json` to "Copy Bundle Resources" for both targets
6. Configure URL scheme `gitapearls` for deep linking

## Files Included

| File | Purpose |
|------|---------|
| `README.md` | This file — project overview |
| `context.md` | Architecture decisions and agent reference |
| `SETUP.md` | Step-by-step Xcode setup guide (legacy) |
| `verses.json` | Sample verses (30 included, ready for 150) |
| `*.swift` | All source code — app + widget |
| `GitaPearls.xcodeproj` | ✅ Xcode project (configured and building) |

## SwiftUI Previews

All widget views include Xcode canvas previews:
- Lock screen widgets: inline, rectangular, circular
- Home screen widgets: small, medium, large
- Combined preview showing all 6 families

## Privacy

- No data collection
- No analytics
- No network calls
- No third-party SDKs
- All data stays on device

## License

Free app. Swami Sivananda translation is public domain.

## Attribution

- **Translation**: Swami Sivananda (public domain)
- **Verses**: 30 sample verses from Bhagavad Gita chapters 2-18
- **App**: Open source — feel free to expand to 150 verses

## Current Status

✅ **Xcode project created and building**  
✅ **All Swift source code complete**  
✅ **Widgets configured with optimized layouts**  
✅ **App icon generated (1024×1024 PNG)**  
✅ **SwiftUI Previews added for all widget families**  
✅ **Dark mode support throughout**  
⏳ **Ready for device testing**  
⏳ **Ready for App Store submission prep**

## Next Steps

1. Test on physical device (widgets work best on real devices)
2. Verify dark mode appearance on device
3. Create App Store listing with screenshots (light + dark mode)
4. Enable GitHub Pages for privacy policy (`docs/privacy.html`)
5. Submit for review
