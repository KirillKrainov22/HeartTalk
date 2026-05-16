import UIKit

class NamesViewController: UIViewController {

    var onFinish: ((String, String) -> Void)?

    private let viewModel: OnboardingViewModel

    init(viewModel: OnboardingViewModel = OnboardingViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.viewModel = OnboardingViewModel()
        super.init(coder: coder)
    }

    private let progressStack: UIStackView = {
        let bar1 = UIView()
        bar1.backgroundColor = Theme.shared.accent
        bar1.layer.cornerRadius = 1.5
        bar1.translatesAutoresizingMaskIntoConstraints = false
        bar1.heightAnchor.constraint(equalToConstant: 3).isActive = true

        let bar2 = UIView()
        bar2.backgroundColor = Theme.shared.accent
        bar2.layer.cornerRadius = 1.5
        bar2.translatesAutoresizingMaskIntoConstraints = false
        bar2.heightAnchor.constraint(equalToConstant: 3).isActive = true

        let stack = UIStackView(arrangedSubviews: [bar1, bar2])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: 32, weight: .bold)
        l.textColor = Theme.shared.label
        let attr = NSMutableAttributedString(string: "Как вас зовут?")
        attr.addAttribute(.kern, value: -0.8, range: NSRange(location: 0, length: attr.length))
        l.attributedText = attr
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Это сохранится только на вашем устройстве"
        l.font = .systemFont(ofSize: 16)
        l.textColor = Theme.shared.label2
        l.numberOfLines = 0
        return l
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.textColor = Theme.shared.label3
        l.text = "ВАШЕ ИМЯ"
        return l
    }()

    private let nameField = GlassTextField()

    private let partnerLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let partnerField = GlassTextField()
    private let continueButton = PrimaryButton(title: "Продолжить")

    private let blob1 = UIView()
    private let blob2 = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.shared.background
        setupBlobs()
        setupUI()

        nameField.placeholder = "Например, Кирилл"
        partnerField.placeholder = "Например, Аня"
        nameField.onTextChanged = { [weak self] _ in self?.updateButton() }
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        continueButton.setDisabledState(true)

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nameField.textField.becomeFirstResponder()
    }

    private func setupBlobs() {
        blob1.translatesAutoresizingMaskIntoConstraints = false
        blob1.backgroundColor = Theme.shared.accent
        blob1.layer.cornerRadius = 140
        blob1.alpha = 0.45
        view.addSubview(blob1)

        blob2.translatesAutoresizingMaskIntoConstraints = false
        blob2.backgroundColor = Theme.shared.accentDark
        blob2.layer.cornerRadius = 100
        blob2.alpha = 0.40
        view.addSubview(blob2)

        NSLayoutConstraint.activate([
            blob1.widthAnchor.constraint(equalToConstant: 280),
            blob1.heightAnchor.constraint(equalToConstant: 280),
            blob1.topAnchor.constraint(equalTo: view.topAnchor, constant: -60),
            blob1.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 60),
            blob2.widthAnchor.constraint(equalToConstant: 200),
            blob2.heightAnchor.constraint(equalToConstant: 200),
            blob2.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -120),
            blob2.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -60),
        ])
    }

    private func setupUI() {
        // Partner label
        let partnerTitle = NSMutableAttributedString(string: "ИМЯ ПАРТНЁРА  ", attributes: [
            .font: UIFont.systemFont(ofSize: 13, weight: .semibold),
            .foregroundColor: Theme.shared.label3,
        ])
        partnerTitle.append(NSAttributedString(string: "необязательно", attributes: [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: Theme.shared.label3,
        ]))
        partnerLabel.attributedText = partnerTitle

        // Info card
        let infoCard = createInfoCard()

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        view.addSubview(continueButton)

        contentView.addSubview(progressStack)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(nameField)
        contentView.addSubview(partnerLabel)
        contentView.addSubview(partnerField)
        contentView.addSubview(infoCard)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -16),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            progressStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            progressStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            progressStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -28),

            titleLabel.topAnchor.constraint(equalTo: progressStack.bottomAnchor, constant: 44),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -28),

            nameLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 36),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),

            nameField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            nameField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            nameField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -28),

            partnerLabel.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 22),
            partnerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),

            partnerField.topAnchor.constraint(equalTo: partnerLabel.bottomAnchor, constant: 8),
            partnerField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            partnerField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -28),

            infoCard.topAnchor.constraint(equalTo: partnerField.bottomAnchor, constant: 18),
            infoCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            infoCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -28),
            infoCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),

            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
    }

    private func createInfoCard() -> UIView {
        let card = GlassView(cornerRadius: 14, opacity: 0.35)
        card.translatesAutoresizingMaskIntoConstraints = false

        let icon = UIImageView(image: UIImage(systemName: "info.circle")?.withTintColor(Theme.shared.accent, renderingMode: .alwaysOriginal))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit

        let text = UILabel()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.text = "Приложение работает полностью офлайн. Данные хранятся только на этом устройстве и никуда не передаются."
        text.font = .systemFont(ofSize: 13)
        text.textColor = Theme.shared.label2
        text.numberOfLines = 0

        card.addSubview(icon)
        card.addSubview(text)

        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            icon.topAnchor.constraint(equalTo: card.topAnchor, constant: 13),
            icon.widthAnchor.constraint(equalToConstant: 16),
            icon.heightAnchor.constraint(equalToConstant: 16),
            text.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 10),
            text.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            text.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            text.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
        ])

        return card
    }

    private func updateButton() {
        continueButton.setDisabledState(!viewModel.validate(name: nameField.text))
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func continueTapped() {
        let name = nameField.text.trimmingCharacters(in: .whitespaces)
        let partner = partnerField.text.trimmingCharacters(in: .whitespaces)
        viewModel.saveNames(name: name, partner: partner)
        onFinish?(name, partner)
    }
}
