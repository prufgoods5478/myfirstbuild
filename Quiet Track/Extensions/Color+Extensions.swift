import SwiftUI

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let length = hexSanitized.count
        
        switch length {
        case 6:
            self.init(
                red: Double((rgb & 0xFF0000) >> 16) / 255.0,
                green: Double((rgb & 0x00FF00) >> 8) / 255.0,
                blue: Double(rgb & 0x0000FF) / 255.0
            )
        case 8:
            self.init(
                red: Double((rgb & 0xFF000000) >> 24) / 255.0,
                green: Double((rgb & 0x00FF0000) >> 16) / 255.0,
                blue: Double((rgb & 0x0000FF00) >> 8) / 255.0,
                opacity: Double(rgb & 0x000000FF) / 255.0
            )
        default:
            return nil
        }
    }
    
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components else { return nil }
        
        let r = components[0]
        let g = components.count > 1 ? components[1] : r
        let b = components.count > 2 ? components[2] : r
        
        return String(format: "#%02X%02X%02X",
                      Int(r * 255),
                      Int(g * 255),
                      Int(b * 255))
    }
}

struct AppTheme {
    static let background = Color(hex: "#FAFAFA") ?? .white
    static let cardBackground = Color.white
    static let primaryText = Color(hex: "#1A1A2E") ?? .black
    static let secondaryText = Color(hex: "#6B7280") ?? .gray
    static let accent = Color(hex: "#4ECDC4") ?? .teal
    static let accentSecondary = Color(hex: "#FF6B6B") ?? .red
    
    static let shadowColor = Color.black.opacity(0.08)
    static let shadowRadius: CGFloat = 12
    static let shadowY: CGFloat = 4
    
    static let cornerRadius: CGFloat = 20
    static let cardPadding: CGFloat = 16
    static let spacing: CGFloat = 12
    
    static let headerGradient = LinearGradient(
        colors: [
            Color(hex: "#4ECDC4") ?? .teal,
            Color(hex: "#44A08D") ?? .green
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let warmGradient = LinearGradient(
        colors: [
            Color(hex: "#FF6B6B") ?? .red,
            Color(hex: "#FFA07A") ?? .orange
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

extension Color {
    static var adaptiveBackground: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1)
                : UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
        })
    }
    
    static var adaptiveCardBackground: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.17, green: 0.17, blue: 0.18, alpha: 1)
                : UIColor.white
        })
    }
    
    static var adaptivePrimaryText: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor.white
                : UIColor(red: 0.1, green: 0.1, blue: 0.18, alpha: 1)
        })
    }
    
    static var adaptiveSecondaryText: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.7, green: 0.7, blue: 0.75, alpha: 1)
                : UIColor(red: 0.42, green: 0.45, blue: 0.5, alpha: 1)
        })
    }
}
