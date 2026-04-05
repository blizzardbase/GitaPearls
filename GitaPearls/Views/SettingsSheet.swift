import SwiftUI

struct SettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section("About") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("GitaPearls")
                            .font(.headline)
                        Text("Version 1.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                    
                    Text("GitaPearls brings the timeless wisdom of the Bhagavad Gita to your daily life. Each time you unlock your phone, discover a new verse from Swami Sivananda's respected translation.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                Section("Attribution") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Translation")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("Swami Sivananda (public domain)")
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Verses")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("150 verses across all 18 chapters")
                    }
                }
                
                Section("Privacy") {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("No data collected", systemImage: "checkmark.shield")
                        Label("No analytics", systemImage: "checkmark.shield")
                        Label("No network calls", systemImage: "checkmark.shield")
                        Label("No third-party SDKs", systemImage: "checkmark.shield")
                    }
                    .font(.body)

                    Link(destination: URL(string: "https://blizzardbase.github.io/GitaPearls/privacy.html")!) {
                        Label("Privacy Policy", systemImage: "doc.text")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SettingsSheet_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SettingsSheet()
                .previewDisplayName("Light Mode")
            
            SettingsSheet()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}