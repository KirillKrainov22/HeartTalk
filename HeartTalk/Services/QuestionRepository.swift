import Foundation
import CoreData

protocol QuestionRepositoryType: AnyObject {
    var allQuestions: [Question] { get }
    var categories: [String] { get }

    func load(completion: @escaping (Result<Void, Error>) -> Void)
    func questions(for category: String) -> [Question]

    func isDiscussed(_ id: Int) -> Bool
    func markDiscussed(_ id: Int)

    func isFavorite(_ id: Int) -> Bool
    @discardableResult func toggleFavorite(_ id: Int) -> Bool

    func note(for id: Int) -> String
    func saveNote(_ text: String, for id: Int)

    var discussedCount: Int { get }
    var favoritesCount: Int { get }
    var notesCount: Int { get }
    var categoriesExplored: Int { get }
    func allNotes() -> [String]

    func dailyQuestion() -> Question?
    func discussedCountByWeekday() -> [Int]
}

extension Notification.Name {
    static let questionsDidChange = Notification.Name("HeartTalk.questionsDidChange")
}

final class QuestionRepository: QuestionRepositoryType {

    private let stack: CoreDataStack
    private let loader: QuestionLoading
    private let defaults: UserDefaults

    private(set) var allQuestions: [Question] = []
    let categories: [String] = QuestionCategory.allKeys

    private let dailyQuestionKey = "daily_question"
    private let dailyDateKey = "daily_date"

    init(stack: CoreDataStack = .shared,
         loader: QuestionLoading = QuestionLoader(),
         defaults: UserDefaults = .standard) {
        self.stack = stack
        self.loader = loader
        self.defaults = defaults
    }

    // MARK: - Loading

    func load(completion: @escaping (Result<Void, Error>) -> Void) {
        loader.load { [weak self] result in
            switch result {
            case .success(let qs):
                self?.allQuestions = qs
                completion(.success(()))
            case .failure(let err):
                completion(.failure(err))
            }
        }
    }

    func questions(for category: String) -> [Question] {
        allQuestions.filter { $0.category == category }
    }

    // MARK: - Discussed

    func isDiscussed(_ id: Int) -> Bool {
        count(in: DiscussedEntry.self, id: id) > 0
    }

    func markDiscussed(_ id: Int) {
        guard !isDiscussed(id) else { return }
        let entry = DiscussedEntry(context: stack.viewContext)
        entry.questionID = Int64(id)
        entry.discussedAt = Date()
        stack.saveIfNeeded()
        NotificationCenter.default.post(name: .questionsDidChange, object: nil)
    }

    // MARK: - Favorites

    func isFavorite(_ id: Int) -> Bool {
        count(in: FavoriteEntry.self, id: id) > 0
    }

    @discardableResult
    func toggleFavorite(_ id: Int) -> Bool {
        let ctx = stack.viewContext
        let request: NSFetchRequest<FavoriteEntry> = FavoriteEntry.fetchRequest()
        request.predicate = NSPredicate(format: "questionID == %lld", Int64(id))
        request.fetchLimit = 1

        if let existing = try? ctx.fetch(request).first {
            ctx.delete(existing)
            stack.saveIfNeeded()
            NotificationCenter.default.post(name: .questionsDidChange, object: nil)
            return false
        }
        let entry = FavoriteEntry(context: ctx)
        entry.questionID = Int64(id)
        entry.addedAt = Date()
        stack.saveIfNeeded()
        NotificationCenter.default.post(name: .questionsDidChange, object: nil)
        return true
    }

    // MARK: - Notes

    func note(for id: Int) -> String {
        let ctx = stack.viewContext
        let request: NSFetchRequest<NoteEntry> = NoteEntry.fetchRequest()
        request.predicate = NSPredicate(format: "questionID == %lld", Int64(id))
        request.fetchLimit = 1
        return ((try? ctx.fetch(request))?.first?.text) ?? ""
    }

