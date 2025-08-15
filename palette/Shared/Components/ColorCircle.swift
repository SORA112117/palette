//
//  ColorCircle.swift
//  palette
//
//  Created by Claude on 2025/08/14.
//

import SwiftUI

// MARK: - 色表示用円形コンポーネント
struct ColorCircle: View {
    
    // MARK: - Properties
    let color: ExtractedColor
    let size: CGFloat
    let showPercentage: Bool
    let showHexCode: Bool
    let onTap: (() -> Void)?
    
    // MARK: - State
    @State private var isPressed = false
    
    // MARK: - Initializer
    init(
        color: ExtractedColor,
        size: CGFloat = 60,
        showPercentage: Bool = false,
        showHexCode: Bool = false,
        onTap: (() -> Void)? = nil
    ) {
        self.color = color
        self.size = size
        self.showPercentage = showPercentage
        self.showHexCode = showHexCode
        self.onTap = onTap
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 8) {
            // 色の円
            Circle()
                .fill(color.color)
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isPressed)
                .onTapGesture {
                    onTap?()
                }
                .onLongPressGesture(minimumDuration: 0) { isPressing in
                    isPressed = isPressing
                } perform: {}
            
            // 詳細情報
            if showPercentage || showHexCode {
                VStack(spacing: 2) {
                    if showHexCode {
                        Text(color.hexCode)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    
                    if showPercentage {
                        Text("\(color.percentage, specifier: "%.1f")%")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

// MARK: - 拡張バリエーション
extension ColorCircle {
    
    /// 大きめサイズの色表示
    static func large(
        color: ExtractedColor,
        showInfo: Bool = true,
        onTap: (() -> Void)? = nil
    ) -> some View {
        ColorCircle(
            color: color,
            size: 80,
            showPercentage: showInfo,
            showHexCode: showInfo,
            onTap: onTap
        )
    }
    
    /// 小さめサイズの色表示
    static func small(
        color: ExtractedColor,
        onTap: (() -> Void)? = nil
    ) -> some View {
        ColorCircle(
            color: color,
            size: 40,
            showPercentage: false,
            showHexCode: false,
            onTap: onTap
        )
    }
    
    /// インタラクティブな色表示（詳細表示用）
    static func interactive(
        color: ExtractedColor,
        onTap: (() -> Void)? = nil
    ) -> some View {
        ColorCircle(
            color: color,
            size: 70,
            showPercentage: true,
            showHexCode: true,
            onTap: onTap
        )
        .contextMenu {
            Button(action: {
                UIPasteboard.general.string = color.hexCode
            }) {
                Label("HEXコードをコピー", systemImage: "doc.on.doc")
            }
            
            Button(action: {
                let rgbText = "RGB(\(Int(color.rgb.red)), \(Int(color.rgb.green)), \(Int(color.rgb.blue)))"
                UIPasteboard.general.string = rgbText
            }) {
                Label("RGB値をコピー", systemImage: "doc.on.doc")
            }
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        Text("ColorCircle Examples")
            .font(.title2)
            .fontWeight(.bold)
        
        HStack(spacing: 20) {
            ColorCircle.small(color: ExtractedColor.sampleColors[0])
            
            ColorCircle(
                color: ExtractedColor.sampleColors[1],
                size: 60,
                showPercentage: true
            )
            
            ColorCircle.large(color: ExtractedColor.sampleColors[2])
        }
        
        ColorCircle.interactive(color: ExtractedColor.sampleColors[3])
    }
    .padding()
}