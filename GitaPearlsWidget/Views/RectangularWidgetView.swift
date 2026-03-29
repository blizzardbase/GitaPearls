import SwiftUI
import WidgetKit

struct RectangularWidgetView: View {
    let verse: Verse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(verse.reference)
                .font(.caption)
                .fontWeight(.semibold)
            
            Text(truncatedMeaning)
                .font(.caption)
                .lineLimit(3)
        }
        .widgetURL(URL(string: "gitapearls://verse/\(verse.id)"))
    }
    
    private var truncatedMeaning: String {
        let firstSentence = verse.meaning.components(separatedBy: ". ").first ?? verse.meaning
        if firstSentence.count > 80 {
            return String(firstSentence.prefix(80)) + "..."
        }
        return firstSentence + "."
    }
}