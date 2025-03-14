//
//  ContentView.swift
//  LuckyPicker
//
//  Created by whs on 2025/3/14.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var optionsManager: OptionsManager
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("首页", systemImage: "house")
                }
            
            HistoryView()
                .tabItem {
                    Label("历史", systemImage: "clock")
                }
            
            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gearshape")
                }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(OptionsManager())
}
