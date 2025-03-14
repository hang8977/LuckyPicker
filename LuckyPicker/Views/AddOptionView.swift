import SwiftUI

struct AddOptionView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var optionsManager: OptionsManager
    @State private var optionText = ""
    @State private var options: [Option] = []
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("返回")
                        .foregroundColor(.blue)
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
                        let newOption = Option(text: optionText, color: Color.randomHexString)
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
                        Circle()
                            .fill(Color(hex: option.color))
                            .frame(width: 20, height: 20)
                        
                        Text(option.text)
                            .padding(.leading, 8)
                        
                        Spacer()
                        
                        Button(action: {
                            // 删除选项
                            if let index = optionsManager.options.firstIndex(where: { $0.id == option.id }) {
                                optionsManager.removeOption(at: index)
                                options = optionsManager.options
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            
            // 添加新选项按钮
            Button(action: {
                if !optionText.isEmpty {
                    let newOption = Option(text: optionText, color: Color.randomHexString)
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
    }
} 