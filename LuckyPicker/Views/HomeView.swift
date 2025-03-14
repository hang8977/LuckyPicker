import SwiftUI

struct HomeView: View {
    @EnvironmentObject var optionsManager: OptionsManager
    @State private var showResultView = false
    @State private var selectedOption: Option?
    @State private var triggerSpin = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("决策转盘")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Spacer()
                
                // 使用修改后的WheelView组件
                WheelView(
                    options: $optionsManager.options,
                    triggerSpin: $triggerSpin,
                    onSpinEnd: { option in
                        selectedOption = option
                        optionsManager.addToHistory(result: option)
                        showResultView = true
                    }
                )
                .padding()
                
                Button(action: {
                    // 触发转盘旋转
                    triggerSpin = true
                }) {
                    Text("开始选择")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 150)
                        .background(Color.blue)
                        .cornerRadius(25)
                        .shadow(radius: 3)
                }
                .padding(.bottom, 30)
                
                Spacer()
            }
            .navigationBarItems(trailing: 
                NavigationLink(destination: AddOptionView()) {
                    Image(systemName: "plus")
                        .font(.system(size: 22))
                        .foregroundColor(.blue)
                        .padding(8)
                        .background(Circle().fill(Color.blue.opacity(0.1)))
                }
            )
            .sheet(isPresented: $showResultView) {
                if let option = selectedOption {
                    ResultView(option: option)
                }
            }
        }
    }
} 