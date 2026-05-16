import UIKit

protocol QuestionsViewControllerDelegate: AnyObject {
    func questionsVC(_ vc: QuestionsViewController, didSelectQuestion index: Int, inCategory category: String)
    func questionsVCDidRequestNotificationInfo(_ vc: QuestionsViewController)
}

class QuestionsViewController: UIViewController {

    weak var delegate: QuestionsViewControllerDelegate?

    private let viewModel: QuestionsViewModel
    private let theme = Theme.shared
    private let toastView = ToastView()

    // Header
    private let greetingLabel = UILabel()
    private let appIconView = UIView()
    private let appIconHeart = UIImageView(image: UIImage(systemName: "heart.fill")?.withRenderingMode(.alwaysTemplate))
    private let titleLabel = UILabel()
    private let bellButton = UIButton(type: .system)
    private let bellCircle = UIView()

    // Pills
    private let pillsScroll = UIScrollView()
    private let pillsStack = UIStackView()

    // Dots
    private let dotsStack = UIStackView()

    // Cards
    private var collectionView: UICollectionView!
    private let cardWidth: CGFloat = 313
    private let cardSpacing: CGFloat = 16

    // Nav
    private let prevButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)
    private let prevCircle = UIView()
    private let nextCircle = UIView()
    private let categoryLabel = UILabel()

    init(viewModel: QuestionsViewModel = QuestionsViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.viewModel = QuestionsViewModel()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        viewModel.onDataChanged = { [weak self] in
            self?.collectionView.reloadData()
            self?.updatePills()
            self?.updateNavButtons()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(externalDataChanged),
                                               name: .questionsDidChange, object: nil)

        setupHeader()
        setupPills()
        setupCollectionView()
        setupNavButtons()
        updateThemeColors()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.reloadQuestions()
        collectionView.reloadData()
        updateThemeColors()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Обновляем shadowPath у активного pill после layout (только path,
        // чтобы не вызвать loop через updatePills, который меняет font)
        for pill in pillsStack.arrangedSubviews {
            guard !pill.bounds.isEmpty else { continue }
            pill.layer.shadowPath = UIBezierPath(roundedRect: pill.bounds, cornerRadius: 20).cgPath
        }
    }

    @objc private func externalDataChanged() {
        viewModel.reloadQuestions()
        collectionView.reloadData()
    }

    private func headerTitle() -> String {
        let user = UserSettings.shared.userName.trimmingCharacters(in: .whitespaces)
        let partner = UserSettings.shared.partnerName.trimmingCharacters(in: .whitespaces)
        if !user.isEmpty && !partner.isEmpty { return "\(user) и \(partner)" }
        if !user.isEmpty { return user }
        return "HeartTalk"
    }

    func updateThemeColors() {
        greetingLabel.textColor = theme.label2
        greetingLabel.text = viewModel.greetingText()
        let title = headerTitle()
        let attr = NSMutableAttributedString(string: title)
        attr.addAttribute(.kern, value: -0.5, range: NSRange(location: 0, length: title.count))
        attr.addAttribute(.foregroundColor, value: theme.label, range: NSRange(location: 0, length: title.count))
        titleLabel.attributedText = attr
        appIconView.backgroundColor = theme.accent
        bellButton.tintColor = theme.accent
        bellCircle.backgroundColor = theme.fill
        prevCircle.backgroundColor = theme.fill
        nextCircle.backgroundColor = theme.fill
        categoryLabel.textColor = theme.label3
        updatePills()
        updateNavButtons()
        collectionView?.reloadData()
    }

    // MARK: - Header

    private func setupHeader() {
        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.tag = 100
        view.addSubview(headerView)

        greetingLabel.translatesAutoresizingMaskIntoConstraints = false
        greetingLabel.font = .appBody(13, weight: .medium)
        headerView.addSubview(greetingLabel)

        let titleRow = UIView()
        titleRow.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleRow)

        appIconView.translatesAutoresizingMaskIntoConstraints = false
        appIconView.layer.cornerRadius = 12
        appIconView.layer.shadowColor = UIColor.black.cgColor
        appIconView.layer.shadowOpacity = 0.18
        appIconView.layer.shadowOffset = CGSize(width: 0, height: 6)
        appIconView.layer.shadowRadius = 18
        // Размер фиксированный (44x44), задаём shadowPath сразу
        appIconView.layer.shadowPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 44, height: 44), cornerRadius: 12).cgPath

        appIconHeart.translatesAutoresizingMaskIntoConstraints = false
        appIconHeart.tintColor = .white
        appIconHeart.contentMode = .scaleAspectFit
        appIconView.addSubview(appIconHeart)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 34, weight: .bold)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.55
        titleLabel.numberOfLines = 1

        bellCircle.translatesAutoresizingMaskIntoConstraints = false
        bellCircle.layer.cornerRadius = 18
        bellButton.translatesAutoresizingMaskIntoConstraints = false
        updateBellIcon()
        bellButton.addTarget(self, action: #selector(bellTapped), for: .touchUpInside)

        titleRow.addSubview(appIconView)
        titleRow.addSubview(titleLabel)
        titleRow.addSubview(bellCircle)
        titleRow.addSubview(bellButton)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            greetingLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            greetingLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),

            titleRow.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 2),
            titleRow.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            titleRow.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            titleRow.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),

            appIconView.leadingAnchor.constraint(equalTo: titleRow.leadingAnchor),
            appIconView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            appIconView.widthAnchor.constraint(equalToConstant: 44),
            appIconView.heightAnchor.constraint(equalToConstant: 44),

            appIconHeart.centerXAnchor.constraint(equalTo: appIconView.centerXAnchor),
            appIconHeart.centerYAnchor.constraint(equalTo: appIconView.centerYAnchor),
            appIconHeart.widthAnchor.constraint(equalToConstant: 24),
            appIconHeart.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.leadingAnchor.constraint(equalTo: appIconView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: bellCircle.leadingAnchor, constant: -8),
            titleLabel.topAnchor.constraint(equalTo: titleRow.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: titleRow.bottomAnchor),

            bellCircle.trailingAnchor.constraint(equalTo: titleRow.trailingAnchor),
            bellCircle.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            bellCircle.widthAnchor.constraint(equalToConstant: 36),
            bellCircle.heightAnchor.constraint(equalToConstant: 36),

            bellButton.centerXAnchor.constraint(equalTo: bellCircle.centerXAnchor),
            bellButton.centerYAnchor.constraint(equalTo: bellCircle.centerYAnchor),
        ])
    }

    // MARK: - Pills

    private func setupPills() {
        pillsScroll.translatesAutoresizingMaskIntoConstraints = false
        pillsScroll.showsHorizontalScrollIndicator = false
        pillsScroll.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        view.addSubview(pillsScroll)

        pillsStack.translatesAutoresizingMaskIntoConstraints = false
        pillsStack.axis = .horizontal
        pillsStack.spacing = 8
        pillsScroll.addSubview(pillsStack)

        for (index, cat) in viewModel.categories.enumerated() {
            let pill = UIButton(type: .system)
            pill.tag = index
            pill.setTitle(cat, for: .normal)
            pill.titleLabel?.font = .appBody(15)
            pill.contentEdgeInsets = UIEdgeInsets(top: 8, left: 18, bottom: 8, right: 18)
            pill.layer.cornerRadius = 20
            pill.addTarget(self, action: #selector(pillTapped(_:)), for: .touchUpInside)
            pillsStack.addArrangedSubview(pill)
        }

        let header = view.viewWithTag(100)!
        NSLayoutConstraint.activate([
            pillsScroll.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 16),
            pillsScroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pillsScroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pillsScroll.heightAnchor.constraint(equalToConstant: 44),
            pillsStack.topAnchor.constraint(equalTo: pillsScroll.topAnchor),
            pillsStack.leadingAnchor.constraint(equalTo: pillsScroll.leadingAnchor),
            pillsStack.trailingAnchor.constraint(equalTo: pillsScroll.trailingAnchor),
            pillsStack.bottomAnchor.constraint(equalTo: pillsScroll.bottomAnchor),
            pillsStack.heightAnchor.constraint(equalTo: pillsScroll.heightAnchor),
        ])
        updatePills()
    }

    private func updatePills() {
        for (index, cat) in viewModel.categories.enumerated() {
            guard let pill = pillsStack.arrangedSubviews[safe: index] as? UIButton else { continue }
            let isActive = cat == viewModel.currentCategory
            pill.backgroundColor = isActive ? theme.accent : theme.cardBackground
            pill.setTitleColor(isActive ? .white : theme.label, for: .normal)
            pill.titleLabel?.font = .appBody(15, weight: isActive ? .semibold : .regular)
            pill.layer.shadowColor = isActive ? theme.accent.cgColor : nil
            pill.layer.shadowOpacity = isActive ? 0.35 : 0
            pill.layer.shadowOffset = CGSize(width: 0, height: 4)
            pill.layer.shadowRadius = 16
            // shadowPath считаем по фактическим bounds (нужен layout pass до этого)
            if !pill.bounds.isEmpty {
                pill.layer.shadowPath = UIBezierPath(roundedRect: pill.bounds, cornerRadius: 20).cgPath
            }
        }
    }

    // MARK: - Dots

    private func setupDots() {
        dotsStack.translatesAutoresizingMaskIntoConstraints = false
        dotsStack.axis = .horizontal
        dotsStack.spacing = 6
        dotsStack.alignment = .center
        view.addSubview(dotsStack)
        NSLayoutConstraint.activate([
            dotsStack.topAnchor.constraint(equalTo: pillsScroll.bottomAnchor, constant: 14),
            dotsStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dotsStack.heightAnchor.constraint(equalToConstant: 6),
        ])
    }

    private func updateDots() {
        dotsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for i in 0..<viewModel.questions.count {
            let dot = UIView()
            dot.translatesAutoresizingMaskIntoConstraints = false
            let isActive = i == viewModel.currentIndex
            dot.backgroundColor = isActive ? theme.accent : theme.fill
            dot.layer.cornerRadius = 3
            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: isActive ? 20 : 6),
                dot.heightAnchor.constraint(equalToConstant: 6),
            ])
            dotsStack.addArrangedSubview(dot)
        }
    }

    // MARK: - Collection View

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = cardSpacing
        layout.itemSize = CGSize(width: cardWidth, height: 400)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = .fast
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 28, bottom: 0, right: 28)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(QuestionCardCell.self, forCellWithReuseIdentifier: "QuestionCard")
        collectionView.clipsToBounds = false
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: pillsScroll.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 420),
        ])
    }

    // MARK: - Nav

    private func setupNavButtons() {
        prevCircle.translatesAutoresizingMaskIntoConstraints = false
        prevCircle.layer.cornerRadius = 24
        nextCircle.translatesAutoresizingMaskIntoConstraints = false
        nextCircle.layer.cornerRadius = 24
        prevButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryLabel.font = .appBody(13)
        categoryLabel.textAlignment = .center

        prevButton.setImage(UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)), for: .normal)
        nextButton.setImage(UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)), for: .normal)
        prevButton.addTarget(self, action: #selector(prevTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)

        view.addSubview(prevCircle)
        view.addSubview(nextCircle)
        view.addSubview(prevButton)
        view.addSubview(nextButton)
        view.addSubview(categoryLabel)

        NSLayoutConstraint.activate([
            prevCircle.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 14),
            prevCircle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            prevCircle.widthAnchor.constraint(equalToConstant: 48),
            prevCircle.heightAnchor.constraint(equalToConstant: 48),
            prevButton.centerXAnchor.constraint(equalTo: prevCircle.centerXAnchor),
            prevButton.centerYAnchor.constraint(equalTo: prevCircle.centerYAnchor),
            nextCircle.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 14),
            nextCircle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextCircle.widthAnchor.constraint(equalToConstant: 48),
            nextCircle.heightAnchor.constraint(equalToConstant: 48),
            nextButton.centerXAnchor.constraint(equalTo: nextCircle.centerXAnchor),
            nextButton.centerYAnchor.constraint(equalTo: nextCircle.centerYAnchor),
            categoryLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            categoryLabel.centerYAnchor.constraint(equalTo: prevCircle.centerYAnchor),
        ])
        updateNavButtons()
    }

    private func updateNavButtons() {
        let canPrev = viewModel.currentIndex > 0
        let canNext = viewModel.currentIndex < viewModel.questions.count - 1
        prevButton.tintColor = canPrev ? theme.label : theme.label3
        nextButton.tintColor = canNext ? theme.label : theme.label3
        prevCircle.alpha = canPrev ? 1 : 0.35
        nextCircle.alpha = canNext ? 1 : 0.35
        prevButton.isEnabled = canPrev
        nextButton.isEnabled = canNext
        categoryLabel.text = viewModel.currentCategory
        categoryLabel.textColor = theme.label3
    }

    // MARK: - Actions

    @objc private func pillTapped(_ sender: UIButton) {
        let cat = viewModel.categories[sender.tag]
        guard cat != viewModel.currentCategory else { return }
        viewModel.setCategory(cat)
        updatePills()
        updateDots()
        collectionView.reloadData()
        if !viewModel.questions.isEmpty {
            collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: false)
        }
        updateNavButtons()
    }

    @objc private func prevTapped() {
        guard viewModel.currentIndex > 0 else { return }
        scrollToCard(at: viewModel.currentIndex - 1, animated: true)
    }

    @objc private func nextTapped() {
        guard viewModel.currentIndex < viewModel.questions.count - 1 else { return }
        scrollToCard(at: viewModel.currentIndex + 1, animated: true)
    }

    private func updateBellIcon() {
        let isOn = UserSettings.shared.isNotificationsEnabled
        let name = isOn ? "bell" : "bell.slash"
        bellButton.setImage(UIImage(systemName: name, withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)), for: .normal)
    }

    @objc private func bellTapped() {
        let newState = !UserSettings.shared.isNotificationsEnabled
        UserSettings.shared.isNotificationsEnabled = newState
        updateBellIcon()
        let message = newState ? "Уведомления включены" : "Уведомления выключены"
        toastView.show(message: message, in: view)
        delegate?.questionsVCDidRequestNotificationInfo(self)
    }

    private func scrollToCard(at index: Int, animated: Bool) {
        viewModel.setCurrentIndex(index)
        collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: animated)
        UIView.animate(withDuration: 0.35) {
            self.updateNavButtons()
            self.view.layoutIfNeeded()
        }
        collectionView.reloadData()
    }

    func showToast(_ message: String) {
        toastView.show(message: message, in: view)
    }
}

