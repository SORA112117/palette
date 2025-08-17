//
//  AppConfigurationService.swift
//  palette
//
//  Created by Claude on 2025/08/17.
//

import Foundation
import SwiftUI

// MARK: - アプリ設定サービス
@MainActor
final class AppConfigurationService: AppConfigurationProviding, ObservableObject {
    
    // MARK: - Properties
    @AppStorage("hapticFeedbackEnabled") 
    var hapticFeedbackEnabled: Bool = true
    
    @AppStorage("autoSavePalettes") 
    var autoSavePalettes: Bool = false
    
    @AppStorage("appTheme") 
    private var appThemeString: String = AppTheme.system.rawValue
    
    @AppStorage("defaultColorCount") 
    var defaultColorCount: Int = 5
    
    // MARK: - AppConfigurationProviding Conformance
    
    var appTheme: AppTheme {
        get {
            AppTheme(rawValue: appThemeString) ?? .system
        }
        set {
            appThemeString = newValue.rawValue
        }
    }
    
    // MARK: - Additional Configuration Properties
    
    @AppStorage("colorExtractionQuality")
    private var colorExtractionQualityString: String = ColorExtractionQuality.medium.rawValue
    
    var colorExtractionQuality: ColorExtractionQuality {
        get {
            ColorExtractionQuality(rawValue: colorExtractionQualityString) ?? .medium
        }
        set {
            colorExtractionQualityString = newValue.rawValue
        }
    }
    
    @AppStorage("hasCompletedOnboarding")
    var hasCompletedOnboarding: Bool = false
    
    @AppStorage("lastOpenedPaletteID")
    var lastOpenedPaletteID: String = ""
    
    // MARK: - Privacy & Legal
    
    @AppStorage("analyticsEnabled")
    var analyticsEnabled: Bool = false
    
    @AppStorage("crashReportingEnabled")
    var crashReportingEnabled: Bool = true
    
    // MARK: - Display Settings
    
    @AppStorage("showHexValues")
    var showHexValues: Bool = true
    
    @AppStorage("showRGBValues")
    var showRGBValues: Bool = false
    
    @AppStorage("showHSLValues")
    var showHSLValues: Bool = false
    
    @AppStorage("compactColorDisplay")
    var compactColorDisplay: Bool = false
    
    // MARK: - Export Settings
    
    @AppStorage("defaultExportFormat")
    private var defaultExportFormatString: String = "JSON"
    
    var defaultExportFormat: ExportFormat {
        get {
            ExportFormat(rawValue: defaultExportFormatString) ?? .json
        }
        set {
            defaultExportFormatString = newValue.rawValue
        }
    }
    
    @AppStorage("includeImageInExport")
    var includeImageInExport: Bool = false
    
    // MARK: - Performance Settings
    
    @AppStorage("reduceAnimations")
    var reduceAnimations: Bool = false
    
    @AppStorage("lowPowerModeOptimizations")
    var lowPowerModeOptimizations: Bool = true
    
    // MARK: - Notification Settings
    
    @AppStorage("reminderNotificationsEnabled")
    var reminderNotificationsEnabled: Bool = false
    
    @AppStorage("paletteUpdateNotificationsEnabled")
    var paletteUpdateNotificationsEnabled: Bool = true
    
    // MARK: - Methods
    
    /// 設定を初期値にリセット
    func resetToDefaults() {
        hapticFeedbackEnabled = true
        autoSavePalettes = false
        appTheme = .system
        defaultColorCount = 5
        colorExtractionQuality = .medium
        analyticsEnabled = false
        crashReportingEnabled = true
        showHexValues = true
        showRGBValues = false
        showHSLValues = false
        compactColorDisplay = false
        defaultExportFormat = .json
        includeImageInExport = false
        reduceAnimations = false
        lowPowerModeOptimizations = true
        reminderNotificationsEnabled = false
        paletteUpdateNotificationsEnabled = true
    }
    
    /// エクスポート用の設定辞書を取得
    func getConfigurationDictionary() -> [String: Any] {
        return [
            "hapticFeedbackEnabled": hapticFeedbackEnabled,
            "autoSavePalettes": autoSavePalettes,
            "appTheme": appTheme.rawValue,
            "defaultColorCount": defaultColorCount,
            "colorExtractionQuality": colorExtractionQuality.rawValue,
            "showHexValues": showHexValues,
            "showRGBValues": showRGBValues,
            "showHSLValues": showHSLValues,
            "compactColorDisplay": compactColorDisplay,
            "defaultExportFormat": defaultExportFormat.rawValue,
            "includeImageInExport": includeImageInExport
        ]
    }
    
    /// 設定辞書からインポート
    func importConfiguration(from dictionary: [String: Any]) {
        if let value = dictionary["hapticFeedbackEnabled"] as? Bool {
            hapticFeedbackEnabled = value
        }
        if let value = dictionary["autoSavePalettes"] as? Bool {
            autoSavePalettes = value
        }
        if let value = dictionary["appTheme"] as? String,
           let theme = AppTheme(rawValue: value) {
            appTheme = theme
        }
        if let value = dictionary["defaultColorCount"] as? Int {
            defaultColorCount = value
        }
        if let value = dictionary["colorExtractionQuality"] as? String,
           let quality = ColorExtractionQuality(rawValue: value) {
            colorExtractionQuality = quality
        }
        if let value = dictionary["showHexValues"] as? Bool {
            showHexValues = value
        }
        if let value = dictionary["showRGBValues"] as? Bool {
            showRGBValues = value
        }
        if let value = dictionary["showHSLValues"] as? Bool {
            showHSLValues = value
        }
        if let value = dictionary["compactColorDisplay"] as? Bool {
            compactColorDisplay = value
        }
        if let value = dictionary["defaultExportFormat"] as? String,
           let format = ExportFormat(rawValue: value) {
            defaultExportFormat = format
        }
        if let value = dictionary["includeImageInExport"] as? Bool {
            includeImageInExport = value
        }
    }
}

// MARK: - Supporting Types

enum ExportFormat: String, CaseIterable {
    case json = "JSON"
    case csv = "CSV"
    case txt = "TXT"
    case ase = "ASE"
    
    var displayName: String {
        switch self {
        case .json: return "JSON形式"
        case .csv: return "CSV形式"
        case .txt: return "テキスト形式"
        case .ase: return "Adobe Swatch Exchange"
        }
    }
    
    var fileExtension: String {
        return rawValue.lowercased()
    }
}