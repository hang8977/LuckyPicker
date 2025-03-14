import SwiftUI

struct WheelView: View {
    @Binding var options: [Option]
    @State private var rotation: Double = 0
    @State private var isSpinning = false
    @State private var selectedOption: Option?
    var onSpinEnd: (Option) -> Void
    
    private let spinDuration: Double = 3.0
    
    var body: some View {
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
                    color: Color(hex: options[index].color)
                )
            }
            
            // 转盘中心
            Circle()
                .fill(Color.white)
                .frame(width: 20, height: 20)
                .shadow(radius: 2)
            
            // 转盘指针
            Triangle()
                .fill(Color.black)
                .frame(width: 20, height: 20)
                .offset(y: -150)
        }
        .frame(width: 300, height: 300)
        .rotationEffect(.degrees(rotation))
        .gesture(
            TapGesture()
                .onEnded { _ in
                    if !isSpinning {
                        spinWheel()
                    }
                }
        )
    }
    
    private func startAngle(for index: Int) -> Double {
        let sliceAngle = 360.0 / Double(options.count)
        return sliceAngle * Double(index)
    }
    
    private func endAngle(for index: Int) -> Double {
        let sliceAngle = 360.0 / Double(options.count)
        return sliceAngle * Double(index + 1)
    }
    
    private func spinWheel() {
        guard !options.isEmpty else { return }
        
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
        }
    }
}

struct WheelSliceView: View {
    let startAngle: Double
    let endAngle: Double
    let color: Color
    
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 150, y: 150))
            path.addArc(
                center: CGPoint(x: 150, y: 150),
                radius: 150,
                startAngle: .degrees(startAngle),
                endAngle: .degrees(endAngle),
                clockwise: false
            )
            path.closeSubpath()
        }
        .fill(color)
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