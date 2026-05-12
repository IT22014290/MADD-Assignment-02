import SwiftUI

// MARK: - Nursery Theme

enum NurseryTheme {
    static let primary   = Color(red: 0.176, green: 0.529, blue: 0.671)
    static let secondary = Color(red: 0.204, green: 0.286, blue: 0.369)
    static let accent    = Color(red: 1.000, green: 0.596, blue: 0.196)
    static let teal      = Color(red: 0.000, green: 0.749, blue: 0.671)
    static let purple    = Color(red: 0.482, green: 0.408, blue: 0.933)
    static let orange    = Color(red: 1.000, green: 0.549, blue: 0.259)
    static let pink      = Color(red: 0.914, green: 0.118, blue: 0.549)
    static let red       = Color(red: 0.898, green: 0.224, blue: 0.208)
    static let indigo    = Color(red: 0.247, green: 0.318, blue: 0.710)
    static let green     = Color(red: 0.298, green: 0.686, blue: 0.314)
    static let background     = Color(red: 0.945, green: 0.953, blue: 0.961)
    static let cardBg         = Color.white
    static let navyBg         = Color(red: 0.110, green: 0.176, blue: 0.247)
    static let textPrimary    = Color(red: 0.133, green: 0.133, blue: 0.133)
    static let textSecondary  = Color(red: 0.400, green: 0.400, blue: 0.420)

    static func gradient(_ color: Color) -> LinearGradient {
        LinearGradient(colors: [color, color.opacity(0.75)],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    static let brandGradient = LinearGradient(
        colors: [primary, teal],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - View Modifiers

struct CardModifier: ViewModifier {
    var padding: CGFloat = 16
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(NurseryTheme.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    var color: Color = NurseryTheme.primary
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(color.opacity(configuration.isPressed ? 0.75 : 1.0))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    var color: Color = NurseryTheme.primary
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(color.opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(color.opacity(0.3), lineWidth: 1))
    }
}

extension View {
    func cardStyle(padding: CGFloat = 16) -> some View {
        modifier(CardModifier(padding: padding))
    }

    func sectionHeaderStyle() -> some View {
        self
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(NurseryTheme.textSecondary)
            .textCase(.uppercase)
            .tracking(0.8)
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255,
                  opacity: Double(a)/255)
    }
}

// MARK: - Date Helpers

extension Date {
    var shortTimeString: String {
        let f = DateFormatter(); f.timeStyle = .short; return f.string(from: self)
    }
    var shortDateString: String {
        let f = DateFormatter(); f.dateStyle = .short; return f.string(from: self)
    }
    var mediumDateString: String {
        let f = DateFormatter(); f.dateStyle = .medium; return f.string(from: self)
    }
    var dayMonthString: String {
        let f = DateFormatter(); f.dateFormat = "d MMM"; return f.string(from: self)
    }
    var weekdayString: String {
        let f = DateFormatter(); f.dateFormat = "EEE"; return f.string(from: self)
    }
    var timeAgoString: String {
        let seconds = Int(Date().timeIntervalSince(self))
        if seconds < 60 { return "Just now" }
        if seconds < 3600 { return "\(seconds / 60)m ago" }
        if seconds < 86400 { return "\(seconds / 3600)h ago" }
        return mediumDateString
    }
    var isToday: Bool { Calendar.current.isDateInToday(self) }
}
