import Foundation

final class QuestionDetailViewModel {

    private let repository: QuestionRepositoryType

    let category: String
    let questionIndex: Int

    var question: Question? {
        let qs = repository.questions(for: category)
        guard questionIndex < qs.count else { return nil }
        return qs[questionIndex]
    }

    var onChanged: (() -> Void)?

    init(repository: QuestionRepositoryType = AppDependencies.shared.repository,
         category: String,
         questionIndex: Int) {
        self.repository = repository
        self.category = category
        self.questionIndex = questionIndex
    }

    var isDiscussed: Bool {
        guard let q = question else { return false }
        return repository.isDiscussed(q.id)
    }

    var isFavorite: Bool {
        guard let q = question else { return false }
        return repository.isFavorite(q.id)
    }

    var noteText: String {
        guard let q = question else { return "" }
        return repository.note(for: q.id)
    }

    @discardableResult
    func toggleFavorite() -> Bool {
        guard let q = question else { return false }
        let result = repository.toggleFavorite(q.id)
        onChanged?()
        return result
    }

    func markDiscussedIfNeeded() -> Bool {
        guard let q = question, !repository.isDiscussed(q.id) else { return false }
        repository.markDiscussed(q.id)
        UserSettings.shared.updateStreak()
        onChanged?()
        return true
    }

    func saveNote(_ text: String) {
        guard let q = question else { return }
        repository.saveNote(text, for: q.id)
    }

    func relatedQuestions(limit: Int = 3) -> [(category: String, index: Int, question: Question, isDiscussed: Bool)] {
        let otherCats = repository.categories.filter { $0 != category }
        var result: [(String, Int, Question, Bool)] = []
        for cat in otherCats.prefix(limit) {
            guard let q = repository.questions(for: cat).first else { continue }
            result.append((cat, 0, q, repository.isDiscussed(q.id)))
        }
        return result
    }
}
