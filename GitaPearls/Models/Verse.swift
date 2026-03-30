import Foundation

struct Verse: Codable, Identifiable, Hashable {
    let id: Int
    let chapter: Int
    let verse: Int
    let text: String
    let meaning: String
    let reference: String
    let tags: [String]
    let context: String?
    let speaker: String?
    
    enum CodingKeys: String, CodingKey {
        case id, chapter, verse, text, meaning, reference, tags, context, speaker
    }
}

extension Verse {
    static let sample = Verse(
        id: 1,
        chapter: 2,
        verse: 47,
        text: "karmanye vadhikaraste ma phaleshu kadacana",
        meaning: "You have a right to perform your prescribed duties, but you are not entitled to the fruits of your actions.",
        reference: "BG 2.47",
        tags: ["karma", "duty", "detachment"],
        context: "Krishna responds to Arjuna's despair about fighting his kinsmen",
        speaker: "Krishna"
    )
}