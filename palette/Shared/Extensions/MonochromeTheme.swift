//
//  MonochromeTheme.swift
//  palette
//
//  Created by Claude on 2025/08/15.
//

import SwiftUI

// MARK: - モノクロ・スマートテーマ
extension Color {
    
    // MARK: - Monochrome Color Palette
    
    /// 純黒 - 最重要テキスト・アイコン
    static let smartBlack = Color(red: 0.05, green: 0.05, blue: 0.05)
    
    /// ダークグレー - 主要テキスト・ボタン
    static let smartDarkGray = Color(red: 0.25, green: 0.25, blue: 0.25)
    
    /// ミディアムグレー - 二次テキスト・アイコン
    static let smartMediumGray = Color(red: 0.50, green: 0.50, blue: 0.50)
    
    /// ライトグレー - 区切り線・背景
    static let smartLightGray = Color(red: 0.75, green: 0.75, blue: 0.75)
    
    /// オフホワイト - カード背景
    static let smartOffWhite = Color(red: 0.97, green: 0.97, blue: 0.97)
    
    /// 純白 - 背景・ハイライト
    static let smartWhite = Color.white
    
    // MARK: - Accent Colors (minimal usage)
    
    /// アクセント - 成功時のみ使用
    static let smartAccent = Color(red: 0.15, green: 0.15, blue: 0.15)
    
    /// エラー - 必要最小限
    static let smartError = Color(red: 0.30, green: 0.30, blue: 0.30)
    
    // MARK: - Semantic Colors
    
    /// 主要テキスト
    static let textPrimary = Color.smartBlack
    static let textSecondary = Color.smartDarkGray
    static let textTertiary = Color.smartMediumGray
    static let textQuaternary = Color.smartLightGray
    
    /// アイコン
    static let iconPrimary = Color.smartBlack
    static let iconSecondary = Color.smartDarkGray
    static let iconTertiary = Color.smartMediumGray
    
    /// 背景
    static let backgroundPrimary = Color.smartWhite
    static let backgroundSecondary = Color.smartOffWhite
    
    /// ボーダー・区切り線
    static let borderPrimary = Color.smartLightGray
    static let borderSecondary = Color.smartLightGray.opacity(0.5)
    
    /// 表面・カード
    static let surfacePrimary = Color.smartWhite
    static let surfaceSecondary = Color.smartOffWhite
    
    // MARK: - Interactive States
    
    /// プレス状態
    static let statePressed = Color.smartDarkGray.opacity(0.1)
    
    /// ホバー状態
    static let stateHover = Color.smartMediumGray.opacity(0.08)
    
    /// 選択状態
    static let stateSelected = Color.smartDarkGray.opacity(0.15)
    
    /// フォーカス状態
    static let stateFocus = Color.smartBlack.opacity(0.1)
}

// MARK: - スマートテーマ設定
struct SmartTheme {
    
    // MARK: - Layout Constants
    
    /// コーナーラディウス
    static let cornerRadiusSmall: CGFloat = 4
    static let cornerRadiusMedium: CGFloat = 8
    static let cornerRadiusLarge: CGFloat = 12
    static let cornerRadiusXLarge: CGFloat = 16
    
    /// シャドウ設定（最小限）
    static let shadowColor = Color.smartBlack.opacity(0.04)
    static let shadowRadius: CGFloat = 4
    static let shadowOffset = CGSize(width: 0, height: 1)
    
    /// エレベーション（シャドウレイヤー）
    static let elevationLow = (color: Color.smartBlack.opacity(0.02), radius: CGFloat(2), offset: CGSize(width: 0, height: 1))
    static let elevationMedium = (color: Color.smartBlack.opacity(0.04), radius: CGFloat(4), offset: CGSize(width: 0, height: 2))
    static let elevationHigh = (color: Color.smartBlack.opacity(0.08), radius: CGFloat(8), offset: CGSize(width: 0, height: 4))
    
    /// スペーシング（8dpベース）
    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 16
    static let spacingL: CGFloat = 24
    static let spacingXL: CGFloat = 32
    static let spacingXXL: CGFloat = 40
    
    /// タイポグラフィ
    static let fontSizeXS: CGFloat = 10
    static let fontSizeS: CGFloat = 12
    static let fontSizeM: CGFloat = 14
    static let fontSizeL: CGFloat = 16
    static let fontSizeXL: CGFloat = 18
    static let fontSizeXXL: CGFloat = 20
    static let fontSizeTitle: CGFloat = 24
    static let fontSizeHeader: CGFloat = 32
    
