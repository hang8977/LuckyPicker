import SwiftUI

struct SettingsView: View {
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("vibrationEnabled") private var vibrationEnabled = true
    @AppStorage("spinDuration") private var spinDuration: Double = 3.0
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    
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
                        
                        // 深色模式
                        HStack {
                            Image(systemName: "moon.fill")
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            
                            Text("深色模式")
                                .padding(.leading, 8)
                            
                            Spacer()
                            
                            Toggle("", isOn: $darkModeEnabled)
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
                        
                        // 数据导出
                        NavigationLink(destination: DataExportView()) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(.blue)
                                    .frame(width: 30)
                                
                                Text("数据导出")
                                    .padding(.leading, 8)
                            }
                        }
                        .padding(.vertical, 8)
                        
                        // 主题设置
                        NavigationLink(destination: ThemeSettingsView()) {
                            HStack {
                                Image(systemName: "paintpalette")
                                    .foregroundColor(.blue)
                                    .frame(width: 30)
                                
                                Text("主题设置")
                                    .padding(.leading, 8)
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

// 数据导出视图
struct DataExportView: View {
    var body: some View {
        VStack {
            Text("数据导出")
                .font(.headline)
                .padding()
            
            Text("此功能允许您导出历史记录和选项数据")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding()
            
            Button(action: {
                // 导出数据的逻辑
            }) {
                Text("导出数据")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
            
            Spacer()
        }
        .padding()
        .navigationTitle("数据导出")
    }
}

// 主题设置视图
struct ThemeSettingsView: View {
    @State private var selectedTheme = 0
    let themes = ["默认", "暗夜", "自然", "糖果", "海洋"]
    
    var body: some View {
        VStack {
            Text("主题设置")
                .font(.headline)
                .padding()
            
            List {
                ForEach(0..<themes.count, id: \.self) { index in
                    Button(action: {
                        selectedTheme = index
                    }) {
                        HStack {
                            Text(themes[index])
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if selectedTheme == index {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            
            Spacer()
        }
        .navigationTitle("主题设置")
    }
} 