import SwiftUI

struct SettingsView: View {
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("vibrationEnabled") private var vibrationEnabled = true
    
    var body: some View {
        NavigationView {
            VStack {
                Text("设置")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                List {
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
                    
                    // 高级功能
                    NavigationLink(destination: Text("高级功能页面")) {
                        HStack {
                            Image(systemName: "star")
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            
                            Text("高级功能")
                                .padding(.leading, 8)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 8)
                    
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