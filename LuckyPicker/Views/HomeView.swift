import SwiftUI

struct HomeView: View {
    @EnvironmentObject var optionsManager: OptionsManager
    @State private var showResultView = false
    @State private var selectedOption: Option?
    
    var body: some View {
        NavigationView {
            VStack {
                Text("决策转盘")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Spacer()
                
                WheelView(
                    options: $optionsManager.options,
                    onSpinEnd: { option in
                        selectedOption = option
                        optionsManager.addToHistory(result: option)
                        showResultView = true
                    }
                )
                .padding()
                
                Button(action: {
                    // 转盘视图内部已经处理了旋转逻辑
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