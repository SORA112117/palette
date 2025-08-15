//
//  StorageService.swift
//  palette
//
//  Created by Claude on 2025/08/14.
//

import Foundation
import SwiftUI
import CoreData

// MARK: - データ永続化サービス
@MainActor
class StorageService: ObservableObject {
    
    // MARK: - Singleton
    static let shared = StorageService()
    
    // MARK: - Properties
    @Published var savedPalettes: [ColorPalette] = []
    @Published var favoritesPalettes: [ColorPalette] = []
    
    private let userDefaults = UserDefaults.standard
    private let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    private let palettesDirectory: URL
    private let imagesDirectory: URL
    
    // MARK: - UserDefaults Keys
    private enum UserDefaultsKeys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let colorExtractionQuality = "colorExtractionQuality"
        static let defaultColorCount = "defaultColorCount"
        static let autoSavePalettes = "autoSavePalettes"
        static let hapticFeedbackEnabled = "hapticFeedbackEnabled"
        static let lastOpenedPaletteID = "lastOpenedPaletteID"
        static let appTheme = "appTheme"
    }
    
    // MARK: - Initialization
    private init() {
        // ディレクトリの作成
        palettesDirectory = documentsDirectory.appendingPathComponent("Palettes")
        imagesDirectory = documentsDirectory.appendingPathComponent("Images")
        
        createDirectoriesIfNeeded()
        loadAllPalettes()
    }
    
    // MARK: - Directory Management
    
    private func createDirectoriesIfNeeded() {
        do {
            try FileManager.default.createDirectory(at: palettesDirectory, withIntermediateDirectories: true)
            try FileManager.default.createDirectory(at: imagesDirectory, withIntermediateDirectories: true)
        } catch {
            print("ディレクトリ作成エラー: \(error)")
        }
    }
    
    // MARK: - Palette Management
    
    /// パレットを保存
    func savePalette(_ palette: ColorPalette) async throws {
        let fileName = "\(palette.id.uuidString).json"
        let fileURL = palettesDirectory.appendingPathComponent(fileName)
        
        // 画像データを別ファイルとして保存
        var modifiedPalette = palette
        if let imageData = palette.sourceImageData {
            let imageFileName = "\(palette.id.uuidString).jpg"
            let imageURL = imagesDirectory.appendingPathComponent(imageFileName)
            try imageData.write(to: imageURL)
            modifiedPalette = ColorPalette(
                id: palette.id,
                createdAt: palette.createdAt,
                sourceImageData: nil, // JSONには含めない
                colors: palette.colors,
                title: palette.title,
                tags: palette.tags
            )
        }
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(modifiedPalette)
        try data.write(to: fileURL)
        
        // メモリ上のリストも更新
        if let index = savedPalettes.firstIndex(where: { $0.id == palette.id }) {
            savedPalettes[index] = palette
        } else {
            savedPalettes.insert(palette, at: 0)
        }
        
        // 最大保存数を超えた場合、古いものを削除
        if savedPalettes.count > 100 {
            if let oldestPalette = savedPalettes.last {
                try await deletePalette(oldestPalette)
            }
        }
    }
    
    /// パレットを削除
    func deletePalette(_ palette: ColorPalette) async throws {
        let fileName = "\(palette.id.uuidString).json"
        let fileURL = palettesDirectory.appendingPathComponent(fileName)
        
        // ファイルを削除
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }
        
        // 関連画像も削除
        let imageFileName = "\(palette.id.uuidString).jpg"
        let imageURL = imagesDirectory.appendingPathComponent(imageFileName)
        if FileManager.default.fileExists(atPath: imageURL.path) {
            try FileManager.default.removeItem(at: imageURL)
        }
        
        // メモリ上のリストからも削除
        savedPalettes.removeAll { $0.id == palette.id }
        favoritesPalettes.removeAll { $0.id == palette.id }
    }
    
    /// すべてのパレットを読み込み
    func loadAllPalettes() {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: palettesDirectory,
                includingPropertiesForKeys: nil,
                options: .skipsHiddenFiles
            )
            
            let decoder = JSONDecoder()
            var palettes: [ColorPalette] = []
            
            for fileURL in fileURLs where fileURL.pathExtension == "json" {
                do {
                    let data = try Data(contentsOf: fileURL)
                    var palette = try decoder.decode(ColorPalette.self, from: data)
                    
                    // 関連画像を読み込み
                    let imageFileName = "\(palette.id.uuidString).jpg"
                    let imageURL = imagesDirectory.appendingPathComponent(imageFileName)
                    if FileManager.default.fileExists(atPath: imageURL.path) {
                        let imageData = try Data(contentsOf: imageURL)
                        palette = ColorPalette(
                            id: palette.id,
                            createdAt: palette.createdAt,
                            sourceImageData: imageData,
                            colors: palette.colors,
                            title: palette.title,
                            tags: palette.tags
                        )
                    }
                    
                    palettes.append(palette)
                } catch {
                    print("パレット読み込みエラー: \(error)")
                }
            }
            
            // 作成日時でソート（新しい順）
            savedPalettes = palettes.sorted { $0.createdAt > $1.createdAt }
            
        } catch {
            print("ディレクトリ読み込みエラー: \(error)")
        }
    }
    
    /// パレットをお気に入りに追加/削除
    func toggleFavorite(_ palette: ColorPalette) {
        if favoritesPalettes.contains(where: { $0.id == palette.id }) {
            favoritesPalettes.removeAll { $0.id == palette.id }
        } else {
            favoritesPalettes.append(palette)
        }
        saveFavoriteIDs()
    }
    
    private func saveFavoriteIDs() {
        let favoriteIDs = favoritesPalettes.map { $0.id.uuidString }
        userDefaults.set(favoriteIDs, forKey: "favoritePaletteIDs")
    }
    
    private func loadFavoriteIDs() {
        guard let favoriteIDs = userDefaults.stringArray(forKey: "favoritePaletteIDs") else { return }
        favoritesPalettes = savedPalettes.filter { palette in
            favoriteIDs.contains(palette.id.uuidString)
        }
    }
    
    // MARK: - User Preferences
    
    var hasCompletedOnboarding: Bool {
        get { userDefaults.bool(forKey: UserDefaultsKeys.hasCompletedOnboarding) }
        set { userDefaults.set(newValue, forKey: UserDefaultsKeys.hasCompletedOnboarding) }
    }
    
    var colorExtractionQuality: ColorExtractionQuality {
        get {
            let rawValue = userDefaults.string(forKey: UserDefaultsKeys.colorExtractionQuality) ?? "medium"
            return ColorExtractionQuality(rawValue: rawValue) ?? .medium
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: UserDefaultsKeys.colorExtractionQuality)
        }
    }
    
    var defaultColorCount: Int {
        get { userDefaults.integer(forKey: UserDefaultsKeys.defaultColorCount) == 0 ? 5 : userDefaults.integer(forKey: UserDefaultsKeys.defaultColorCount) }
        set { userDefaults.set(newValue, forKey: UserDefaultsKeys.defaultColorCount) }
    }
    
    var autoSavePalettes: Bool {
        get { userDefaults.bool(forKey: UserDefaultsKeys.autoSavePalettes) }
        set { userDefaults.set(newValue, forKey: UserDefaultsKeys.autoSavePalettes) }
    }
    
    var hapticFeedbackEnabled: Bool {
        get { 
            if userDefaults.object(forKey: UserDefaultsKeys.hapticFeedbackEnabled) == nil {
                return true // デフォルトでON
            }
            return userDefaults.bool(forKey: UserDefaultsKeys.hapticFeedbackEnabled)
        }
        set { userDefaults.set(newValue, forKey: UserDefaultsKeys.hapticFeedbackEnabled) }
    }
    
    var appTheme: AppTheme {
        get {
            let rawValue = userDefaults.string(forKey: UserDefaultsKeys.appTheme) ?? "system"
            return AppTheme(rawValue: rawValue) ?? .system
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: UserDefaultsKeys.appTheme)
        }
    }
    
    // MARK: - Search and Filter
    
    func searchPalettes(query: String) -> [ColorPalette] {
        guard !query.isEmpty else { return savedPalettes }
        
        return savedPalettes.filter { palette in
            // タイトルで検索
            if let title = palette.title, title.localizedCaseInsensitiveContains(query) {
                return true
            }
            // タグで検索
            if palette.tags.contains(where: { $0.localizedCaseInsensitiveContains(query) }) {
                return true
            }
            // 色の名前で検索
            if palette.colors.contains(where: { color in
                color.name?.localizedCaseInsensitiveContains(query) ?? false
            }) {
                return true
            }
            return false
        }
    }
    
    func filterPalettes(by filter: PaletteFilter) -> [ColorPalette] {
        switch filter {
        case .all:
            return savedPalettes
        case .favorites:
            return favoritesPalettes
        case .recent:
            let oneWeekAgo = Date().addingTimeInterval(-7 * 24 * 60 * 60)
            return savedPalettes.filter { $0.createdAt > oneWeekAgo }
        case .byTag(let tag):
            return savedPalettes.filter { $0.tags.contains(tag) }
        }
    }
    
    // MARK: - Export/Import
    
    func exportPalette(_ palette: ColorPalette) -> Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return try? encoder.encode(palette)
    }
    
    func importPalette(from data: Data) throws -> ColorPalette {
        let decoder = JSONDecoder()
        return try decoder.decode(ColorPalette.self, from: data)
    }
    
    // MARK: - Statistics
    
    func getPaletteStatistics() -> PaletteStatistics {
        let totalCount = savedPalettes.count
        let favoritesCount = favoritesPalettes.count
        let totalColors = savedPalettes.flatMap { $0.colors }.count
        let uniqueTags = Set(savedPalettes.flatMap { $0.tags }).count
        
        return PaletteStatistics(
            totalPalettes: totalCount,
            favoritePalettes: favoritesCount,
            totalColors: totalColors,
            uniqueTags: uniqueTags,
            oldestPalette: savedPalettes.last?.createdAt,
            newestPalette: savedPalettes.first?.createdAt
        )
    }
}

// MARK: - Supporting Types

enum ColorExtractionQuality: String, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    
    var displayName: String {
        switch self {
        case .low: return "低画質（高速）"
        case .medium: return "標準"
        case .high: return "高画質（低速）"
        }
    }
    
    var imageSize: CGFloat {
        switch self {
        case .low: return 256
        case .medium: return 512
        case .high: return 1024
        }
    }
}

enum AppTheme: String, CaseIterable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    var displayName: String {
        switch self {
        case .system: return "システム設定に従う"
        case .light: return "ライトモード"
        case .dark: return "ダークモード"
        }
    }
}

enum PaletteFilter {
    case all
    case favorites
    case recent
    case byTag(String)
}

struct PaletteStatistics {
    let totalPalettes: Int
    let favoritePalettes: Int
    let totalColors: Int
    let uniqueTags: Int
    let oldestPalette: Date?
    let newestPalette: Date?
}