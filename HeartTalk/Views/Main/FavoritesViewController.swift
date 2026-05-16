import UIKit

protocol FavoritesViewControllerDelegate: AnyObject {
    func favoritesVC(_ vc: FavoritesViewController, didSelectQuestion index: Int, inCategory category: String)
}

class FavoritesViewController: UIViewController {

    weak var delegate: FavoritesViewControllerDelegate?

    private let viewModel: FavoritesViewModel
    private let theme = Theme.shared

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let subtitleLabel = UILabel()
    private let titleLabel = UILabel()

    init(viewModel: FavoritesViewModel = FavoritesViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.viewModel = FavoritesViewModel()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupUI()
        viewModel.onDataChanged = { [weak self] in self?.renderItems() }
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData),
                                               name: .questionsDidChange, object: nil)
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateThemeColors()
        reloadData()
    }

    func updateThemeColors() {
        subtitleLabel.textColor = theme.label2
        let attr = NSMutableAttributedString(string: "Избранное")
        attr.addAttribute(.kern, value: -1.0, range: NSRange(location: 0, length: attr.length))
        attr.addAttribute(.foregroundColor, value: theme.label, range: NSRange(location: 0, length: attr.length))
        titleLabel.attributedText = attr
    }

    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 12

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Сохранённые"
        subtitleLabel.font = .appBody(13, weight: .medium)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 40, weight: .bold)
        headerView.addSubview(subtitleLabel)
        headerView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            subtitleLabel.topAnchor.constraint(equalTo: headerView.topAnchor),
            subtitleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 2),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
        ])
        contentStack.addArrangedSubview(headerView)
        contentStack.setCustomSpacing(24, after: headerView)

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
    }

    @objc func reloadData() {
        viewModel.reload()
    }

    private func renderItems() {
        while contentStack.arrangedSubviews.count > 1 {
            contentStack.arrangedSubviews.last?.removeFromSuperview()
        }

        if viewModel.items.isEmpty {
            showEmptyState()
        } else {
            for item in viewModel.items {
                contentStack.addArrangedSubview(createFavCard(item: item))
            }
        }
    }

    private func showEmptyState() {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let iconBg = GlassView(cornerRadius: 36, opacity: 0.65)
        iconBg.translatesAutoresizingMaskIntoConstraints = false
        let heartIV = UIImageView(image: UIImage(systemName: "heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)))
        heartIV.translatesAutoresizingMaskIntoConstraints = false
        heartIV.tintColor = theme.label3

        let emptyTitle = UILabel()
        emptyTitle.translatesAutoresizingMaskIntoConstraints = false
        emptyTitle.text = "Пока пусто"
        emptyTitle.font = .appBody(22, weight: .bold)
        emptyTitle.textColor = theme.label

        let emptySubtitle = UILabel()
        emptySubtitle.translatesAutoresizingMaskIntoConstraints = false
        emptySubtitle.text = "Нажмите на сердечко на карточке вопроса, чтобы сохранить его сюда"
        emptySubtitle.font = .appBody(15)
        emptySubtitle.textColor = theme.label2
        emptySubtitle.numberOfLines = 0
        emptySubtitle.textAlignment = .center

        iconBg.addSubview(heartIV)
        container.addSubview(iconBg)
        container.addSubview(emptyTitle)
        container.addSubview(emptySubtitle)

        NSLayoutConstraint.activate([
            iconBg.topAnchor.constraint(equalTo: container.topAnchor, constant: 60),
            iconBg.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            iconBg.widthAnchor.constraint(equalToConstant: 72),
            iconBg.heightAnchor.constraint(equalToConstant: 72),
            heartIV.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            heartIV.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
            emptyTitle.topAnchor.constraint(equalTo: iconBg.bottomAnchor, constant: 20),
            emptyTitle.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            emptySubtitle.topAnchor.constraint(equalTo: emptyTitle.bottomAnchor, constant: 8),
            emptySubtitle.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            emptySubtitle.widthAnchor.constraint(lessThanOrEqualToConstant: 260),
            emptySubtitle.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])

        contentStack.addArrangedSubview(container)
    }

    private func createFavCard(item: FavoritesViewModel.Item) -> UIView {
        let card = GlassView(cornerRadius: 20, opacity: 0.68)
        card.translatesAutoresizingMaskIntoConstraints = false

        let catLbl = UILabel()
        catLbl.translatesAutoresizingMaskIntoConstraints = false
        catLbl.font = .appBody(12, weight: .semibold)
        catLbl.textColor = theme.accent
        catLbl.text = item.category.uppercased()

        let qLbl = UILabel()
        qLbl.translatesAutoresizingMaskIntoConstraints = false
        qLbl.text = item.question.question
        qLbl.font = .appBody(17)
        qLbl.textColor = theme.label
        qLbl.numberOfLines = 0

        let badgeStack = UIStackView()
        badgeStack.translatesAutoresizingMaskIntoConstraints = false
        badgeStack.axis = .horizontal
        badgeStack.spacing = 8

        if item.isDiscussed {
            badgeStack.addArrangedSubview(makeBadge("✓ Обсуждён"))
        }
        badgeStack.addArrangedSubview(makeBadge("♥ Избранное"))

        card.addSubview(catLbl)
        card.addSubview(qLbl)
        card.addSubview(badgeStack)

        NSLayoutConstraint.activate([
            catLbl.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            catLbl.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            qLbl.topAnchor.constraint(equalTo: catLbl.bottomAnchor, constant: 8),
            qLbl.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            qLbl.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            badgeStack.topAnchor.constraint(equalTo: qLbl.bottomAnchor, constant: 14),
            badgeStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            badgeStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20),
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(favCardTapped(_:)))
        card.addGestureRecognizer(tap)
        card.isUserInteractionEnabled = true
        card.accessibilityIdentifier = "\(item.category):\(item.indexInCategory)"

        return card
    }

    private func makeBadge(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = "  \(text)  "
        l.font = .appBody(12)
        l.textColor = theme.accent
        l.backgroundColor = theme.accent.withAlphaComponent(0.10)
        l.layer.cornerRadius = 10
        l.clipsToBounds = true
        return l
    }

    @objc private func favCardTapped(_ sender: UITapGestureRecognizer) {
        guard let id = sender.view?.accessibilityIdentifier else { return }
        let parts = id.split(separator: ":")
        guard parts.count == 2, let index = Int(parts[1]) else { return }
        delegate?.favoritesVC(self, didSelectQuestion: index, inCategory: String(parts[0]))
    }
}
