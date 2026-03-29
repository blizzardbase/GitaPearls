import SwiftUI

struct VerseDetailView: View {
    let verse: Verse
    @EnvironmentObject var verseStore: VerseStore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Reference Header
                HStack {
                    Text(verse.reference)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: shareVerse) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title3)
                    }
                }
                
                Divider()
                
                // Sanskrit Text (if available)
                if !verse.text.isEmpty {
                    Text(verse.text)
                        .font(.body)
                        .italic()
                        .foregroundColor(.secondary)
                        .padding(.bottom, 8)
                }
                
                // Meaning
                Text(verse.meaning)
                    .font(.body)
                    .lineSpacing(6)
                
                Divider()
                
                // Tags
                if !verse.tags.isEmpty {
                    FlowLayout(spacing: 8) {
                        ForEach(verse.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(12)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle(verse.reference)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: toggleFavorite) {
                    Image(systemName: verseStore.isFavorite(verse.id) ? "heart.fill" : "heart")
                        .foregroundColor(verseStore.isFavorite(verse.id) ? .red : .primary)
                }
            }
        }
    }
    
    private func toggleFavorite() {
        verseStore.toggleFavorite(verse.id)
    }
    
    private func shareVerse() {
        let shareText = "\(verse.reference) — \(verse.meaning.prefix(100))... — Bhagavad Gita (Sivananda translation) via GitaPearls"
        
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        // Present the share sheet
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

// Simple flow layout for tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: result.positions[index], proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

struct VerseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            VerseDetailView(verse: Verse.sample)
                .environmentObject(VerseStore.shared)
        }
    }
}