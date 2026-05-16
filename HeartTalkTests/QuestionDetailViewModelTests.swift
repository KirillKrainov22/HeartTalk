import XCTest
@testable import HeartTalk

final class QuestionDetailViewModelTests: XCTestCase {

    private var repo: DetailFakeRepository!

    // markDiscussedIfNeeded() дёргает UserSettings.shared (стандартный
    // UserDefaults) — снимаем затронутые ключи, чтобы не загрязнять окружение.
    private let streakKey = "streak_count"
    private let lastActiveKey = "last_active_date"
    private var savedStreak: Any?
    private var savedLastActive: Any?

    override func setUp() {
        super.setUp()
        repo = DetailFakeRepository()
        savedStreak = UserDefaults.standard.object(forKey: streakKey)
        savedLastActive = UserDefaults.standard.object(forKey: lastActiveKey)
        UserDefaults.standard.removeObject(forKey: streakKey)
        UserDefaults.standard.removeObject(forKey: lastActiveKey)
    }

    override func tearDown() {
        UserDefaults.standard.set(savedStreak, forKey: streakKey)
        UserDefaults.standard.set(savedLastActive, forKey: lastActiveKey)
        repo = nil
        super.tearDown()
    }

    private func makeVM(category: String = "Психология", index: Int = 0) -> QuestionDetailViewModel {
        QuestionDetailViewModel(repository: repo, category: category, questionIndex: index)
    }

    func test_question_outOfBounds_returnsNil() {
        let vm = makeVM(category: "Психология", index: 99)
        XCTAssertNil(vm.question)
        XCTAssertFalse(vm.isDiscussed)
        XCTAssertFalse(vm.isFavorite)
        XCTAssertEqual(vm.noteText, "")
    }

    func test_toggleFavorite_togglesAndFiresOnChanged() {
        let vm = makeVM()
        var changedCount = 0
        vm.onChanged = { changedCount += 1 }

        XCTAssertTrue(vm.toggleFavorite())   // added
        XCTAssertTrue(vm.isFavorite)
        XCTAssertFalse(vm.toggleFavorite())  // removed
        XCTAssertFalse(vm.isFavorite)
        XCTAssertEqual(changedCount, 2)
    }

    func test_markDiscussedIfNeeded_firstTimeTrue_thenFalse() {
        let vm = makeVM()
        var changedCount = 0
        vm.onChanged = { changedCount += 1 }

        XCTAssertTrue(vm.markDiscussedIfNeeded())
        XCTAssertTrue(vm.isDiscussed)
        XCTAssertEqual(changedCount, 1)

        // Повторно — уже обсуждён, ничего не делаем.
        XCTAssertFalse(vm.markDiscussedIfNeeded())
        XCTAssertEqual(changedCount, 1)
    }

    func test_saveNote_persistsViaRepository() {
        let vm = makeVM()
        vm.saveNote("моя заметка")
        XCTAssertEqual(vm.noteText, "моя заметка")
        XCTAssertEqual(repo.note(for: 1), "моя заметка")
    }

    func test_relatedQuestions_excludesCurrentCategoryAndRespectsLimit() {
        let vm = makeVM(category: "Психология")

        let all = vm.relatedQuestions(limit: 3)
        XCTAssertEqual(all.count, 3)
        XCTAssertFalse(all.contains { $0.category == "Психология" })
        XCTAssertEqual(all.map { $0.category },
                       ["Совместное будущее", "Финансы", "Истории"])

        let limited = vm.relatedQuestions(limit: 2)
        XCTAssertEqual(limited.count, 2)
    }

    func test_relatedQuestions_reflectsDiscussedState() {
        repo.markDiscussed(4) // первый вопрос "Финансы"
        let vm = makeVM(category: "Психология")
        let financy = vm.relatedQuestions().first { $0.category == "Финансы" }
        XCTAssertEqual(financy?.isDiscussed, true)
    }
}

// MARK: - Fake

private final class DetailFakeRepository: QuestionRepositoryType {
    var allQuestions: [Question] = [
        Question(id: 1, question: "p1", category: "Психология"),
        Question(id: 2, question: "p2", category: "Психология"),
        Question(id: 3, question: "b1", category: "Совместное будущее"),
        Question(id: 4, question: "f1", category: "Финансы"),
        Question(id: 5, question: "s1", category: "Истории"),
    ]
    let categories: [String] = QuestionCategory.allKeys
    private var discussed: Set<Int> = []
    private var favorites: Set<Int> = []
    private var notes: [Int: String] = [:]

    func load(completion: @escaping (Result<Void, Error>) -> Void) { completion(.success(())) }
    func questions(for category: String) -> [Question] { allQuestions.filter { $0.category == category } }
    func isDiscussed(_ id: Int) -> Bool { discussed.contains(id) }
    func markDiscussed(_ id: Int) { discussed.insert(id) }
    func isFavorite(_ id: Int) -> Bool { favorites.contains(id) }
    func toggleFavorite(_ id: Int) -> Bool {
        if favorites.contains(id) { favorites.remove(id); return false }
        favorites.insert(id); return true
    }
    func note(for id: Int) -> String { notes[id] ?? "" }
    func saveNote(_ text: String, for id: Int) { notes[id] = text }
    var discussedCount: Int { discussed.count }
    var favoritesCount: Int { favorites.count }
    var notesCount: Int { notes.values.filter { !$0.isEmpty }.count }
    var categoriesExplored: Int {
        categories.filter { cat in
            let qs = allQuestions.filter { $0.category == cat }
            return !qs.isEmpty && qs.allSatisfy { discussed.contains($0.id) }
        }.count
    }
    func allNotes() -> [String] { notes.values.filter { !$0.isEmpty } }
    func dailyQuestion() -> Question? { allQuestions.first }
    func discussedCountByWeekday() -> [Int] { Array(repeating: 0, count: 7) }
}
