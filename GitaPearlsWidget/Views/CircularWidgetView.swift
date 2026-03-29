import SwiftUI
import WidgetKit

struct CircularWidgetView: View {
    let verse: Verse
    
    var body: some View {
        ZStack {
            Circle()
                .fill(.clear)
            
            Text("ॐ")
                .font(.title)
                .fontWeight(.light)
        }
        .widgetURL(URL(string: "gitapearls://verse/\(verse.id)"))
    }
}

struct CircularWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        CircularWidgetView(verse: Verse.sample)
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
    }
}