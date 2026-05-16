import Foundation

final class SettingsViewModel {

    private let settings: UserSettings
    private let notifications: NotificationService

    var onChanged: (() -> Void)?

    init(settings: UserSettings = .shared,
         notifications: NotificationService = .shared) {
        self.settings = settings
        self.notifications = notifications
    }

    var isDark: Bool { Theme.shared.isDark }
    var paletteID: String { Theme.shared.palette.id }

    var isNotificationsEnabled: Bool { settings.isNotificationsEnabled }
    var isQuietHoursEnabled: Bool { settings.isQuietHoursEnabled }

    func setDarkMode(_ dark: Bool) {
        Theme.shared.apply(dark: dark)
        onChanged?()
    }

    func setPalette(_ palette: ColorPalette) {
        Theme.shared.apply(palette: palette)
        onChanged?()
    }

    func setNotificationsEnabled(_ enabled: Bool, onResult: @escaping (Bool) -> Void) {
        settings.isNotificationsEnabled = enabled
        if enabled {
            notifications.requestPermission { [settings] granted in
                if granted {
                    NotificationService.shared.scheduleDailyReminder()
                } else {
                    settings.isNotificationsEnabled = false
                }
                onResult(granted)
            }
        } else {
            notifications.cancelDailyReminder()
            onResult(true)
        }
    }

    func setQuietHoursEnabled(_ enabled: Bool) {
        settings.isQuietHoursEnabled = enabled
    }
}
