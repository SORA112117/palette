//
//  HomeViewModel.swift
//  palette
//
//  Created by Claude on 2025/08/14.
//

import Foundation
import SwiftUI
import PhotosUI
import Combine

// MARK: - ホーム画面ViewModel
@MainActor
class HomeViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var recentPalettes: [ColorPalette] = []
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingImagePicker = false
    @Published var showingColorExtraction = false
    @Published var showingGallery = false
    @Published var selectedImage: UIImage?
    
    // MARK: - Services
    private let colorExtractionService = ColorExtractionService()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        loadRecentPalettes()
        setupPhotoItemObserver()
    }
    
    // MARK: - Public Methods
    
    /// 最近のパレットを読み込む
    func loadRecentPalettes() {
        // TODO: CoreDataやUserDefaultsから実際のデータを読み込む
        // 現在はサンプルデータを使用
        recentPalettes = Array(ColorPalette.samplePalettes.prefix(3))
    }
    
    /// 写真ライブラリから画像を選択
    func selectPhotoFromLibrary() {
        showingImagePicker = true
    }
    
    /// カメラで撮影
    func takePhoto() {
        // TODO: カメラ機能の実装
        // 現在は写真ライブラリを開く
        showingImagePicker = true
    }
    
    /// ギャラリーを表示
    func showGallery() {
        showingGallery = true
    }
    
    /// パレットから色抽出画面へ遷移
    func extractColorsFromPalette(_ palette: ColorPalette) {
        // TODO: パレット詳細画面への遷移
    }
    
    /// エラーメッセージをクリア
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Private Methods
    
    /// 選択された写真アイテムの監視設定
    private func setupPhotoItemObserver() {
        $selectedPhotoItem
            .compactMap { $0 }
            .sink { [weak self] photoItem in
                Task {
                    await self?.processSelectedPhoto(photoItem)
                }
            }
            .store(in: &cancellables)
    }
    
    /// 選択された写真を処理
    private func processSelectedPhoto(_ photoItem: PhotosPickerItem) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            guard let imageData = try await photoItem.loadTransferable(type: Data.self),
                  let image = UIImage(data: imageData) else {
                throw HomeError.imageLoadFailed
            }
            
            selectedImage = image
            showingColorExtraction = true
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - HomeError
enum HomeError: LocalizedError {
    case imageLoadFailed
    case colorExtractionFailed
    
    var errorDescription: String? {
        switch self {
        case .imageLoadFailed:
            return "画像の読み込みに失敗しました"
        case .colorExtractionFailed:
            return "色の抽出に失敗しました"
        }
    }
}