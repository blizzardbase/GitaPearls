import SwiftUI
import WidgetKit

struct RectangularWidgetView: View {
    let verse: Verse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(verse.reference)
                .font(.caption)
                .fontWeight(.semibold)
            
            Text(verse.meaning)
                .font(.caption2)
                .lineLimit(4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .widgetURL(URL(string: "gitapearls://verse/\(verse.id)"))
    }
}

struct RectangularWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        RectangularWidgetView(verse: Verse.sample)
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
    }
}