    /// アニメーション
    static let animationFast = Animation.easeInOut(duration: 0.2)
    static let animationMedium = Animation.easeInOut(duration: 0.3)
    static let animationSlow = Animation.easeInOut(duration: 0.5)
}

// MARK: - スマートスタイルモディファイア
extension View {
    
    /// スマートカードスタイル
    func smartCard(elevation: SmartCardElevation = .medium) -> some View {
        let shadowProps = elevation.shadowProperties
        return self
            .background(Color.surfacePrimary)
            .cornerRadius(SmartTheme.cornerRadiusMedium)
            .shadow(
                color: shadowProps.color,
                radius: shadowProps.radius,
                x: shadowProps.offset.width,
                y: shadowProps.offset.height
            )
    }
    
    /// スマートボタンスタイル
    func smartButton(style: SmartButtonStyle = .primary, isPressed: Bool = false) -> some View {
        Group {
            switch style {
            case .primary:
                self
                    .foregroundColor(.smartWhite)
                    .background(
                        RoundedRectangle(cornerRadius: SmartTheme.cornerRadiusMedium)
                            .fill(isPressed ? Color.smartMediumGray : Color.smartBlack)
                    )
            case .secondary:
                self
                    .foregroundColor(.textPrimary)
                    .background(
                        RoundedRectangle(cornerRadius: SmartTheme.cornerRadiusMedium)
                            .stroke(Color.borderPrimary, lineWidth: 1)
                            .background(
                                RoundedRectangle(cornerRadius: SmartTheme.cornerRadiusMedium)
                                    .fill(isPressed ? Color.statePressed : Color.backgroundPrimary)
                            )
                    )
            case .ghost:
                self
                    .foregroundColor(.textSecondary)
                    .background(
                        RoundedRectangle(cornerRadius: SmartTheme.cornerRadiusMedium)
                            .fill(isPressed ? Color.statePressed : Color.clear)
                    )
            }
        }
    }
    
    /// スマートテキストスタイル
    func smartText(_ style: SmartTextStyle) -> some View {
        switch style {
        case .header:
            return self
                .foregroundColor(.textPrimary)
                .font(.system(size: SmartTheme.fontSizeHeader, weight: .bold, design: .default))
        case .title:
            return self
                .foregroundColor(.textPrimary)
                .font(.system(size: SmartTheme.fontSizeTitle, weight: .semibold, design: .default))
        case .subtitle:
            return self
                .foregroundColor(.textPrimary)
                .font(.system(size: SmartTheme.fontSizeXL, weight: .medium, design: .default))
        case .body:
            return self
                .foregroundColor(.textPrimary)
                .font(.system(size: SmartTheme.fontSizeL, weight: .regular, design: .default))
        case .bodySecondary:
            return self
                .foregroundColor(.textSecondary)
                .font(.system(size: SmartTheme.fontSizeL, weight: .regular, design: .default))
        case .caption:
            return self
                .foregroundColor(.textTertiary)
                .font(.system(size: SmartTheme.fontSizeM, weight: .regular, design: .default))
        case .captionSecondary:
            return self
                .foregroundColor(.textQuaternary)
                .font(.system(size: SmartTheme.fontSizeS, weight: .regular, design: .default))
        }
    }
    
    /// スマート入力フィールド
    func smartInput() -> some View {
        self
            .padding(.horizontal, SmartTheme.spacingM)
            .padding(.vertical, SmartTheme.spacingS)
            .background(Color.backgroundSecondary)
            .cornerRadius(SmartTheme.cornerRadiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: SmartTheme.cornerRadiusMedium)
                    .stroke(Color.borderPrimary, lineWidth: 1)
            )
    }
}

// MARK: - Supporting Enums
enum SmartCardElevation {
    case low
    case medium
    case high
    
    var shadowProperties: (color: Color, radius: CGFloat, offset: CGSize) {
        switch self {
        case .low:
            return SmartTheme.elevationLow
        case .medium:
            return SmartTheme.elevationMedium
        case .high:
            return SmartTheme.elevationHigh
        }
    }
}

enum SmartButtonStyle {
    case primary
    case secondary
    case ghost
}

enum SmartTextStyle {
    case header
    case title
    case subtitle
    case body
    case bodySecondary
    case caption
    case captionSecondary
}