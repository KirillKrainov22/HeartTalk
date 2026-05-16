import Foundation

final class OnboardingViewModel {

    private let settings: UserSettings
    private let notifications: NotificationService

    init(settings: UserSettings = .shared,
         notifications: NotificationService = .shared) {
        self.settings = settings
        self.notifications = notifications
    }

    func validate(name: String) -> Bool {
        name.trimmingCharacters(in: .whitespaces).count >= 2
    }

    func saveNames(name: String, partner: String) {
        settings.userName = name.trimmingCharacters(in: .whitespaces)
        settings.partnerName = partner.trimmingCharacters(in: .whitespaces)
    }

    func finishOnboarding() {
        settings.isOnboarded = true
        settings.updateStreak()
        notifications.requestPermission { granted in
            if granted {
                NotificationService.shared.scheduleDailyReminder()
            }
        }
    }
}
