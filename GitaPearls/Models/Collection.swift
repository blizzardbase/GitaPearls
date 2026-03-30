import Foundation

struct Collection: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let description: String
    let verseIDs: [Int]
}
