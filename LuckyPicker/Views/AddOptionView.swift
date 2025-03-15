import SwiftUI

struct AddOptionView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var optionsManager: OptionsManager
    @State private var optionText = ""
    @State private var options: [Option] = []
    
    var body: some View {
        VStack {
            // 自定义导航栏，使用更美观的方式
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                        .imageScale(.large)
                }
                
                Spacer()
                
                Text("添加选项")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("完成")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            
            // 输入框
            HStack {
                TextField("输入选项内容", text: $optionText)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                Button(action: {
                    if !optionText.isEmpty {
                        // 使用uniqueHexString方法生成不同的颜色
                        let existingColors = optionsManager.options.map { $0.color }
                        let newColor = Color.uniqueHexString(existingColors: existingColors)
                        let newOption = Option(text: optionText, color: newColor)
                        optionsManager.addOption(newOption)
                        options = optionsManager.options
                        optionText = ""
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 24))
                }
            }
            .padding()
            
            // 已添加选项列表
            List {
                ForEach(optionsManager.options) { option in
                    HStack {
                        // 增大颜色块尺寸并添加边框
                        Circle()
                            .fill(Color(hex: option.color))
                            .frame(width: 30, height: 30)
                            .overlay(
                                Circle()
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                            .shadow(radius: 1)
                        
                        Text(option.text)
                            .padding(.leading, 8)
                            .font(.system(size: 16, weight: .medium))
                        
                        Spacer()
                        
                        // 显示颜色名称（可选）
                        Text(colorName(for: option.color))
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.trailing, 8)
                        
                        Button(action: {
                            // 删除选项
                            if let index = optionsManager.options.firstIndex(where: { $0.id == option.id }) {
                                optionsManager.removeOption(at: index)
                                options = optionsManager.options
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                                .font(.system(size: 20))
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            
            // 添加新选项按钮
            Button(action: {
                if !optionText.isEmpty {
                    // 使用uniqueHexString方法生成不同的颜色
                    let existingColors = optionsManager.options.map { $0.color }
                    let newColor = Color.uniqueHexString(existingColors: existingColors)
                    let newOption = Option(text: optionText, color: newColor)
                    optionsManager.addOption(newOption)
                    options = optionsManager.options
                    optionText = ""
                }
            }) {
                Text("添加新选项")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
            .disabled(optionText.isEmpty)
            
            Text("提示：可以从列表拖拽选项来排序")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.bottom)
        }
        .onAppear {
            options = optionsManager.options
        }
        // 隐藏系统导航栏的返回按钮，使用我们自定义的导航栏
        .navigationBarHidden(true)
    }
    
    // 根据颜色十六进制值返回颜色名称
    private func colorName(for hexColor: String) -> String {
        switch hexColor {
        case "#FF4136": return "红色"
        case "#0074D9": return "蓝色"
        case "#2ECC40": return "绿色"
        case "#FFDC00": return "黄色"
        case "#FF851B": return "橙色"
        case "#B10DC9": return "紫色"
        case "#01FF70": return "亮绿"
        case "#F012BE": return "粉色"
        case "#39CCCC": return "青色"
        case "#85144b": return "深红"
        default: return ""
        }
    }
} 