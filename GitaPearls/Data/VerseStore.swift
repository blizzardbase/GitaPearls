import Foundation

class VerseStore: ObservableObject {
    static let shared = VerseStore()
    
    private let defaults: UserDefaults
    private let favoriteVerseIDsKey = "favoriteVerseIDs"
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
        defaults.set(favoriteVerseIDs.sorted(), forKey: favoriteVerseIDsKey)
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

