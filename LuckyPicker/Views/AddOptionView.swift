import SwiftUI

struct AddOptionView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var optionsManager: OptionsManager
    @State private var optionText = ""
    @State private var options: [Option] = []
    @State private var editMode: EditMode = .active
    @State private var isLongPressing = false
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // 现代化导航栏
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .imageScale(.medium)
                        Text("返回")
                            .font(.body)
                    }
                    .foregroundColor(.accentColor)
                }
                
                Spacer()
                
                Text("添加选项")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("完成")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.accentColor)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                colorScheme == .dark ? 
                    Color(UIColor.systemBackground).opacity(0.95) : 
                    Color(UIColor.systemBackground).opacity(0.95)
            )
            .overlay(
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(Color(UIColor.separator))
                    .opacity(0.8),
                alignment: .bottom
            )
            
            // 优化的输入区域
            VStack(alignment: .leading, spacing: 8) {
                Text("新选项")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.leading, 4)
                
                HStack(spacing: 12) {
                    TextField("输入选项内容", text: $optionText)
                        .font(.body)
                        .padding(12)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                        .focused($isInputFocused)
                        .submitLabel(.done)
                        .onSubmit {
                            addNewOption()
                        }
                    
                    Button(action: {
                        addNewOption()
                        // 添加触觉反馈
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.accentColor)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .disabled(optionText.isEmpty)
                    .opacity(optionText.isEmpty ? 0.6 : 1)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            // 选项列表标题
            if !optionsManager.options.isEmpty {
                HStack {
                    Text("已添加选项")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(optionsManager.options.count)个选项")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            
            // 优化的列表视图
            if !optionsManager.options.isEmpty {
                List {
                    ForEach(optionsManager.options) { option in
                        HStack(spacing: 16) {
                            // 优化的颜色圆圈
                            Circle()
                                .fill(Color(hex: option.color))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .stroke(
                                            colorScheme == .dark ? 
                                                Color.white.opacity(0.2) : 
                                                Color.black.opacity(0.1),
                                            lineWidth: 1
                                        )
                                )
                                .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                            
                            // 选项文本
                            Text(option.text)
                                .font(.body)
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .lineLimit(1)
                                .truncationMode(.tail)
                            
                            // 删除按钮
                            Button(action: {
                                if let index = optionsManager.options.firstIndex(where: { $0.id == option.id }) {
                                    // 触觉反馈
                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.impactOccurred()
                                    
                                    // 删除选项
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        optionsManager.removeOption(at: index)
                                        options = optionsManager.options
                                    }
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(Color.red.opacity(0.85))
                                    .frame(width: 44, height: 44)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .accessibility(label: Text("删除\(option.text)"))
                        }
                        .padding(.vertical, 12)
                        .contentShape(Rectangle())
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(UIColor.secondarySystemGroupedBackground))
                                .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                        )
                    }
                    .onMove { indices, newOffset in
                        var updatedOptions = optionsManager.options
                        updatedOptions.move(fromOffsets: indices, toOffset: newOffset)
                        optionsManager.options = updatedOptions
                        options = optionsManager.options
                    }
                }
                .listStyle(PlainListStyle())
                .environment(\.editMode, $editMode)
                .frame(maxHeight: .infinity)
                .background(Color.clear)
            } else {
                // 空状态提示
                VStack(spacing: 16) {
                    Image(systemName: "list.bullet.circle")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary.opacity(0.7))
                    
                    Text("暂无选项")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("添加一些选项来开始")
                        .font(.subheadline)
                        .foregroundColor(.secondary.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.vertical, 40)
            }
            
            // 底部操作区域
            VStack(spacing: 12) {
                Button(action: {
                    addNewOption()
                }) {
                    HStack {
                        Image(systemName: "plus")
                            .font(.headline)
                        Text("添加新选项")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        optionText.isEmpty ? 
                            Color.accentColor.opacity(0.6) : 
                            Color.accentColor
                    )
                    .foregroundColor(.white)
                    .cornerRadius(14)
                    .shadow(color: Color.accentColor.opacity(0.3), radius: 3, x: 0, y: 2)
                }
                .disabled(optionText.isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            .padding(.top, 8)
            .background(
                Rectangle()
                    .fill(colorScheme == .dark ? 
                          Color(UIColor.systemBackground).opacity(0.95) : 
                          Color(UIColor.systemBackground).opacity(0.95))
                    .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: -2)
            )
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .onAppear {
            options = optionsManager.options
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isInputFocused = true
            }
        }
        .navigationBarHidden(true)
    }
    
    // 添加新选项的函数
    private func addNewOption() {
        if !optionText.isEmpty {
            let existingColors = optionsManager.options.map { $0.color }
            let newColor = Color.uniqueHexString(existingColors: existingColors)
            let newOption = Option(text: optionText, color: newColor)
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                optionsManager.addOption(newOption)
                options = optionsManager.options
                optionText = ""
            }
        }
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