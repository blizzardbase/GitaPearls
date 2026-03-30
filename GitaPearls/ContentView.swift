import SwiftUI

struct ContentView: View {
    @Binding var selectedVerseID: Int?
    @EnvironmentObject var verseStore: VerseStore
    @State private var searchText = ""
    @State private var showFavoritesOnly = false
    @State private var showSettings = false
    @State private var showWidgetSetup = false
    
    @State private var verses: [Verse] = []
    
    var filteredVerses: [Verse] {
        var result = verses
        
        if showFavoritesOnly {
            result = result.filter { verseStore.isFavorite($0.id) }
        }
        
        if !searchText.isEmpty {
            result = result.filter { verse in
                verse.meaning.localizedCaseInsensitiveContains(searchText) ||
                verse.reference.localizedCaseInsensitiveContains(searchText) ||
                verse.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        return result
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                
                // Favorites Toggle
                Picker("Filter", selection: $showFavoritesOnly) {
                    Text("All Verses").tag(false)
                    Text("Favorites Only").tag(true)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                // Verse List
                List(filteredVerses) { verse in
                    NavigationLink(value: verse) {
                        VerseRowView(verse: verse)
                    }
                }
                .listStyle(.plain)
                .navigationDestination(for: Verse.self) { verse in
                    VerseDetailView(verse: verse)
                }
            }
            .navigationTitle("GitaPearls")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showWidgetSetup = true }) {
                        Image(systemName: "questionmark.circle")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsSheet()
            }
            .sheet(isPresented: $showWidgetSetup) {
                WidgetSetupSheet()
            }
        }
        .onAppear {
            loadVerses()
        }
        .onChange(of: selectedVerseID) { newID in
            if let id = newID,
               let verse = verses.first(where: { $0.id == id }) {
                // Navigate to verse detail
                // This would require NavigationPath management
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

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search verses...", text: $text)
                .textFieldStyle(.plain)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(10)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView(selectedVerseID: .constant(nil))
                .environmentObject(VerseStore.shared)
                .previewDisplayName("Light Mode")
            
            ContentView(selectedVerseID: .constant(nil))
                .environmentObject(VerseStore.shared)
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}