import Foundation

struct Option: Identifiable, Codable, Equatable {
    var id = UUID()
    var text: String
    var color: String // 存储颜色的十六进制值
    
    static func == (lhs: Option, rhs: Option) -> Bool {
        return lhs.id == rhs.id
    }
}

struct HistoryRecord: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var result: Option
    var totalOptions: Int
    var timeString: String
}

class OptionsManager: ObservableObject {
    @Published var options: [Option] = []
    @Published var history: [HistoryRecord] = []
    
    private let optionsKey = "savedOptions"
    private let historyKey = "savedHistory"
    
    init() {
        loadOptions()
        loadHistory()
    }
    
    func addOption(_ option: Option) {
        options.append(option)
        saveOptions()
        resetSelectionCounts()
    }
    
    func removeOption(at index: Int) {
        if index >= 0 && index < options.count {
            options.remove(at: index)
            saveOptions()
            resetSelectionCounts()
        }
    }
    
    func addToHistory(result: Option) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let timeString = formatter.string(from: Date())
        
        let record = HistoryRecord(
            date: Date(),
            result: result,
            totalOptions: options.count,
            timeString: timeString
        )
        
        history.append(record)
        saveHistory()
    }
    
    func clearHistory() {
        history.removeAll()
        saveHistory()
    }
    
    private func saveOptions() {
        if let encoded = try? JSONEncoder().encode(options) {
            UserDefaults.standard.set(encoded, forKey: optionsKey)
        }
    }
    
    private func loadOptions() {
        if let data = UserDefaults.standard.data(forKey: optionsKey),
           let decoded = try? JSONDecoder().decode([Option].self, from: data) {
            options = decoded
        } else {
            // 默认选项，确保每个选项使用不同的颜色
            options = [
                Option(text: "火锅", color: "#FF4136"),  // 鲜红色
                Option(text: "寿司", color: "#0074D9"),  // 鲜蓝色
                Option(text: "披萨", color: "#2ECC40"),  // 鲜绿色
                Option(text: "汉堡", color: "#FFDC00"),  // 鲜黄色
                Option(text: "炒饭", color: "#B10DC9"),  // 紫色
                Option(text: "烤肉", color: "#FF851B"),  // 橙色
                Option(text: "沙拉", color: "#01FF70"),  // 亮绿色
                Option(text: "面条", color: "#F012BE")   // 粉色
            ]
        }
    }
    
    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: historyKey)
        }
    }
    
    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: historyKey),
           let decoded = try? JSONDecoder().decode([HistoryRecord].self, from: data) {
            history = decoded
        }
    }
    
    func resetSelectionCounts() {
        UserDefaults.standard.removeObject(forKey: "optionSelectionCounts")
    }
} 