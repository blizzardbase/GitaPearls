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

struct InlineWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        InlineWidgetView(verse: Verse.sample)
            .previewContext(WidgetPreviewContext(family: .accessoryInline))
    }
}