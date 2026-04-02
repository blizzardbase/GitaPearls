import WidgetKit
import SwiftUI

struct GitaEntry: TimelineEntry {
    let date: Date
    let verse: Verse
    let isFavorite: Bool
    let collectionNames: [String]
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> GitaEntry {
        GitaEntry(date: Date(), verse: Verse.sample, isFavorite: false, collectionNames: ["Detachment from Outcomes"])
    }

    func getSnapshot(in context: Context, completion: @escaping (GitaEntry) -> Void) {
        let result = loadVerse(for: Date())
        let entry = GitaEntry(date: Date(), verse: result.verse, isFavorite: result.isFavorite, collectionNames: result.collectionNames)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<GitaEntry>) -> Void) {
        var entries: [GitaEntry] = []

        // Generate 12 entries over 24 hours (every 2 hours)
        let currentDate = Date()
        for hourOffset in stride(from: 0, through: 22, by: 2) {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let result = loadVerse(for: entryDate)
            let entry = GitaEntry(date: entryDate, verse: result.verse, isFavorite: result.isFavorite, collectionNames: result.collectionNames)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

    private struct VerseResult {
        let verse: Verse
        let isFavorite: Bool
        let collectionNames: [String]
    }

    private struct WidgetCollection: Codable {
        let id: Int
        let title: String
        let description: String
        let verseIDs: [Int]
    }

    private func loadCollections() -> [WidgetCollection] {
        guard let url = Bundle.main.url(forResource: "collections", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([String: [WidgetCollection]].self, from: data) else {
            return []
        }
        return decoded["collections"] ?? []
    }

    private func loadVerse(for date: Date) -> VerseResult {
        // Load from widget's own bundle
        guard let url = Bundle.main.url(forResource: "verses", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([String: [Verse]].self, from: data),
              let verses = decoded["verses"],
              !verses.isEmpty else {
            return VerseResult(verse: Verse.sample, isFavorite: false, collectionNames: [])
        }

        // Get favorites from App Group UserDefaults
        let defaults = UserDefaults(suiteName: "group.com.blizzardbase.gitapearls")
        let favoriteIDs = defaults?.array(forKey: "favoriteVerseIDs") as? [Int] ?? []

        // Create seeded random based on date components (year, month, day, hour)
        // This ensures all widgets show the same verse for the same time slot
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
        let seed = (components.year ?? 0) * 1000000 +
                   (components.month ?? 0) * 10000 +
                   (components.day ?? 0) * 100 +
                   (components.hour ?? 0)

        // 30% chance to pick from favorites (same seeded decision)
        var seededRNG = SeededRandom(seed: seed)
        let pickedFromFavorites = !favoriteIDs.isEmpty && seededRNG.randomInt(in: 0...9) < 3

        let selectedVerse: Verse
        var isFavorite = false

        if pickedFromFavorites {
            let favoriteIndex = seededRNG.randomInt(in: 0..<favoriteIDs.count)
            let favoriteID = favoriteIDs[favoriteIndex]
            if let verse = verses.first(where: { $0.id == favoriteID }) {
                selectedVerse = verse
                isFavorite = true
            } else {
                let verseIndex = seededRNG.randomInt(in: 0..<verses.count)
                selectedVerse = verses[verseIndex]
                isFavorite = favoriteIDs.contains(selectedVerse.id)
            }
        } else {
            let verseIndex = seededRNG.randomInt(in: 0..<verses.count)
            selectedVerse = verses[verseIndex]
            isFavorite = favoriteIDs.contains(selectedVerse.id)
        }

        // Find collections this verse belongs to
        let collections = loadCollections()
        let collectionNames = collections
            .filter { $0.verseIDs.contains(selectedVerse.id) }
            .map { $0.title }

        return VerseResult(verse: selectedVerse, isFavorite: isFavorite, collectionNames: collectionNames)
    }
}

@main
struct GitaPearlsWidget: Widget {
    let kind: String = "GitaPearlsWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            GitaWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("GitaPearls")
        .description("Bhagavad Gita verses on your lock screen")
        .supportedFamilies([
            .accessoryInline,
            .accessoryRectangular,
            .accessoryCircular,
            .systemSmall,
            .systemMedium,
            .systemLarge
        ])
        .contentMarginsDisabled()
    }
}

struct GitaWidgetEntryView: View {
    var entry: GitaEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        if #available(iOSApplicationExtension 17.0, *) {
            widgetContent
                .containerBackground(for: .widget) {
                    Color(.systemBackground)
                }
        } else {
            widgetContent
        }
    }

    private var widgetContent: some View {
        Group {
            switch family {
            case .accessoryInline:
                InlineWidgetView(verse: entry.verse)
            case .accessoryRectangular:
                RectangularWidgetView(verse: entry.verse)
            case .accessoryCircular:
                CircularWidgetView(verse: entry.verse)
            case .systemSmall, .systemMedium, .systemLarge:
                HomeWidgetView(entry: entry)
            default:
                RectangularWidgetView(verse: entry.verse)
            }
        }
    }
}

// MARK: - Previews for all lock screen widget families

struct GitaWidgetEntryView_Previews: PreviewProvider {
    static let sampleEntry = GitaEntry(date: Date(), verse: Verse.sample, isFavorite: true, collectionNames: ["Detachment from Outcomes"])
    
    static var previews: some View {
        Group {
            // Lock screen widgets (grayscale)
            GitaWidgetEntryView(entry: sampleEntry)
                .previewContext(WidgetPreviewContext(family: .accessoryInline))
                .previewDisplayName("Inline")
            
            GitaWidgetEntryView(entry: sampleEntry)
                .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
                .previewDisplayName("Rectangular")
            
            GitaWidgetEntryView(entry: sampleEntry)
                .previewContext(WidgetPreviewContext(family: .accessoryCircular))
                .previewDisplayName("Circular")
            
            // Home screen widgets (color)
            GitaWidgetEntryView(entry: sampleEntry)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDisplayName("Small Home")
            
            GitaWidgetEntryView(entry: sampleEntry)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDisplayName("Medium Home")
            
            GitaWidgetEntryView(entry: sampleEntry)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
                .previewDisplayName("Large Home")
        }
    }
}