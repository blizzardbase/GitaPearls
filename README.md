# GitaPearls

A free iOS app that brings the timeless wisdom of the Bhagavad Gita to your lock screen. Each time you unlock your phone, discover a new verse from Swami Sivananda's respected public domain translation.

## Features

- **Lock Screen Widget**: Displays a new verse every time you unlock your phone
- **150 Curated Verses**: Essential teachings from the Bhagavad Gita
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
├── GitaPearlsApp.swift              # App entry point
├── ContentView.swift                # Main list view
├── Views/
│   ├── VerseRowView.swift           # List row component
│   ├── VerseDetailView.swift        # Full verse view
│   ├── SettingsSheet.swift          # Settings + about
│   └── WidgetSetupSheet.swift       # Onboarding instructions
├── Models/
│   └── Verse.swift                  # Shared verse model
├── Data/
│   ├── verses.json                  # 150 curated verses
│   └── VerseStore.swift             # UserDefaults wrapper
├── Widget/
│   ├── GitaPearlsWidget.swift       # Widget configuration
│   ├── Provider.swift               # TimelineProvider
│   └── Views/
│       ├── InlineWidgetView.swift    # accessoryInline
│       ├── RectangularWidgetView.swift # accessoryRectangular
│       └── HomeWidgetView.swift      # Small/medium (optional)
└── Info.plist + Entitlements        # App Groups config
```

## Development Setup

1. Open `GitaPearls.xcodeproj` in Xcode 15+
2. Configure App Group: `group.com.yourname.gitapearls`
3. Build and run on iOS 16+ device/simulator
4. Add widget to lock screen to test

## Privacy

- No data collection
- No analytics
- No network calls
- No third-party SDKs
- All data stays on device

## License

Free app. Swami Sivananda translation is public domain.

## Attribution

- Translation: Swami Sivananda
- JSON source: [To be added when sourced]