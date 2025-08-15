//
//  ExtractedColor.swift
//  palette
//
//  Created by Claude on 2025/08/14.
//

import Foundation
import SwiftUI

// MARK: - 抽出色モデル
struct ExtractedColor: Codable, Identifiable, Hashable {
    let id: UUID
    let hexCode: String
    let rgb: RGBColor
    let hsl: HSLColor
    let percentage: Double // 画像内での占有率
    let name: String? // 色の名前（オプション）
    
    init(id: UUID = UUID(), hexCode: String, rgb: RGBColor, hsl: HSLColor, percentage: Double, name: String? = nil) {
        self.id = id
        self.hexCode = hexCode
        self.rgb = rgb
        self.hsl = hsl
        self.percentage = percentage
        self.name = name
    }
    
    // SwiftUIのColorオブジェクトに変換
    var color: Color {
        Color(
            red: rgb.red / 255.0,
            green: rgb.green / 255.0,
            blue: rgb.blue / 255.0
        )
    }
    
    // UIColorオブジェクトに変換
    var uiColor: UIColor {
        UIColor(
            red: rgb.red / 255.0,
            green: rgb.green / 255.0,
            blue: rgb.blue / 255.0,
            alpha: 1.0
        )
    }
}

// MARK: - RGB色空間モデル
struct RGBColor: Codable, Hashable {
    let red: Double
    let green: Double
    let blue: Double
    
    init(red: Double, green: Double, blue: Double) {
        self.red = max(0, min(255, red))
        self.green = max(0, min(255, green))
        self.blue = max(0, min(255, blue))
    }
    
    // HEXコードに変換
    var hexCode: String {
        return String(format: "#%02X%02X%02X", 
                     Int(red), 
                     Int(green), 
                     Int(blue))
    }
    
    // HSLに変換
    var hsl: HSLColor {
        let r = red / 255.0
        let g = green / 255.0
        let b = blue / 255.0
        
        let max = Swift.max(r, g, b)
        let min = Swift.min(r, g, b)
        let delta = max - min
        
        var h: Double = 0
        let s: Double
        let l: Double = (max + min) / 2
        
        if delta == 0 {
            s = 0
        } else {
            s = l > 0.5 ? delta / (2 - max - min) : delta / (max + min)
            
            switch max {
            case r:
                h = ((g - b) / delta) + (g < b ? 6 : 0)
            case g:
                h = (b - r) / delta + 2
            case b:
                h = (r - g) / delta + 4
            default:
                break
            }
            h /= 6
        }
        
        return HSLColor(
            hue: h * 360,
            saturation: s * 100,
            lightness: l * 100
        )
    }
}

// MARK: - HSL色空間モデル
struct HSLColor: Codable, Hashable {
    let hue: Double        // 0-360
    let saturation: Double // 0-100
    let lightness: Double  // 0-100
    
    init(hue: Double, saturation: Double, lightness: Double) {
        self.hue = max(0, min(360, hue))
        self.saturation = max(0, min(100, saturation))
        self.lightness = max(0, min(100, lightness))
    }
    
    // RGBに変換
    var rgb: RGBColor {
        let h = hue / 360.0
        let s = saturation / 100.0
        let l = lightness / 100.0
        
        if s == 0 {
            let gray = l * 255
            return RGBColor(red: gray, green: gray, blue: gray)
        }
        
        let c = (1 - abs(2 * l - 1)) * s
        let x = c * (1 - abs((h * 6).truncatingRemainder(dividingBy: 2) - 1))
        let m = l - c / 2
        
        var r: Double = 0
        var g: Double = 0
        var b: Double = 0
        
        switch h * 6 {
        case 0..<1:
            r = c; g = x; b = 0
        case 1..<2:
            r = x; g = c; b = 0
        case 2..<3:
            r = 0; g = c; b = x
        case 3..<4:
            r = 0; g = x; b = c
        case 4..<5:
            r = x; g = 0; b = c
        case 5..<6:
            r = c; g = 0; b = x
        default:
            break
        }
        
        return RGBColor(
            red: (r + m) * 255,
            green: (g + m) * 255,
            blue: (b + m) * 255
        )
    }
}

// MARK: - サンプルデータ
extension ExtractedColor {
    static let sampleColors: [ExtractedColor] = [
        ExtractedColor(
            hexCode: "#FF6B6B",
            rgb: RGBColor(red: 255, green: 107, blue: 107),
            hsl: HSLColor(hue: 0, saturation: 100, lightness: 71),
            percentage: 35.2,
            name: "Coral Pink"
        ),
        ExtractedColor(
            hexCode: "#4ECDC4", 
            rgb: RGBColor(red: 78, green: 205, blue: 196),
            hsl: HSLColor(hue: 176, saturation: 57, lightness: 55),
            percentage: 28.7,
            name: "Turquoise"
        ),
        ExtractedColor(
            hexCode: "#45B7D1",
            rgb: RGBColor(red: 69, green: 183, blue: 209),
            hsl: HSLColor(hue: 191, saturation: 62, lightness: 55),
            percentage: 18.9,
            name: "Sky Blue"
        ),
        ExtractedColor(
            hexCode: "#96CEB4",
            rgb: RGBColor(red: 150, green: 206, blue: 180),
            hsl: HSLColor(hue: 148, saturation: 36, lightness: 70),
            percentage: 12.1,
            name: "Mint Green"
        ),
        ExtractedColor(
            hexCode: "#FFEAA7",
            rgb: RGBColor(red: 255, green: 234, blue: 167),
            hsl: HSLColor(hue: 46, saturation: 100, lightness: 83),
            percentage: 5.1,
            name: "Soft Yellow"
        )
    ]
}