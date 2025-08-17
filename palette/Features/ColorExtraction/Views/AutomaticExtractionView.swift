//
//  AutomaticExtractionView.swift
//  palette
//
//  Created by Claude on 2025/08/15.
//

import SwiftUI
import PhotosUI

// MARK: - 自動色抽出画面
struct AutomaticExtractionView: View {
    
    // MARK: - State
    @StateObject private var viewModel = AutomaticExtractionViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.diContainer) private var diContainer
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // ヘッダー
            headerSection
            
            // メインコンテンツ
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: SmartTheme.spacingL) {
                    if let selectedImage = viewModel.selectedImage {
                        imageDisplaySection(selectedImage)
                        colorCountSelectionSection
                        
                        if viewModel.isExtracting {
                            extractionProgressSection
                        } else if !viewModel.extractedColors.isEmpty {
                            extractedColorsSection
                            actionButtonsSection
                        } else {
                            extractionButtonSection
                        }
                    } else {
                        imageSelectionSection
                    }
                }
                .padding(.horizontal, SmartTheme.spacingL)
                .padding(.bottom, SmartTheme.spacingXL)
            }
        }
        .background(Color.surfaceSecondary.opacity(0.3))
        .navigationTitle("自動抽出")
        .navigationBarTitleDisplayMode(.inline)
        .photosPicker(
            isPresented: $viewModel.showingImagePicker,
            selection: $viewModel.selectedPhotoItem,
            matching: .images,
            photoLibrary: .shared()
        )
        .onChange(of: viewModel.selectedImage) { _, newImage in
            // 画像選択時の自動処理
            if newImage != nil {
                viewModel.resetExtraction()
            }
        }
        .alert("パレットに名前を付けてください", isPresented: $viewModel.showingNameInputAlert) {
            TextField("パレット名", text: $viewModel.paletteName)
                .smartText(.body)
            
            Button("保存") {
                viewModel.savePaletteWithName()
            }
            Button("キャンセル", role: .cancel) {
                viewModel.paletteName = ""
            }
        } message: {
            Text("空白の場合は「自動抽出パレット(\(viewModel.selectedColorCount)色)」として保存されます")
                .smartText(.caption)
        }
        .alert("パレット作成完了", isPresented: $viewModel.showingCompletionAlert) {
            Button("ギャラリーで確認") {
                NavigationRouter.shared.navigateToGallery()
                // ギャラリーに移動するのでhomePathをクリア
                diContainer.navigationRouter.homePath = NavigationPath()
            }
            Button("閉じる") {
                // NavigationStackコンテキストでは、NavigationPathから最後の要素を削除
                if !diContainer.navigationRouter.homePath.isEmpty {
                    diContainer.navigationRouter.homePath.removeLast()
                }
            }
        } message: {
            Text("選択した設定でパレットを作成しました")
        }
        .errorAlert(error: Binding<Error?>(
            get: { viewModel.errorMessage.map { NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: $0]) } },
            set: { _ in viewModel.clearError() }
        ))
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            Button("キャンセル") {
                // NavigationStackコンテキストでは、NavigationPathから最後の要素を削除
                if !diContainer.navigationRouter.homePath.isEmpty {
                    diContainer.navigationRouter.homePath.removeLast()
                }
            }
            .smartText(.bodySecondary)
            
            Spacer()
            
            if viewModel.selectedImage != nil {
                Button("画像を変更") {
                    viewModel.selectDifferentImage()
                }
                .smartText(.body)
            }
        }
        .padding(.horizontal, SmartTheme.spacingL)
        .padding(.vertical, SmartTheme.spacingM)
        .background(Color.surfacePrimary.shadow(color: SmartTheme.shadowColor, radius: 2, y: 1))
    }
    
    // MARK: - Image Selection Section
    private var imageSelectionSection: some View {
        VStack(spacing: SmartTheme.spacingL) {
            Spacer()
            
            Image(systemName: "wand.and.stars")
                .font(.system(size: 64, weight: .light))
                .foregroundColor(.iconSecondary)
            
            VStack(spacing: SmartTheme.spacingM) {
                Text("画像を選択してください")
                    .smartText(.title)
                
                Text("選択した画像から自動的に\n主要な色を抽出します")
                    .smartText(.bodySecondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("画像を選択") {
                viewModel.selectImage()
            }
            .padding(.horizontal, SmartTheme.spacingL)
            .padding(.vertical, SmartTheme.spacingM)
            .background(Color.smartBlack)
            .foregroundColor(.white)
            .cornerRadius(SmartTheme.cornerRadiusMedium)
            .smartText(.body)
            
            Spacer()
        }
    }
    
    // MARK: - Image Display Section
    private func imageDisplaySection(_ image: UIImage) -> some View {
        VStack(spacing: SmartTheme.spacingM) {
            Text("選択された画像")
                .smartText(.subtitle)
            
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 250)
                .cornerRadius(SmartTheme.cornerRadiusLarge)
                .shadow(color: SmartTheme.shadowColor, radius: SmartTheme.shadowRadius, y: 4)
        }
    }
    
    // MARK: - Color Count Selection Section
    private var colorCountSelectionSection: some View {
        VStack(alignment: .leading, spacing: SmartTheme.spacingM) {
            Text("抽出する色数: \(viewModel.selectedColorCount)色")
                .smartText(.subtitle)
            
            Text("多いほど詳細な色分析ができますが、処理に時間がかかります")
                .smartText(.caption)
            
            // カスタムスライダー
            VStack(spacing: SmartTheme.spacingS) {
                HStack {
                    Text("3")
                        .smartText(.caption)
                    Spacer()
                    Text("10")
                        .smartText(.caption)
                }
                
                Slider(
                    value: Binding<Double>(
                        get: { Double(viewModel.selectedColorCount) },
                        set: { viewModel.selectedColorCount = Int($0) }
                    ),
                    in: 3...10,
                    step: 1
                )
                .tint(Color.smartBlack)
            }
            
            // 色数プリセット
            HStack(spacing: SmartTheme.spacingS) {
                ForEach([3, 5, 7, 10], id: \.self) { count in
                    Button("\(count)") {
                        viewModel.selectedColorCount = count
                        HapticManager.shared.selectionChanged()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        viewModel.selectedColorCount == count 
                        ? Color.smartBlack 
                        : Color.surfaceSecondary
                    )
                    .foregroundColor(
                        viewModel.selectedColorCount == count 
                        ? .white 
                        : .textSecondary
                    )
                    .cornerRadius(SmartTheme.cornerRadiusSmall)
                    .font(.system(size: 14, weight: .medium))
                }
                
                Spacer()
            }
        }
        .padding(SmartTheme.spacingL)
        .smartCard(elevation: .medium)
    }
    
    // MARK: - Extraction Button Section
    private var extractionButtonSection: some View {
        Button("色を抽出開始") {
            Task {
                await viewModel.extractColors()
            }
        }
        .padding(.horizontal, SmartTheme.spacingL)
        .padding(.vertical, SmartTheme.spacingM)
        .background(Color.smartBlack)
        .foregroundColor(.white)
        .cornerRadius(SmartTheme.cornerRadiusMedium)
        .smartText(.body)
        .shadow(color: Color.smartBlack.opacity(0.3), radius: 8, y: 4)
    }
    
    // MARK: - Extraction Progress Section
    private var extractionProgressSection: some View {
        VStack(spacing: SmartTheme.spacingL) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(Color.smartBlack)
            
            Text("色を分析中...")
                .smartText(.subtitle)
            
            Text("画像から主要な色を抽出しています")
                .smartText(.bodySecondary)
            
            ProgressView(value: viewModel.extractionProgress)
                .tint(Color.smartBlack)
                .frame(maxWidth: 200)
        }
        .padding(SmartTheme.spacingXL)
        .smartCard(elevation: .medium)
    }
    
    // MARK: - Extracted Colors Section
    private var extractedColorsSection: some View {
        VStack(alignment: .leading, spacing: SmartTheme.spacingM) {
            Text("抽出された色 (\(viewModel.extractedColors.count)色)")
                .smartText(.subtitle)
            
            // 色の一覧表示
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 80))
            ], spacing: SmartTheme.spacingM) {
                ForEach(viewModel.extractedColors) { color in
                    VStack(spacing: SmartTheme.spacingS) {
                        Circle()
                            .fill(color.color)
                            .frame(width: 64, height: 64)
                            .overlay(
                                Circle()
                                    .stroke(Color.borderPrimary, lineWidth: 2)
                            )
                        
                        VStack(spacing: 2) {
                            Text(color.hexCode)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.textPrimary)
                            
                            Text("\(color.percentage, specifier: "%.1f")%")
                                .font(.system(size: 10, weight: .regular))
                                .foregroundColor(.textTertiary)
                        }
                    }
                }
            }
            
            // グラデーションプレビュー
            LinearGradient(
                colors: viewModel.extractedColors.map { $0.color },
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 60)
            .cornerRadius(SmartTheme.cornerRadiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: SmartTheme.cornerRadiusMedium)
                    .stroke(Color.borderPrimary, lineWidth: 1)
            )
        }
        .padding(SmartTheme.spacingL)
        .smartCard(elevation: .medium)
    }
    
    // MARK: - Action Buttons Section
    private var actionButtonsSection: some View {
        HStack(spacing: SmartTheme.spacingM) {
            Button("再抽出") {
                Task {
                    await viewModel.extractColors()
                }
            }
            .padding(.horizontal, SmartTheme.spacingL)
            .padding(.vertical, SmartTheme.spacingM)
            .background(Color.surfaceSecondary)
            .foregroundColor(.textSecondary)
            .cornerRadius(SmartTheme.cornerRadiusMedium)
            .smartText(.bodySecondary)
            
            Button("パレット保存") {
                viewModel.savePalette()
            }
            .padding(.horizontal, SmartTheme.spacingL)
            .padding(.vertical, SmartTheme.spacingM)
            .background(Color.smartBlack)
            .foregroundColor(.white)
            .cornerRadius(SmartTheme.cornerRadiusMedium)
            .smartText(.body)
        }
    }
}

