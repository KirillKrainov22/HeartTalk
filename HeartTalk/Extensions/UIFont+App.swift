import UIKit

extension UIFont {
    static func appTitle(_ size: CGFloat) -> UIFont {
        .systemFont(ofSize: size, weight: .bold)
    }

    static func appBody(_ size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        .systemFont(ofSize: size, weight: weight)
    }

    static func appSerif(_ size: CGFloat) -> UIFont {
        if let dm = UIFont(name: "DMSerifDisplay-Regular", size: size) {
            return dm
        }
        return UIFont(name: "Georgia", size: size) ?? .systemFont(ofSize: size)
    }
}
