//
//  GradientBackground.swift
//  palette
//
//  Created by Claude on 2025/08/14.
//

import SwiftUI

// MARK: - グラデーション背景コンポーネント
struct GradientBackground: View {
    
    // MARK: - Properties
    let colors: [Color]
    let gradientType: GradientType
    let orientation: GradientOrientation
    let opacity: Double
    let animated: Bool
    
    // MARK: - State
    @State private var animationOffset: CGFloat = 0
    
    // MARK: - Initializer
    init(
        colors: [Color],
        gradientType: GradientType = .linear,
        orientation: GradientOrientation = .vertical,
        opacity: Double = 1.0,
        animated: Bool = false
    ) {
        self.colors = colors
        self.gradientType = gradientType
        self.orientation = orientation
        self.opacity = opacity
        self.animated = animated
    }
    
    // MARK: - Convenience Initializers
    init(
        palette: ColorPalette,
        gradientType: GradientType = .linear,
        orientation: GradientOrientation = .vertical,
        opacity: Double = 1.0,
        animated: Bool = false
    ) {
        self.init(
            colors: palette.gradientColors,
            gradientType: gradientType,
            orientation: orientation,
            opacity: opacity,
            animated: animated
        )
    }
    
    init(
        extractedColors: [ExtractedColor],
        gradientType: GradientType = .linear,
        orientation: GradientOrientation = .vertical,
        opacity: Double = 1.0,
        animated: Bool = false
    ) {
        self.init(
            colors: extractedColors.map { $0.color },
            gradientType: gradientType,
            orientation: orientation,
            opacity: opacity,
            animated: animated
        )
    }
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            switch gradientType {
            case .linear:
                linearGradient
            case .radial:
                radialGradient(size: geometry.size)
            case .angular:
                angularGradient
            case .diamond:
                diamondGradient(size: geometry.size)
            }
        }
        .opacity(opacity)
        .onAppear {
            if animated {
                startAnimation()
            }
        }
    }
    
    // MARK: - Gradient Types
    
    private var linearGradient: some View {
        LinearGradient(
            colors: animatedColors,
            startPoint: orientation.startPoint,
            endPoint: orientation.endPoint
        )
    }
    
    private func radialGradient(size: CGSize) -> some View {
        RadialGradient(
            colors: animatedColors,
            center: .center,
            startRadius: 0,
            endRadius: max(size.width, size.height) / 2
        )
    }
    
    private var angularGradient: some View {
        AngularGradient(
            colors: animatedColors,
            center: .center,
            startAngle: .degrees(animationOffset),
            endAngle: .degrees(360 + animationOffset)
        )
    }
    
    private func diamondGradient(size: CGSize) -> some View {
        ZStack {
            ForEach(0..<colors.count, id: \.self) { index in
                let color = colors[index]
                let scale = 1.0 - (Double(index) / Double(colors.count)) * 0.8
                
                Diamond()
                    .fill(color)
                    .scaleEffect(scale)
                    .opacity(0.7)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var animatedColors: [Color] {
        if animated {
            return colors.map { color in
                color.opacity(0.8 + sin(animationOffset * .pi / 180) * 0.2)
            }
        }
        return colors
    }
    
    // MARK: - Animation
    
    private func startAnimation() {
        withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
            animationOffset = 360
        }
    }
}

// MARK: - Diamond Shape
struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let radius = min(rect.width, rect.height) / 2
            
            path.move(to: CGPoint(x: center.x, y: center.y - radius))
            path.addLine(to: CGPoint(x: center.x + radius, y: center.y))
            path.addLine(to: CGPoint(x: center.x, y: center.y + radius))
            path.addLine(to: CGPoint(x: center.x - radius, y: center.y))
            path.closeSubpath()
        }
    }
}

// MARK: - 便利なファクトリーメソッド
extension GradientBackground {
    
    /// シンプルな線形グラデーション
    static func linear(
        colors: [Color],
        orientation: GradientOrientation = .vertical
    ) -> GradientBackground {
        GradientBackground(
            colors: colors,
            gradientType: .linear,
            orientation: orientation
        )
    }
    
    /// アニメーション付き放射グラデーション
    static func animatedRadial(
        colors: [Color]
    ) -> GradientBackground {
        GradientBackground(
            colors: colors,
            gradientType: .radial,
            animated: true
        )
    }
    
    /// 回転する角度グラデーション
    static func rotatingAngular(
        colors: [Color]
    ) -> GradientBackground {
        GradientBackground(
            colors: colors,
            gradientType: .angular,
            animated: true
        )
    }
    
    /// パレットベースのグラデーション
    static func fromPalette(
        _ palette: ColorPalette,
        type: GradientType = .linear,
        orientation: GradientOrientation = .vertical
    ) -> GradientBackground {
        GradientBackground(
            palette: palette,
            gradientType: type,
            orientation: orientation
        )
    }
    
    /// 淡い背景グラデーション
    static func subtle(
        colors: [Color],
        orientation: GradientOrientation = .vertical
    ) -> GradientBackground {
        GradientBackground(
            colors: colors,
            gradientType: .linear,
            orientation: orientation,
            opacity: 0.3
        )
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 0) {
        // 線形グラデーション
        GradientBackground.linear(
            colors: [Color.red, Color.orange, Color.yellow],
            orientation: .horizontal
        )
        .frame(height: 100)
        
        // 放射グラデーション
        GradientBackground(
            colors: [Color.blue, Color.purple, Color.pink],
            gradientType: .radial
        )
        .frame(height: 100)
        
        // 角度グラデーション（アニメーション付き）
        GradientBackground.rotatingAngular(
            colors: [Color.green, Color.blue, Color.purple, Color.pink]
        )
        .frame(height: 100)
        
        // ダイヤモンドグラデーション
        GradientBackground(
            colors: [Color.yellow, Color.orange, Color.red],
            gradientType: .diamond
        )
        .frame(height: 100)
    }
}