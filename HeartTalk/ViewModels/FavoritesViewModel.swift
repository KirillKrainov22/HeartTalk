import Foundation

final class FavoritesViewModel {

    struct Item {
        let question: Question
        let category: String
        let indexInCategory: Int
        let isDiscussed: Bool
    }

    private let repository: QuestionRepositoryType
    private(set) var items: [Item] = []

    var onDataChanged: (() -> Void)?

    init(repository: QuestionRepositoryType = AppDependencies.shared.repository) {
        self.repository = repository
    }

    func reload() {
        var newItems: [Item] = []
        for cat in repository.categories {
            for (idx, q) in repository.questions(for: cat).enumerated() where repository.isFavorite(q.id) {
                newItems.append(Item(question: q, category: cat,
                                     indexInCategory: idx,
                                     isDiscussed: repository.isDiscussed(q.id)))
            }
        }
        items = newItems
        onDataChanged?()
    }
}
