import XCTest
@testable import HeartTalk

final class QuestionRepositoryTests: XCTestCase {

    private var stack: CoreDataStack!
    private var loader: StubLoader!
    private var defaults: UserDefaults!
    private var repo: QuestionRepository!

    override func setUp() {
        super.setUp()
        stack = CoreDataStack(modelName: "HeartTalk", inMemory: true)
        loader = StubLoader(questions: TestData.questions)
        defaults = UserDefaults(suiteName: "QuestionRepositoryTests")!
        defaults.removePersistentDomain(forName: "QuestionRepositoryTests")
        repo = QuestionRepository(stack: stack, loader: loader, defaults: defaults)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: "QuestionRepositoryTests")
        repo = nil
        stack = nil
        loader = nil
        defaults = nil
        super.tearDown()
    }

    func test_load_populatesAllQuestionsAndKeepsCategoryFilter() {
        let exp = expectation(description: "load")
        repo.load { result in
            if case .failure = result { XCTFail("expected success") }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)

        XCTAssertEqual(repo.allQuestions.count, 4)
        XCTAssertEqual(repo.questions(for: "Психология").count, 2)
        XCTAssertEqual(repo.questions(for: "Финансы").count, 1)
    }

    func test_markDiscussed_persistsAndUpdatesCount() {
        loadSync()
        XCTAssertEqual(repo.discussedCount, 0)
        XCTAssertFalse(repo.isDiscussed(1))

        repo.markDiscussed(1)

        XCTAssertTrue(repo.isDiscussed(1))
        XCTAssertEqual(repo.discussedCount, 1)
    }

    func test_markDiscussed_isIdempotent() {
        loadSync()
        repo.markDiscussed(1)
        repo.markDiscussed(1)
        XCTAssertEqual(repo.discussedCount, 1)
    }

    func test_toggleFavorite_addsThenRemoves() {
        loadSync()
        let added = repo.toggleFavorite(2)
        XCTAssertTrue(added)
        XCTAssertTrue(repo.isFavorite(2))
        XCTAssertEqual(repo.favoritesCount, 1)

        let removed = repo.toggleFavorite(2)
        XCTAssertFalse(removed)
        XCTAssertFalse(repo.isFavorite(2))
        XCTAssertEqual(repo.favoritesCount, 0)
    }

    func test_saveNote_persistsAndOverwrites() {
        loadSync()
        repo.saveNote("hello", for: 3)
        XCTAssertEqual(repo.note(for: 3), "hello")
        XCTAssertEqual(repo.notesCount, 1)

        repo.saveNote("changed", for: 3)
        XCTAssertEqual(repo.note(for: 3), "changed")
        XCTAssertEqual(repo.notesCount, 1)
    }

    func test_emptyNote_isNotCountedInNotesCount() {
        loadSync()
        repo.saveNote("", for: 3)
        XCTAssertEqual(repo.notesCount, 0)
    }

    func test_categoriesExplored_requiresAllQuestionsInCategory() {
        loadSync()
        // Психология содержит q1 и q2. Обсуждаем только q1 — категория ещё не изучена.
        repo.markDiscussed(1)
        XCTAssertEqual(repo.categoriesExplored, 0)

        // Дообсуждаем q2 — теперь вся Психология пройдена.
        repo.markDiscussed(2)
        XCTAssertEqual(repo.categoriesExplored, 1)
    }

    func test_categoriesExplored_countsOnlyFullyDiscussedCategories() {
        loadSync()
        repo.markDiscussed(1) // Психология (нужны 1 и 2)
        repo.markDiscussed(2) // Психология — завершена
        repo.markDiscussed(3) // Финансы (единственный вопрос) — завершена
        // Истории (q4) не тронуты, Совместное будущее без вопросов в наборе.
        XCTAssertEqual(repo.categoriesExplored, 2)

        repo.markDiscussed(4) // Истории — завершена
        XCTAssertEqual(repo.categoriesExplored, 3)
    }

    func test_dailyQuestion_cachedSameDay() {
        loadSync()
        let q1 = repo.dailyQuestion()
        let q2 = repo.dailyQuestion()
        XCTAssertNotNil(q1)
        XCTAssertEqual(q1?.id, q2?.id)
    }

    func test_dailyQuestion_prefersUndiscussed() {
        loadSync()
        for q in repo.allQuestions where q.id != 3 {
            repo.markDiscussed(q.id)
        }
        let daily = repo.dailyQuestion()
        XCTAssertEqual(daily?.id, 3)
    }

    func test_allNotes_returnsOnlyNonEmpty() {
        loadSync()
        repo.saveNote("первая", for: 1)
        repo.saveNote("", for: 2)
        repo.saveNote("третья", for: 3)
        XCTAssertEqual(Set(repo.allNotes()), Set(["первая", "третья"]))
    }

    // MARK: - Helpers

    private func loadSync() {
        let exp = expectation(description: "load")
        repo.load { _ in exp.fulfill() }
        wait(for: [exp], timeout: 1)
    }
}

// MARK: - Fixtures

private final class StubLoader: QuestionLoading {
    let questions: [Question]
    init(questions: [Question]) { self.questions = questions }
    func load(completion: @escaping (Result<[Question], QuestionLoaderError>) -> Void) {
        DispatchQueue.main.async { completion(.success(self.questions)) }
    }
}

private enum TestData {
    static let questions: [Question] = [
        Question(id: 1, question: "q1", category: "Психология"),
        Question(id: 2, question: "q2", category: "Психология"),
        Question(id: 3, question: "q3", category: "Финансы"),
        Question(id: 4, question: "q4", category: "Истории"),
    ]
}
