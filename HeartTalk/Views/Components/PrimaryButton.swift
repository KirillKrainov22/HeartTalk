import UIKit

class PrimaryButton: UIButton {

    private var isDisabledState = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    convenience init(title: String) {
        self.init(frame: .zero)
        setTitle(title, for: .normal)
    }

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 56).isActive = true
        layer.cornerRadius = 18
        titleLabel?.font = .appBody(17, weight: .semibold)
        updateAppearance()

        addTarget(self, action: #selector(touchDown), for: .touchDown)
        addTarget(self, action: #selector(touchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    func updateAppearance() {
        let theme = Theme.shared
        if isDisabledState {
            backgroundColor = UIColor.black.withAlphaComponent(0.10)
            setTitleColor(theme.label3, for: .normal)
            layer.shadowOpacity = 0
        } else {
            backgroundColor = theme.accent
            setTitleColor(.white, for: .normal)
            layer.shadowColor = theme.accent.cgColor
            layer.shadowOpacity = 0.38
            layer.shadowOffset = CGSize(width: 0, height: 10)
            layer.shadowRadius = 28
        }
    }

    func setDisabledState(_ disabled: Bool) {
        isDisabledState = disabled
        isUserInteractionEnabled = !disabled
        updateAppearance()
    }

    @objc private func touchDown() {
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
        }
    }

    @objc private func touchUp() {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
            self.transform = .identity
        }
    }
}
