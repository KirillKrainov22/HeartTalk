import UIKit

/// Корневой контейнер, который держит статичный фон (блобы).
/// MainTabBarController встраивается как дочерний VC с прозрачным view.
/// Так фон гарантированно виден всегда — UIKit не может его перекрыть
/// своими внутренними контейнерами, потому что фон находится ВЫШЕ в иерархии.
final class AppBackgroundViewController: UIViewController {

    private let blob1 = UIView()
    private let blob2 = UIView()
    private let blob3 = UIView()
    private weak var embeddedTabBar: MainTabBarController?

    override func viewDidLoad() {
        super.viewDidLoad()
        Theme.shared.loadSaved()
        setupBlobs()
        applyTheme()
    }

    private func setupBlobs() {
        let sw = UIScreen.main.bounds.width
        let sh = UIScreen.main.bounds.height

        blob1.frame = CGRect(x: sw - 220, y: -60, width: 280, height: 280)
        blob1.layer.cornerRadius = 140

        blob2.frame = CGRect(x: -60, y: sh - 260, width: 200, height: 200)
        blob2.layer.cornerRadius = 100

        blob3.frame = CGRect(x: sw - 120, y: sh / 2 - 75, width: 150, height: 150)
        blob3.layer.cornerRadius = 75

        for blob in [blob1, blob2, blob3] {
            view.addSubview(blob)
        }
    }

    func applyTheme() {
        let theme = Theme.shared
        view.backgroundColor = theme.background
        blob1.backgroundColor = theme.accent
        blob1.alpha = theme.isDark ? 0.30 : 0.55
        blob2.backgroundColor = theme.accentDark
        blob2.alpha = theme.isDark ? 0.25 : 0.40
        blob3.backgroundColor = theme.accent
        blob3.alpha = theme.isDark ? 0.20 : 0.35
        embeddedTabBar?.applyTheme()
    }

    func embedMainTabBar(_ tabBar: MainTabBarController) {
        embeddedTabBar = tabBar

        Theme.shared.onChanged = { [weak self] in self?.applyTheme() }

        addChild(tabBar)
        tabBar.view.frame = view.bounds
        tabBar.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tabBar.view.backgroundColor = .clear
        view.addSubview(tabBar.view)
        tabBar.didMove(toParent: self)
        tabBar.view.layoutIfNeeded()
    }
}
