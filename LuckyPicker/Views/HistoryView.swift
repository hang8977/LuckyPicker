import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var optionsManager: OptionsManager
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("历史记录")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: {
                        showingDeleteAlert = true
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .font(.system(size: 20))
                    }
                    .alert(isPresented: $showingDeleteAlert) {
                        Alert(
                            title: Text("清除历史记录"),
                            message: Text("确定要清除所有历史记录吗？此操作不可撤销。"),
                            primaryButton: .destructive(Text("清除")) {
                                optionsManager.clearHistory()
                            },
                            secondaryButton: .cancel(Text("取消"))
                        )
                    }
                }
                .padding()
                
                if optionsManager.history.isEmpty {
                    Spacer()
                    Text("暂无历史记录")
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    List {
                        // 按日期分组
                        Section(header: Text("今天")) {
                            ForEach(todayRecords) { record in
                                HistoryItemView(record: record)
                            }
                        }
                        
                        if !yesterdayRecords.isEmpty {
                            Section(header: Text("昨天")) {
                                ForEach(yesterdayRecords) { record in
                                    HistoryItemView(record: record)
                                }
                            }
                        }
                        
                        if !olderRecords.isEmpty {
                            Section(header: Text("更早")) {
                                ForEach(olderRecords) { record in
                                    HistoryItemView(record: record)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // 获取今天的记录
    private var todayRecords: [HistoryRecord] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return optionsManager.history.filter { record in
            calendar.isDate(record.date, inSameDayAs: today)
        }
    }
    
    // 获取昨天的记录
    private var yesterdayRecords: [HistoryRecord] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else {
            return []
        }
        
        return optionsManager.history.filter { record in
            calendar.isDate(record.date, inSameDayAs: yesterday)
        }
    }
    
    // 获取更早的记录
    private var olderRecords: [HistoryRecord] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today) else {
            return []
        }
        
        return optionsManager.history.filter { record in
            record.date < twoDaysAgo
        }
    }
}

struct HistoryItemView: View {
    let record: HistoryRecord
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(record.result.text)
                    .font(.headline)
                
                Text("从 \(record.totalOptions) 个选项中选择")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(record.timeString)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }
} 