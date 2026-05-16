import UIKit

class GlassView: UIView {

    private var cornerR: CGFloat = 20

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    convenience init(cornerRadius: CGFloat = 20, opacity: CGFloat = 0.55) {
        self.init(frame: .zero)
        cornerR = cornerRadius
        layer.cornerRadius = cornerRadius
        refreshAppearance()
    }

    private func setup() {
        layer.cornerCurve = .continuous
        layer.cornerRadius = cornerR
        refreshAppearance()
    }

    func refreshAppearance() {
        backgroundColor = .white
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.06
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 8
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // shadowPath обязателен: иначе iOS растрирует view на CPU
        // при каждом layout-проходе для построения тени → freezes.
        if !bounds.isEmpty {
            layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerR).cgPath
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        refreshAppearance()
    }
}
