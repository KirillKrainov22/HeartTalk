import UIKit

struct ColorPalette {
    let id: String
    let label: String
    let main: UIColor
    let dark: UIColor
    let grad: UIColor

    static let all: [ColorPalette] = [
        ColorPalette(id: "terracotta", label: "Терракота", main: UIColor(hex: "#C1683A"), dark: UIColor(hex: "#9E4E22"), grad: UIColor(hex: "#D4784A")),
        ColorPalette(id: "ruby", label: "Рубин", main: UIColor(hex: "#C41230"), dark: UIColor(hex: "#9E0E24"), grad: UIColor(hex: "#E8314A")),
        ColorPalette(id: "indigo", label: "Индиго", main: UIColor(hex: "#4A5FC1"), dark: UIColor(hex: "#3348A0"), grad: UIColor(hex: "#6677D4")),
        ColorPalette(id: "plum", label: "Слива", main: UIColor(hex: "#8B3A8F"), dark: UIColor(hex: "#6E2472"), grad: UIColor(hex: "#A34FA8")),
        ColorPalette(id: "pine", label: "Сосна", main: UIColor(hex: "#2D6A4F"), dark: UIColor(hex: "#1B4D38"), grad: UIColor(hex: "#3D8A65")),
        ColorPalette(id: "midnight", label: "Полночь", main: UIColor(hex: "#1B3A6B"), dark: UIColor(hex: "#102650"), grad: UIColor(hex: "#2A5298")),
        ColorPalette(id: "rose", label: "Роза", main: UIColor(hex: "#B5446E"), dark: UIColor(hex: "#8E2E55"), grad: UIColor(hex: "#C9567F")),
        ColorPalette(id: "amber", label: "Янтарь", main: UIColor(hex: "#C47A1E"), dark: UIColor(hex: "#9E5E10"), grad: UIColor(hex: "#D9920A")),
        ColorPalette(id: "graphite", label: "Графит", main: UIColor(hex: "#4A4A4A"), dark: UIColor(hex: "#2E2E2E"), grad: UIColor(hex: "#606060")),
        ColorPalette(id: "lavender", label: "Лаванда", main: UIColor(hex: "#7B6DB0"), dark: UIColor(hex: "#5C509A"), grad: UIColor(hex: "#9180C4")),
    ]

    static func palette(for id: String) -> ColorPalette {
        all.first { $0.id == id } ?? all[0]
    }
}

final class Theme {
    static let shared = Theme()

    private(set) var palette: ColorPalette = .all[0]
    private(set) var isDark: Bool = false

    var accent: UIColor { palette.main }
    var accentDark: UIColor { palette.dark }

    var background: UIColor { isDark ? UIColor(hex: "#1C1C1E") : UIColor(hex: "#EDEAE6") }
    var label: UIColor { isDark ? UIColor.white.withAlphaComponent(0.92) : UIColor(hex: "#1A1A1A") }
    var label2: UIColor { isDark ? UIColor.white.withAlphaComponent(0.55) : UIColor.black.withAlphaComponent(0.50) }
    var label3: UIColor { isDark ? UIColor.white.withAlphaComponent(0.30) : UIColor.black.withAlphaComponent(0.30) }
    var separator: UIColor { isDark ? UIColor.white.withAlphaComponent(0.10) : UIColor.black.withAlphaComponent(0.10) }
    var fill: UIColor { isDark ? UIColor.white.withAlphaComponent(0.10) : UIColor.black.withAlphaComponent(0.07) }
    var cardBackground: UIColor { isDark ? UIColor.white.withAlphaComponent(0.10) : UIColor.white.withAlphaComponent(0.65) }

    var onChanged: (() -> Void)?

    func apply(palette: ColorPalette) {
        self.palette = palette
        UserSettings.shared.accentColorID = palette.id
        onChanged?()
    }

    func apply(dark: Bool) {
        self.isDark = dark
        UserSettings.shared.isDarkMode = dark
        onChanged?()
    }

    func loadSaved() {
        let id = UserSettings.shared.accentColorID
        palette = ColorPalette.palette(for: id)
        isDark = UserSettings.shared.isDarkMode
    }
}

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
