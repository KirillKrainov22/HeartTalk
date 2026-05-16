import UIKit

class SplashViewController: UIViewController {

    var onStart: (() -> Void)?

    private let iconContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 28
        v.backgroundColor = Theme.shared.accent
        v.layer.shadowColor = Theme.shared.accent.cgColor
        v.layer.shadowOpacity = 0.45
        v.layer.shadowOffset = CGSize(width: 0, height: 24)
        v.layer.shadowRadius = 56
        return v
    }()

    private let heartIcon: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(systemName: "heart.fill")?.withRenderingMode(.alwaysTemplate)
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: 42, weight: .bold)
        l.textColor = Theme.shared.label
        l.textAlignment = .center
        let attr = NSMutableAttributedString(string: "HeartTalk")
        attr.addAttribute(.kern, value: -1.2, range: NSRange(location: 0, length: 9))
        l.attributedText = attr
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Вопросы, которые сближают двух людей"
        l.font = .systemFont(ofSize: 17)
        l.textColor = Theme.shared.label2
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()

    private let startButton = PrimaryButton(title: "Начать")

    private let blob1: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 140
        v.alpha = 0.45
        return v
    }()

    private let blob2: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 100
        v.alpha = 0.40
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.shared.background
        setupBlobs()
        setupUI()
        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateIn()
    }

    private func setupBlobs() {
        blob1.backgroundColor = Theme.shared.accent
        blob2.backgroundColor = Theme.shared.accentDark
        view.addSubview(blob1)
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
        let centerStack = UIStackView(arrangedSubviews: [iconContainer, titleLabel, subtitleLabel])
        centerStack.axis = .vertical
        centerStack.alignment = .center
        centerStack.spacing = 0
        centerStack.translatesAutoresizingMaskIntoConstraints = false
        centerStack.setCustomSpacing(30, after: iconContainer)
        centerStack.setCustomSpacing(14, after: titleLabel)

        iconContainer.addSubview(heartIcon)
        view.addSubview(centerStack)
        view.addSubview(startButton)

        NSLayoutConstraint.activate([
            iconContainer.widthAnchor.constraint(equalToConstant: 100),
            iconContainer.heightAnchor.constraint(equalToConstant: 100),
            heartIcon.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            heartIcon.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            heartIcon.widthAnchor.constraint(equalToConstant: 56),
            heartIcon.heightAnchor.constraint(equalToConstant: 56),
            centerStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerStack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            subtitleLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 260),
            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
    }

    private func animateIn() {
        let content = view.subviews
        content.forEach { $0.alpha = 0; $0.transform = CGAffineTransform(translationX: 40, y: 0) }
        UIView.animate(withDuration: 0.4, delay: 0.1, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.5) {
            content.forEach { $0.alpha = 1; $0.transform = .identity }
        }
    }

    @objc private func startTapped() {
        onStart?()
    }
}
