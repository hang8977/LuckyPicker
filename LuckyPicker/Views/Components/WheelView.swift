import SwiftUI

struct WheelView: View {
    @Binding var options: [Option]
    @State private var rotation: Double = 0
    @State private var isSpinning = false
    @State private var selectedOption: Option?
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
                        
                        // 转盘分区
                        ForEach(0..<options.count, id: \.self) { index in
                            WheelSliceView(
                                startAngle: startAngle(for: index),
                                endAngle: endAngle(for: index),
                                color: Color(hex: options[index].color),
                                text: options[index].text
                            )
                        }
                        
                        // 转盘中心
                        Circle()
                            .fill(Color.white)
                            .frame(width: 20, height: 20)
                            .shadow(radius: 2)
                    }
                    .frame(width: 300, height: 300)
                    .rotationEffect(.degrees(rotation))
                    .padding()
                }
            }
            
            // 颜色和选项映射关系展示区域
            if showLegend && !options.isEmpty {
                LegendView(options: options)
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
    
    private func startAngle(for index: Int) -> Double {
        let sliceAngle = 360.0 / Double(options.count)
        return sliceAngle * Double(index)
    }
    
    private func endAngle(for index: Int) -> Double {
        let sliceAngle = 360.0 / Double(options.count)
        return sliceAngle * Double(index + 1)
    }
    
    // 将方法改为公开，供外部调用
    func spinWheel() {
        guard !options.isEmpty, !isSpinning else { return }
        
        isSpinning = true
        
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
            let selectedIndex = Int(floor(pointerPosition / sliceAngle)) % options.count
            
            // 确保索引在有效范围内
            let finalIndex = selectedIndex >= 0 && selectedIndex < options.count ? selectedIndex : 0
            
            selectedOption = options[finalIndex]
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
    
    var body: some View {
        ZStack {
            // 扇形背景
            SlicePath(startAngle: startAngle, endAngle: endAngle)
                .fill(color)
            
            // 扇形边框
            SlicePath(startAngle: startAngle, endAngle: endAngle)
                .stroke(Color.white, lineWidth: 2)
        }
    }
}

// 颜色和选项映射关系展示组件
struct LegendView: View {
    let options: [Option]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("选项列表")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.bottom, 4)
            
            // 使用LazyVGrid以适应不同屏幕尺寸
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 12) {
                ForEach(options) { option in
                    LegendItemView(option: option)
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
}

// 单个选项的展示组件
struct LegendItemView: View {
    let option: Option
    
    var body: some View {
        HStack(spacing: 10) {
            // 颜色指示器
            Circle()
                .fill(Color(hex: option.color))
                .frame(width: 16, height: 16)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
            
            // 选项文本
            Text(option.text)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.primary)
                .lineLimit(1)
            
            Spacer()
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(UIColor.systemBackground))
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