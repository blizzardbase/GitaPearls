import SwiftUI
import WidgetKit

struct HomeWidgetView: View {
    let entry: GitaEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallHomeWidget(entry: entry)
        case .systemMedium:
            MediumHomeWidget(entry: entry)
        default:
            SmallHomeWidget(entry: entry)
        }
    }
}

struct SmallHomeWidget: View {
    let entry: GitaEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.verse.reference)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            Text(truncatedMeaning)
                .font(.body)
                .lineLimit(4)
        }
        .padding()
        .widgetURL(URL(string: "gitapearls://verse/\(entry.verse.id)"))
    }
    
    private var truncatedMeaning: String {
        let firstSentence = entry.verse.meaning.components(separatedBy: ". ").first ?? entry.verse.meaning
        if firstSentence.count > 100 {
            return String(firstSentence.prefix(100)) + "..."
        }
        return firstSentence + "."
    }
}

struct MediumHomeWidget: View {
    let entry: GitaEntry
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.verse.reference)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                Text(entry.verse.meaning)
                    .font(.body)
                    .lineLimit(5)
                
                Spacer()
                
                Text("Tap to read more →")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .widgetURL(URL(string: "gitapearls://verse/\(entry.verse.id)"))
    }
}