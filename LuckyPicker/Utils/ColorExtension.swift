import SwiftUI

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
    
    func toHex() -> String {
        guard let components = UIColor(self).cgColor.components else {
            return "#000000"
        }
        
        let r = components[0]
        let g = components[1]
        let b = components[2]
        
        return String(
            format: "#%02X%02X%02X",
            Int(r * 255),
            Int(g * 255),
            Int(b * 255)
        )
    }
    
    static var randomBright: Color {
        let availableColors = [
            Color(hex: "#FF69B4"), // 粉红色
            Color(hex: "#6A5ACD"), // 蓝紫色
            Color(hex: "#9370DB"), // 中等紫色
            Color(hex: "#4169E1"), // 皇家蓝
            Color(hex: "#FF6347")  // 番茄色
        ]
        return availableColors.randomElement() ?? .blue
    }
    
    static var randomHexString: String {
        let availableColors = [
            "#FF69B4", // 粉红色
            "#6A5ACD", // 蓝紫色
            "#9370DB", // 中等紫色
            "#4169E1", // 皇家蓝
            "#FF6347"  // 番茄色
        ]
        return availableColors.randomElement() ?? "#4169E1"
    }
} 