// MARK: - View Model
@MainActor
class AutomaticExtractionViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var showingImagePicker = false
    @Published var selectedColorCount: Int = 5
    @Published var isExtracting = false
    @Published var extractionProgress: Double = 0.0
    @Published var extractedColors: [ExtractedColor] = []
    @Published var showingCompletionAlert = false
    @Published var showingNameInputAlert = false
    @Published var paletteName = ""
    @Published var errorMessage: String?
    
    private let colorExtractionService = ColorExtractionService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // PhotosPickerItemの変更を監視
        $selectedPhotoItem
            .compactMap { $0 }
            .sink { item in
                Task { @MainActor in
                    if let imageData = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: imageData) {
                        self.selectedImage = image
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func selectImage() {
        showingImagePicker = true
    }
    
    func selectDifferentImage() {
        selectedImage = nil
        extractedColors.removeAll()
        showingImagePicker = true
    }
    
    func resetExtraction() {
        extractedColors.removeAll()
        isExtracting = false
        extractionProgress = 0.0
    }
    
    func extractColors() async {
        guard let image = selectedImage else { return }
        
        isExtracting = true
        extractionProgress = 0.0
        errorMessage = nil
        
        // プログレスアニメーション
        let progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            Task { @MainActor in
                if self.extractionProgress < 0.9 {
                    self.extractionProgress += 0.05
                } else {
                    timer.invalidate()
                }
            }
        }
        
        do {
            let colors = try await colorExtractionService.extractColors(
                from: image,
                colorCount: selectedColorCount
            )
            
            progressTimer.invalidate()
            extractionProgress = 1.0
            
            // 少し遅延を入れてから結果表示
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            
            extractedColors = colors
            isExtracting = false
            
            HapticManager.shared.success()
            
        } catch {
            progressTimer.invalidate()
            isExtracting = false
            extractionProgress = 0.0
            errorMessage = "色の抽出に失敗しました: \(error.localizedDescription)"
            
            HapticManager.shared.error()
        }
    }
    
    func savePalette() {
        guard !extractedColors.isEmpty else { return }
        paletteName = "" // リセット
        showingNameInputAlert = true
    }
    
    func savePaletteWithName() {
        guard !extractedColors.isEmpty, let image = selectedImage else { return }
        
        let finalName = paletteName.trimmingCharacters(in: .whitespacesAndNewlines)
        let paletteTitle = finalName.isEmpty ? "自動抽出パレット(\(selectedColorCount)色)" : finalName
        
        let palette = ColorPalette(
            sourceImageData: image.jpegData(compressionQuality: 0.8),
            colors: extractedColors,
            title: paletteTitle,
            tags: ["自動抽出", "\(selectedColorCount)色"]
        )
        
        Task {
            do {
                try await StorageService.shared.savePalette(palette)
                showingCompletionAlert = true
                HapticManager.shared.paletteSaved()
            } catch {
                errorMessage = "パレットの保存に失敗しました"
                HapticManager.shared.error()
            }
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
}

import Combine

// MARK: - Preview
#Preview {
    NavigationStack {
        AutomaticExtractionView()
            .withDependencies(DIContainer.shared)
    }
}