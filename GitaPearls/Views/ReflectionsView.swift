import SwiftUI

struct ReflectionsView: View {
    @EnvironmentObject var verseStore: VerseStore
    @State private var verses: [Verse] = []
    @State private var selectedVerse: Verse?
    @State private var searchText = ""
    
    var versesWithReflections: [Verse] {
        let reflectionIDs = verseStore.getVersesWithReflections()
        let result = reflectionIDs.compactMap { id in
            verses.first { $0.id == id }
        }
        return result
    }
    
    var filteredVerses: [Verse] {
        guard !searchText.isEmpty else { return versesWithReflections }
        return versesWithReflections.filter { verse in
            let reflection = verseStore.getReflection(for: verse.id) ?? ""
            return verse.meaning.localizedCaseInsensitiveContains(searchText) ||
                   verse.reference.localizedCaseInsensitiveContains(searchText) ||
                   reflection.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    func getReflection(for verse: Verse) -> String {
        verseStore.getReflection(for: verse.id) ?? ""
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                
                ScrollView {
                    if filteredVerses.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: searchText.isEmpty ? "pencil.line" : "magnifyingglass")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary)
                            
                            Text(searchText.isEmpty ? "No Reflections Yet" : "No Matching Reflections")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(searchText.isEmpty ? "Open any verse and write your reflection to see it here." : "Try a different search term.")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        .padding(.top, 60)
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredVerses) { verse in
                                NavigationLink(value: verse) {
                                    ReflectionCard(verse: verse, reflection: getReflection(for: verse))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("My Reflections")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search reflections...")
            .navigationDestination(for: Verse.self) { verse in
                VerseDetailView(verse: verse)
            }
            .onAppear {
                loadVerses()
            }
        }
    }
    
    private func loadVerses() {
        guard let url = Bundle.main.url(forResource: "verses", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([String: [Verse]].self, from: data) else {
            return
        }
        verses = decoded["verses"] ?? []
    }
}

// MARK: - Reflection Card

struct ReflectionCard: View {
    let verse: Verse
    let reflection: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(verse.reference)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Image(systemName: "pencil.line")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
            
            Text(verse.meaning)
                .font(.subheadline)
                .foregroundColor(.primary)
                .lineLimit(2)
            
            Divider()
            
            Text(reflection)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(3)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Previews

struct ReflectionsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ReflectionsView()
                .environmentObject(VerseStore.shared)
                .previewDisplayName("Reflections - Light")
            
            ReflectionsView()
                .environmentObject(VerseStore.shared)
                .preferredColorScheme(.dark)
                .previewDisplayName("Reflections - Dark")
        }
    }
}
