import SwiftUI

// 颜色生成工具类 - 确保颜色不重复
struct ColorGenerator {
    // 预定义的高对比度颜色集合
    static let predefinedColors: [String] = [
        "#FF3B30", // 红色
        "#34C759", // 绿色
        "#007AFF", // 蓝色
        "#FF9500", // 橙色
        "#AF52DE", // 紫色
        "#5AC8FA", // 浅蓝色
        "#FFCC00", // 黄色
        "#FF2D55", // 粉红色
        "#5856D6", // 靛蓝色
        "#8E8E93", // 灰色
        "#32ADE6", // 天蓝色
        "#FF9500", // 橙色
        "#C69C6D", // 棕色
        "#53D769", // 浅绿色
        "#FC3158", // 深粉色
        "#147EFB", // 深蓝色
        "#53D769", // 浅绿色
        "#FFCC00", // 黄色
        "#FF3824", // 亮红色
        "#30B0C7", // 青色
        "#E63B8B", // 洋红色
        "#A2845E", // 棕褐色
        "#FDBE57", // 金色
        "#66DA43"  // 草绿色
    ]
    
    // 生成HSB颜色空间的颜色，确保视觉上的区分度
    static func generateHSBColors(count: Int) -> [String] {
        var colors: [String] = []
        
        // 如果数量小于等于预定义颜色数量，直接使用预定义颜色
        if count <= predefinedColors.count {
            return Array(predefinedColors.prefix(count))
        }
        
        // 否则使用HSB颜色空间生成均匀分布的颜色
        for i in 0..<count {
            // 均匀分布的色相值
            let hue = Double(i) / Double(count)
            // 固定的饱和度和亮度，确保颜色鲜艳
            let saturation: Double = 0.8
            let brightness: Double = 0.9
            
            let color = UIColor(hue: CGFloat(hue), 
                               saturation: CGFloat(saturation), 
                               brightness: CGFloat(brightness), 
                               alpha: 1.0)
            
            // 转换为十六进制颜色代码
            colors.append(color.toHexString())
        }
        
        return colors
    }
}

// UIColor扩展，添加转换为十六进制字符串的方法
extension UIColor {
    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return String(
            format: "#%02X%02X%02X",
            Int(r * 255),
            Int(g * 255),
            Int(b * 255)
        )
    }
}

struct WheelView: View {
    @Binding var options: [Option]
    @State private var rotation: Double = 0
    @State private var isSpinning = false
    @State private var selectedOption: Option?
    @State private var selectedIndex: Int? = nil
    var onSpinEnd: (Option) -> Void
    
    // 可选的触发旋转绑定
    var triggerSpin: Binding<Bool>?
    
    // 使用AppStorage获取用户设置的旋转时间
    @AppStorage("spinDuration") private var spinDuration: Double = 3.0
    
    // 控制是否显示图例
    @State private var showLegend: Bool = true
    
