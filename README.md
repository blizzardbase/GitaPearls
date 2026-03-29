# GitaPearls

A free iOS app that brings the timeless wisdom of the Bhagavad Gita to your lock screen. Each time you unlock your phone, discover a new verse from Swami Sivananda's respected public domain translation.

## Features

- **Lock Screen Widget**: Displays a new verse every time you unlock your phone
- **150 Curated Verses**: Essential teachings from the Bhagavad Gita (30 sample verses included, expandable)
- **Browse & Search**: Explore all verses with keyword search
- **Favorites**: Save verses that resonate with you
- **Free Forever**: No ads, no subscriptions, no tracking

## Technical Details

- **Translation**: Swami Sivananda (public domain)
- **Platform**: iOS 16+ (for lock screen widget support)
- **Architecture**: SwiftUI + WidgetKit + App Groups
- **Data Storage**: UserDefaults (favorites) + Bundled JSON (verses)

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
│   ├── verses.json                  # 150 curated verses (30 samples included)
│   └── VerseStore.swift             # UserDefaults wrapper
├── Widget/
│   ├── GitaPearlsWidget.swift       # Widget configuration
│   ├── Provider.swift               # TimelineProvider
│   └── Views/
│       ├── InlineWidgetView.swift    # accessoryInline
│       ├── RectangularWidgetView.swift # accessoryRectangular
│       ├── CircularWidgetView.swift  # accessoryCircular
│       └── HomeWidgetView.swift      # Small/medium (optional)
└── Info.plist + Entitlements        # App Groups config
```

## Development Setup

**Source code is ready at `~/Vibecoding/GitaPearls/`**

### Option 1: Use Existing Source (Recommended)

1. Follow `SETUP.md` for detailed Xcode project creation instructions
2. Configure App Group: `group.com.yourname.gitapearls`
3. Update bundle references in code to match your Apple ID
4. Build and run on iOS 16+ device/simulator
5. Add widget to lock screen to test

### Option 2: Manual Setup

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
| `SETUP.md` | Step-by-step Xcode setup guide |
| `verses.json` | Sample verses (30 included, ready for 150) |
| `*.swift` | All source code ready to compile |

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

## Next Steps

1. Create Apple Developer Account ($99/year)
2. Follow `SETUP.md` to create Xcode project
3. Test on physical device (widgets work best on real devices)
4. Create App Store listing with screenshots
5. Submit for review