import Foundation

class VerseStore: ObservableObject {
    static let shared = VerseStore()
    
    private let defaults: UserDefaults
    private let favoriteVerseIDsKey = "favoriteVerseIDs"
    private let lastDisplayedVerseIDKey = "lastDisplayedVerseID"
    private let hasCompletedOnboardingKey = "hasCompletedOnboarding"
    private let reflectionsKey = "reflections"
    
    @Published var favoriteVerseIDs: Set<Int> = []
    @Published var reflections: [Int: String] = [:]
    
    init() {
        // Use App Group for sharing with widget
        self.defaults = UserDefaults(suiteName: "group.com.blizzardbase.gitapearls") ?? .standard
        loadFavorites()
        loadReflections()
    }
    
    // MARK: - Favorites
    
    private func loadFavorites() {
        let ids = defaults.array(forKey: favoriteVerseIDsKey) as? [Int] ?? []
        favoriteVerseIDs = Set(ids)
    }
    
    private func saveFavorites() {
        defaults.set(Array(favoriteVerseIDs), forKey: favoriteVerseIDsKey)
    }
    
    func isFavorite(_ verseID: Int) -> Bool {
        favoriteVerseIDs.contains(verseID)
    }
    
    func toggleFavorite(_ verseID: Int) {
        if favoriteVerseIDs.contains(verseID) {
            favoriteVerseIDs.remove(verseID)
        } else {
            favoriteVerseIDs.insert(verseID)
        }
        saveFavorites()
    }
    
    func addFavorite(_ verseID: Int) {
        favoriteVerseIDs.insert(verseID)
        saveFavorites()
    }
    
    func removeFavorite(_ verseID: Int) {
        favoriteVerseIDs.remove(verseID)
        saveFavorites()
    }
    
    // MARK: - Last Displayed
    
    func getLastDisplayedVerseID() -> Int? {
        let id = defaults.integer(forKey: lastDisplayedVerseIDKey)
        return id == 0 ? nil : id
    }
    
    func setLastDisplayedVerseID(_ id: Int) {
        defaults.set(id, forKey: lastDisplayedVerseIDKey)
    }
    
    // MARK: - Onboarding
    
    func hasCompletedOnboarding() -> Bool {
        defaults.bool(forKey: hasCompletedOnboardingKey)
    }
    
    func setCompletedOnboarding(_ completed: Bool = true) {
        defaults.set(completed, forKey: hasCompletedOnboardingKey)
    }
    
    // MARK: - Reflections
    
    private func loadReflections() {
        if let data = defaults.data(forKey: reflectionsKey),
           let decoded = try? JSONDecoder().decode([Int: String].self, from: data) {
            reflections = decoded
        }
    }
    
    private func saveReflections() {
        if let encoded = try? JSONEncoder().encode(reflections) {
            defaults.set(encoded, forKey: reflectionsKey)
        }
    }
    
    func getReflection(for verseID: Int) -> String? {
        reflections[verseID]
    }
    
    func saveReflection(_ text: String, for verseID: Int) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            reflections.removeValue(forKey: verseID)
        } else {
            reflections[verseID] = trimmed
        }
        saveReflections()
    }
    
    func hasReflection(for verseID: Int) -> Bool {
        guard let text = reflections[verseID] else { return false }
        return !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func getVersesWithReflections() -> [Int] {
        reflections.keys.filter { id in
            guard let text = reflections[id] else { return false }
            return !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }.sorted()
    }
}

// MARK: - Widget Support

extension VerseStore {
    /// Get a random verse ID, optionally weighted toward favorites
    func getRandomVerseID(from allVerseIDs: [Int]) -> Int {
        let favoriteIDs = Array(favoriteVerseIDs)
        
        // 30% chance to pick from favorites if favorites exist
        if !favoriteIDs.isEmpty && Int.random(in: 0...9) < 3 {
            return favoriteIDs.randomElement()!
        }
        
        return allVerseIDs.randomElement()!
    }
}