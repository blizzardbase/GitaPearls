import SwiftUI

struct VerseRowView: View {
    let verse: Verse
    @EnvironmentObject var verseStore: VerseStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(verse.reference)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if verseStore.isFavorite(verse.id) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            
            Text(truncatedMeaning)
                .font(.body)
                .lineLimit(2)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 4)
    }
    
    private var truncatedMeaning: String {
        // Return first sentence or first 100 chars
        let firstSentence = verse.meaning.components(separatedBy: ". ").first ?? verse.meaning
        if firstSentence.count > 100 {
            return String(firstSentence.prefix(100)) + "..."
        }
        return firstSentence + "."
    }
}

struct VerseRowView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VerseRowView(verse: Verse.sample)
                .environmentObject(VerseStore.shared)
                .previewDisplayName("Light Mode")
            
            VerseRowView(verse: Verse.sample)
                .environmentObject(VerseStore.shared)
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}