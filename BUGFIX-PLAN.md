# GitaPearls — Pre-App Store Fix Plan

**Created**: 2026-04-03
**Source**: Independent code review by frontier agent
**Status**: ALL FIXES MERGED ✅ — 3 agent PRs merged to main
**Estimated effort**: 5-7 hours
**App Store readiness**: YES — all CRITICAL and HIGH issues resolved (2026-04-05)

---

## CRITICAL (must fix before submission) — ✅ ALL FIXED

### C1 — Add Privacy Manifest ✅ FIXED (Agent 1, PR #1)
- `PrivacyInfo.xcprivacy` created with `NSPrivacyAccessedAPITypes` for UserDefaults. Added to both app and widget targets in `project.pbxproj`.

### C2 — Fix iPad Share Sheet Crash ✅ FIXED (Agent 2, PR #3)
- Replaced `UIActivityViewController` with SwiftUI `ShareLink` in `VerseDetailView.swift`.

---

## HIGH (should fix before release) — ✅ ALL FIXED

### H1 — Implement Widget Deep Link Navigation ✅ FIXED (Agent 2, PR #3)
- `NavigationPath` added to `ContentView.swift`. `onChange(of: selectedVerseID)` pushes `VerseDetailView` and clears the binding after navigation.

### H2 — Autosave Reflections ✅ FIXED (Agent 2, PR #3)
- Autosave on `scenePhase` transition to `.background`/`.inactive` in `VerseDetailView.swift`. Debounce task cancelled in `onDisappear` before final save.

---

## MEDIUM (should fix for quality) — ✅ ALL FIXED

### M1 — Add collections.json to Widget Target ✅ FIXED (Agent 1, PR #1)
- `collections.json` added to widget target's Copy Bundle Resources in `project.pbxproj`.

### M2 — Cache JSON in Widget Timeline ✅ FIXED (Agent 3, PR #2)
- Verses and collections decoded once per `getTimeline()` call, not per-entry.

### M3 — Stabilize Favorites Ordering ✅ FIXED (Agent 3, PR #2)
- `VerseStore.swift` now persists favorites as `.sorted()` and sorts again after reading.

### M4 — Add Accessibility Labels ✅ FIXED (Agent 2, PR #3)
- `.accessibilityLabel(...)` added to all toolbar buttons. Decorative icons marked `.accessibilityHidden(true)`.

### M5 — Update Privacy Policy ✅ FIXED (Agent 1, PR #1)
- `privacy.html` updated to disclose local reflection storage (on-device only).

---

## LOW (nice-to-have) — ✅ ALL FIXED

### L1 — Clean Up Navigation Stacking ✅ FIXED (Agent 2, PR #3)
- Inner `NavigationStack` removed from `CollectionsView.swift` and `ReflectionsView.swift`. Single `.searchable` modifier used per screen.

### L2 — Remove Dead Code ✅ FIXED (Agent 3, PR #2)
- `getLastDisplayedVerseID`, `setLastDisplayedVerseID`, `getRandomVerseID` removed from `VerseStore.swift`.

---

## What Passed Review
- Info.plist and entitlements files valid
- App Group wiring consistent across both targets
- verses.json and collections.json valid, no duplicates or missing fields
- All 6 widget families declared with deep link URLs and placeholder fallbacks
- No hardcoded API keys, tokens, or network calls
- No file exceeds 300 lines
- App icon and launch screen configured

---

## Execution Strategy (3 Agents — Sequential + Parallel)

Apply the sequential branching lesson: launch Agent 1 first (it touches project.pbxproj which is a conflict magnet). Merge it. Then launch Agents 2 and 3 in parallel (zero file overlap between them).

### IMPORTANT RULES FOR ALL AGENTS
- **DO NOT modify** files owned by other agents
- Read `context.md` and this `BUGFIX-PLAN.md` before starting
- This is a SwiftUI + WidgetKit iOS project — test with `xcodebuild` if available
- No new dependencies or packages without approval
- Commit to a named branch, push, and create a PR against main

