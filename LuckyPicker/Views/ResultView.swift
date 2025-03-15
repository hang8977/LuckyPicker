import SwiftUI

struct ResultView: View {
    let option: Option
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var optionsManager: OptionsManager
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("vibrationEnabled") private var vibrationEnabled = true
    
    // 添加选项选中次数统计
    @AppStorage("optionSelectionCounts") private var optionSelectionCountsData: Data = Data()
    @State private var selectionCounts: [String: Int] = [:]
    @State private var totalSelections: Int = 0
    
    var body: some View {
        VStack(spacing: 25) {
            // 移除"今天中午吃什么"标题
            
            // 结果卡片
            resultCard
                .padding(.top, 40)
            
            // 选中次数统计
            if totalSelections > 0 {
                selectionStatsView
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            Spacer()
            
            // 操作按钮
            actionButtons
            
            Spacer()
            
            Text("本次决策已保存至历史记录")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.bottom, 20)
        }
        .padding()
        .onAppear {
            // 加载选项选中次数
            loadSelectionCounts()
            
            // 更新当前选项的选中次数
            updateSelectionCount()
            
            // 播放声音
            if soundEnabled {
                playSound()
            }
            
            // 触发震动
            if vibrationEnabled {
                triggerHapticFeedback()
            }
        }
    }
    
    // 结果卡片视图
    private var resultCard: some View {
        VStack(spacing: 16) {
            Text(option.text)
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(Color(hex: option.color))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if let count = selectionCounts[option.text], count > 1 {
                Text("第\(count)次被选中")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 30)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: option.color).opacity(0.15))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(hex: option.color), lineWidth: 2)
        )
    }
    
    // 选项统计视图
    private var selectionStatsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("选择统计")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("共\(totalSelections)次")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 4)
            
            // 统计图表
            VStack(spacing: 10) {
                ForEach(selectionCounts.sorted(by: { $0.value > $1.value }), id: \.key) { key, value in
                    if value > 0 {
                        // 查找对应选项的颜色
                        let optionColor = findOptionColor(for: key)
                        ResultStatBarView(
                            optionText: key,
                            count: value,
                            percentage: Double(value) / Double(totalSelections),
                            color: key == option.text ? Color(hex: option.color) : optionColor
                        )
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(UIColor.separator), lineWidth: 0.5)
        )
    }
    
    // 查找选项的颜色
    private func findOptionColor(for text: String) -> Color {
        // 从OptionsManager中查找对应的选项
        if let matchingOption = findOptionByText(text) {
            return Color(hex: matchingOption.color)
        }
        return .gray
    }
    
    // 根据文本查找选项
    private func findOptionByText(_ text: String) -> Option? {
        // 使用OptionsManager查找选项
        return optionsManager.options.first(where: { $0.text == text })
    }
    
    // 操作按钮
    private var actionButtons: some View {
        VStack(spacing: 16) {
            Button(action: {
                // 再来一次
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("再转一次")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(width: 200)
                .background(Color(hex: option.color))
                .cornerRadius(25)
            }
            
            Button(action: {
                // 分享结果
                let activityVC = UIActivityViewController(
                    activityItems: ["我使用决策转盘选择了：\(option.text)"],
                    applicationActivities: nil
                )
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController {
                    rootViewController.present(activityVC, animated: true, completion: nil)
                }
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("分享结果")
                }
                .font(.headline)
                .foregroundColor(Color(hex: option.color))
                .padding()
                .frame(width: 200)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color(hex: option.color), lineWidth: 2)
                )
            }
        }
    }
    
    // 加载选项选中次数
    private func loadSelectionCounts() {
        if let counts = try? JSONDecoder().decode([String: Int].self, from: optionSelectionCountsData) {
            selectionCounts = counts
            totalSelections = counts.values.reduce(0, +)
        }
    }
    
    // 更新当前选项的选中次数
    private func updateSelectionCount() {
        let currentCount = selectionCounts[option.text] ?? 0
        selectionCounts[option.text] = currentCount + 1
        totalSelections += 1
        
        // 保存更新后的选中次数
        if let data = try? JSONEncoder().encode(selectionCounts) {
            optionSelectionCountsData = data
        }
    }
    
    private func playSound() {
        // 在实际应用中，这里会实现声音播放逻辑
    }
    
    private func triggerHapticFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

// 统计条形图视图
struct ResultStatBarView: View {
    let optionText: String
    let count: Int
    let percentage: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                // 选项文本
                Text(optionText)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Spacer()
                
                // 次数和百分比
                Text("\(count)次 (\(Int(percentage * 100))%)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            // 进度条
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 背景
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(UIColor.systemGray5))
                        .frame(height: 8)
                    
                    // 进度
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: max(4, geometry.size.width * CGFloat(percentage)), height: 8)
                }
            }
            .frame(height: 8)
        }
    }
} 