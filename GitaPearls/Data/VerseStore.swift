import Foundation

class VerseStore: ObservableObject {
    static let shared = VerseStore()
    
    private let defaults: UserDefaults
    private let favoriteVerseIDsKey = "favoriteVerseIDs"
    private let lastDisplayedVerseIDKey = "lastDisplayedVerseID"
    private let hasCompletedOnboardingKey = "hasCompletedOnboarding"
    
    @Published var favoriteVerseIDs: Set<Int> = []
    
    init() {
        // Use App Group for sharing with widget
        self.defaults = UserDefaults(suiteName: "group.com.yourname.gitapearls") ?? .standard
        loadFavorites()
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