//
//  ServiceProtocols.swift
//  palette
//
//  Created by Claude on 2025/08/17.
//

import Foundation
import SwiftUI
import UIKit

// MARK: - Service Protocols

/// ストレージサービスプロトコル
@MainActor
protocol StorageServiceProtocol: AnyObject {
    var savedPalettes: [ColorPalette] { get }
    var favoritesPalettes: [ColorPalette] { get }
    var hapticFeedbackEnabled: Bool { get set }
    
    func savePalette(_ palette: ColorPalette) async throws
    func deletePalette(_ palette: ColorPalette) async throws
    func loadAllPalettes()
    func toggleFavorite(_ palette: ColorPalette)
    func getCacheSize() async -> Int
    func clearCache() async
    func clearAllData() async
}

/// ナビゲーションルータープロトコル
@MainActor
protocol NavigationRouterProtocol: ObservableObject {
    var selectedTab: AppTab { get set }
    var homePath: NavigationPath { get set }
    var galleryPath: NavigationPath { get set }
    var settingsPath: NavigationPath { get set }
    var presentedSheet: SheetDestination? { get set }
    var presentedFullScreenCover: FullScreenDestination? { get set }
    var alertItem: AlertItem? { get set }
    
    func navigateToHome()
    func navigateToGallery()
    func navigateToSettings()
    func navigateToPaletteDetail(_ palette: ColorPalette, from tab: AppTab?)
    func presentColorExtraction(image: UIImage)
    func presentPaletteEditor(palette: ColorPalette)
    func presentWallpaperCreator(palette: ColorPalette)
    func presentShareSheet(items: [Any])
    func showAlert(_ alert: AlertItem)
    func dismissAllModals()
    func resetCurrentNavigationStack()
}

/// ハプティックフィードバックプロトコル
@MainActor
protocol HapticProviding: AnyObject {
    func lightImpact()
    func mediumImpact()
    func heavyImpact()
    func selectionChanged()
    func success()
    func warning()
    func error()
    func colorSelection()
    func paletteSaved()
}

/// 色抽出サービスプロトコル
protocol ColorExtractionProviding: AnyObject {
    func extractColors(from image: UIImage, colorCount: Int) async throws -> [ExtractedColor]
}

// MARK: - Configuration Protocol

/// アプリ設定プロトコル
@MainActor
protocol AppConfigurationProviding {
    var hapticFeedbackEnabled: Bool { get set }
    var autoSavePalettes: Bool { get set }
    var appTheme: AppTheme { get set }
    var defaultColorCount: Int { get set }
}