// MARK: - UICollectionView

extension QuestionsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.questions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QuestionCard", for: indexPath) as! QuestionCardCell
        let q = viewModel.questions[indexPath.item]
        let isActive = indexPath.item == viewModel.currentIndex
        cell.configure(question: q,
                       index: indexPath.item,
                       total: viewModel.questions.count,
                       isActive: isActive,
                       isDone: viewModel.isDiscussed(q.id),
                       isFav: viewModel.isFavorite(q.id))

        cell.onTap = { [weak self] in
            guard let self = self else { return }
            if indexPath.item == self.viewModel.currentIndex {
                self.delegate?.questionsVC(self,
                                           didSelectQuestion: indexPath.item,
                                           inCategory: self.viewModel.currentCategory)
            } else {
                self.scrollToCard(at: indexPath.item, animated: true)
            }
        }
        cell.onHeartTap = { [weak self] _ in
            guard let self = self else { return }
            let added = self.viewModel.toggleFavorite(at: indexPath.item) ?? false
            self.toastView.show(message: added ? "Добавлено в избранное" : "Удалено из избранного", in: self.view)
            self.collectionView.reloadData()
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: cardWidth, height: 400)
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pageWidth = cardWidth + cardSpacing
        let offset = scrollView.contentOffset.x + scrollView.contentInset.left
        var targetPage = round(offset / pageWidth)
        if velocity.x > 0.3 { targetPage = ceil(offset / pageWidth) }
        else if velocity.x < -0.3 { targetPage = floor(offset / pageWidth) }
        targetPage = max(0, min(targetPage, CGFloat(viewModel.questions.count - 1)))
        targetContentOffset.pointee.x = targetPage * pageWidth - scrollView.contentInset.left

        let newIndex = Int(targetPage)
        if newIndex != viewModel.currentIndex {
            viewModel.setCurrentIndex(newIndex)
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3) {
                    self.updateNavButtons()
                }
                self.collectionView.reloadData()
            }
        }
    }
}

