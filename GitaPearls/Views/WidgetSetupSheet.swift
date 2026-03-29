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
                            
                            Text("Add GitaPearls to Your Lock Screen")
                                .font(.title2)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            
                            Text("See a new verse each time you unlock your phone")
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
                                title: "Lock your iPhone",
                                description: "Press the side button to lock your screen."
                            )
                            
                            StepView(
                                number: 2,
                                title: "Long press the lock screen",
                                description: "Press and hold anywhere on your wallpaper."
                            )
                            
                            StepView(
                                number: 3,
                                title: "Tap Customize",
                                description: "Select either Lock Screen or Home Screen."
                            )
                            
                            StepView(
                                number: 4,
                                title: "Add GitaPearls widget",
                                description: "Tap the widget area, find GitaPearls, and choose your preferred size."
                            )
                            
                            StepView(
                                number: 5,
                                title: "Done!",
                                description: "Lock your phone again and unlock to see your first verse."
                            )
                        }
                        .padding(.horizontal)
                        
                        // Note about refresh
                        HStack {
                            Image(systemName: "info.circle")
                            Text("Verses refresh throughout the day automatically.")
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
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
        WidgetSetupSheet()
    }
}