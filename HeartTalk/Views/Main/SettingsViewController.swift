import UIKit

class SettingsViewController: UIViewController {

    private let viewModel: SettingsViewModel
    private let theme = Theme.shared

    init(viewModel: SettingsViewModel = SettingsViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.viewModel = SettingsViewModel()
        super.init(coder: coder)
    }

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsVerticalScrollIndicator = false
        return sv
    }()

    private let contentStack: UIStackView = {
        let s = UIStackView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .vertical
        s.spacing = 32
        return s
    }()

    private var notifToggle: UISwitch!
    private var quietToggle: UISwitch!
    private var colorCircles: [(UIView, UILabel)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateThemeColors()
    }

    func updateThemeColors() {
        // Refresh colors when theme changes
        view.setNeedsLayout()
    }

    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 8),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -110),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
        ])

        // Header
        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        let subLbl = UILabel()
        subLbl.translatesAutoresizingMaskIntoConstraints = false
        subLbl.text = "Персонализация"
        subLbl.font = .appBody(13, weight: .medium)
        subLbl.textColor = theme.label2
        let titleLbl = UILabel()
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        titleLbl.font = .systemFont(ofSize: 40, weight: .bold)
        let attr = NSMutableAttributedString(string: "Настройки")
        attr.addAttribute(.kern, value: -1.0, range: NSRange(location: 0, length: attr.length))
        attr.addAttribute(.foregroundColor, value: theme.label, range: NSRange(location: 0, length: attr.length))
        titleLbl.attributedText = attr
        headerView.addSubview(subLbl)
        headerView.addSubview(titleLbl)
        NSLayoutConstraint.activate([
            subLbl.topAnchor.constraint(equalTo: headerView.topAnchor),
            subLbl.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            titleLbl.topAnchor.constraint(equalTo: subLbl.bottomAnchor, constant: 2),
            titleLbl.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            titleLbl.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
        ])
        contentStack.addArrangedSubview(headerView)

        // Appearance section
        contentStack.addArrangedSubview(createSection("ВНЕШНИЙ ВИД", content: createAppearanceContent()))

        // Notifications section
        contentStack.addArrangedSubview(createSection("УВЕДОМЛЕНИЯ", content: createNotificationsContent()))

        // Data section
        contentStack.addArrangedSubview(createSection("ДАННЫЕ", content: createDataContent()))

        // About section
        contentStack.addArrangedSubview(createSection("О ПРИЛОЖЕНИИ", content: createAboutContent()))
    }

    private func createSection(_ title: String, content: UIView) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let titleLbl = UILabel()
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        let titleAttr = NSMutableAttributedString(string: title)
        titleAttr.addAttribute(.kern, value: 0.6, range: NSRange(location: 0, length: titleAttr.length))
        titleLbl.attributedText = titleAttr
        titleLbl.font = .appBody(13, weight: .semibold)
        titleLbl.textColor = theme.label2

        container.addSubview(titleLbl)
        container.addSubview(content)

        NSLayoutConstraint.activate([
            titleLbl.topAnchor.constraint(equalTo: container.topAnchor),
            titleLbl.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 4),
            content.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 8),
            content.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            content.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])

        return container
    }

    // MARK: - Appearance

    private func createAppearanceContent() -> UIView {
        let card = GlassView(cornerRadius: 20, opacity: 0.68)
        card.translatesAutoresizingMaskIntoConstraints = false

        let innerStack = UIStackView()
        innerStack.axis = .vertical
        innerStack.spacing = 16
        innerStack.translatesAutoresizingMaskIntoConstraints = false

        // Color label
        let colorLbl = UILabel()
        colorLbl.translatesAutoresizingMaskIntoConstraints = false
        colorLbl.text = "Акцентный цвет"
        colorLbl.font = .appBody(15)
        colorLbl.textColor = theme.label
        innerStack.addArrangedSubview(colorLbl)

        // Color grid - 5x2
        let colorGrid = UIView()
        colorGrid.translatesAutoresizingMaskIntoConstraints = false

        colorCircles = []
        let palettes = ColorPalette.all

        for (i, p) in palettes.enumerated() {
            let col = i % 5
            let row = i / 5

            let circleContainer = UIView()
            circleContainer.translatesAutoresizingMaskIntoConstraints = false
            circleContainer.tag = i
            let tap = UITapGestureRecognizer(target: self, action: #selector(colorTapped(_:)))
            circleContainer.addGestureRecognizer(tap)
            circleContainer.isUserInteractionEnabled = true

            let circle = UIView()
            circle.translatesAutoresizingMaskIntoConstraints = false
            circle.layer.cornerRadius = 22
            circle.backgroundColor = p.main

            let checkmark = UIImageView(image: UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .bold))?.withTintColor(.white, renderingMode: .alwaysOriginal))
            checkmark.translatesAutoresizingMaskIntoConstraints = false
            checkmark.isHidden = true
            checkmark.tag = 999
            circle.addSubview(checkmark)

            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = p.label
            label.font = .appBody(11)
            label.textColor = theme.label3
            label.textAlignment = .center

            circleContainer.addSubview(circle)
            circleContainer.addSubview(label)
            colorGrid.addSubview(circleContainer)

            let spacing: CGFloat = (UIScreen.main.bounds.width - 40 - 40 - 44 * 5) / 4
            let x = CGFloat(col) * (44 + spacing)
            let y = CGFloat(row) * 68

            NSLayoutConstraint.activate([
                circleContainer.leadingAnchor.constraint(equalTo: colorGrid.leadingAnchor, constant: x),
                circleContainer.topAnchor.constraint(equalTo: colorGrid.topAnchor, constant: y),
                circleContainer.widthAnchor.constraint(equalToConstant: 44),

                circle.topAnchor.constraint(equalTo: circleContainer.topAnchor),
                circle.centerXAnchor.constraint(equalTo: circleContainer.centerXAnchor),
                circle.widthAnchor.constraint(equalToConstant: 44),
                circle.heightAnchor.constraint(equalToConstant: 44),

                checkmark.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
                checkmark.centerYAnchor.constraint(equalTo: circle.centerYAnchor),

                label.topAnchor.constraint(equalTo: circle.bottomAnchor, constant: 6),
                label.centerXAnchor.constraint(equalTo: circleContainer.centerXAnchor),
                label.bottomAnchor.constraint(equalTo: circleContainer.bottomAnchor),
            ])

            colorCircles.append((circle, label))
        }

        colorGrid.heightAnchor.constraint(equalToConstant: 136).isActive = true
        innerStack.addArrangedSubview(colorGrid)
        updateColorSelection()

        // Separator
        let sep = UIView()
        sep.translatesAutoresizingMaskIntoConstraints = false
        sep.backgroundColor = theme.separator
        sep.heightAnchor.constraint(equalToConstant: 1).isActive = true

        card.addSubview(innerStack)
        NSLayoutConstraint.activate([
            innerStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            innerStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            innerStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            innerStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
        ])

        return card
    }

    // MARK: - Notifications

    private func createNotificationsContent() -> UIView {
        let card = GlassView(cornerRadius: 20, opacity: 0.68)
        card.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false

        notifToggle = UISwitch()
        notifToggle.onTintColor = theme.accent
        notifToggle.isOn = viewModel.isNotificationsEnabled
        notifToggle.addTarget(self, action: #selector(notifToggled), for: .valueChanged)

        stack.addArrangedSubview(createSettingsRow(
            icon: "bell", tint: theme.accent,
            title: "Вопрос дня", sub: "Ежедневное напоминание",
            right: notifToggle, showSep: true
        ))

        quietToggle = UISwitch()
        quietToggle.onTintColor = theme.accent
        quietToggle.isOn = viewModel.isQuietHoursEnabled
        quietToggle.addTarget(self, action: #selector(quietToggled), for: .valueChanged)

        stack.addArrangedSubview(createSettingsRow(
            icon: "moon", tint: UIColor(hex: "#34C759"),
            title: "Тихие часы", sub: "22:00 — 8:00",
            right: quietToggle, showSep: false
        ))

        card.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor),
        ])

        return card
    }

    // MARK: - Data

    private func createDataContent() -> UIView {
        let card = GlassView(cornerRadius: 20, opacity: 0.68)
        card.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false

        stack.addArrangedSubview(createSettingsRow(
            icon: "lock", tint: UIColor(hex: "#007AFF"),
            title: "Приватность", sub: "Все данные хранятся локально",
            right: nil, showSep: false
        ))

        card.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor),
        ])

        return card
    }

    // MARK: - About

    private func createAboutContent() -> UIView {
        let card = GlassView(cornerRadius: 20, opacity: 0.68)
        card.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false

        stack.addArrangedSubview(createSettingsRow(
            icon: "info.circle", tint: theme.accent,
            title: "HeartTalk", sub: "Версия 1.0.0 (beta)",
            right: nil, showSep: false
        ))

        card.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor),
        ])

        return card
    }

    // MARK: - Helpers

    private func createSettingsRow(icon: String, tint: UIColor, title: String, sub: String, right: UIView?, showSep: Bool) -> UIView {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false

        let iconBg = UIView()
        iconBg.translatesAutoresizingMaskIntoConstraints = false
        iconBg.backgroundColor = tint
        iconBg.layer.cornerRadius = 8

        let iconIV = UIImageView(image: UIImage(systemName: icon, withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .medium))?.withTintColor(.white, renderingMode: .alwaysOriginal))
        iconIV.translatesAutoresizingMaskIntoConstraints = false
        iconIV.contentMode = .scaleAspectFit
        iconBg.addSubview(iconIV)

        let titleLbl = UILabel()
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        titleLbl.text = title
        titleLbl.font = .appBody(16)
        titleLbl.textColor = theme.label

        let subLbl = UILabel()
        subLbl.translatesAutoresizingMaskIntoConstraints = false
        subLbl.text = sub
        subLbl.font = .appBody(13)
        subLbl.textColor = theme.label3

        row.addSubview(iconBg)
        row.addSubview(titleLbl)
        row.addSubview(subLbl)

        var constraints = [
            iconBg.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 18),
            iconBg.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            iconBg.widthAnchor.constraint(equalToConstant: 32),
            iconBg.heightAnchor.constraint(equalToConstant: 32),

            iconIV.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            iconIV.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),

            titleLbl.leadingAnchor.constraint(equalTo: iconBg.trailingAnchor, constant: 14),
            titleLbl.topAnchor.constraint(equalTo: row.topAnchor, constant: 14),

            subLbl.leadingAnchor.constraint(equalTo: titleLbl.leadingAnchor),
            subLbl.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 1),
            subLbl.bottomAnchor.constraint(equalTo: row.bottomAnchor, constant: -14),
        ]

        if let right = right {
            right.translatesAutoresizingMaskIntoConstraints = false
            row.addSubview(right)
            constraints.append(right.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -18))
            constraints.append(right.centerYAnchor.constraint(equalTo: row.centerYAnchor))
            constraints.append(titleLbl.trailingAnchor.constraint(lessThanOrEqualTo: right.leadingAnchor, constant: -8))
        }

        if showSep {
            let sep = UIView()
            sep.translatesAutoresizingMaskIntoConstraints = false
            sep.backgroundColor = theme.separator
            row.addSubview(sep)
            constraints.append(contentsOf: [
                sep.leadingAnchor.constraint(equalTo: titleLbl.leadingAnchor),
                sep.trailingAnchor.constraint(equalTo: row.trailingAnchor),
                sep.bottomAnchor.constraint(equalTo: row.bottomAnchor),
                sep.heightAnchor.constraint(equalToConstant: 0.5),
            ])
        }

        NSLayoutConstraint.activate(constraints)
        return row
    }

    private func makeChevron() -> UIImageView {
        let iv = UIImageView(image: UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .medium))?.withTintColor(theme.label3, renderingMode: .alwaysOriginal))
        iv.contentMode = .scaleAspectFit
        return iv
    }

    // MARK: - Actions

    @objc private func colorTapped(_ sender: UITapGestureRecognizer) {
        guard let tag = sender.view?.tag else { return }
        viewModel.setPalette(ColorPalette.all[tag])
        updateColorSelection()
    }

    @objc private func notifToggled() {
        let desired = notifToggle.isOn
        viewModel.setNotificationsEnabled(desired) { [weak self] granted in
            if desired && !granted {
                self?.notifToggle.setOn(false, animated: true)
            }
        }
    }

    @objc private func quietToggled() {
        viewModel.setQuietHoursEnabled(quietToggle.isOn)
    }

    private func updateColorSelection() {
        let activeID = theme.palette.id
        // Все circles одинакового размера 44x44, cornerRadius 22 — фиксированный shadowPath
        let circlePath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 44, height: 44), cornerRadius: 22).cgPath
        for (i, (circle, label)) in colorCircles.enumerated() {
            let palette = ColorPalette.all[i]
            let isActive = palette.id == activeID

            circle.layer.shadowPath = circlePath

            if isActive {
                circle.layer.borderWidth = 3
                circle.layer.borderColor = UIColor.white.cgColor
                circle.layer.shadowColor = palette.main.cgColor
                circle.layer.shadowOpacity = 0.5
                circle.layer.shadowOffset = .zero
                circle.layer.shadowRadius = 5
                label.textColor = palette.main
                label.font = .appBody(11, weight: .semibold)
            } else {
                circle.layer.borderWidth = 0
                circle.layer.shadowOpacity = 0.15
                circle.layer.shadowColor = UIColor.black.cgColor
                circle.layer.shadowOffset = CGSize(width: 0, height: 2)
                circle.layer.shadowRadius = 8
                label.textColor = theme.label3
                label.font = .appBody(11, weight: .regular)
            }

            // Show/hide checkmark
            if let checkmark = circle.viewWithTag(999) as? UIImageView {
                checkmark.isHidden = !isActive
            }
        }
    }
}
