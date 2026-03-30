import SwiftUI

enum ViewMode: String, CaseIterable {
    case all = "All"
    case favorites = "Favorites"
    case reflections = "Reflections"
    case collections = "Collections"
}

struct ContentView: View {
    @Binding var selectedVerseID: Int?
    @EnvironmentObject var verseStore: VerseStore
    @State private var searchText = ""
    @State private var showSettings = false
    @State private var showWidgetSetup = false
    @State private var viewMode: ViewMode = .all
    
    @State private var verses: [Verse] = []
    
    var todaysVerse: Verse? {
        guard !verses.isEmpty else { return nil }
        let calendar = Calendar.current
        let today = calendar.dateComponents([.year, .month, .day], from: Date())
        let seed = (today.year ?? 0) * 10000 + (today.month ?? 0) * 100 + (today.day ?? 0)
        var rng = SeededRandom(seed: seed)
        let index = rng.nextInt(in: 0..<verses.count)
        return verses[index]
    }
    
    var filteredVerses: [Verse] {
        var result = verses
        
        if viewMode == .favorites {
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
                // View Mode Segmented Control
                Picker("View Mode", selection: $viewMode) {
                    ForEach(ViewMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 8)
                
                // Content based on view mode
                switch viewMode {
                case .collections:
                    CollectionsView()
                case .reflections:
                    ReflectionsView()
                default:
                    verseListView
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
               let _ = verses.first(where: { $0.id == id }) {
                // Navigate to verse detail
                // This would require NavigationPath management
            }
        }
    }
    
    @ViewBuilder
    private var verseListView: some View {
        VStack(spacing: 0) {
            // Search Bar (only for All and Favorites)
            SearchBar(text: $searchText)
                .padding(.horizontal)
                .padding(.vertical, 8)
            
            // Verse List (with Today's Verse at top when viewing All)
            List {
                if viewMode == .all && searchText.isEmpty, let verse = todaysVerse {
                    Section {
                        NavigationLink(value: verse) {
                            TodaysVerseCard(verse: verse)
                        }
                        .listRowBackground(Color(.secondarySystemBackground))
                    } header: {
                        Text("Today's Verse")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .textCase(nil)
                    }
                }
                
                Section {
                    ForEach(filteredVerses) { verse in
                        NavigationLink(value: verse) {
                            VerseRowView(verse: verse)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationDestination(for: Verse.self) { verse in
                VerseDetailView(verse: verse)
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

// MARK: - Today's Verse Card

struct TodaysVerseCard: View {
    let verse: Verse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(verse.reference)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                Spacer()
                Image(systemName: "sparkles")
                    .font(.caption2)
                    .foregroundColor(.orange)
            }
            
            Text(verse.meaning)
                .font(.callout)
                .lineLimit(3)
                .lineSpacing(3)
            
            if let speaker = verse.speaker, let context = verse.context {
                HStack(spacing: 4) {
                    Image(systemName: "person.circle")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("\(speaker) — \(context)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Seeded Random

struct SeededRandom {
    private var state: UInt64
    
    init(seed: Int) {
        var seed = UInt64(bitPattern: Int64(seed))
        seed = seed &+ 0x9E3779B97F4A7C15
        var z = seed
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        state = z ^ (z >> 31)
    }
    
    mutating func next() -> UInt64 {
        state = state &+ 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
    
    mutating func nextInt(in range: Range<Int>) -> Int {
        let rangeWidth = UInt64(range.upperBound - range.lowerBound)
        let random = next() % rangeWidth
        return range.lowerBound + Int(random)
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