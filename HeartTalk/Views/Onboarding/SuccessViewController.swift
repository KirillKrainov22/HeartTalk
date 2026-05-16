import UIKit

class SuccessViewController: UIViewController {

    var userName: String = ""
    var partnerName: String = ""
    var onFinish: (() -> Void)?

    private let checkCircle: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 48
        v.backgroundColor = Theme.shared.accent
        v.layer.shadowColor = Theme.shared.accent.cgColor
        v.layer.shadowOpacity = 0.45
        v.layer.shadowOffset = CGSize(width: 0, height: 20)
        v.layer.shadowRadius = 50
        return v
    }()

    private let checkIcon: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 36, weight: .semibold)
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(systemName: "checkmark", withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: 34, weight: .bold)
        l.textColor = Theme.shared.label
        l.textAlignment = .center
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: 17)
        l.textColor = Theme.shared.label2
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()

    private let goButton = PrimaryButton(title: "Перейти в приложение")

    private let blob1 = UIView()
    private let blob2 = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.shared.background
        setupBlobs()

        let attr = NSMutableAttributedString(string: "Привет, \(userName)!")
        attr.addAttribute(.kern, value: -0.8, range: NSRange(location: 0, length: attr.length))
        titleLabel.attributedText = attr

        if !partnerName.isEmpty {
            subtitleLabel.text = "Ты и \(partnerName) готовы начать. Каждый день — новый вопрос для вашего разговора."
        } else {
            subtitleLabel.text = "Всё готово. Начни разговор который важен."
        }

        setupUI()
        goButton.addTarget(self, action: #selector(goTapped), for: .touchUpInside)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateIn()
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
        checkCircle.addSubview(checkIcon)

        let centerStack = UIStackView(arrangedSubviews: [checkCircle, titleLabel, subtitleLabel])
        centerStack.axis = .vertical
        centerStack.alignment = .center
        centerStack.spacing = 0
        centerStack.translatesAutoresizingMaskIntoConstraints = false
        centerStack.setCustomSpacing(32, after: checkCircle)
        centerStack.setCustomSpacing(12, after: titleLabel)

        view.addSubview(centerStack)
        view.addSubview(goButton)

        NSLayoutConstraint.activate([
            checkCircle.widthAnchor.constraint(equalToConstant: 96),
            checkCircle.heightAnchor.constraint(equalToConstant: 96),
            checkIcon.centerXAnchor.constraint(equalTo: checkCircle.centerXAnchor),
            checkIcon.centerYAnchor.constraint(equalTo: checkCircle.centerYAnchor),
            centerStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerStack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            subtitleLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 280),
            goButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            goButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            goButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
    }

    private func animateIn() {
        checkCircle.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        checkCircle.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0.15, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5) {
            self.checkCircle.transform = .identity
            self.checkCircle.alpha = 1
        }
    }

    @objc private func goTapped() {
        onFinish?()
    }
}
