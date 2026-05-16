import Foundation

final class UserSettings {
    static let shared = UserSettings()

    private let nameKey = "user_name"
    private let partnerKey = "partner_name"
    private let onboardedKey = "is_onboarded"
    private let accentKey = "accent_color_id"
    private let darkKey = "is_dark_mode"
    private let notifEnabledKey = "notif_enabled"
    private let quietHoursKey = "quiet_hours"
    private let streakKey = "streak_count"
    private let lastActiveKey = "last_active_date"

    private let defaults: UserDefaults
    private let now: () -> Date

    init(defaults: UserDefaults = .standard, now: @escaping () -> Date = Date.init) {
        self.defaults = defaults
        self.now = now
    }

    var userName: String {
        get { defaults.string(forKey: nameKey) ?? "" }
        set { defaults.set(newValue, forKey: nameKey) }
    }

    var partnerName: String {
        get { defaults.string(forKey: partnerKey) ?? "" }
        set { defaults.set(newValue, forKey: partnerKey) }
    }

    var isOnboarded: Bool {
        get { defaults.bool(forKey: onboardedKey) }
        set { defaults.set(newValue, forKey: onboardedKey) }
    }

    var accentColorID: String {
        get { defaults.string(forKey: accentKey) ?? "terracotta" }
        set { defaults.set(newValue, forKey: accentKey) }
    }

    var isDarkMode: Bool {
        get { defaults.bool(forKey: darkKey) }
        set { defaults.set(newValue, forKey: darkKey) }
    }

    var isNotificationsEnabled: Bool {
        get {
            if defaults.object(forKey: notifEnabledKey) == nil { return true }
            return defaults.bool(forKey: notifEnabledKey)
        }
        set { defaults.set(newValue, forKey: notifEnabledKey) }
    }

    var isQuietHoursEnabled: Bool {
        get { defaults.bool(forKey: quietHoursKey) }
        set { defaults.set(newValue, forKey: quietHoursKey) }
    }

    var streak: Int {
        get { defaults.integer(forKey: streakKey) }
        set { defaults.set(newValue, forKey: streakKey) }
    }

    func updateStreak() {
        let today = Calendar.current.startOfDay(for: now())
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayStr = formatter.string(from: today)

        if let last = defaults.string(forKey: lastActiveKey) {
            if last == todayStr { return }
            if let lastDate = formatter.date(from: last) {
                let diff = Calendar.current.dateComponents([.day], from: lastDate, to: today).day ?? 0
                if diff == 1 {
                    streak += 1
                } else if diff > 1 {
                    streak = 1
                }
            }
        } else {
            streak = 1
        }
        defaults.set(todayStr, forKey: lastActiveKey)
    }
}
