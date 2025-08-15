//
//  Color+Extensions.swift
//  palette
//
//  Created by Claude on 2025/08/14.
//

import SwiftUI

// MARK: - Color Extensions
extension Color {
    
    // MARK: - Initializers
    
    /// HEXコードからColorを作成
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    /// RGBColorからColorを作成
    init(_ rgbColor: RGBColor) {
        self.init(
            red: rgbColor.red / 255.0,
            green: rgbColor.green / 255.0,
            blue: rgbColor.blue / 255.0
        )
    }
    
    /// HSLColorからColorを作成
    init(_ hslColor: HSLColor) {
        let rgb = hslColor.rgb
        self.init(rgb)
    }
    
    // MARK: - Computed Properties
    
    /// HEXコード文字列を取得
    var hexString: String {
        let uic = UIColor(self)
        guard let components = uic.cgColor.components, components.count >= 3 else {
            return "#000000"
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
    
    /// RGBColorを取得
    var rgbColor: RGBColor {
        let uic = UIColor(self)
        guard let components = uic.cgColor.components, components.count >= 3 else {
            return RGBColor(red: 0, green: 0, blue: 0)
        }
        return RGBColor(
            red: Double(components[0]) * 255,
            green: Double(components[1]) * 255,
            blue: Double(components[2]) * 255
        )
    }
    
    /// HSLColorを取得
    var hslColor: HSLColor {
        return rgbColor.hsl
    }
    
    /// 明度を取得
    var luminance: Double {
        let rgb = rgbColor
        let r = rgb.red / 255.0
        let g = rgb.green / 255.0
        let b = rgb.blue / 255.0
        
        // sRGB線形化
        func linearize(_ value: Double) -> Double {
            return value <= 0.03928 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
        }
        
        let linearR = linearize(r)
        let linearG = linearize(g)
        let linearB = linearize(b)
        
        // ITU-R BT.709の係数
        return 0.2126 * linearR + 0.7152 * linearG + 0.0722 * linearB
    }
    
    /// この色に対してコントラストの良いテキスト色を取得
    var contrastingTextColor: Color {
        return luminance > 0.5 ? .black : .white
    }
    
    // MARK: - Color Manipulation
    
    /// 明度を調整した色を返す
    func adjustingLightness(by amount: Double) -> Color {
        let hsl = hslColor
        let newLightness = max(0, min(100, hsl.lightness + amount))
        return Color(HSLColor(hue: hsl.hue, saturation: hsl.saturation, lightness: newLightness))
    }
    
    /// 彩度を調整した色を返す
    func adjustingSaturation(by amount: Double) -> Color {
        let hsl = hslColor
        let newSaturation = max(0, min(100, hsl.saturation + amount))
        return Color(HSLColor(hue: hsl.hue, saturation: newSaturation, lightness: hsl.lightness))
    }
    
    /// 色相を調整した色を返す
    func adjustingHue(by degrees: Double) -> Color {
        let hsl = hslColor
        let newHue = (hsl.hue + degrees).truncatingRemainder(dividingBy: 360)
        let adjustedHue = newHue < 0 ? newHue + 360 : newHue
        return Color(HSLColor(hue: adjustedHue, saturation: hsl.saturation, lightness: hsl.lightness))
    }
    
    /// より明るい色を返す
    func lighter(by amount: Double = 10) -> Color {
        return adjustingLightness(by: amount)
    }
    
    /// より暗い色を返す
    func darker(by amount: Double = 10) -> Color {
        return adjustingLightness(by: -amount)
    }
    
    /// より鮮やかな色を返す
    func moreSaturated(by amount: Double = 10) -> Color {
        return adjustingSaturation(by: amount)
    }
    
    /// より淡い色を返す
    func lessSaturated(by amount: Double = 10) -> Color {
        return adjustingSaturation(by: -amount)
    }
    
    // MARK: - Color Harmony
    
    /// 補色を取得
    var complementary: Color {
        return adjustingHue(by: 180)
    }
    
    /// 三色配色を取得
    var triadic: [Color] {
        return [
            self,
            adjustingHue(by: 120),
            adjustingHue(by: 240)
        ]
    }
    
    /// 四色配色を取得
    var tetradic: [Color] {
        return [
            self,
            adjustingHue(by: 90),
            adjustingHue(by: 180),
            adjustingHue(by: 270)
        ]
    }
    
    /// 類似色配色を取得
    var analogous: [Color] {
        return [
            adjustingHue(by: -30),
            self,
            adjustingHue(by: 30)
        ]
    }
    
    /// 分割補色配色を取得
    var splitComplementary: [Color] {
        return [
            self,
            adjustingHue(by: 150),
            adjustingHue(by: 210)
        ]
    }
    
    // MARK: - Predefined Colors
    
    /// アプリのカスタムカラー
    static let primaryPink = Color(hex: "#FF6B6B")
    static let primaryTurquoise = Color(hex: "#4ECDC4")
    static let primaryBlue = Color(hex: "#45B7D1")
    static let primaryGreen = Color(hex: "#96CEB4")
    static let primaryYellow = Color(hex: "#FFEAA7")
    
    /// グラデーション用カラーセット
    static let sunsetGradient = [Color(hex: "#FF6B6B"), Color(hex: "#FFEAA7")]
    static let oceanGradient = [Color(hex: "#4ECDC4"), Color(hex: "#45B7D1")]
    static let forestGradient = [Color(hex: "#96CEB4"), Color(hex: "#74B9FF")]
    static let twilightGradient = [Color(hex: "#A29BFE"), Color(hex: "#6C5CE7")]
    
    // MARK: - Utility Methods
    
    /// 二つの色の中間色を計算
    static func interpolate(from startColor: Color, to endColor: Color, fraction: Double) -> Color {
        let fraction = max(0, min(1, fraction))
        
        let startRGB = startColor.rgbColor
        let endRGB = endColor.rgbColor
        
        let r = startRGB.red + (endRGB.red - startRGB.red) * fraction
        let g = startRGB.green + (endRGB.green - startRGB.green) * fraction
        let b = startRGB.blue + (endRGB.blue - startRGB.blue) * fraction
        
        return Color(RGBColor(red: r, green: g, blue: b))
    }
    
    /// 色の配列から滑らかなグラデーションを生成
    static func smoothGradient(colors: [Color], steps: Int = 10) -> [Color] {
        guard colors.count >= 2 else { return colors }
        
        var result: [Color] = []
        let segmentCount = colors.count - 1
        let stepsPerSegment = steps / segmentCount
        
        for i in 0..<segmentCount {
            let startColor = colors[i]
            let endColor = colors[i + 1]
            
            for step in 0..<stepsPerSegment {
                let fraction = Double(step) / Double(stepsPerSegment)
                result.append(interpolate(from: startColor, to: endColor, fraction: fraction))
            }
        }
        
        result.append(colors.last!)
        return result
    }
}

// MARK: - Preview Helper
#Preview {
    ScrollView {
        VStack(spacing: 20) {
            // HEX初期化テスト
            HStack {
                Rectangle().fill(Color(hex: "#FF6B6B")).frame(width: 50, height: 50)
                Rectangle().fill(Color(hex: "#4ECDC4")).frame(width: 50, height: 50)
                Rectangle().fill(Color(hex: "#45B7D1")).frame(width: 50, height: 50)
            }
            
            // 色調整テスト
            let baseColor = Color(hex: "#FF6B6B")
            HStack {
                Rectangle().fill(baseColor.darker()).frame(width: 50, height: 50)
                Rectangle().fill(baseColor).frame(width: 50, height: 50)
                Rectangle().fill(baseColor.lighter()).frame(width: 50, height: 50)
            }
            
            // 配色テスト
            HStack {
                ForEach(Color.primaryPink.triadic.indices, id: \.self) { index in
                    Rectangle()
                        .fill(Color.primaryPink.triadic[index])
                        .frame(width: 50, height: 50)
                }
            }
        }
        .padding()
    }
}