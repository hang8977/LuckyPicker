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
    }
    
    func removeOption(at index: Int) {
        if index >= 0 && index < options.count {
            options.remove(at: index)
            saveOptions()
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
            // 默认选项
            options = [
                Option(text: "火锅", color: "#FF69B4"),
                Option(text: "寿司", color: "#6A5ACD"),
                Option(text: "披萨", color: "#9370DB"),
                Option(text: "汉堡", color: "#FF69B4"),
                Option(text: "炒饭", color: "#6A5ACD")
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
} 