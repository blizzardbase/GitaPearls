import SwiftUI

struct VerseDetailView: View {
    let verse: Verse
    @EnvironmentObject var verseStore: VerseStore
    @Environment(\.dismiss) private var dismiss
    @State private var reflectionText: String = ""
    @State private var showClearConfirmation = false
    @FocusState private var isReflectionFocused: Bool
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Context Card
                if let speaker = verse.speaker, let context = verse.context {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.secondary)
                                .font(.caption)
                            Text(speaker)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                        Text(context)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(.tertiarySystemBackground))
                    .cornerRadius(10)
                }
                
                // Sanskrit Text (if available)
                if !verse.text.isEmpty {
                    Text(verse.text)
                        .font(.body)
                        .italic()
                        .foregroundColor(.secondary)
                }
                
                // Meaning
                Text(verse.meaning)
                    .font(.body)
                    .lineSpacing(6)
                
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
                    .padding(.top, 12)
                }
                
                // My Reflection Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "pencil.line")
                            .font(.caption)
                            .foregroundColor(.orange)
                        Text("My Reflection")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    
                    TextEditor(text: $reflectionText)
                        .font(.body)
                        .frame(minHeight: 100)
                        .padding(8)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                        .focused($isReflectionFocused)
                    
                    if !reflectionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Button(action: { 
                            showClearConfirmation = true
                        }) {
                            Text("Clear Reflection")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.top, 8)
                
                Spacer()
            }
            .padding()
            .padding(.top, 8)
        }
        .navigationTitle(verse.reference)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: shareVerse) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: toggleFavorite) {
                    Image(systemName: verseStore.isFavorite(verse.id) ? "heart.fill" : "heart")
                        .foregroundColor(verseStore.isFavorite(verse.id) ? .red : .primary)
                }
            }
        }
        .onAppear {
            reflectionText = verseStore.getReflection(for: verse.id) ?? ""
        }
        .onDisappear {
            let trimmed = reflectionText.trimmingCharacters(in: .whitespacesAndNewlines)
            verseStore.saveReflection(trimmed, for: verse.id)
        }
        .confirmationDialog("Clear Reflection", isPresented: $showClearConfirmation, titleVisibility: .visible) {
            Button("Clear", role: .destructive) {
                reflectionText = ""
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to clear this reflection? This cannot be undone.")
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
            let position = CGPoint(
                x: bounds.minX + result.positions[index].x,
                y: bounds.minY + result.positions[index].y
            )
            subview.place(at: position, proposal: .unspecified)
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
        Group {
            NavigationStack {
                VerseDetailView(verse: Verse.sample)
                    .environmentObject(VerseStore.shared)
            }
            .previewDisplayName("Light Mode")
            
            NavigationStack {
                VerseDetailView(verse: Verse.sample)
                    .environmentObject(VerseStore.shared)
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
    }
}