---

### Agent 1: Privacy & Config (launch FIRST, merge before others start)

**Goal**: Fix all privacy, config, and build system issues.

**Files Owned**:
```
PrivacyInfo.xcprivacy (new file — create this)
GitaPearls.xcodeproj/project.pbxproj
privacy.html
```

**Tasks**:
- **C1** — Create `PrivacyInfo.xcprivacy` with `NSPrivacyAccessedAPITypes` for UserDefaults. Add to both app and widget targets in `project.pbxproj`.
- **M1** — Add `GitaPearls/Data/collections.json` to the widget target's Copy Bundle Resources in `project.pbxproj`.
- **M5** — Update `privacy.html` to disclose local reflection storage (on-device only).

**Branch**: `agent-1/privacy-config`

---

### Agent 2: Views & Navigation (launch AFTER Agent 1 merges)

**Goal**: Fix the share sheet crash, implement deep link navigation, add autosave, and improve accessibility across all view files.

**Files Owned**:
```
GitaPearls/Views/VerseDetailView.swift
GitaPearls/ContentView.swift
GitaPearls/Views/CollectionsView.swift
GitaPearls/Views/ReflectionsView.swift
```

**Tasks**:
- **C2** — Replace `UIActivityViewController` in `VerseDetailView.swift` with SwiftUI `ShareLink` (iPad-safe, no popover anchor needed).
- **H1** — Implement deep link navigation in `ContentView.swift`. Add `NavigationPath` or `navigationDestination(item:)`. When `selectedVerseID` changes, push `VerseDetailView` for that verse, then clear the binding.
- **H2** — Add reflection autosave in `VerseDetailView.swift`. Save on text changes with debounce. Also flush on `scenePhase` transition to `.background`/`.inactive`.
- **M4** — Add `.accessibilityLabel(...)` to all image-only toolbar buttons in `ContentView.swift` and `VerseDetailView.swift`. Mark decorative icons as `.accessibilityHidden(true)`.
- **L1** — Clean up `CollectionsView.swift` and `ReflectionsView.swift`: remove inner `NavigationStack`, pick one search UI per screen.

**Branch**: `agent-2/views-navigation`

---

### Agent 3: Data & Widget (launch PARALLEL with Agent 2)

**Goal**: Fix data integrity and widget performance issues.

**Files Owned**:
```
GitaPearls/Models/VerseStore.swift
GitaPearlsWidget/GitaPearlsWidget.swift
```

**Tasks**:
- **M2** — Cache decoded JSON in `GitaPearlsWidget.swift`. Decode verses and collections once per timeline generation instead of per-entry. Use a static cache inside the extension process.
- **M3** — Stabilize favorites ordering in `VerseStore.swift`. Persist as `favoriteVerseIDs.sorted()`. Sort again after reading before seeded indexing.
- **L2** — Remove dead code in `VerseStore.swift`: `getLastDisplayedVerseID`, `setLastDisplayedVerseID`, `getRandomVerseID`, and any unused state properties.

**Branch**: `agent-3/data-widget`

---

### Merge Order
1. **Agent 1** first — touches project.pbxproj (build system file, conflict-prone)
2. **Agent 2** and **Agent 3** merge in either order — zero file overlap between them
3. Run `xcodebuild` after all merges to verify clean build

---

## Verification Checklist (post-fix)
- [ ] `PrivacyInfo.xcprivacy` exists and is included in both targets
- [ ] Share button works on iPad simulator without crashing
- [ ] Tapping any widget navigates to the correct verse in the app
- [ ] Reflections auto-save when backgrounding the app mid-edit
- [ ] Large widget shows collection names
- [ ] Favorites order is stable across widget refreshes
- [ ] VoiceOver reads meaningful labels on all toolbar buttons
- [ ] Privacy policy mentions reflections storage
- [ ] No dead code remains
- [ ] `xcodebuild` succeeds with no warnings on both targets
