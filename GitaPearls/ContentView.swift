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
    @State private var navigationPath = NavigationPath()
    
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
        NavigationStack(path: $navigationPath) {
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
                    .accessibilityLabel("Widget Setup Guide")
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gear")
                    }
                    .accessibilityLabel("Settings")
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsSheet()
            }
            .sheet(isPresented: $showWidgetSetup) {
                WidgetSetupSheet()
            }
            .navigationDestination(for: Verse.self) { verse in
                VerseDetailView(verse: verse)
            }
        }
        .onAppear {
            loadVerses()
        }
        .onChange(of: selectedVerseID) { newID in
            guard let id = newID else { return }
            if let verse = verses.first(where: { $0.id == id }) {
                navigationPath.append(verse)
            }
            selectedVerseID = nil
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
        }
    }
    
    private func loadVerses() {
        guard let url = Bundle.main.url(forResource: "verses", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([String: [Verse]].self, from: data) else {
            return
        }
        
        verses = decoded["verses"] ?? []
        if let id = selectedVerseID,
           let verse = verses.first(where: { $0.id == id }) {
            navigationPath.append(verse)
            selectedVerseID = nil
        }
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
                .accessibilityLabel("Clear search")
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