// MARK: - QuestionCardCell

class QuestionCardCell: UICollectionViewCell {

    private let numberLabel = UILabel()
    private let questionLabel = UILabel()
    private let statusBadge = UILabel()
    private let heartButton = UIButton(type: .system)
    private let shineView = UIView()

    var onTap: (() -> Void)?
    var onHeartTap: ((Int) -> Void)?
    private var questionID: Int = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        contentView.layer.cornerRadius = 28
        contentView.layer.cornerCurve = .continuous
        contentView.clipsToBounds = true
        layer.cornerRadius = 28
        layer.cornerCurve = .continuous
        layer.masksToBounds = false

        [shineView, numberLabel, questionLabel, statusBadge, heartButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        shineView.isUserInteractionEnabled = false
        numberLabel.font = .appBody(11, weight: .semibold)
        questionLabel.numberOfLines = 0
        statusBadge.font = .appBody(12, weight: .medium)
        statusBadge.layer.cornerRadius = 10
        statusBadge.clipsToBounds = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        contentView.addGestureRecognizer(tap)
        heartButton.addTarget(self, action: #selector(heartTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            shineView.topAnchor.constraint(equalTo: contentView.topAnchor),
            shineView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            shineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            shineView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.5),
            numberLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 28),
            numberLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 26),
            numberLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -26),
            questionLabel.topAnchor.constraint(equalTo: numberLabel.bottomAnchor, constant: 16),
            questionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 26),
            questionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -26),
            statusBadge.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 26),
            statusBadge.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -28),
            statusBadge.heightAnchor.constraint(equalToConstant: 26),
            heartButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -26),
            heartButton.centerYAnchor.constraint(equalTo: statusBadge.centerYAnchor),
            heartButton.widthAnchor.constraint(equalToConstant: 28),
            heartButton.heightAnchor.constraint(equalToConstant: 28),
            questionLabel.bottomAnchor.constraint(lessThanOrEqualTo: statusBadge.topAnchor, constant: -16),
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // КРИТИЧНО: shadowRadius=60 без shadowPath заставляет iOS растрировать
        // ячейку на CPU при каждом layout → видимый фриз при scroll/reload.
        if !bounds.isEmpty {
            layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 28).cgPath
        }
    }

    func configure(question: Question, index: Int, total: Int, isActive: Bool, isDone: Bool, isFav: Bool) {
        questionID = question.id
        let theme = Theme.shared

        let numStr = String(format: "%02d", index + 1)
        let numText = NSMutableAttributedString(string: "ВОПРОС \(numStr) / \(total)")
        numText.addAttribute(.kern, value: 1.0, range: NSRange(location: 0, length: numText.length))
        numberLabel.attributedText = numText
        questionLabel.text = question.question
        statusBadge.text = "  \(isDone ? "✓ Обсуждён" : "Не обсуждён")  "

        if isActive {
            contentView.backgroundColor = theme.accent
            layer.borderWidth = 1
            layer.borderColor = UIColor.white.withAlphaComponent(0.45).cgColor
            layer.shadowColor = theme.accent.cgColor
            layer.shadowOpacity = 0.45
            layer.shadowOffset = CGSize(width: 0, height: 24)
            layer.shadowRadius = 60
            numberLabel.textColor = UIColor.white.withAlphaComponent(0.55)
            questionLabel.font = .appBody(22, weight: .semibold)
            questionLabel.textColor = .white
            statusBadge.backgroundColor = UIColor.white.withAlphaComponent(0.20)
            statusBadge.textColor = .white
            heartButton.setImage(UIImage(systemName: isFav ? "heart.fill" : "heart")?.withTintColor(isFav ? .white : UIColor.white.withAlphaComponent(0.45), renderingMode: .alwaysOriginal), for: .normal)
            transform = .identity
            alpha = 1.0

            shineView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
            let gradient = CAGradientLayer()
            gradient.colors = [UIColor.white.withAlphaComponent(0.18).cgColor, UIColor.clear.cgColor]
            gradient.frame = CGRect(x: 0, y: 0, width: 400, height: 200)
            shineView.layer.addSublayer(gradient)
        } else {
            contentView.backgroundColor = theme.cardBackground
            layer.borderWidth = 1
            layer.borderColor = UIColor.white.withAlphaComponent(0.65).cgColor
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOpacity = 0.08
            layer.shadowOffset = CGSize(width: 0, height: 8)
            layer.shadowRadius = 24
            numberLabel.textColor = theme.label3
            questionLabel.font = .appBody(17)
            questionLabel.textColor = theme.label
            statusBadge.backgroundColor = isDone ? theme.accent.withAlphaComponent(0.12) : theme.fill
            statusBadge.textColor = isDone ? theme.accent : theme.label3
            heartButton.setImage(UIImage(systemName: isFav ? "heart.fill" : "heart")?.withTintColor(isFav ? theme.accent : theme.label3, renderingMode: .alwaysOriginal), for: .normal)
            transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
            alpha = 0.55
            shineView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        }
    }

    @objc private func didTap() {
        UIView.animate(withDuration: 0.12, delay: 0, options: .curveEaseIn) {
            self.transform = self.transform.scaledBy(x: 0.96, y: 0.96)
        } completion: { _ in
            self.onTap?()
        }
    }
    @objc private func heartTapped() { onHeartTap?(questionID) }
}

// MARK: - Safe subscript

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
