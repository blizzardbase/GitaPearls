import WidgetKit
import SwiftUI

struct GitaEntry: TimelineEntry {
    let date: Date
    let verse: Verse
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> GitaEntry {
        GitaEntry(date: Date(), verse: Verse.sample)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (GitaEntry) -> Void) {
        let entry = GitaEntry(date: Date(), verse: loadVerse(for: Date()))
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<GitaEntry>) -> Void) {
        var entries: [GitaEntry] = []
        
        // Generate 12 entries over 24 hours (every 2 hours)
        let currentDate = Date()
        for hourOffset in stride(from: 0, through: 22, by: 2) {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let verse = loadVerse(for: entryDate)
            let entry = GitaEntry(date: entryDate, verse: verse)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    private func loadVerse(for date: Date) -> Verse {
        // Load from widget's own bundle
        guard let url = Bundle.main.url(forResource: "verses", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([String: [Verse]].self, from: data),
              let verses = decoded["verses"],
              !verses.isEmpty else {
            return Verse.sample
        }
        
        // Get favorites from App Group UserDefaults
        let defaults = UserDefaults(suiteName: "group.com.yourname.gitapearls")
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
        let isFavorite = !favoriteIDs.isEmpty && seededRNG.randomInt(in: 0...9) < 3
        
        if isFavorite {
            let favoriteIndex = seededRNG.randomInt(in: 0..<favoriteIDs.count)
            let favoriteID = favoriteIDs[favoriteIndex]
            if let verse = verses.first(where: { $0.id == favoriteID }) {
                return verse
            }
        }
        
        // Pick from all verses using seeded random
        let verseIndex = seededRNG.randomInt(in: 0..<verses.count)
        return verses[verseIndex]
    }
}

// Seeded random number generator for deterministic verse selection
struct SeededRandom {
    private var state: UInt64
    
    init(seed: Int) {
        var hasher = Hasher()
        hasher.combine(seed)
        state = UInt64(abs(hasher.finalize()))
        if state == 0 { state = 1 }
    }
    
    mutating func randomInt(in range: ClosedRange<Int>) -> Int {
        let count = range.upperBound - range.lowerBound + 1
        let randomValue = randomUInt64()
        return range.lowerBound + Int(randomValue % UInt64(count))
    }
    
    mutating func randomInt(in range: Range<Int>) -> Int {
        let count = range.upperBound - range.lowerBound
        let randomValue = randomUInt64()
        return range.lowerBound + Int(randomValue % UInt64(count))
    }
    
    private mutating func randomUInt64() -> UInt64 {
        // Linear congruential generator
        state = 6364136223846793005 &* state &+ 1
        return state
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

// MARK: - Previews for all lock screen widget families

struct GitaWidgetEntryView_Previews: PreviewProvider {
    static let sampleEntry = GitaEntry(date: Date(), verse: Verse.sample)
    
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