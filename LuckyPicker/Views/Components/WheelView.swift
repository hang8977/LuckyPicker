import SwiftUI

struct WheelView: View {
    @Binding var options: [Option]
    @State private var rotation: Double = 0
    @State private var isSpinning = false
    @State private var selectedOption: Option?
    var onSpinEnd: (Option) -> Void
    
    // 可选的触发旋转绑定
    var triggerSpin: Binding<Bool>?
    
    private let spinDuration: Double = 3.0
    
    init(options: Binding<[Option]>, triggerSpin: Binding<Bool>? = nil, onSpinEnd: @escaping (Option) -> Void) {
        self._options = options
        self.triggerSpin = triggerSpin
        self.onSpinEnd = onSpinEnd
    }
    
    var body: some View {
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
            }
        }
        .onChange(of: triggerSpin?.wrappedValue) { newValue in
            if let newValue = newValue, newValue != false {
                spinWheel()
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
        
        // 计算最终停止位置对应的选项
        let normalizedRotation = targetRotation.truncatingRemainder(dividingBy: 360)
        let sliceAngle = 360.0 / Double(options.count)
        let selectedIndex = Int(floor(normalizedRotation / sliceAngle))
        let safeIndex = (options.count - 1) - (selectedIndex % options.count)
        let finalIndex = safeIndex >= 0 && safeIndex < options.count ? safeIndex : 0
        
        withAnimation(.easeInOut(duration: spinDuration)) {
            rotation = targetRotation
        }
        
        // 旋转结束后的回调
        DispatchQueue.main.asyncAfter(deadline: .now() + spinDuration + 0.5) {
            selectedOption = options[finalIndex]
            if let selected = selectedOption {
                onSpinEnd(selected)
            }
            isSpinning = false
            
            // 重置触发器
            if let triggerSpin = triggerSpin {
                triggerSpin.wrappedValue = false
            }
        }
    }
}

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
            
            // 使用更简单、更可靠的方法显示文本
            GeometryReader { geometry in
                let center = CGPoint(x: geometry.size.width/2, y: geometry.size.height/2)
                let radius = min(geometry.size.width, geometry.size.height)/2
                
                // 计算扇形中心角度
                let midAngleDegrees = (startAngle + endAngle) / 2
                let midAngleRadians = midAngleDegrees * .pi / 180
                
                // 计算文本位置（在扇形中间位置）
                let textDistance = radius * 0.6
                let textPosition = CGPoint(
                    x: center.x + textDistance * CGFloat(cos(midAngleRadians)),
                    y: center.y + textDistance * CGFloat(sin(midAngleRadians))
                )
                
                // 文本标签 - 使用ZStack确保背景和文本对齐
                ZStack {
                    // 背景圆形
                    Circle()
                        .fill(Color.black.opacity(0.3))
                        .frame(width: 30, height: 30)
                    
                    // 文本
                    Text(text)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 1, x: 0, y: 0)
                        .fixedSize()
                }
                .position(textPosition)
            }
        }
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