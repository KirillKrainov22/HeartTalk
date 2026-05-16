import Foundation

/// Composition root — единая точка сборки зависимостей.
/// Простой service locator для MVVM (без сторонних DI-фреймворков).
final class AppDependencies {
    static let shared = AppDependencies()

    let repository: QuestionRepositoryType
    let settings: UserSettings
    let notifications: NotificationService
    let nlp: NLPService

    init(repository: QuestionRepositoryType = QuestionRepository(),
         settings: UserSettings = .shared,
         notifications: NotificationService = .shared,
         nlp: NLPService = .shared) {
        self.repository = repository
        self.settings = settings
        self.notifications = notifications
        self.nlp = nlp
    }
}
