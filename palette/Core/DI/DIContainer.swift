//
//  DIContainer.swift
//  palette
//
//  Created by Claude on 2025/08/17.
//

import Foundation
import SwiftUI
import UIKit

// MARK: - 依存性注入コンテナ
@MainActor
final class DIContainer: ObservableObject {
    
    // MARK: - Singleton
    static let shared = DIContainer()
    
    // MARK: - Core Services
    let appConfiguration: AppConfigurationService
    let storageService: any StorageServiceProtocol
    let hapticManager: any HapticProviding
    let colorExtractionService: any ColorExtractionProviding
    let navigationRouter: any NavigationRouterProtocol
    
    // MARK: - Initialization
    private init() {
        // 1. 設定サービスを最初に初期化（他のサービスが依存するため）
        self.appConfiguration = AppConfigurationService()
        
        // 2. 既存のハプティックマネージャーを使用（互換性のため）
        self.hapticManager = HapticManager.shared
        
        // 3. ナビゲーションルーターを初期化（既存のシングルトンを使用）
        self.navigationRouter = NavigationRouter.shared
        
        // 4. ストレージサービスを初期化（既存のシングルトンを使用）
        self.storageService = StorageService.shared
        
        // 5. 既存の色抽出サービスを使用
        self.colorExtractionService = ColorExtractionService()
        
        // 6. サービス間の相互依存を設定
        setupServiceDependencies()
    }
    
    // MARK: - Service Dependencies Setup
    
    private func setupServiceDependencies() {
        // 将来的にサービス間の相互依存がある場合はここで設定
        // 例: navigationRouter.setStorageService(storageService)
    }
    
    // MARK: - Factory Methods
    
    /// HomeViewModelを作成
    func makeHomeViewModel() -> HomeViewModel {
        return HomeViewModel(
            storageService: storageService,
            navigationRouter: navigationRouter,
            hapticProvider: hapticManager,
            appConfiguration: appConfiguration
        )
    }
    
    /// GalleryViewModelを作成
    func makeGalleryViewModel() -> GalleryViewModel {
        return GalleryViewModel()
    }
    
    /// ColorExtractionViewModelを作成
    func makeColorExtractionViewModel(sourceImage: UIImage) -> ColorExtractionViewModel {
        return ColorExtractionViewModel(sourceImage: sourceImage)
    }
    
    // MARK: - Service Access Methods
    
    /// 現在のアプリテーマを取得
    var currentTheme: AppTheme {
        appConfiguration.appTheme
    }
    
    /// ハプティックフィードバックが有効かどうか
    var isHapticFeedbackEnabled: Bool {
        appConfiguration.hapticFeedbackEnabled
    }
    
    /// デフォルトの色数を取得
    var defaultColorCount: Int {
        appConfiguration.defaultColorCount
    }
    
    // MARK: - Lifecycle Methods
    
    /// アプリ起動時の初期化処理
    func initializeApp() {
        storageService.loadAllPalettes()
    }
    
    /// アプリ終了時のクリーンアップ処理
    func cleanup() {
        // 必要に応じてクリーンアップ処理を実行
        // 例: キャッシュの保存、一時ファイルの削除など
    }
}

// MARK: - SwiftUI Environment Support

/// DIContainerをEnvironmentで提供するためのKey
struct DIContainerKey: EnvironmentKey {
    @MainActor static let defaultValue: DIContainer = DIContainer.shared
}

extension EnvironmentValues {
    var diContainer: DIContainer {
        get { self[DIContainerKey.self] }
        set { self[DIContainerKey.self] = newValue }
    }
}

// MARK: - View Extensions for DI

extension View {
    /// DIContainerを環境に注入
    @MainActor
    func withDependencies(_ container: DIContainer = DIContainer.shared) -> some View {
        self.environment(\.diContainer, container)
    }
}

// MARK: - ViewModel Factory Protocol

/// ViewModelを作成するためのファクトリープロトコル
@MainActor
protocol ViewModelFactory {
    func makeHomeViewModel() -> HomeViewModel
    func makeGalleryViewModel() -> GalleryViewModel
    func makeColorExtractionViewModel(sourceImage: UIImage) -> ColorExtractionViewModel
}

extension DIContainer: ViewModelFactory {}

// MARK: - Service Locator Pattern Support

/// サービスロケーターパターンでサービスにアクセスするためのヘルパー
enum ServiceLocator {
    
    @MainActor
    static var shared: DIContainer {
        DIContainer.shared
    }
    
    @MainActor
    static var storageService: any StorageServiceProtocol {
        shared.storageService
    }
    
    @MainActor
    static var hapticManager: any HapticProviding {
        shared.hapticManager
    }
    
    @MainActor
    static var navigationRouter: any NavigationRouterProtocol {
        shared.navigationRouter
    }
    
    @MainActor
    static var appConfiguration: any AppConfigurationProviding {
        shared.appConfiguration
    }
    
    @MainActor
    static var colorExtractionService: any ColorExtractionProviding {
        shared.colorExtractionService
    }
}