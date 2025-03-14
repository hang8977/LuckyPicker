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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(optionsManager)
        }
    }
}
