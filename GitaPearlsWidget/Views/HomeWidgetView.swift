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
        case .systemLarge:
            LargeHomeWidget(entry: entry)
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
            
            Text(entry.verse.meaning)
                .font(.callout)
                .lineLimit(8)
            
            Spacer(minLength: 0)
        }
        .padding()
        .widgetURL(URL(string: "gitapearls://verse/\(entry.verse.id)"))
    }
}

struct MediumHomeWidget: View {
    let entry: GitaEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(entry.verse.reference)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            Text(entry.verse.meaning)
                .font(.footnote)
                .lineLimit(8)
            
            Spacer(minLength: 0)
        }
        .padding()
        .widgetURL(URL(string: "gitapearls://verse/\(entry.verse.id)"))
    }
}

struct LargeHomeWidget: View {
    let entry: GitaEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(entry.verse.reference)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.orange)
            
            if !entry.verse.text.isEmpty {
                Text(entry.verse.text)
                    .font(.callout)
                    .italic()
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            Divider()
            
            Text(entry.verse.meaning)
                .font(.body)
                .lineLimit(12)
            
            Spacer(minLength: 0)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .widgetURL(URL(string: "gitapearls://verse/\(entry.verse.id)"))
    }
}

// MARK: - Previews

struct HomeWidgetView_Previews: PreviewProvider {
    static let sampleEntry = GitaEntry(date: Date(), verse: Verse.sample)
    
    static var previews: some View {
        Group {
            HomeWidgetView(entry: sampleEntry)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDisplayName("Small Home")
            
            HomeWidgetView(entry: sampleEntry)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDisplayName("Medium Home")
            
            HomeWidgetView(entry: sampleEntry)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
                .previewDisplayName("Large Home")
        }
    }
}
