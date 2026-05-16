import UIKit

protocol QuestionDetailDelegate: AnyObject {
    func detailDidGoBack()
    func detailDidToggleFavorite()
    func detailDidMarkDone()
}

class QuestionDetailViewController: UIViewController {

    weak var delegate: QuestionDetailDelegate?
    private let viewModel: QuestionDetailViewModel
    private let theme = Theme.shared
    private let toastView = ToastView()

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let backButton = UIButton(type: .system)
    private let backCircle = UIView()
    private let catPill = UIView()
    private let catLabel = UILabel()
    private let favButton = UIButton(type: .system)
    private let favCircle = UIView()

    private let mainCard = GlassView(cornerRadius: 20, opacity: 0.68)
    private let numberLabel = UILabel()
    private let questionLabel = UILabel()
    private let hintLabel = UILabel()
    private let doneButton = UIButton(type: .system)

    private let noteCard = GlassView(cornerRadius: 20, opacity: 0.68)
    private let noteTitle = UILabel()
    private let noteTextView = UITextView()
    private let noteCounter = UILabel()

    private let relatedTitle = UILabel()
    private let relatedScroll = UIScrollView()
    private let relatedStack = UIStackView()

    init(viewModel: QuestionDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.viewModel = QuestionDetailViewModel(category: "Психология", questionIndex: 0)
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.shared.background
        setupNav()
        setupScrollContent()
        populateData()
    }

