import UIKit

class GlassTextField: UIView {

    let textField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.font = .appBody(17)
        tf.backgroundColor = .clear
        tf.borderStyle = .none
        return tf
    }()

    private let glassBackground: GlassView

    var text: String {
        get { textField.text ?? "" }
        set { textField.text = newValue }
    }

    var placeholder: String? {
        didSet {
            textField.attributedPlaceholder = NSAttributedString(
                string: placeholder ?? "",
                attributes: [.foregroundColor: UIColor.black.withAlphaComponent(0.28)]
            )
        }
    }

    var onTextChanged: ((String) -> Void)?

    override init(frame: CGRect) {
        glassBackground = GlassView(cornerRadius: 18, opacity: 0.55)
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        glassBackground = GlassView(cornerRadius: 18, opacity: 0.55)
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false

        glassBackground.translatesAutoresizingMaskIntoConstraints = false
        addSubview(glassBackground)
        addSubview(textField)

        NSLayoutConstraint.activate([
            glassBackground.topAnchor.constraint(equalTo: topAnchor),
            glassBackground.leadingAnchor.constraint(equalTo: leadingAnchor),
            glassBackground.trailingAnchor.constraint(equalTo: trailingAnchor),
            glassBackground.bottomAnchor.constraint(equalTo: bottomAnchor),

            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor),
            heightAnchor.constraint(equalToConstant: 54),
        ])

        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        textField.textColor = Theme.shared.label
        textField.returnKeyType = .done
        textField.delegate = self
    }

    @objc private func textDidChange() {
        onTextChanged?(textField.text ?? "")
    }
}

extension GlassTextField: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
