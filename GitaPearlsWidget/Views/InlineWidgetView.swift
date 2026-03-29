import SwiftUI
import WidgetKit

struct InlineWidgetView: View {
    let verse: Verse
    
    var body: some View {
        Text(verse.reference)
            .font(.caption)
            .widgetURL(URL(string: "gitapearls://verse/\(verse.id)"))
    }
}