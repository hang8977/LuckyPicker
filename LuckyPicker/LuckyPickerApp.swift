//
//  LuckyPickerApp.swift
//  LuckyPicker
//
//  Created by whs on 2025/3/14.
//

import SwiftUI

@main
struct LuckyPickerApp: App {
    @StateObject private var optionsManager = OptionsManager()
    
    init() {
        // 在APP启动时重置统计数据
        UserDefaults.standard.removeObject(forKey: "optionSelectionCounts")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(optionsManager)
        }
    }
}
