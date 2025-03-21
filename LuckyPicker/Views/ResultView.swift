import SwiftUI
import StoreKit

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
    // 添加一个映射字典，用于存储ID到文本的映射
    @State private var idToTextMap: [String: String] = [:]
    
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
            
            let optionId = option.id.uuidString
            if let count = selectionCounts[optionId], count > 1 {
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
                        // 获取选项文本
                        let optionText = idToTextMap[key] ?? "未知选项"
                        // 查找对应选项的颜色
                        let optionColor = findOptionColor(for: optionText)
                        ResultStatBarView(
                            optionText: optionText,
                            count: value,
                            percentage: Double(value) / Double(totalSelections),
                            color: optionText == option.text ? Color(hex: option.color) : optionColor
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
            
            // 分享按钮已被注释掉
            /* 
            // 更新分享按钮
            Button(action: {
                // 生成分享图片
                let shareImage = generateShareImage()
                
                // 准备分享内容
                let appName = "决策转盘"
                let shareText = "我使用「\(appName)」选择了：\(option.text) 🎯\n\n试试看你的选择吧！#决策转盘#"
                
                // 创建分享项
                let activityItems: [Any] = [shareText, shareImage]
                
                // 配置分享控制器
                let activityVC = UIActivityViewController(
                    activityItems: activityItems,
                    applicationActivities: nil
                )
                
                // 设置排除的活动类型
                activityVC.excludedActivityTypes = [
                    .assignToContact,
                    .addToReadingList,
                    .openInIBooks
                ]
                
                // 分享完成后的回调
                activityVC.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
                    if completed {
                        // 记录分享事件
                        logShareEvent(platform: activityType?.rawValue ?? "unknown")
                        
                        // 提示用户评分
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            promptForReview()
                        }
                    }
                }
                
                // 在iPad上设置弹出位置
                if let popoverController = activityVC.popoverPresentationController {
                    popoverController.sourceView = UIApplication.shared.windows.first
                    popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
                    popoverController.permittedArrowDirections = []
                }
                
                // 显示分享控制器
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController {
                    rootViewController.present(activityVC, animated: true, completion: nil)
                }
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up.fill") // 使用填充样式图标
                    Text("分享结果")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(width: 200)
                .background(Color(hex: option.color))
                .cornerRadius(25)
                .shadow(color: Color(hex: option.color).opacity(0.3), radius: 5, x: 0, y: 2)
            }
            */
        }
    }
    
    // 生成分享图片
    private func generateShareImage() -> UIImage {
        // 创建要分享的视图
        let shareView = VStack(spacing: 20) {
            // 应用标题
            Text("决策转盘")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.gray)
            
            // 结果卡片
            VStack(spacing: 16) {
                Text("我的选择是")
                    .font(.system(size: 20))
                    .foregroundColor(.gray)
                
                Text(option.text)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(Color(hex: option.color))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                let optionId = option.id.uuidString
                if let count = selectionCounts[optionId], count > 1 {
                    Text("第\(count)次被选中")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 30)
            .padding(.horizontal, 20)
            .frame(width: 300)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: option.color).opacity(0.15))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(hex: option.color), lineWidth: 2)
            )
            
            // 应用标语
            Text("扫码下载「决策转盘」App")
                .font(.system(size: 16))
                .foregroundColor(.gray)
            
            // 这里可以添加二维码图片
            // Image("AppQRCode")
            //    .resizable()
            //    .frame(width: 100, height: 100)
        }
        .frame(width: 350, height: 500)
        .padding()
        .background(Color.white)
        
        // 将视图转换为UIImage
        let controller = UIHostingController(rootView: shareView)
        controller.view.frame = CGRect(x: 0, y: 0, width: 350, height: 500)
        
        let renderer = UIGraphicsImageRenderer(size: controller.view.bounds.size)
        let image = renderer.image { _ in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
        
        return image
    }
    
    // 记录分享事件
    private func logShareEvent(platform: String) {
        // 在实际应用中，这里可以实现分析追踪逻辑
        print("分享到平台: \(platform)")
        
        // 例如，可以使用Firebase Analytics或其他分析工具记录事件
        // Analytics.logEvent("share_result", parameters: ["platform": platform, "option": option.text])
    }
    
    // 提示用户评分
    private func promptForReview() {
        // 检查是否应该显示评分提示
        let shareCount = UserDefaults.standard.integer(forKey: "shareCount")
        UserDefaults.standard.set(shareCount + 1, forKey: "shareCount")
        
        // 每分享3次提示一次评分
        if (shareCount + 1) % 3 == 0 {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: windowScene)
            }
        }
    }
    
    // 加载选项选中次数
    private func loadSelectionCounts() {
        if let counts = try? JSONDecoder().decode([String: Int].self, from: optionSelectionCountsData) {
            selectionCounts = counts
            totalSelections = counts.values.reduce(0, +)
            
            // 更新ID到文本的映射
            updateIdToTextMap()
        }
    }
    
    // 更新ID到文本的映射
    private func updateIdToTextMap() {
        // 清空现有映射
        idToTextMap = [:]
        
        // 为当前选项添加映射
        idToTextMap[option.id.uuidString] = option.text
        
        // 为所有可用选项添加映射
        for opt in optionsManager.options {
            idToTextMap[opt.id.uuidString] = opt.text
        }
    }
    
    // 更新当前选项的选中次数
    private func updateSelectionCount() {
        let optionId = option.id.uuidString
        let currentCount = selectionCounts[optionId] ?? 0
        selectionCounts[optionId] = currentCount + 1
        totalSelections += 1
        
        // 更新ID到文本的映射
        idToTextMap[optionId] = option.text
        
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