import UIKit

class MainTabBarController: UITabBarController {

    private let questionsVC = QuestionsViewController()
    private let favoritesVC = FavoritesViewController()
    private let statsVC = StatsViewController()
    private let settingsVC = SettingsViewController()

    private var questionsNav: UINavigationController!
    private var favoritesNav: UINavigationController!

    // Custom floating tab bar
    private let tabBarContainer = UIView()
    private let tabBarGlass = GlassView(cornerRadius: 34, opacity: 0.40)
    private var tabLabels: [UILabel] = []
    private var tabDots: [UIView] = []
    private var tabHighlights: [UIView] = []

    private let tabItems: [(icon: String, label: String)] = [
        ("bubble.left.and.bubble.right", "Вопросы"),
        ("heart", "Избранное"),
        ("chart.bar", "Статистика"),
        ("gearshape", "Настройки"),
    ]


    override func viewDidLoad() {
        super.viewDidLoad()

        questionsVC.delegate = self
        favoritesVC.delegate = self

        questionsNav = makeNav(root: questionsVC)
        favoritesNav = makeNav(root: favoritesVC)
        let statsNav = makeNav(root: statsVC)
        let settingsNav = makeNav(root: settingsVC)

        viewControllers = [questionsNav, favoritesNav, statsNav, settingsNav]

        delegate = self
        tabBar.isHidden = true

        setupCustomTabBar()

        questionsNav.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0)

        applyTheme()
        updateTabBarAppearance()

