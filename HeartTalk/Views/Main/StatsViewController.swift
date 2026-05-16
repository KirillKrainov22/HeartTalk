import UIKit

class StatsViewController: UIViewController {

    private let viewModel: StatsViewModel
    private let theme = Theme.shared

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let heroNumberLabel = UILabel()
    private let heroSubLabel = UILabel()
    private var statValueLabels: [UILabel] = []
    private var toneBarFills: [UIView] = []
    private var tonePctLabels: [UILabel] = []
    private var toneBarBgs: [UIView] = []

    private var weekBars: [UIView] = []
    private var weekBarHeights: [NSLayoutConstraint] = []
    private var weekCounts: [Int] = Array(repeating: 0, count: 7)
    private weak var weekCardView: UIView?
    private weak var activeTooltip: UIView?
    private let weekDayLabels = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]

    init(viewModel: StatsViewModel = StatsViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.viewModel = StatsViewModel()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupUI()
        viewModel.onSnapshotReady = { [weak self] snap in self?.apply(snap) }
        NotificationCenter.default.addObserver(self, selector: #selector(externalChange),
                                               name: .questionsDidChange, object: nil)
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateThemeColors()
        viewModel.refresh()
    }

    @objc private func externalChange() { viewModel.refresh() }

    func updateThemeColors() {
        heroNumberLabel.textColor = theme.label
        heroSubLabel.textColor = theme.label2
    }

    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 16

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

        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        let subLbl = UILabel()
        subLbl.translatesAutoresizingMaskIntoConstraints = false
        subLbl.text = "Ваш прогресс"
        subLbl.font = .appBody(13, weight: .medium)
        subLbl.textColor = theme.label2
        let titleLbl = UILabel()
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        titleLbl.font = .systemFont(ofSize: 40, weight: .bold)
        let attr = NSMutableAttributedString(string: "Статистика")
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

        heroNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        heroNumberLabel.font = .systemFont(ofSize: 100, weight: .bold)
        heroSubLabel.translatesAutoresizingMaskIntoConstraints = false
        heroSubLabel.text = "вопросов обсуждено вместе"
        heroSubLabel.font = .appBody(15)

        let heroView = UIView()
        heroView.translatesAutoresizingMaskIntoConstraints = false
        heroView.addSubview(heroNumberLabel)
        heroView.addSubview(heroSubLabel)
        NSLayoutConstraint.activate([
            heroNumberLabel.topAnchor.constraint(equalTo: heroView.topAnchor),
            heroNumberLabel.leadingAnchor.constraint(equalTo: heroView.leadingAnchor),
            heroSubLabel.topAnchor.constraint(equalTo: heroNumberLabel.bottomAnchor, constant: 4),
            heroSubLabel.leadingAnchor.constraint(equalTo: heroView.leadingAnchor),
            heroSubLabel.bottomAnchor.constraint(equalTo: heroView.bottomAnchor),
        ])
        contentStack.addArrangedSubview(heroView)

        contentStack.addArrangedSubview(createStatsGrid())
        contentStack.addArrangedSubview(createToneCard())
        contentStack.addArrangedSubview(createWeekCard())
    }

    private func createStatsGrid() -> UIView {
        let stats: [(String, String, String, Bool)] = [
            ("Заметок", "0", "сохранено", false),
            ("Избранных", "0", "сохранено", false),
            ("Серия", "0", "дня подряд", false),
            ("Категорий", "0/4", "изучено", false),
        ]

        statValueLabels = []
        var cards: [UIView] = []

        for (label, val, sub, isAccent) in stats {
            let card = GlassView(cornerRadius: 20, opacity: 0.68)
            card.translatesAutoresizingMaskIntoConstraints = false
            if isAccent { card.backgroundColor = theme.accent.withAlphaComponent(0.10) }

            let tLbl = UILabel()
            tLbl.translatesAutoresizingMaskIntoConstraints = false
            tLbl.text = label.uppercased()
            tLbl.font = .appBody(11, weight: .semibold)
            tLbl.textColor = isAccent ? theme.accent : theme.label2

            let vLbl = UILabel()
            vLbl.translatesAutoresizingMaskIntoConstraints = false
            vLbl.text = val
            vLbl.font = .systemFont(ofSize: 32, weight: .bold)
            vLbl.textColor = isAccent ? theme.accent : theme.label
            statValueLabels.append(vLbl)

            let sLbl = UILabel()
            sLbl.translatesAutoresizingMaskIntoConstraints = false
            sLbl.text = sub
            sLbl.font = .appBody(12)
            sLbl.textColor = theme.label3

            card.addSubview(tLbl)
            card.addSubview(vLbl)
            card.addSubview(sLbl)
            NSLayoutConstraint.activate([
                tLbl.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
                tLbl.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
                vLbl.topAnchor.constraint(equalTo: tLbl.bottomAnchor, constant: 8),
                vLbl.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
                sLbl.topAnchor.constraint(equalTo: vLbl.bottomAnchor, constant: 2),
                sLbl.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
                sLbl.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18),
            ])
            cards.append(card)
        }

        let row1 = UIStackView(arrangedSubviews: [cards[0], cards[1]])
        row1.axis = .horizontal; row1.spacing = 12; row1.distribution = .fillEqually
        row1.translatesAutoresizingMaskIntoConstraints = false
        let row2 = UIStackView(arrangedSubviews: [cards[2], cards[3]])
        row2.axis = .horizontal; row2.spacing = 12; row2.distribution = .fillEqually
        row2.translatesAutoresizingMaskIntoConstraints = false

        let vStack = UIStackView(arrangedSubviews: [row1, row2])
        vStack.axis = .vertical; vStack.spacing = 12
        vStack.translatesAutoresizingMaskIntoConstraints = false
        return vStack
    }

    private func createToneCard() -> UIView {
        let card = GlassView(cornerRadius: 20, opacity: 0.68)
        card.translatesAutoresizingMaskIntoConstraints = false

        let titleLbl = UILabel()
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        titleLbl.text = "Тональность заметок"
        titleLbl.font = .appBody(15, weight: .semibold)
        titleLbl.textColor = theme.label

        let nlpLbl = UILabel()
        nlpLbl.translatesAutoresizingMaskIntoConstraints = false
        nlpLbl.text = "NLP"
        nlpLbl.font = .appBody(13)
        nlpLbl.textColor = theme.label3

        let barsStack = UIStackView()
        barsStack.axis = .vertical
        barsStack.spacing = 12
        barsStack.translatesAutoresizingMaskIntoConstraints = false

        let tones: [(String, UIColor)] = [
            ("Позитив", UIColor(hex: "#34C759")),
            ("Нейтрально", UIColor(hex: "#FF9F0A")),
            ("Негатив", UIColor(hex: "#FF3B30")),
        ]

        toneBarFills = []
        tonePctLabels = []
        toneBarBgs = []

        for (label, color) in tones {
            let row = UIView()
            row.translatesAutoresizingMaskIntoConstraints = false
            row.heightAnchor.constraint(equalToConstant: 20).isActive = true

            let lbl = UILabel()
            lbl.translatesAutoresizingMaskIntoConstraints = false
            lbl.text = label
            lbl.font = .appBody(13)
            lbl.textColor = theme.label2

            let barBg = UIView()
            barBg.translatesAutoresizingMaskIntoConstraints = false
            barBg.backgroundColor = theme.fill
            barBg.layer.cornerRadius = 3
            toneBarBgs.append(barBg)

            let barFill = UIView()
            barFill.translatesAutoresizingMaskIntoConstraints = false
            barFill.backgroundColor = color
            barFill.layer.cornerRadius = 3
            toneBarFills.append(barFill)

            let pctLbl = UILabel()
            pctLbl.translatesAutoresizingMaskIntoConstraints = false
            pctLbl.font = .appBody(13, weight: .semibold)
            pctLbl.textColor = theme.label
            pctLbl.textAlignment = .right
            pctLbl.text = "0%"
            tonePctLabels.append(pctLbl)

            barBg.addSubview(barFill)
            row.addSubview(lbl)
            row.addSubview(barBg)
            row.addSubview(pctLbl)

            NSLayoutConstraint.activate([
                lbl.leadingAnchor.constraint(equalTo: row.leadingAnchor),
                lbl.centerYAnchor.constraint(equalTo: row.centerYAnchor),
                lbl.widthAnchor.constraint(equalToConstant: 90),
                barBg.leadingAnchor.constraint(equalTo: lbl.trailingAnchor, constant: 10),
                barBg.centerYAnchor.constraint(equalTo: row.centerYAnchor),
                barBg.heightAnchor.constraint(equalToConstant: 6),
                barBg.trailingAnchor.constraint(equalTo: pctLbl.leadingAnchor, constant: -10),
                barFill.leadingAnchor.constraint(equalTo: barBg.leadingAnchor),
                barFill.topAnchor.constraint(equalTo: barBg.topAnchor),
                barFill.bottomAnchor.constraint(equalTo: barBg.bottomAnchor),
                barFill.widthAnchor.constraint(equalToConstant: 0),
                pctLbl.trailingAnchor.constraint(equalTo: row.trailingAnchor),
                pctLbl.centerYAnchor.constraint(equalTo: row.centerYAnchor),
                pctLbl.widthAnchor.constraint(equalToConstant: 40),
            ])
            barsStack.addArrangedSubview(row)
        }

        card.addSubview(titleLbl)
        card.addSubview(nlpLbl)
        card.addSubview(barsStack)

        NSLayoutConstraint.activate([
            titleLbl.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            titleLbl.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            nlpLbl.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            nlpLbl.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            barsStack.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 16),
            barsStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            barsStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            barsStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20),
        ])
        return card
    }

    private func createWeekCard() -> UIView {
        let card = GlassView(cornerRadius: 20, opacity: 0.68)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.clipsToBounds = false
        weekCardView = card

        let titleLbl = UILabel()
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        titleLbl.text = "Активность за неделю"
        titleLbl.font = .appBody(15, weight: .semibold)
        titleLbl.textColor = theme.label

        let subLbl = UILabel()
        subLbl.translatesAutoresizingMaskIntoConstraints = false
        subLbl.text = "вопросов/день"
        subLbl.font = .appBody(13)
        subLbl.textColor = theme.label3

        let barsContainer = UIStackView()
        barsContainer.axis = .horizontal
        barsContainer.spacing = 8
        barsContainer.distribution = .fillEqually
        barsContainer.alignment = .bottom
        barsContainer.translatesAutoresizingMaskIntoConstraints = false

        weekBars = []
        weekBarHeights = []
        let todayWeekday = currentWeekdayIndex()

        for (i, day) in weekDayLabels.enumerated() {
            let col = UIView()
            col.translatesAutoresizingMaskIntoConstraints = false
            col.tag = i
            col.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(barTapped(_:)))
            col.addGestureRecognizer(tap)

            let bar = UIView()
            bar.translatesAutoresizingMaskIntoConstraints = false
            bar.backgroundColor = i == todayWeekday ? theme.accent : theme.fill
            bar.layer.cornerRadius = 3
            weekBars.append(bar)
            let h = bar.heightAnchor.constraint(equalToConstant: 4)
            h.isActive = true
            weekBarHeights.append(h)

            let dayLbl = UILabel()
            dayLbl.translatesAutoresizingMaskIntoConstraints = false
            dayLbl.text = day
            dayLbl.font = .appBody(11)
            dayLbl.textColor = theme.label3
            dayLbl.textAlignment = .center

            col.addSubview(bar)
            col.addSubview(dayLbl)
            NSLayoutConstraint.activate([
                bar.topAnchor.constraint(greaterThanOrEqualTo: col.topAnchor),
                bar.leadingAnchor.constraint(equalTo: col.leadingAnchor, constant: 4),
                bar.trailingAnchor.constraint(equalTo: col.trailingAnchor, constant: -4),
                bar.bottomAnchor.constraint(equalTo: dayLbl.topAnchor, constant: -4),
                dayLbl.centerXAnchor.constraint(equalTo: col.centerXAnchor),
                dayLbl.bottomAnchor.constraint(equalTo: col.bottomAnchor),
            ])
            barsContainer.addArrangedSubview(col)
        }

        card.addSubview(titleLbl)
        card.addSubview(subLbl)
        card.addSubview(barsContainer)
        NSLayoutConstraint.activate([
            titleLbl.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            titleLbl.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            subLbl.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            subLbl.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            barsContainer.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 16),
            barsContainer.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            barsContainer.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            barsContainer.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20),
            barsContainer.heightAnchor.constraint(equalToConstant: 100),
        ])
        return card
    }

    private func currentWeekdayIndex() -> Int {
        var calendar = Calendar(identifier: .iso8601)
        calendar.firstWeekday = 2
        guard let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.start else { return 0 }
        let days = calendar.dateComponents([.day], from: startOfWeek, to: Date()).day ?? 0
        return max(0, min(6, days))
    }

    private func apply(_ snap: StatsViewModel.Snapshot) {
        let attr = NSMutableAttributedString(string: "\(snap.discussedTotal)")
        attr.addAttribute(.kern, value: -5.0, range: NSRange(location: 0, length: attr.length))
        heroNumberLabel.attributedText = attr

        if statValueLabels.count >= 4 {
            statValueLabels[0].text = "\(snap.notesCount)"
            statValueLabels[1].text = "\(snap.favoritesCount)"
            statValueLabels[2].text = "\(snap.streak)"
            statValueLabels[3].text = "\(snap.categoriesExplored)/\(snap.totalCategories)"
        }

        let pcts = [snap.sentiment.positive, snap.sentiment.neutral, snap.sentiment.negative]
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let self = self else { return }
            for (i, barFill) in self.toneBarFills.enumerated() {
                let pct = pcts[i]
                self.tonePctLabels[i].text = "\(Int(pct))%"
                if let barBg = self.toneBarBgs[safe: i] {
                    let maxWidth = barBg.bounds.width
                    barFill.constraints.filter { $0.firstAttribute == .width }.forEach { $0.isActive = false }
                    barFill.widthAnchor.constraint(equalToConstant: maxWidth * CGFloat(pct) / 100.0).isActive = true
                    UIView.animate(withDuration: 0.8, delay: Double(i) * 0.1, options: .curveEaseOut) {
                        barBg.layoutIfNeeded()
                    }
                }
            }
        }

        // Week activity — absolute scale: 16pt per question, capped at 80
        weekCounts = snap.weekActivity
        let today = currentWeekdayIndex()
        for (i, bar) in weekBars.enumerated() {
            let value = snap.weekActivity[safe: i] ?? 0
            let h = value > 0 ? min(80, CGFloat(value) * 16) : 4
            weekBarHeights[i].constant = h
            bar.backgroundColor = (value > 0 || i == today) ? theme.accent : theme.fill
        }
        UIView.animate(withDuration: 0.45) { self.view.layoutIfNeeded() }
    }

    @objc private func barTapped(_ sender: UITapGestureRecognizer) {
        guard let col = sender.view, let card = weekCardView else { return }
        let index = col.tag
        let count = weekCounts[safe: index] ?? 0

        activeTooltip?.removeFromSuperview()

        let tooltip = UIView()
        tooltip.backgroundColor = UIColor(hex: "#1A1A1A")
        tooltip.layer.cornerRadius = 8

        let label = UILabel()
        label.text = count == 0 ? "0" : "\(count)"
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .white
        label.sizeToFit()

        let hPad: CGFloat = 10
        let tooltipW = label.frame.width + hPad * 2
        let tooltipH: CGFloat = 26
        label.frame = CGRect(x: hPad, y: (tooltipH - label.frame.height) / 2,
                             width: label.frame.width, height: label.frame.height)
        tooltip.addSubview(label)

        card.layoutIfNeeded()
        let colFrame = col.convert(col.bounds, to: card)
        let bar = weekBars[index]
        let barFrame = bar.convert(bar.bounds, to: card)

        let tooltipX = max(8, min(colFrame.midX - tooltipW / 2, card.bounds.width - tooltipW - 8))
        let tooltipY = max(8, barFrame.minY - tooltipH - 6)
        tooltip.frame = CGRect(x: tooltipX, y: tooltipY, width: tooltipW, height: tooltipH)

        tooltip.alpha = 0
        tooltip.transform = CGAffineTransform(translationX: 0, y: 4).scaledBy(x: 0.85, y: 0.85)
        card.addSubview(tooltip)
        activeTooltip = tooltip

        UIView.animate(withDuration: 0.18, delay: 0, options: .curveEaseOut) {
            tooltip.alpha = 1
            tooltip.transform = .identity
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak tooltip] in
            UIView.animate(withDuration: 0.18) { tooltip?.alpha = 0 } completion: { _ in
                tooltip?.removeFromSuperview()
            }
        }
    }
}
