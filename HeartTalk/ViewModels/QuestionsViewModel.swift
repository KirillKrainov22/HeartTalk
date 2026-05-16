import Foundation

final class QuestionsViewModel {

    private let repository: QuestionRepositoryType

    private(set) var currentCategory: String
    private(set) var currentIndex: Int = 0
    private(set) var questions: [Question] = []

    var categories: [String] { repository.categories }

    var onDataChanged: (() -> Void)?

    init(repository: QuestionRepositoryType = AppDependencies.shared.repository,
         initialCategory: String = "Психология") {
        self.repository = repository
        self.currentCategory = initialCategory
        reloadQuestions()
    }

    func reloadQuestions() {
        questions = repository.questions(for: currentCategory)
        if currentIndex >= questions.count { currentIndex = max(0, questions.count - 1) }
    }

    func setCategory(_ category: String) {
        guard category != currentCategory else { return }
        currentCategory = category
        currentIndex = 0
        reloadQuestions()
        onDataChanged?()
    }

    func setCurrentIndex(_ index: Int) {
        guard index >= 0, index < questions.count else { return }
        currentIndex = index
    }

    func goNext() -> Bool {
        guard currentIndex < questions.count - 1 else { return false }
        currentIndex += 1
        return true
    }

    func goPrev() -> Bool {
        guard currentIndex > 0 else { return false }
        currentIndex -= 1
        return true
    }

    func isDiscussed(_ id: Int) -> Bool { repository.isDiscussed(id) }
    func isFavorite(_ id: Int) -> Bool { repository.isFavorite(id) }

    @discardableResult
    func toggleFavorite(at index: Int) -> Bool? {
        guard index >= 0, index < questions.count else { return nil }
        let result = repository.toggleFavorite(questions[index].id)
        return result
    }

    func greetingText(now: Date = Date()) -> String {
        let hour = Calendar.current.component(.hour, from: now)
        switch hour {
        case 0..<6: return "Доброй ночи"
        case 6..<12: return "Доброе утро"
        case 12..<18: return "Добрый день"
        default: return "Добрый вечер"
        }
    }
}