    private func setupNav() {
        let navBar = UIView()
        navBar.translatesAutoresizingMaskIntoConstraints = false
        navBar.tag = 200
        view.addSubview(navBar)

        backCircle.translatesAutoresizingMaskIntoConstraints = false
        backCircle.layer.cornerRadius = 18
        backCircle.layer.cornerCurve = .continuous
        backCircle.clipsToBounds = true
        backCircle.backgroundColor = Theme.shared.fill
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)), for: .normal)
        backButton.tintColor = theme.accent
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        catPill.translatesAutoresizingMaskIntoConstraints = false
        catPill.backgroundColor = Theme.shared.accent
        catPill.layer.cornerRadius = 16
        catPill.layer.cornerCurve = .continuous
        catPill.clipsToBounds = true
        catLabel.translatesAutoresizingMaskIntoConstraints = false
        catLabel.font = .appBody(13, weight: .semibold)
        catLabel.textColor = .white
        catLabel.text = viewModel.category.uppercased()

        favCircle.translatesAutoresizingMaskIntoConstraints = false
        favCircle.layer.cornerRadius = 18
        favCircle.layer.cornerCurve = .continuous
        favCircle.clipsToBounds = true
        favCircle.backgroundColor = Theme.shared.fill
        favButton.translatesAutoresizingMaskIntoConstraints = false
        favButton.addTarget(self, action: #selector(favTapped), for: .touchUpInside)

        navBar.addSubview(backCircle)
        navBar.addSubview(backButton)
        navBar.addSubview(catPill)
        catPill.addSubview(catLabel)
        navBar.addSubview(favCircle)
        navBar.addSubview(favButton)

        NSLayoutConstraint.activate([
            navBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            navBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            navBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            navBar.heightAnchor.constraint(equalToConstant: 36),

            backCircle.leadingAnchor.constraint(equalTo: navBar.leadingAnchor),
            backCircle.centerYAnchor.constraint(equalTo: navBar.centerYAnchor),
            backCircle.widthAnchor.constraint(equalToConstant: 36),
            backCircle.heightAnchor.constraint(equalToConstant: 36),
            backButton.centerXAnchor.constraint(equalTo: backCircle.centerXAnchor),
            backButton.centerYAnchor.constraint(equalTo: backCircle.centerYAnchor),

            catPill.centerXAnchor.constraint(equalTo: navBar.centerXAnchor),
            catPill.centerYAnchor.constraint(equalTo: navBar.centerYAnchor),
            catPill.heightAnchor.constraint(equalToConstant: 32),
            catLabel.leadingAnchor.constraint(equalTo: catPill.leadingAnchor, constant: 16),
            catLabel.trailingAnchor.constraint(equalTo: catPill.trailingAnchor, constant: -16),
            catLabel.centerYAnchor.constraint(equalTo: catPill.centerYAnchor),

            favCircle.trailingAnchor.constraint(equalTo: navBar.trailingAnchor),
            favCircle.centerYAnchor.constraint(equalTo: navBar.centerYAnchor),
            favCircle.widthAnchor.constraint(equalToConstant: 36),
            favCircle.heightAnchor.constraint(equalToConstant: 36),
            favButton.centerXAnchor.constraint(equalTo: favCircle.centerXAnchor),
            favButton.centerYAnchor.constraint(equalTo: favCircle.centerYAnchor),
        ])
    }

    private func setupScrollContent() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .interactive
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 16

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        let navBar = view.viewWithTag(200)!

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: navBar.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -40),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
        ])

        mainCard.translatesAutoresizingMaskIntoConstraints = false
        [numberLabel, questionLabel, hintLabel].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        numberLabel.font = .appBody(13, weight: .medium)
        numberLabel.textColor = theme.label3
        questionLabel.font = .appBody(26, weight: .semibold)
        questionLabel.textColor = theme.label
        questionLabel.numberOfLines = 0
        hintLabel.font = .appBody(13)
        hintLabel.textColor = theme.label3
        hintLabel.numberOfLines = 0
        hintLabel.text = "Обсудите этот вопрос устно — приложение не заменяет живой разговор"

        mainCard.addSubview(numberLabel)
        mainCard.addSubview(questionLabel)
        mainCard.addSubview(hintLabel)

        NSLayoutConstraint.activate([
            numberLabel.topAnchor.constraint(equalTo: mainCard.topAnchor, constant: 28),
            numberLabel.leadingAnchor.constraint(equalTo: mainCard.leadingAnchor, constant: 24),
            numberLabel.trailingAnchor.constraint(equalTo: mainCard.trailingAnchor, constant: -24),
            questionLabel.topAnchor.constraint(equalTo: numberLabel.bottomAnchor, constant: 16),
            questionLabel.leadingAnchor.constraint(equalTo: mainCard.leadingAnchor, constant: 24),
            questionLabel.trailingAnchor.constraint(equalTo: mainCard.trailingAnchor, constant: -24),
            hintLabel.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 24),
            hintLabel.leadingAnchor.constraint(equalTo: mainCard.leadingAnchor, constant: 24),
            hintLabel.trailingAnchor.constraint(equalTo: mainCard.trailingAnchor, constant: -24),
            hintLabel.bottomAnchor.constraint(equalTo: mainCard.bottomAnchor, constant: -28),
            mainCard.heightAnchor.constraint(greaterThanOrEqualToConstant: 280),
        ])
        contentStack.addArrangedSubview(mainCard)

        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.layer.cornerRadius = 18
        doneButton.titleLabel?.font = .appBody(17, weight: .semibold)
        doneButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        contentStack.addArrangedSubview(doneButton)

        noteCard.translatesAutoresizingMaskIntoConstraints = false
        [noteTitle, noteTextView, noteCounter].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        noteTitle.text = "ЛИЧНАЯ ЗАМЕТКА"
        noteTitle.font = .appBody(13, weight: .semibold)
        noteTitle.textColor = theme.label3
        noteTextView.font = .appBody(15)
        noteTextView.textColor = theme.label
        noteTextView.backgroundColor = .clear
        noteTextView.delegate = self
        noteTextView.isScrollEnabled = false
        noteCounter.font = .appBody(12)
        noteCounter.textColor = theme.label3
        noteCounter.textAlignment = .right

        noteCard.addSubview(noteTitle)
        noteCard.addSubview(noteTextView)
        noteCard.addSubview(noteCounter)
        NSLayoutConstraint.activate([
            noteTitle.topAnchor.constraint(equalTo: noteCard.topAnchor, constant: 18),
            noteTitle.leadingAnchor.constraint(equalTo: noteCard.leadingAnchor, constant: 20),
            noteTextView.topAnchor.constraint(equalTo: noteTitle.bottomAnchor, constant: 10),
            noteTextView.leadingAnchor.constraint(equalTo: noteCard.leadingAnchor, constant: 16),
            noteTextView.trailingAnchor.constraint(equalTo: noteCard.trailingAnchor, constant: -16),
            noteTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60),
            noteCounter.topAnchor.constraint(equalTo: noteTextView.bottomAnchor, constant: 6),
            noteCounter.trailingAnchor.constraint(equalTo: noteCard.trailingAnchor, constant: -20),
            noteCounter.bottomAnchor.constraint(equalTo: noteCard.bottomAnchor, constant: -18),
        ])
        contentStack.addArrangedSubview(noteCard)

        relatedTitle.translatesAutoresizingMaskIntoConstraints = false
        relatedTitle.text = "Похожие"
        relatedTitle.font = .appBody(22, weight: .bold)
        relatedTitle.textColor = theme.label
        contentStack.addArrangedSubview(relatedTitle)

        relatedScroll.translatesAutoresizingMaskIntoConstraints = false
        relatedScroll.showsHorizontalScrollIndicator = false
        relatedStack.translatesAutoresizingMaskIntoConstraints = false
        relatedStack.axis = .horizontal
        relatedStack.spacing = 14
        relatedScroll.addSubview(relatedStack)
        contentStack.addArrangedSubview(relatedScroll)

        NSLayoutConstraint.activate([
            relatedScroll.heightAnchor.constraint(equalToConstant: 240),
            relatedStack.topAnchor.constraint(equalTo: relatedScroll.topAnchor),
            relatedStack.leadingAnchor.constraint(equalTo: relatedScroll.leadingAnchor),
            relatedStack.trailingAnchor.constraint(equalTo: relatedScroll.trailingAnchor),
            relatedStack.bottomAnchor.constraint(equalTo: relatedScroll.bottomAnchor),
            relatedStack.heightAnchor.constraint(equalTo: relatedScroll.heightAnchor),
        ])
    }

    private func populateData() {
        guard let q = viewModel.question else { return }
        let numStr = String(format: "%02d", viewModel.questionIndex + 1)
        numberLabel.text = "ВОПРОС \(numStr)"
        questionLabel.text = q.question
        updateFavButton()
        updateDoneButton()

        let noteText = viewModel.noteText
        noteTextView.text = noteText
        noteCounter.text = "\(noteText.count)/100"
        buildRelatedCards()
    }

    private func updateFavButton() {
        let isFav = viewModel.isFavorite
        favButton.setImage(UIImage(systemName: isFav ? "heart.fill" : "heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)), for: .normal)
        favButton.tintColor = isFav ? theme.accent : theme.label3
    }

    private func updateDoneButton() {
        let isDone = viewModel.isDiscussed
        if isDone {
            doneButton.backgroundColor = UIColor(hex: "#27AE60")
            doneButton.setTitle("  Уже обсуждено", for: .normal)
            doneButton.setTitleColor(.white, for: .normal)
            doneButton.setImage(UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold))?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
            doneButton.layer.shadowColor = UIColor(hex: "#27AE60").cgColor
        } else {
            doneButton.backgroundColor = theme.accent
            doneButton.setTitle("  Обсуждено", for: .normal)
            doneButton.setTitleColor(.white, for: .normal)
            doneButton.setImage(UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold))?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
            doneButton.layer.shadowColor = theme.accent.cgColor
        }
        doneButton.layer.shadowOpacity = 0.35
        doneButton.layer.shadowOffset = CGSize(width: 0, height: 8)
        doneButton.layer.shadowRadius = 24
    }

    private func buildRelatedCards() {
        relatedStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for related in viewModel.relatedQuestions() {
            let card = GlassView(cornerRadius: 24, opacity: 0.65)
            card.translatesAutoresizingMaskIntoConstraints = false
            card.isUserInteractionEnabled = true

            let catLbl = UILabel()
            catLbl.translatesAutoresizingMaskIntoConstraints = false
            catLbl.text = related.category.uppercased()
            catLbl.font = .appBody(11, weight: .semibold)
            catLbl.textColor = theme.label3

            let qLbl = UILabel()
            qLbl.translatesAutoresizingMaskIntoConstraints = false
            qLbl.text = related.question.question
            qLbl.font = .appBody(15)
            qLbl.textColor = theme.label
            qLbl.numberOfLines = 0

            let badge = UILabel()
            badge.translatesAutoresizingMaskIntoConstraints = false
            badge.text = related.isDiscussed ? "  ✓ Обсуждён  " : "  Не обсуждён  "
            badge.font = .appBody(12)
            badge.textColor = related.isDiscussed ? theme.accent : theme.label2
            badge.backgroundColor = related.isDiscussed ? theme.accent.withAlphaComponent(0.12) : theme.fill
            badge.layer.cornerRadius = 10
            badge.clipsToBounds = true

            card.addSubview(catLbl)
            card.addSubview(qLbl)
            card.addSubview(badge)

            NSLayoutConstraint.activate([
                card.widthAnchor.constraint(equalToConstant: 200),
                catLbl.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
                catLbl.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
                qLbl.topAnchor.constraint(equalTo: catLbl.bottomAnchor, constant: 12),
                qLbl.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
                qLbl.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
                badge.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
                badge.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20),
            ])

            let category = related.category
            let index = related.index
            let tap = UITapGestureRecognizer(target: self, action: #selector(relatedCardTapped(_:)))
            card.addGestureRecognizer(tap)
            card.accessibilityIdentifier = "\(category):\(index)"

            relatedStack.addArrangedSubview(card)
        }
    }

    @objc private func relatedCardTapped(_ sender: UITapGestureRecognizer) {
        guard let id = sender.view?.accessibilityIdentifier else { return }
        let parts = id.split(separator: ":")
        guard parts.count == 2, let index = Int(parts[1]) else { return }
        let category = String(parts[0])

        let vm = QuestionDetailViewModel(category: category, questionIndex: index)
        let vc = QuestionDetailViewController(viewModel: vm)
        vc.delegate = delegate
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func backTapped() { delegate?.detailDidGoBack() }

    @objc private func favTapped() {
        let added = viewModel.toggleFavorite()
        updateFavButton()
        toastView.show(message: added ? "Добавлено в избранное" : "Удалено из избранного", in: view)
        delegate?.detailDidToggleFavorite()
    }

    @objc private func doneTapped() {
        guard viewModel.markDiscussedIfNeeded() else { return }
        updateDoneButton()
        toastView.show(message: "Отмечено как обсуждённое!", in: view)
        delegate?.detailDidMarkDone()
    }
}

extension QuestionDetailViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let current = textView.text ?? ""
        guard let stringRange = Range(range, in: current) else { return false }
        let updated = current.replacingCharacters(in: stringRange, with: text)
        return updated.count <= 100
    }

    func textViewDidChange(_ textView: UITextView) {
        let text = textView.text ?? ""
        noteCounter.text = "\(text.count)/100"
        viewModel.saveNote(text)
    }
}
