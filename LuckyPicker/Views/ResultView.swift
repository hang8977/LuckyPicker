import SwiftUI

struct ResultView: View {
    let option: Option
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("vibrationEnabled") private var vibrationEnabled = true
    
    var body: some View {
        VStack(spacing: 30) {
            Text("今天中午吃什么？")
                .font(.title2)
                .foregroundColor(.gray)
                .padding(.top, 50)
            
            Text(option.text)
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(Color(hex: option.color))
            
            Text("第3次被选中")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
            
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
                .background(Color.blue)
                .cornerRadius(25)
            }
            
            Button(action: {
                // 分享结果
                let activityVC = UIActivityViewController(
                    activityItems: ["我今天使用决策转盘选择了：\(option.text)"],
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
                .foregroundColor(.blue)
                .padding()
                .frame(width: 200)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.blue, lineWidth: 2)
                )
            }
            
            Spacer()
            
            Text("本次决策已保存至历史记录")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.bottom, 20)
        }
        .padding()
        .onAppear {
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
    
    private func playSound() {
        // 在实际应用中，这里会实现声音播放逻辑
    }
    
    private func triggerHapticFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
} 