    init(options: Binding<[Option]>, triggerSpin: Binding<Bool>? = nil, onSpinEnd: @escaping (Option) -> Void) {
        self._options = options
        self.triggerSpin = triggerSpin
        self.onSpinEnd = onSpinEnd
    }
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                // 指针（放在最外层，不随转盘旋转）
                VStack {
                    // 指针，指向下方，适应深色模式
                    Triangle()
                        .fill(Color(UIColor.systemBackground))
                        .overlay(
                            Triangle()
                                .stroke(Color(UIColor.label), lineWidth: 2)
                        )
                        .shadow(color: Color(UIColor.label).opacity(0.5), radius: 2, x: 0, y: 0)
                        .frame(width: 20, height: 20)
                        .rotationEffect(.degrees(180))
                    
                    // 转盘部分
                    ZStack {
                        // 转盘背景
                        Circle()
                            .fill(Color.white)
                            .shadow(radius: 5)
                        
                        if options.isEmpty {
                            // 空状态设计 - 简约风格
                            ZStack {
                                // 背景圆形 - 提供视觉边界
                                Circle()
                                    .fill(Color(UIColor.systemGray6))
                                    .opacity(0.7)
                                    .frame(width: 200, height: 200)
                                
                                VStack(spacing: 12) {
                                    Text("暂无选项")
                                        .font(.system(size: 22, weight: .medium))
                                        .foregroundColor(Color(UIColor.label))
                                    
                                    Text("点击右上角添加新选项")
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundColor(Color(UIColor.secondaryLabel))
                                        .multilineTextAlignment(.center)
                                }
                                .padding(.horizontal, 24)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            // 转盘分区
                            ForEach(0..<options.count, id: \.self) { index in
                                WheelSliceView(
                                    startAngle: startAngle(for: index),
                                    endAngle: endAngle(for: index),
                                    color: getColorForIndex(index),
                                    text: options[index].text,
                                    optionsCount: options.count
                                )
                            }
                        }
                        
                        // 转盘中心 - 只在有选项时显示
                        if !options.isEmpty {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 20, height: 20)
                                .shadow(radius: 2)
                                .zIndex(2) // 确保圆心始终在最上层
                        }
                    }
                    .frame(width: 300, height: 300)
                    .rotationEffect(.degrees(rotation))
                    .padding()
                }
            }
            
            // 颜色和选项映射关系展示区域
            if showLegend && !options.isEmpty {
                // 选项列表
                LegendView(options: options, selectedIndex: selectedIndex, getColorForIndex: getColorForIndex)
                    .padding(.horizontal)
                    .transition(.opacity)
            }
        }
        .onChange(of: triggerSpin?.wrappedValue) { newValue in
            if let newValue = newValue, newValue != false {
                spinWheel()
                
                // 旋转时隐藏图例
                withAnimation {
                    showLegend = false
                }
            }
        }
    }
    
    // 根据索引获取颜色，确保颜色不重复
    private func getColorForIndex(_ index: Int) -> Color {
        // 直接使用选项中存储的颜色
        if index < options.count {
            return Color(hex: options[index].color)
        }
        
        // 如果索引超出范围，使用默认颜色
        return Color.gray
    }
    
    private func startAngle(for index: Int) -> Double {
        let sliceAngle = 360.0 / Double(max(1, options.count))
        return sliceAngle * Double(index)
    }
    
    private func endAngle(for index: Int) -> Double {
        let sliceAngle = 360.0 / Double(max(1, options.count))
        return sliceAngle * Double(index + 1)
    }
    
    // 将方法改为公开，供外部调用
    func spinWheel() {
        guard !options.isEmpty, !isSpinning else { return }
        
        isSpinning = true
        selectedIndex = nil
        
        // 随机旋转角度 (2-5圈 + 随机偏移)
        let baseRotation = Double.random(in: 2...5) * 360
        let randomOffset = Double.random(in: 0...360)
        let targetRotation = rotation + baseRotation + randomOffset
        
        withAnimation(.easeInOut(duration: spinDuration)) {
            rotation = targetRotation
        }
        
        // 旋转结束后的回调
        DispatchQueue.main.asyncAfter(deadline: .now() + spinDuration + 0.5) {
            // 修正计算逻辑：指针在顶部（270度位置）
            // 1. 首先计算转盘最终旋转的角度（取余360度）
            let finalRotation = rotation.truncatingRemainder(dividingBy: 360)
            
            // 2. 计算指针相对于转盘的位置（指针固定在270度位置）
            // 由于转盘顺时针旋转，指针相对于转盘的位置是逆时针的
            // 所以是 (360 - finalRotation + 270) % 360 = (630 - finalRotation) % 360
            let pointerPosition = (630 - finalRotation).truncatingRemainder(dividingBy: 360)
            
            // 3. 根据指针位置确定选中的选项
            let sliceAngle = 360.0 / Double(options.count)
            let index = Int(floor(pointerPosition / sliceAngle)) % options.count
            
            // 确保索引在有效范围内
            let finalIndex = index >= 0 && index < options.count ? index : 0
            
            selectedOption = options[finalIndex]
            selectedIndex = finalIndex
            
            if let selected = selectedOption {
                onSpinEnd(selected)
            }
            isSpinning = false
            
            // 重置触发器
            if let triggerSpin = triggerSpin {
                triggerSpin.wrappedValue = false
            }
            
            // 旋转结束后显示图例
            withAnimation(.easeIn(duration: 0.3).delay(0.5)) {
                showLegend = true
            }
        }
    }
}

