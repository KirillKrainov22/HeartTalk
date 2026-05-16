import XCTest
@testable import HeartTalk

final class StatsViewModelTests: XCTestCase {

    private var defaults: UserDefaults!
    private var settings: UserSettings!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: "StatsViewModelTests")!
        defaults.removePersistentDomain(forName: "StatsViewModelTests")
        settings = UserSettings(defaults: defaults)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: "StatsViewModelTests")
        settings = nil
        defaults = nil
        super.tearDown()
    }

    func test_refresh_mapsRepositoryValuesIntoSnapshot() {
        let repo = StatsFakeRepository()
        repo.discussedCount = 7
        repo.notesCount = 3
        repo.favoritesCount = 4
        repo.categoriesExploredValue = 2
        repo.weekActivityValue = [1, 0, 2, 0, 0, 3, 0]
        settings.streak = 5

        let vm = StatsViewModel(repository: repo, nlp: .shared, settings: settings)

        var captured: StatsViewModel.Snapshot?
        vm.onSnapshotReady = { captured = $0 }
        vm.refresh()

        let snap = try! XCTUnwrap(captured)
        XCTAssertEqual(snap.discussedTotal, 7)
        XCTAssertEqual(snap.notesCount, 3)
        XCTAssertEqual(snap.favoritesCount, 4)
        XCTAssertEqual(snap.streak, 5)
        XCTAssertEqual(snap.categoriesExplored, 2)
        XCTAssertEqual(snap.totalCategories, repo.categories.count)
        XCTAssertEqual(snap.weekActivity, [1, 0, 2, 0, 0, 3, 0])
    }

    func test_refresh_emptyNotes_producesZeroSentiment() {
        let repo = StatsFakeRepository() // allNotes() == []
        let vm = StatsViewModel(repository: repo, nlp: .shared, settings: settings)

        var captured: StatsViewModel.Snapshot?
        vm.onSnapshotReady = { captured = $0 }
        vm.refresh()

        let s = try! XCTUnwrap(captured).sentiment
        XCTAssertEqual(s.positive, 0)
        XCTAssertEqual(s.neutral, 0)
        XCTAssertEqual(s.negative, 0)
    }
}

// MARK: - Fake

private final class StatsFakeRepository: QuestionRepositoryType {
    var allQuestions: [Question] = []
    let categories: [String] = QuestionCategory.allKeys

    var discussedCount = 0
    var favoritesCount = 0
    var notesCount = 0
    var categoriesExploredValue = 0
    var weekActivityValue = Array(repeating: 0, count: 7)

    func load(completion: @escaping (Result<Void, Error>) -> Void) { completion(.success(())) }
    func questions(for category: String) -> [Question] { [] }
    func isDiscussed(_ id: Int) -> Bool { false }
    func markDiscussed(_ id: Int) {}
    func isFavorite(_ id: Int) -> Bool { false }
    func toggleFavorite(_ id: Int) -> Bool { false }
    func note(for id: Int) -> String { "" }
    func saveNote(_ text: String, for id: Int) {}
    var categoriesExplored: Int { categoriesExploredValue }
    func allNotes() -> [String] { [] }
    func dailyQuestion() -> Question? { nil }
    func discussedCountByWeekday() -> [Int] { weekActivityValue }
}
