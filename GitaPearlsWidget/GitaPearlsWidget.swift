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
        let entry = GitaEntry(date: Date(), verse: loadRandomVerse())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<GitaEntry>) -> Void) {
        var entries: [GitaEntry] = []
        
        // Generate 12 entries over 24 hours (every 2 hours)
        let currentDate = Date()
        for hourOffset in stride(from: 0, through: 22, by: 2) {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let verse = loadRandomVerse()
            let entry = GitaEntry(date: entryDate, verse: verse)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    private func loadRandomVerse() -> Verse {
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
        
        // 30% chance to pick from favorites
        if !favoriteIDs.isEmpty, Int.random(in: 0...9) < 3 {
            let favoriteID = favoriteIDs.randomElement()!
            if let verse = verses.first(where: { $0.id == favoriteID }) {
                return verse
            }
        }
        
        return verses.randomElement() ?? Verse.sample
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
            .systemMedium
        ])
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
        case .systemSmall, .systemMedium:
            HomeWidgetView(entry: entry)
        default:
            RectangularWidgetView(verse: entry.verse)
        }
    }
}

struct GitaWidget_Previews: PreviewProvider {
    static var previews: some View {
        GitaWidgetEntryView(entry: GitaEntry(date: Date(), verse: Verse.sample))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
    }
}