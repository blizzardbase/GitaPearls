import SwiftUI

struct CollectionsView: View {
    @State private var collections: [Collection] = []
    @State private var verses: [Verse] = []
    @State private var selectedCollectionID: Int?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(collections) { collection in
                        NavigationLink(value: collection) {
                            CollectionCard(collection: collection)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("Collections")
            .navigationDestination(for: Collection.self) { collection in
                CollectionDetailView(collection: collection, allVerses: verses)
            }
            .onAppear {
                loadCollections()
                loadVerses()
            }
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
                Text("\(collection.verseIDs.count) verses")
                    .font(.caption)
                    .foregroundColor(.secondary)
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
    
    var collectionVerses: [Verse] {
        allVerses.filter { collection.verseIDs.contains($0.id) }
            .sorted { collection.verseIDs.firstIndex(of: $0.id) ?? 0 < collection.verseIDs.firstIndex(of: $1.id) ?? 0 }
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
