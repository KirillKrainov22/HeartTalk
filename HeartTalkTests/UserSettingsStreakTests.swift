import XCTest
@testable import HeartTalk

final class UserSettingsStreakTests: XCTestCase {

    private var defaults: UserDefaults!
    private var clock: Date!
    private var settings: UserSettings!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: "UserSettingsStreakTests")!
        defaults.removePersistentDomain(forName: "UserSettingsStreakTests")
        clock = date(2026, 5, 15)
        settings = UserSettings(defaults: defaults, now: { [unowned self] in self.clock })
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: "UserSettingsStreakTests")
        settings = nil
        defaults = nil
        clock = nil
        super.tearDown()
    }

    private func date(_ y: Int, _ m: Int, _ d: Int) -> Date {
        var c = DateComponents()
        c.year = y; c.month = m; c.day = d; c.hour = 12
        return Calendar.current.date(from: c)!
    }

    func test_firstCall_setsStreakToOne() {
        XCTAssertEqual(settings.streak, 0)
        settings.updateStreak()
        XCTAssertEqual(settings.streak, 1)
    }

    func test_sameDay_isIdempotent() {
        settings.updateStreak()
        settings.updateStreak()
        settings.updateStreak()
        XCTAssertEqual(settings.streak, 1)
    }

    func test_consecutiveDays_incrementStreak() {
        settings.updateStreak()                 // 15-е → 1
        clock = date(2026, 5, 16)
        settings.updateStreak()                 // 16-е → 2
        clock = date(2026, 5, 17)
        settings.updateStreak()                 // 17-е → 3
        XCTAssertEqual(settings.streak, 3)
    }

    func test_gapMoreThanOneDay_resetsStreak() {
        settings.updateStreak()                 // 15-е → 1
        clock = date(2026, 5, 16)
        settings.updateStreak()                 // 16-е → 2
        clock = date(2026, 5, 20)               // пропуск нескольких дней
        settings.updateStreak()                 // сброс → 1
        XCTAssertEqual(settings.streak, 1)
    }

    func test_resumeAfterGap_thenContinue() {
        settings.updateStreak()                 // 15-е → 1
        clock = date(2026, 5, 25)
        settings.updateStreak()                 // большой пропуск → 1
        clock = date(2026, 5, 26)
        settings.updateStreak()                 // следующий день → 2
        XCTAssertEqual(settings.streak, 2)
    }
}