        Theme.shared.onChanged = { [weak self] in self?.applyTheme() }
    }


    private func makeNav(root: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: root)
        nav.setNavigationBarHidden(true, animated: false)
        nav.view.backgroundColor = .clear
        return nav
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        preloadInactiveTabs()
    }

    private var didPreload = false
    private func preloadInactiveTabs() {
        guard !didPreload else { return }
        didPreload = true
        // Грузим оставшиеся табы по одному в отдельных run loop'ах,
        // чтобы каждое viewDidLoad не блокировало UI больше одного кадра.
        let indices = (0..<(viewControllers?.count ?? 0)).filter { $0 != selectedIndex }
        preloadNext(indices: indices, position: 0)
    }

    private func preloadNext(indices: [Int], position: Int) {
        guard position < indices.count else { return }
        let i = indices[position]
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let nav = self.viewControllers?[i] as? UINavigationController else { return }
            if nav.additionalSafeAreaInsets.bottom == 0 {
                nav.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0)
            }
            nav.loadViewIfNeeded()
            nav.view.frame = self.view.bounds
            nav.viewControllers.first?.loadViewIfNeeded()
            self.preloadNext(indices: indices, position: position + 1)
        }
    }

    // MARK: - Custom Tab Bar

    private func setupCustomTabBar() {
        tabBarContainer.translatesAutoresizingMaskIntoConstraints = false
        tabBarContainer.layer.cornerRadius = 34
        tabBarContainer.layer.cornerCurve = .continuous
        tabBarContainer.clipsToBounds = true

        tabBarGlass.translatesAutoresizingMaskIntoConstraints = false
        tabBarGlass.isUserInteractionEnabled = false

        view.addSubview(tabBarContainer)
        tabBarContainer.addSubview(tabBarGlass)

        NSLayoutConstraint.activate([
            tabBarContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tabBarContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            tabBarContainer.widthAnchor.constraint(equalToConstant: 340),
            tabBarContainer.heightAnchor.constraint(equalToConstant: 68),
            tabBarGlass.topAnchor.constraint(equalTo: tabBarContainer.topAnchor),
            tabBarGlass.leadingAnchor.constraint(equalTo: tabBarContainer.leadingAnchor),
            tabBarGlass.trailingAnchor.constraint(equalTo: tabBarContainer.trailingAnchor),
            tabBarGlass.bottomAnchor.constraint(equalTo: tabBarContainer.bottomAnchor),
        ])

        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        tabBarContainer.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: tabBarContainer.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: tabBarContainer.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: tabBarContainer.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: tabBarContainer.bottomAnchor),
        ])

        for (i, item) in tabItems.enumerated() {
            let tapArea = UIControl()
            tapArea.translatesAutoresizingMaskIntoConstraints = false
            tapArea.tag = i
            tapArea.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)

            let highlight = UIView()
            highlight.translatesAutoresizingMaskIntoConstraints = false
            highlight.backgroundColor = UIColor.white.withAlphaComponent(0.35)
            highlight.layer.cornerRadius = 20
            highlight.alpha = 0
            highlight.isUserInteractionEnabled = false
            tapArea.addSubview(highlight)
            tabHighlights.append(highlight)

            let iconIV = UIImageView()
            iconIV.translatesAutoresizingMaskIntoConstraints = false
            iconIV.image = UIImage(systemName: item.icon, withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .medium))
            iconIV.contentMode = .scaleAspectFit
            iconIV.isUserInteractionEnabled = false
            iconIV.tag = 100 + i
            tapArea.addSubview(iconIV)

            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = item.label
            label.font = .appBody(10, weight: .regular)
            label.textAlignment = .center
            label.isUserInteractionEnabled = false
            tapArea.addSubview(label)
            tabLabels.append(label)

            let dot = UIView()
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.layer.cornerRadius = 2
            dot.alpha = 0
            dot.isUserInteractionEnabled = false
            tapArea.addSubview(dot)
            tabDots.append(dot)

            NSLayoutConstraint.activate([
                highlight.leadingAnchor.constraint(equalTo: tapArea.leadingAnchor, constant: 6),
                highlight.trailingAnchor.constraint(equalTo: tapArea.trailingAnchor, constant: -6),
                highlight.topAnchor.constraint(equalTo: tapArea.topAnchor, constant: 6),
                highlight.bottomAnchor.constraint(equalTo: tapArea.bottomAnchor, constant: -6),

                iconIV.centerXAnchor.constraint(equalTo: tapArea.centerXAnchor),
                iconIV.topAnchor.constraint(equalTo: tapArea.topAnchor, constant: 12),
                iconIV.widthAnchor.constraint(equalToConstant: 24),
                iconIV.heightAnchor.constraint(equalToConstant: 24),

                label.centerXAnchor.constraint(equalTo: tapArea.centerXAnchor),
                label.topAnchor.constraint(equalTo: iconIV.bottomAnchor, constant: 3),

                dot.centerXAnchor.constraint(equalTo: tapArea.centerXAnchor),
                dot.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 2),
                dot.widthAnchor.constraint(equalToConstant: 4),
                dot.heightAnchor.constraint(equalToConstant: 4),
            ])

            stackView.addArrangedSubview(tapArea)
        }
    }

    @objc private func tabTapped(_ sender: UIControl) {
        let newIndex = sender.tag
        if newIndex == selectedIndex {
            if let nav = selectedViewController as? UINavigationController,
               nav.viewControllers.count > 1 {
                nav.popToRootViewController(animated: true)
            }
            return
        }
        selectedIndex = newIndex
        updateTabBarAppearance()
    }

    private func updateTabBarAppearance() {
        let theme = Theme.shared
        let inactiveColor = theme.isDark
            ? UIColor.white.withAlphaComponent(0.45)
            : UIColor(hex: "#3C2314").withAlphaComponent(0.45)
        let highlightBg = theme.isDark
            ? UIColor.white.withAlphaComponent(0.10)
            : theme.accent.withAlphaComponent(0.10)

        for (i, _) in tabItems.enumerated() {
            let isActive = i == selectedIndex
            let color = isActive ? theme.accent : inactiveColor

            if let iconIV = tabBarContainer.viewWithTag(100 + i) as? UIImageView {
                iconIV.tintColor = color
                if isActive {
                    UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 0.55, initialSpringVelocity: 0.6) {
                        iconIV.transform = CGAffineTransform(scaleX: 1.12, y: 1.12)
                    }
                } else {
                    UIView.animate(withDuration: 0.3) { iconIV.transform = .identity }
                }
            }

            UIView.animate(withDuration: 0.3) {
                self.tabLabels[i].textColor = color
                self.tabLabels[i].font = .appBody(10, weight: isActive ? .semibold : .regular)

                self.tabHighlights[i].backgroundColor = highlightBg
                self.tabHighlights[i].alpha = isActive ? 1 : 0
                self.tabHighlights[i].layer.cornerRadius = 24
                self.tabHighlights[i].layer.cornerCurve = .continuous

                self.tabDots[i].alpha = isActive ? 1 : 0
                self.tabDots[i].backgroundColor = theme.accent
            }
        }
        tabBarGlass.refreshAppearance()
    }

    func applyTheme() {
        view.backgroundColor = Theme.shared.background
        updateTabBarAppearance()
        if questionsVC.isViewLoaded { questionsVC.updateThemeColors() }
        if favoritesVC.isViewLoaded { favoritesVC.updateThemeColors() }
        if statsVC.isViewLoaded { statsVC.updateThemeColors() }
        if settingsVC.isViewLoaded { settingsVC.updateThemeColors() }
    }

    // MARK: - Detail navigation

    fileprivate func showDetail(questionIndex: Int, category: String) {
        let vm = QuestionDetailViewModel(category: category, questionIndex: questionIndex)
        let detail = QuestionDetailViewController(viewModel: vm)
        detail.delegate = self

        let currentNav = selectedViewController as? UINavigationController
        currentNav?.pushViewController(detail, animated: true)
    }

    fileprivate func hideDetail() {
        let currentNav = selectedViewController as? UINavigationController
        currentNav?.popViewController(animated: true)
    }
}

// MARK: - UITabBarControllerDelegate

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // Ленивая установка insets — только при первом визите на таб.
        if viewController.additionalSafeAreaInsets.bottom == 0 {
            viewController.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0)
        }
        updateTabBarAppearance()
    }
}

// MARK: - Tabs delegates

extension MainTabBarController: QuestionsViewControllerDelegate {
    func questionsVC(_ vc: QuestionsViewController, didSelectQuestion index: Int, inCategory category: String) {
        showDetail(questionIndex: index, category: category)
    }
    func questionsVCDidRequestNotificationInfo(_ vc: QuestionsViewController) {}
}

extension MainTabBarController: FavoritesViewControllerDelegate {
    func favoritesVC(_ vc: FavoritesViewController, didSelectQuestion index: Int, inCategory category: String) {
        showDetail(questionIndex: index, category: category)
    }
}

extension MainTabBarController: QuestionDetailDelegate {
    func detailDidGoBack() { hideDetail() }
    func detailDidToggleFavorite() {}
    func detailDidMarkDone() {}
}
