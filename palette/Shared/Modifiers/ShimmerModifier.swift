//
//  ShimmerModifier.swift
//  palette
//
//  Created by Claude on 2025/08/14.
//

import SwiftUI

// MARK: - シマー（光沢）エフェクトモディファイア
struct ShimmerModifier: ViewModifier {
    let active: Bool
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                .clear,
                                .white.opacity(0.6),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .scaleEffect(x: 3, y: 1)
                    .offset(x: -UIScreen.main.bounds.width + phase)
                    .opacity(active ? 1 : 0)
            )
            .onAppear {
                if active {
                    withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                        phase = UIScreen.main.bounds.width * 2
                    }
                }
            }
    }
}