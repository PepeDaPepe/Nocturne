import SwiftUI

// Colors
extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    // Base Surfaces
    let background = Color(hex: "0B0F14")
    let surface = Color(hex: "121820")
    let surfaceElevated = Color(hex: "17202C")
    
    // Accents & Signals
    let primaryCyan = Color(hex: "38BDF8")
    let secondaryBlue = Color(hex: "0EA5E9")
    let tertiaryGlow = Color(hex: "67E8F9")
    
    // Text
    let textPrimary = Color(hex: "F1F5F9")
    let textSecondary = Color(hex: "94A3B8")
    let textTertiary = Color(hex: "475569")
    
    // Borders
    let borderHairline = Color(hex: "94A3B8").opacity(0.08)
    let borderActive = Color(hex: "38BDF8").opacity(0.35)
}

// Hex Color Helper
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Spacing & Layout
struct LayoutInfo {
    static let gutterMobile: CGFloat = 16
    static let gutterTablet: CGFloat = 24
    
    static let spaceXS: CGFloat = 4
    static let spaceSM: CGFloat = 8
    static let spaceMD: CGFloat = 12
    static let spaceLG: CGFloat = 16
    static let spaceXL: CGFloat = 24
    
    static let cornerRadiusPoster: CGFloat = 6
    static let cornerRadiusButton: CGFloat = 8
    static let cornerRadiusSheet: CGFloat = 16
}

// View Modifiers
struct PosterStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .aspectRatio(2/3, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: LayoutInfo.cornerRadiusPoster, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: LayoutInfo.cornerRadiusPoster, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
            )
    }
}

extension View {
    func posterStyle() -> some View {
        modifier(PosterStyle())
    }
}
