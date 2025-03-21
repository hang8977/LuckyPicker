import SwiftUI

struct SettingsView: View {
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("vibrationEnabled") private var vibrationEnabled = true
    @AppStorage("spinDuration") private var spinDuration: Double = 3.0
    
    var body: some View {
        NavigationView {
            VStack {
                Text("设置")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                List {
                    Section(header: Text("基本设置")) {
                        // 声音设置
                        HStack {
                            Image(systemName: "speaker.wave.2")
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            
                            Text("音效")
                                .padding(.leading, 8)
                            
                            Spacer()
                            
                            Toggle("", isOn: $soundEnabled)
                                .labelsHidden()
                        }
                        .padding(.vertical, 8)
                        
                        // 震动设置
                        HStack {
                            Image(systemName: "iphone.radiowaves.left.and.right")
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            
                            Text("震动反馈")
                                .padding(.leading, 8)
                            
                            Spacer()
                            
                            Toggle("", isOn: $vibrationEnabled)
                                .labelsHidden()
                        }
                        .padding(.vertical, 8)
                    }
                    
                    Section(header: Text("高级功能")) {
                        // 转盘旋转时间设置
                        NavigationLink(destination: SpinDurationSettingView(spinDuration: $spinDuration)) {
                            HStack {
                                Image(systemName: "timer")
                                    .foregroundColor(.blue)
                                    .frame(width: 30)
                                
                                Text("转盘旋转时间")
                                    .padding(.leading, 8)
                                
                                Spacer()
                                
                                Text("\(String(format: "%.1f", spinDuration))秒")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // 关于
                    Section(header: Text("关于")) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("关于")
                                .font(.headline)
                            
                            Text("版本: 1.0.0")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Text("开发者: ThinkChat Team")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Spacer()
            }
        }
    }
}

// 转盘旋转时间设置视图
struct SpinDurationSettingView: View {
    @Binding var spinDuration: Double
    
    var body: some View {
        VStack {
            Text("转盘旋转时间")
                .font(.headline)
                .padding()
            
            Slider(value: $spinDuration, in: 1.0...5.0, step: 0.5)
                .padding()
            
            Text("\(String(format: "%.1f", spinDuration))秒")
                .font(.title)
                .padding()
            
            Text("调整转盘旋转的时间长度，时间越长，转盘旋转的圈数越多")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
        }
        .padding()
        .navigationTitle("转盘旋转时间")
    }
} 