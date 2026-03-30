import SwiftUI

struct WidgetSetupSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var verseStore = VerseStore.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        VStack(alignment: .center, spacing: 12) {
                            Image(systemName: "quote.bubble.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.orange)
                            
                            Text("Add GitaPearls to Your Home Screen")
                                .font(.title2)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            
                            Text("See a new verse every time you glance at your phone")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 20)
                        
                        // Steps
                        VStack(alignment: .leading, spacing: 20) {
                            StepView(
                                number: 1,
                                title: "Long press on your Home Screen",
                                description: "Press and hold anywhere on your wallpaper until the apps jiggle."
                            )
                            
                            StepView(
                                number: 2,
                                title: "Tap the Plus button",
                                description: "Tap the + button in the top-left corner to open the widget gallery."
                            )
                            
                            StepView(
                                number: 3,
                                title: "Find GitaPearls",
                                description: "Scroll or search to find GitaPearls in the widget list."
                            )
                            
                            StepView(
                                number: 4,
                                title: "Choose your size",
                                description: "Swipe through Small, Medium, and Large options. Tap Add Widget."
                            )
                            
                            StepView(
                                number: 5,
                                title: "Place your widget",
                                description: "Drag the widget to your preferred spot. Tap Done when finished."
                            )
                        }
                        .padding(.horizontal)
                        
                        // Note about lock screen
                        HStack {
                            Image(systemName: "lock.shield")
                            Text("Also available on your Lock Screen — add the verse widget and ॐ symbol together.")
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        // Note about refresh
                        HStack {
                            Image(systemName: "info.circle")
                            Text("Verses refresh throughout the day automatically.")
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        .padding(.top, 6)
                        
                        Spacer(minLength: 40)
                    }
                }
                
                // Bottom button
                VStack {
                    Button(action: completeOnboarding) {
                        Text("Got it!")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(12)
                    }
                    .padding()
                }
                .background(Color(.systemBackground))
            }
            .navigationTitle("Setup Widget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Skip") {
                        completeOnboarding()
                    }
                }
            }
        }
    }
    
    private func completeOnboarding() {
        verseStore.setCompletedOnboarding(true)
        dismiss()
    }
}

struct StepView: View {
    let number: Int
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 32, height: 32)
                
                Text("\(number)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct WidgetSetupSheet_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WidgetSetupSheet()
                .previewDisplayName("Light Mode")
            
            WidgetSetupSheet()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}