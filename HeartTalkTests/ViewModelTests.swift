import XCTest
@testable import HeartTalk

final class QuestionsViewModelTests: XCTestCase {

    func test_setCategory_resetsIndexAndFiltersQuestions() {
        let repo = FakeRepository()
        let vm = QuestionsViewModel(repository: repo, initialCategory: "Психология")
        vm.setCurrentIndex(1)

        vm.setCategory("Финансы")

        XCTAssertEqual(vm.currentCategory, "Финансы")
        XCTAssertEqual(vm.currentIndex, 0)
        XCTAssertTrue(vm.questions.allSatisfy { $0.category == "Финансы" })
    }

    func test_goNext_clampsAtEnd() {
        let repo = FakeRepository()
        let vm = QuestionsViewModel(repository: repo, initialCategory: "Психология")
        vm.setCurrentIndex(vm.questions.count - 1)
        XCTAssertFalse(vm.goNext())
    }

    func test_goPrev_clampsAtZero() {
        let repo = FakeRepository()
        let vm = QuestionsViewModel(repository: repo)
        XCTAssertFalse(vm.goPrev())
    }

    func test_greetingText_morningEveningEtc() {
        let repo = FakeRepository()
        let vm = QuestionsViewModel(repository: repo)
        let cal = Calendar.current
        let morning = cal.date(from: DateComponents(year: 2026, month: 1, day: 1, hour: 8))!
        let evening = cal.date(from: DateComponents(year: 2026, month: 1, day: 1, hour: 20))!
        XCTAssertEqual(vm.greetingText(now: morning), "Доброе утро")
        XCTAssertEqual(vm.greetingText(now: evening), "Добрый вечер")
    }
}

final class OnboardingViewModelTests: XCTestCase {

    func test_validate_minimumLength() {
        let defaults = UserDefaults(suiteName: "OnboardingTest")!
        defaults.removePersistentDomain(forName: "OnboardingTest")
        let settings = UserSettings.shared
        let vm = OnboardingViewModel(settings: settings)
        XCTAssertFalse(vm.validate(name: "a"))
        XCTAssertFalse(vm.validate(name: " "))
        XCTAssertTrue(vm.validate(name: "Ян"))
        XCTAssertTrue(vm.validate(name: "Кирилл"))
    }
}

// MARK: - Fake Repository

private final class FakeRepository: QuestionRepositoryType {
    var allQuestions: [Question] = [
        Question(id: 1, question: "a", category: "Психология"),
        Question(id: 2, question: "b", category: "Психология"),
        Question(id: 3, question: "c", category: "Финансы"),
    ]
    let categories: [String] = ["Психология", "Совместное будущее", "Финансы", "Истории"]
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
        Set(allQuestions.filter { discussed.contains($0.id) }.map { $0.category }).count
    }
    func allNotes() -> [String] { notes.values.filter { !$0.isEmpty } }
    func dailyQuestion() -> Question? { allQuestions.first }
    func discussedCountByWeekday() -> [Int] { Array(repeating: 0, count: 7) }
}
