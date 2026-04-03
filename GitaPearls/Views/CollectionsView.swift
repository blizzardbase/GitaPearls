import SwiftUI

struct CollectionsView: View {
    @State private var collections: [Collection] = []
    @State private var verses: [Verse] = []
    @State private var selectedCollectionID: Int?
    @State private var searchText = ""
    
    var filteredCollections: [Collection] {
        guard !searchText.isEmpty else { return collections }
        return collections.filter { collection in
            if collection.title.localizedCaseInsensitiveContains(searchText) {
                return true
            }
            let collectionVerseIDs = collection.verseIDs
            let matchingVerses = verses.filter { verse in
                collectionVerseIDs.contains(verse.id) &&
                (verse.meaning.localizedCaseInsensitiveContains(searchText) ||
                 verse.reference.localizedCaseInsensitiveContains(searchText))
            }
            return !matchingVerses.isEmpty
        }
    }
    
    func filteredVerses(for collection: Collection) -> [Verse] {
        guard !searchText.isEmpty else {
            return allVerses(for: collection)
        }
        return allVerses(for: collection).filter { verse in
            verse.meaning.localizedCaseInsensitiveContains(searchText) ||
            verse.reference.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    func allVerses(for collection: Collection) -> [Verse] {
        verses.filter { collection.verseIDs.contains($0.id) }
            .sorted { collection.verseIDs.firstIndex(of: $0.id) ?? 0 < collection.verseIDs.firstIndex(of: $1.id) ?? 0 }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(filteredCollections) { collection in
                    NavigationLink(value: collection) {
                        CollectionCard(collection: collection, filteredVerses: filteredVerses(for: collection), isSearching: !searchText.isEmpty)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .navigationTitle("Collections")
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search collections...")
        .navigationDestination(for: Collection.self) { collection in
            CollectionDetailView(collection: collection, allVerses: verses, searchText: searchText)
        }
        .onAppear {
            loadCollections()
            loadVerses()
        }
    }
    
    private func loadCollections() {
        guard let url = Bundle.main.url(forResource: "collections", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([String: [Collection]].self, from: data) else {
            return
        }
        collections = decoded["collections"] ?? []
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

// MARK: - Collection Card

struct CollectionCard: View {
    let collection: Collection
    var filteredVerses: [Verse]?
    var isSearching: Bool = false
    
    var verseCount: Int {
        filteredVerses?.count ?? collection.verseIDs.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(collection.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(collection.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
                .lineSpacing(2)
            
            HStack {
                Image(systemName: "book.pages")
                    .font(.caption)
                    .foregroundColor(.orange)
                if isSearching, let filtered = filteredVerses {
                    Text("\(filtered.count) matching verses")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("\(verseCount) verses")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Collection Detail View

struct CollectionDetailView: View {
    let collection: Collection
    let allVerses: [Verse]
    var searchText: String = ""
    
    var collectionVerses: [Verse] {
        var verses = allVerses.filter { collection.verseIDs.contains($0.id) }
            .sorted { collection.verseIDs.firstIndex(of: $0.id) ?? 0 < collection.verseIDs.firstIndex(of: $1.id) ?? 0 }
        
        if !searchText.isEmpty {
            verses = verses.filter { verse in
                verse.meaning.localizedCaseInsensitiveContains(searchText) ||
                verse.reference.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return verses
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Description Card
                VStack(alignment: .leading, spacing: 8) {
                    Text("About This Collection")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(collection.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
                .padding()
                .background(Color(.tertiarySystemBackground))
                .cornerRadius(12)
                
                // Verses Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Verses")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                    
                    LazyVStack(spacing: 12) {
                        ForEach(collectionVerses) { verse in
                            NavigationLink(value: verse) {
                                CollectionVerseRow(verse: verse)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle(collection.title)
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(for: Verse.self) { verse in
            VerseDetailView(verse: verse)
        }
    }
}

// MARK: - Collection Verse Row

struct CollectionVerseRow: View {
    let verse: Verse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(verse.reference)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            Text(verse.meaning)
                .font(.subheadline)
                .foregroundColor(.primary)
                .lineLimit(3)
                .lineSpacing(2)
            
            if !verse.tags.isEmpty {
                HStack(spacing: 6) {
                    ForEach(verse.tags.prefix(3), id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color(.tertiarySystemBackground))
                            .cornerRadius(8)
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Previews

struct CollectionsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CollectionsView()
                .previewDisplayName("Collections - Light")
            
            CollectionsView()
                .preferredColorScheme(.dark)
                .previewDisplayName("Collections - Dark")
        }
    }
}
