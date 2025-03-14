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
            Color(hex: "#FF4136"), // 鲜红色
            Color(hex: "#0074D9"), // 鲜蓝色
            Color(hex: "#2ECC40"), // 鲜绿色
            Color(hex: "#FFDC00"), // 鲜黄色
            Color(hex: "#FF851B"), // 橙色
            Color(hex: "#B10DC9"), // 紫色
            Color(hex: "#01FF70"), // 亮绿色
            Color(hex: "#F012BE"), // 粉色
            Color(hex: "#39CCCC"), // 青色
            Color(hex: "#85144b")  // 深红色
        ]
        return availableColors.randomElement() ?? .blue
    }
    
    static var randomHexString: String {
        let availableColors = [
            "#FF4136", // 鲜红色
            "#0074D9", // 鲜蓝色
            "#2ECC40", // 鲜绿色
            "#FFDC00", // 鲜黄色
            "#FF851B", // 橙色
            "#B10DC9", // 紫色
            "#01FF70", // 亮绿色
            "#F012BE", // 粉色
            "#39CCCC", // 青色
            "#85144b"  // 深红色
        ]
        return availableColors.randomElement() ?? "#0074D9"
    }
} 