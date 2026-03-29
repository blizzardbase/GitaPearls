# GitaPearls Xcode Setup Guide

This guide walks you through creating the Xcode project and configuring all the necessary settings for the GitaPearls app.

## Prerequisites

- macOS with Xcode 15+ installed
- Apple Developer Account ($99/year for App Store distribution)
- This source code folder at `~/Vibecoding/GitaPearls/`

---

## Step 1: Create Xcode Project

1. Open Xcode
2. File → New → Project
3. Select **iOS → App**
4. Configure:
   - **Name:** GitaPearls
   - **Organization Identifier:** com.yourname (replace with your name)
   - **Interface:** SwiftUI
   - **Language:** Swift
   - **Minimum iOS Version:** 16.0 (required for lock screen widgets)
   - **Include Tests:** Optional (uncheck for now)
5. Save to `~/Vibecoding/` (same level as this source folder)

---

## Step 2: Add Source Files

### Delete Template Files
Delete the auto-generated files:
- `ContentView.swift`
- Any test files you don't need

### Add App Files
1. Right-click project → **Add Files to "GitaPearls"**
2. Select these folders/files from `~/Vibecoding/GitaPearls/GitaPearls/`:
   - `GitaPearlsApp.swift`
   - `ContentView.swift`
   - `Models/` folder
   - `Views/` folder
   - `Data/` folder (includes verses.json)
3. Check **"Copy items if needed"** and select your app target

---

## Step 3: Create Widget Extension

1. File → New → Target
2. Select **iOS → Widget Extension**
3. Configure:
   - **Product Name:** GitaPearlsWidget
   - **Team:** Your Apple ID
   - **Embed in Application:** GitaPearls
4. Click **Finish**
5. When asked to "Activate GitaPearlsWidget scheme", click **Activate**

### Add Widget Files
1. Right-click `GitaPearlsWidget` folder → **Add Files**
2. Select from `~/Vibecoding/GitaPearls/GitaPearlsWidget/`:
   - `GitaPearlsWidget.swift`
   - `Views/` folder
3. Check **"Copy items if needed"** and select the **Widget target only**

---

## Step 4: Configure App Groups (CRITICAL)

Both targets need the same App Group for data sharing.

### For Main App Target:
1. Select project → **GitaPearls** target → **Signing & Capabilities**
2. Click **+ Capability**
3. Add **App Groups**
4. Click **+** under App Groups
5. Enter: `group.com.yourname.gitapearls`
6. Click **Continue** → **Register** → **Done**

### For Widget Target:
1. Select **GitaPearlsWidget** target → **Signing & Capabilities**
2. Click **+ Capability**
3. Add **App Groups**
4. Click **+** and select the SAME group: `group.com.yourname.gitapearls`

**Note:** If you changed the bundle ID, update the App Group and the code accordingly.

---

## Step 5: Add verses.json to Both Targets

The JSON file must be in both bundles:

1. Select `verses.json` in the project navigator
2. In the right panel (File Inspector), check **Target Membership**:
   - ☑️ GitaPearls
   - ☑️ GitaPearlsWidget

---

## Step 6: Configure Deep Linking (URL Types)

1. Select project → **GitaPearls** target → **Info** tab
2. Expand **URL Types**
3. Click **+**
4. Configure:
   - **Identifier:** com.yourname.gitapearls
   - **URL Schemes:** gitapearls
   - **Role:** Editor

---

## Step 7: Update Bundle References in Code

Find and replace in all Swift files:
- `com.yourname.gitapearls` → your actual bundle identifier

Files to check:
- `VerseStore.swift` (App Group reference)
- `GitaPearlsWidget.swift` (App Group reference)

---

## Step 8: Build and Test

1. Select target: **GitaPearls** (not the widget)
2. Choose simulator or device (iOS 16+)
3. Build: **Cmd+B**
4. Run: **Cmd+R**

### Test the Widget:
1. Run on device/simulator
2. Lock screen → Long press → Customize
3. Add GitaPearls widget
4. Lock/unlock to see verse changes

---

## Step 9: Add App Icons

1. Create 1024×1024 PNG icon
2. Assets.xcassets → AppIcon → drop image
3. Xcode auto-generates all sizes

---

## Common Issues & Solutions

### "Cannot find type 'Verse'"
- Ensure `Verse.swift` has target membership for both app AND widget
- Select file → File Inspector → Check both targets

### Widget not refreshing
- Check App Groups are identical in both targets
- Verify `verses.json` is in both targets

### Deep link not working
- Verify URL scheme is set in Info tab
- Use format: `gitapearls://verse/1`

---

## File Structure After Setup

```
GitaPearls.xcodeproj/
├── GitaPearls/
│   ├── GitaPearlsApp.swift
│   ├── ContentView.swift
│   ├── Models/
│   │   └── Verse.swift          ← Target: Both
│   ├── Views/
│   │   ├── VerseRowView.swift
│   │   ├── VerseDetailView.swift
│   │   ├── SettingsSheet.swift
│   │   └── WidgetSetupSheet.swift
│   ├── Data/
│   │   ├── verses.json          ← Target: Both (CRITICAL)
│   │   └── VerseStore.swift
│   ├── Assets.xcassets/
│   └── Info.plist
│
└── GitaPearlsWidget/
    ├── GitaPearlsWidget.swift
    ├── Provider.swift            (included in main widget file)
    └── Views/
        ├── InlineWidgetView.swift
        ├── RectangularWidgetView.swift
        ├── CircularWidgetView.swift
        └── HomeWidgetView.swift
```

---

## Next Steps After Setup

1. Test on real device (widgets don't fully work in simulator)
2. Create App Store screenshots
3. Write privacy policy
4. Submit to App Store

See `context.md` for full project context and architecture details.