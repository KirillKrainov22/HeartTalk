import Foundation

struct Question: Codable, Identifiable {
    let id: Int
    let question: String
    let category: String
}

struct QuestionCategory {
    let name: String
    let key: String
    let questions: [Question]

    static let allKeys = ["Психология", "Совместное будущее", "Финансы", "Истории"]
}
