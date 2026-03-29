import SwiftUI

@main
struct GitaPearlsApp: App {
    @StateObject private var verseStore = VerseStore.shared
    @State private var selectedVerseID: Int?
    @State private var showOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            ContentView(selectedVerseID: $selectedVerseID)
                .environmentObject(verseStore)
                .onOpenURL { url in
                    handleDeepLink(url)
                }
                .onAppear {
                    showOnboarding = !verseStore.hasCompletedOnboarding()
                }
                .sheet(isPresented: $showOnboarding) {
                    WidgetSetupSheet()
                }
        }
    }
    
    private func handleDeepLink(_ url: URL) {
        // Handle gitapearls://verse/47
        guard url.scheme == "gitapearls",
              url.host == "verse",
              let pathComponents = url.pathComponents.last,
              let verseID = Int(pathComponents) else {
            return
        }
        
        selectedVerseID = verseID
    }
}