    func saveNote(_ text: String, for id: Int) {
        let ctx = stack.viewContext
        let request: NSFetchRequest<NoteEntry> = NoteEntry.fetchRequest()
        request.predicate = NSPredicate(format: "questionID == %lld", Int64(id))
        request.fetchLimit = 1

        let entry = (try? ctx.fetch(request).first) ?? NoteEntry(context: ctx)
        entry.questionID = Int64(id)
        entry.text = text
        entry.updatedAt = Date()
        stack.saveIfNeeded()
        NotificationCenter.default.post(name: .questionsDidChange, object: nil)
    }

    // MARK: - Stats

    var discussedCount: Int { count(in: DiscussedEntry.self) }
    var favoritesCount: Int { count(in: FavoriteEntry.self) }

    var notesCount: Int {
        let ctx = stack.viewContext
        let request: NSFetchRequest<NoteEntry> = NoteEntry.fetchRequest()
        request.predicate = NSPredicate(format: "text != %@", "")
        return (try? ctx.count(for: request)) ?? 0
    }

    var categoriesExplored: Int {
        let ctx = stack.viewContext
        let request: NSFetchRequest<DiscussedEntry> = DiscussedEntry.fetchRequest()
        guard let entries = try? ctx.fetch(request) else { return 0 }
        let discussedIDs = Set(entries.map { Int($0.questionID) })
        return categories.filter { cat in
            let qs = allQuestions.filter { $0.category == cat }
            return !qs.isEmpty && qs.allSatisfy { discussedIDs.contains($0.id) }
        }.count
    }

    func allNotes() -> [String] {
        let ctx = stack.viewContext
        let request: NSFetchRequest<NoteEntry> = NoteEntry.fetchRequest()
        request.predicate = NSPredicate(format: "text != %@", "")
        return ((try? ctx.fetch(request)) ?? []).compactMap { $0.text }
    }

    /// Returns array of 7 ints: counts of discussed questions per weekday (Mon..Sun)
    /// for the current calendar week.
    func discussedCountByWeekday() -> [Int] {
        let ctx = stack.viewContext
        let request: NSFetchRequest<DiscussedEntry> = DiscussedEntry.fetchRequest()
        guard let entries = try? ctx.fetch(request) else { return Array(repeating: 0, count: 7) }

        var calendar = Calendar(identifier: .iso8601)
        calendar.firstWeekday = 2 // Monday
        let now = Date()
        guard let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start else {
            return Array(repeating: 0, count: 7)
        }

        var counts = Array(repeating: 0, count: 7)
        for e in entries {
            guard let d = e.discussedAt, d >= startOfWeek else { continue }
            let days = calendar.dateComponents([.day], from: startOfWeek, to: d).day ?? 0
            if days >= 0 && days < 7 {
                counts[days] += 1
            }
        }
        return counts
    }

    // MARK: - Daily Question (cached in UserDefaults — это просто кэш выбора на день)

    func dailyQuestion() -> Question? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayStr = formatter.string(from: Date())

        if let savedDate = defaults.string(forKey: dailyDateKey),
           savedDate == todayStr,
           let savedID = defaults.value(forKey: dailyQuestionKey) as? Int,
           let q = allQuestions.first(where: { $0.id == savedID }) {
            return q
        }

        let discussedIDs = fetchDiscussedIDs()
        let undiscussed = allQuestions.filter { !discussedIDs.contains($0.id) }
        let pool = undiscussed.isEmpty ? allQuestions : undiscussed
        guard let question = pool.randomElement() else { return nil }

        defaults.set(question.id, forKey: dailyQuestionKey)
        defaults.set(todayStr, forKey: dailyDateKey)
        return question
    }

    // MARK: - Helpers

    private func fetchDiscussedIDs() -> Set<Int> {
        let ctx = stack.viewContext
        let request: NSFetchRequest<DiscussedEntry> = DiscussedEntry.fetchRequest()
        let entries = (try? ctx.fetch(request)) ?? []
        return Set(entries.map { Int($0.questionID) })
    }

    private func count<T: NSManagedObject>(in type: T.Type) -> Int {
        let ctx = stack.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: type))
        return (try? ctx.count(for: request)) ?? 0
    }

    private func count<T: NSManagedObject>(in type: T.Type, id: Int) -> Int {
        let ctx = stack.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: type))
        request.predicate = NSPredicate(format: "questionID == %lld", Int64(id))
        return (try? ctx.count(for: request)) ?? 0
    }
}