// 简化的扇形视图
struct WheelSliceView: View {
    let startAngle: Double
    let endAngle: Double
    let color: Color
    let text: String
    let optionsCount: Int
    
    var body: some View {
        ZStack {
            // 扇形背景
            SlicePath(startAngle: startAngle, endAngle: endAngle)
                .fill(color)
            
            // 扇形边框 - 只在选项数量大于1时显示
            if optionsCount > 1 {
                SlicePath(startAngle: startAngle, endAngle: endAngle)
                    .stroke(Color.white, lineWidth: 2)
            }
        }
    }
}

// 颜色和选项映射关系展示组件
struct LegendView: View {
    let options: [Option]
    let selectedIndex: Int?
    let getColorForIndex: (Int) -> Color
    
    // 确定最佳列数
    private func optimalColumnCount() -> Int {
        let count = options.count
        if count <= 6 {
            return 2 // 少量选项时使用2列
        } else if count <= 12 {
            return 3 // 中等数量选项时使用3列
        } else {
            return 4 // 大量选项时使用4列
        }
    }
    
    // 计算内容高度
    private func calculateContentHeight(columnCount: Int, itemHeight: CGFloat = 40) -> CGFloat {
        let count = options.count
        let rowCount = (count + columnCount - 1) / columnCount // 向上取整
        return CGFloat(rowCount) * itemHeight
    }
    
    // 确定是否需要滚动
    private func needsScrolling() -> Bool {
        let contentHeight = calculateContentHeight(columnCount: optimalColumnCount())
        return contentHeight > 160 // 超过160高度时启用滚动
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("选项列表")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // 显示选项数量
                Text("\(options.count)个选项")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 4)
            
            // 根据内容高度决定是否使用ScrollView
            Group {
                if needsScrolling() {
                    // 使用ScrollView确保大量选项时可滚动
                    ScrollView {
                        legendContent
                    }
                    .frame(height: 160) // 固定高度，启用滚动
                } else {
                    // 直接显示内容，高度自适应
                    legendContent
                        .frame(height: calculateContentHeight(columnCount: optimalColumnCount()))
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
        .animation(.easeInOut(duration: 0.3), value: options.count) // 添加动画效果
    }
    
    // 提取公共的内容视图
    private var legendContent: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: optimalColumnCount())
        
        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(Array(options.enumerated()), id: \.element.id) { index, option in
                LegendItemView(
                    option: option,
                    color: getColorForIndex(index),
                    isSelected: index == selectedIndex
                )
            }
        }
        .padding(.vertical, 4)
    }
}

// 单个选项的展示组件
struct LegendItemView: View {
    let option: Option
    let color: Color
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            // 颜色指示器
            Circle()
                .fill(color)
                .frame(width: 14, height: 14)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
            
            // 选项文本 - 使用更紧凑的字体
            Text(option.text)
                .font(.system(size: 14, weight: isSelected ? .bold : .medium))
                .foregroundColor(.primary)
                .lineLimit(1)
                .truncationMode(.tail)
            
            Spacer(minLength: 2)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? color.opacity(0.15) : Color(UIColor.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? color : Color.clear, lineWidth: isSelected ? 1 : 0)
        )
    }
}

struct SlicePath: Shape {
    let startAngle: Double
    let endAngle: Double
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        var path = Path()
        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(startAngle),
            endAngle: .degrees(endAngle),
            clockwise: false
        )
        path.closeSubpath()
        return path
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
} 