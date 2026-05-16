import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var hasTransitioned = false

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        Theme.shared.loadSaved()

        // Прогреваем кастомный шрифт: первый lookup по имени дорогой
        // (iOS сканирует font registry). Делаем это до первого использования.
        _ = UIFont(name: "DMSerifDisplay-Regular", size: 1)

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let splash = SplashViewController()
        window.rootViewController = splash
        window.makeKeyAndVisible()

        let deps = AppDependencies.shared
        deps.repository.load { [weak self] result in
            if case .failure(let err) = result {
                assertionFailure("Failed to load questions: \(err)")
            }
            self?.proceedAfterLoad()
        }

        splash.onStart = { [weak self] in
            self?.proceedAfterLoad()
        }
    }

    private func proceedAfterLoad() {
        // Защита от двойного перехода — оба колбэка могут вызвать этот метод.
        guard !hasTransitioned else { return }
        hasTransitioned = true

        if UserSettings.shared.isOnboarded {
            transition(to: makeMainVC())
        } else {
            transition(to: createOnboardingFlow())
        }
    }

    private func makeMainVC() -> MainTabBarController {
        let tabBar = MainTabBarController()
        tabBar.loadViewIfNeeded()
        tabBar.view.frame = UIScreen.main.bounds
        tabBar.view.layoutIfNeeded()
        return tabBar
    }

    private func transition(to vc: UIViewController) {
        guard let window = window else { return }

        // Берём снимок текущего состояния ДО смены rootVC.
        // Затем устанавливаем новый rootVC (фон уже полностью настроен синхронно),
        // накладываем старый снимок поверх и плавно его убираем —
        // так новый экран с блобами виден с первого кадра.
        let snapshot = window.snapshotView(afterScreenUpdates: false)

        window.rootViewController = vc

        if let snapshot = snapshot {
            window.addSubview(snapshot)
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut) {
                snapshot.alpha = 0
            } completion: { _ in
                snapshot.removeFromSuperview()
            }
        }
    }

    private func createOnboardingFlow() -> UIViewController {
        let nav = UINavigationController()
        nav.setNavigationBarHidden(true, animated: false)

        let splash = SplashViewController()
        splash.onStart = { [weak nav, weak self] in
            let names = NamesViewController()
            names.onFinish = { [weak nav, weak self] name, partner in
                let success = SuccessViewController()
                success.userName = name
                success.partnerName = partner
                success.onFinish = { [weak self] in
                    let onboardingVM = OnboardingViewModel()
                    onboardingVM.finishOnboarding()
                    self?.transition(to: self?.makeMainVC() ?? MainTabBarController())
                }
                nav?.pushViewController(success, animated: true)
            }
            nav?.pushViewController(names, animated: true)
        }

        nav.viewControllers = [splash]
        return nav
    }
}
