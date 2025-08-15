//
//  NavigationRouter.swift
//  palette
//
//  Created by Claude on 2025/08/14.
//

import SwiftUI

// MARK: - ナビゲーションルーター
@MainActor
class NavigationRouter: ObservableObject {
    
    // MARK: - Navigation Paths
    @Published var homePath = NavigationPath()
    @Published var galleryPath = NavigationPath()
    @Published var settingsPath = NavigationPath()
    
    // MARK: - Sheet Presentations
    @Published var presentedSheet: SheetDestination?
    @Published var presentedFullScreenCover: FullScreenDestination?
    
    // MARK: - Tab Selection
    @Published var selectedTab: AppTab = .home
    
    // MARK: - Alert Management
    @Published var alertItem: AlertItem?
    
    // MARK: - Singleton
    static let shared = NavigationRouter()
    
    private init() {}
    
    // MARK: - Navigation Methods
    
    /// ホームタブに移動
    func navigateToHome() {
        selectedTab = .home
        homePath = NavigationPath()
    }
    
    /// ギャラリータブに移動
    func navigateToGallery() {
        selectedTab = .gallery
        galleryPath = NavigationPath()
    }
    
    /// 設定タブに移動
    func navigateToSettings() {
        selectedTab = .settings
        settingsPath = NavigationPath()
    }
    
    /// パレット詳細画面へ遷移
    func navigateToPaletteDetail(_ palette: ColorPalette, from tab: AppTab? = nil) {
        if let tab = tab {
            selectedTab = tab
        }
        
        switch selectedTab {
        case .home:
            homePath.append(NavigationDestination.paletteDetail(palette))
        case .gallery:
            galleryPath.append(NavigationDestination.paletteDetail(palette))
        case .settings:
            settingsPath.append(NavigationDestination.paletteDetail(palette))
        }
    }
    
    /// 色抽出画面をモーダル表示
    func presentColorExtraction(image: UIImage) {
        presentedFullScreenCover = .colorExtraction(image)
    }
    
    /// パレット編集画面をモーダル表示
    func presentPaletteEditor(palette: ColorPalette) {
        presentedSheet = .paletteEditor(palette)
    }
    
    /// 壁紙作成画面をモーダル表示
    func presentWallpaperCreator(palette: ColorPalette) {
        presentedFullScreenCover = .wallpaperCreator(palette)
    }
    
    /// シェアシートを表示
    func presentShareSheet(items: [Any]) {
        presentedSheet = .share(items)
    }
    
    /// アラートを表示
    func showAlert(_ alert: AlertItem) {
        alertItem = alert
    }
    
    /// すべてのモーダルを閉じる
    func dismissAllModals() {
        presentedSheet = nil
        presentedFullScreenCover = nil
    }
    
    /// 現在のナビゲーションスタックをリセット
    func resetCurrentNavigationStack() {
        switch selectedTab {
        case .home:
            homePath = NavigationPath()
        case .gallery:
            galleryPath = NavigationPath()
        case .settings:
            settingsPath = NavigationPath()
        }
    }
}

// MARK: - Navigation Destinations

enum AppTab: String, CaseIterable {
    case home = "home"
    case gallery = "gallery"
    case settings = "settings"
    
    var title: String {
        switch self {
        case .home: return "ホーム"
        case .gallery: return "ギャラリー"
        case .settings: return "設定"
        }
    }
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .gallery: return "rectangle.stack.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

enum NavigationDestination: Hashable {
    case paletteDetail(ColorPalette)
    case taggedPalettes(String)
    case about
    case privacyPolicy
    case terms
    case licenses
}

enum SheetDestination: Identifiable {
    case paletteEditor(ColorPalette)
    case colorPicker(Binding<Color>)
    case tagEditor([String])
    case share([Any])
    case imagePicker
    
    var id: String {
        switch self {
        case .paletteEditor: return "paletteEditor"
        case .colorPicker: return "colorPicker"
        case .tagEditor: return "tagEditor"
        case .share: return "share"
        case .imagePicker: return "imagePicker"
        }
    }
}

enum FullScreenDestination: Identifiable {
    case colorExtraction(UIImage)
    case wallpaperCreator(ColorPalette)
    case onboarding
    case camera
    
    var id: String {
        switch self {
        case .colorExtraction: return "colorExtraction"
        case .wallpaperCreator: return "wallpaperCreator"
        case .onboarding: return "onboarding"
        case .camera: return "camera"
        }
    }
}

// MARK: - Alert Item

struct AlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String?
    let primaryButton: Alert.Button
    let secondaryButton: Alert.Button?
    
    init(
        title: String,
        message: String? = nil,
        primaryButton: Alert.Button = .default(Text("OK")),
        secondaryButton: Alert.Button? = nil
    ) {
        self.title = title
        self.message = message
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
    }
    
    static func error(_ error: Error) -> AlertItem {
        AlertItem(
            title: "エラー",
            message: error.localizedDescription,
            primaryButton: .default(Text("OK"))
        )
    }
    
    static func deleteConfirmation(onDelete: @escaping () -> Void) -> AlertItem {
        AlertItem(
            title: "削除の確認",
            message: "このパレットを削除してもよろしいですか？",
            primaryButton: .destructive(Text("削除")) {
                onDelete()
            },
            secondaryButton: .cancel(Text("キャンセル"))
        )
    }
}