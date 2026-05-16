import Foundation

final class StatsViewModel {

    struct Snapshot {
        let discussedTotal: Int
        let notesCount: Int
        let favoritesCount: Int
        let streak: Int
        let categoriesExplored: Int
        let totalCategories: Int
        let sentiment: NLPService.SentimentStats
        let weekActivity: [Int]
    }

    private let repository: QuestionRepositoryType
    private let nlp: NLPService
    private let settings: UserSettings

    var onSnapshotReady: ((Snapshot) -> Void)?

    init(repository: QuestionRepositoryType = AppDependencies.shared.repository,
         nlp: NLPService = .shared,
         settings: UserSettings = .shared) {
        self.repository = repository
        self.nlp = nlp
        self.settings = settings
    }

    func refresh() {
        let discussed = repository.discussedCount
        let notes = repository.notesCount
        let favs = repository.favoritesCount
        let streak = settings.streak
        let cats = repository.categoriesExplored
        let totalCats = repository.categories.count
        let week = repository.discussedCountByWeekday()
        let allNotes = repository.allNotes()
        let sentiment = nlp.analyzeNotes(allNotes)

        let snapshot = Snapshot(
            discussedTotal: discussed,
            notesCount: notes,
            favoritesCount: favs,
            streak: streak,
            categoriesExplored: cats,
            totalCategories: totalCats,
            sentiment: sentiment,
            weekActivity: week
        )
        onSnapshotReady?(snapshot)
    }
}
