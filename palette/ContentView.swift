//
//  ContentView.swift
//  palette
//
//  Created by 山内壮良 on 2025/08/15.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("ホーム")
                }
            
            // TODO: 他のタブを実装
            Text("ギャラリー")
                .tabItem {
                    Image(systemName: "rectangle.stack.fill")
                    Text("ギャラリー")
                }
            
            Text("設定")
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("設定")
                }
        }
        .tint(.primaryPink)
    }
}

#Preview {
    ContentView()
}
