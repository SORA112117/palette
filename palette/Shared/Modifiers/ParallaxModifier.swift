//
//  ParallaxModifier.swift
//  palette
//
//  Created by Claude on 2025/08/14.
//

import SwiftUI

// MARK: - パララックスエフェクトモディファイア
struct ParallaxModifier: ViewModifier {
    let magnitude: CGFloat
    @State private var offset: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .offset(y: offset)
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                updateOffset()
            }
            .onAppear {
                updateOffset()
            }
    }
    
    private func updateOffset() {
        // パララックス効果の計算
        // 実際の実装では、スクロール位置やデバイスの傾きを考慮する
        withAnimation(.easeOut(duration: 0.3)) {
            offset = magnitude * sin(Date().timeIntervalSince1970 / 10) * 0.5
        }
    }
}