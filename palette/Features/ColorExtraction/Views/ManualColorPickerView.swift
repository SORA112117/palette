//
//  ManualColorPickerView.swift
//  palette
//
//  Created by Claude on 2025/08/15.
//

import SwiftUI
import PhotosUI
import UIKit
import Combine

// MARK: - 手動カラーピッカー画面
struct ManualColorPickerView: View {
    
    // MARK: - State
    @StateObject private var viewModel = ManualColorPickerViewModel()
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // ヘッダー
            headerSection
            
            // メインコンテンツ
            if let selectedImage = viewModel.selectedImage {
                imagePickerSection(selectedImage)
            } else {
                imageSelectionSection
            }
            
            // ボトムセクション
            if !viewModel.selectedColors.isEmpty {
                bottomSection
            }
        }
        .background(Color.backgroundPrimary)
        .navigationTitle("手動ピッカー")
        .navigationBarTitleDisplayMode(.inline)
        .photosPicker(
            isPresented: $viewModel.showingImagePicker,
            selection: $viewModel.selectedPhotoItem,
            matching: .images,
            photoLibrary: .shared()
        )
        .onChange(of: viewModel.selectedImage) { _, newImage in
            // 画像選択時の処理
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
            Text("空白の場合は「手動選択パレット」として保存されます")
                .smartText(.caption)
        }
        .alert("パレット作成完了", isPresented: $viewModel.showingCompletionAlert) {
            Button("ギャラリーで確認") {
                NavigationRouter.shared.navigateToGallery()
                dismiss()
            }
            Button("閉じる") {
                dismiss()
            }
        } message: {
            Text("選択した色でパレットを作成しました")
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            Button("キャンセル") {
                dismiss()
            }
            .smartText(.bodySecondary)
            
            Spacer()
            
            if !viewModel.selectedColors.isEmpty {
                Button("完了") {
                    viewModel.createPaletteFromSelectedColors()
                }
                .smartButton(style: .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.smartBlack)
                .foregroundColor(.white)
                .cornerRadius(SmartTheme.cornerRadiusMedium)
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
            
            Image(systemName: "photo.badge.plus")
                .font(.system(size: 64, weight: .light))
                .foregroundColor(.iconSecondary)
            
            VStack(spacing: SmartTheme.spacingM) {
                Text("画像を選択してください")
                    .smartText(.title)
                
                Text("選択した画像内の好きな場所をタップして\n色を抽出できます")
                    .smartText(.bodySecondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("画像を選択") {
                viewModel.selectImage()
            }
            .smartButton(style: .primary)
            .padding(.horizontal, SmartTheme.spacingL)
            .padding(.vertical, SmartTheme.spacingM)
            
            Spacer()
        }
    }
    
    // MARK: - Image Picker Section
    private func imagePickerSection(_ image: UIImage) -> some View {
        VStack(spacing: 0) {
            // 説明テキスト
            VStack(spacing: SmartTheme.spacingS) {
                Text("画像をタップして色を選択")
                    .smartText(.title)
                
                Text("選択した色: \(viewModel.selectedColors.count)個")
                    .smartText(.bodySecondary)
            }
            .padding(.horizontal, SmartTheme.spacingL)
            .padding(.bottom, SmartTheme.spacingM)
            
            // インタラクティブ画像
            InteractiveImageView(
                image: image,
                selectedPoints: $viewModel.selectedPoints,
                onColorSelected: { color in
                    viewModel.addSelectedColor(color)
                }
            )
            .aspectRatio(contentMode: .fit)
            .cornerRadius(SmartTheme.cornerRadiusLarge)
            .padding(.horizontal, SmartTheme.spacingL)
        }
    }
    
    // MARK: - Bottom Section
    private var bottomSection: some View {
        VStack(spacing: SmartTheme.spacingM) {
            // 選択された色の表示
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: SmartTheme.spacingM) {
                    ForEach(Array(viewModel.selectedColors.enumerated()), id: \.offset) { index, color in
                        VStack(spacing: SmartTheme.spacingS) {
                            Circle()
                                .fill(color)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .stroke(Color.borderPrimary, lineWidth: 2)
                                )
                                .overlay(
                                    Button {
                                        viewModel.removeColor(at: index)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(.white)
                                            .background(Circle().fill(Color.smartError))
                                    }
                                    .offset(x: 16, y: -16)
                                )
                            
                            Text(color.hexString)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.textTertiary)
                        }
                    }
                }
                .padding(.horizontal, SmartTheme.spacingL)
            }
            
            // アクションボタン
            HStack(spacing: SmartTheme.spacingM) {
                Button("リセット") {
                    viewModel.resetSelection()
                }
                .padding(.horizontal, SmartTheme.spacingL)
                .padding(.vertical, SmartTheme.spacingM)
                .background(Color.surfaceSecondary)
                .foregroundColor(.textSecondary)
                .cornerRadius(SmartTheme.cornerRadiusMedium)
                .smartText(.bodySecondary)
                
                Button("パレット作成") {
                    viewModel.createPaletteFromSelectedColors()
                }
                .smartButton(style: .primary)
                .padding(.horizontal, SmartTheme.spacingL)
                .padding(.vertical, SmartTheme.spacingM)
            }
        }
        .padding(.vertical, SmartTheme.spacingL)
        .background(Color.surfacePrimary)
        .shadow(color: SmartTheme.shadowColor, radius: 4, x: 0, y: -2)
    }
}

// MARK: - Interactive Image View
struct InteractiveImageView: View {
    let image: UIImage
    @Binding var selectedPoints: [CGPoint]
    let onColorSelected: (Color) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipped()
                
                // 選択ポイントの表示
                ForEach(Array(selectedPoints.enumerated()), id: \.offset) { index, point in
                    PointMarker(index: index, point: point)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { location in
                handleTap(at: location, in: geometry)
            }
        }
    }
    
    private func handleTap(at location: CGPoint, in geometry: GeometryProxy) {
        selectedPoints.append(location)
        
        // 画像の該当位置から色を取得
        let imageSize = image.size
        let viewSize = geometry.size
        
        // アスペクト比を考慮した位置計算
        let imageAspect = imageSize.width / imageSize.height
        let viewAspect = viewSize.width / viewSize.height
        
        var actualImageRect: CGRect
        
        if imageAspect > viewAspect {
            // 画像が横長の場合
            let scaledHeight = viewSize.width / imageAspect
            actualImageRect = CGRect(
                x: 0,
                y: (viewSize.height - scaledHeight) / 2,
                width: viewSize.width,
                height: scaledHeight
            )
        } else {
            // 画像が縦長の場合
            let scaledWidth = viewSize.height * imageAspect
            actualImageRect = CGRect(
                x: (viewSize.width - scaledWidth) / 2,
                y: 0,
                width: scaledWidth,
                height: viewSize.height
            )
        }
        
        // 相対位置を計算
        let relativeX = (location.x - actualImageRect.minX) / actualImageRect.width
        let relativeY = (location.y - actualImageRect.minY) / actualImageRect.height
        
        // 画像内の座標に変換
        let imageX = relativeX * imageSize.width
        let imageY = relativeY * imageSize.height
        
        // 色を抽出
        if let color = image.getPixelColor(at: CGPoint(x: imageX, y: imageY)) {
            onColorSelected(color)
        }
    }
}

// MARK: - Point Marker
struct PointMarker: View {
    let index: Int
    let point: CGPoint
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 24, height: 24)
            
            Circle()
                .stroke(Color.smartBlack, lineWidth: 3)
                .frame(width: 24, height: 24)
            
            Text("\(index + 1)")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.smartBlack)
        }
        .position(point)
        .animation(.spring(response: 0.3), value: point)
    }
}

// MARK: - View Model
@MainActor
class ManualColorPickerViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var showingImagePicker = false
    @Published var selectedColors: [Color] = []
    @Published var selectedPoints: [CGPoint] = []
    @Published var showingCompletionAlert = false
    @Published var showingNameInputAlert = false
    @Published var paletteName = ""
    
    func selectImage() {
        showingImagePicker = true
    }
    
    func addSelectedColor(_ color: Color) {
        selectedColors.append(color)
        HapticManager.shared.colorSelection()
    }
    
    func removeColor(at index: Int) {
        if index < selectedColors.count {
            selectedColors.remove(at: index)
            selectedPoints.remove(at: index)
            HapticManager.shared.lightImpact()
        }
    }
    
    func resetSelection() {
        selectedColors.removeAll()
        selectedPoints.removeAll()
        HapticManager.shared.mediumImpact()
    }
    
    func createPaletteFromSelectedColors() {
        guard !selectedColors.isEmpty else { return }
        paletteName = "" // リセット
        showingNameInputAlert = true
    }
    
    func savePaletteWithName() {
        guard !selectedColors.isEmpty else { return }
        
        let finalName = paletteName.trimmingCharacters(in: .whitespacesAndNewlines)
        let paletteTitle = finalName.isEmpty ? "手動選択パレット" : finalName
        
        let extractedColors = selectedColors.enumerated().map { index, color in
            ExtractedColor(
                hexCode: color.hexString,
                rgb: color.rgbColor,
                hsl: color.hslColor,
                percentage: 100.0 / Double(selectedColors.count), // 均等に分配
                name: "選択色\(index + 1)"
            )
        }
        
        let palette = ColorPalette(
            sourceImageData: selectedImage?.jpegData(compressionQuality: 0.8),
            colors: extractedColors,
            title: paletteTitle,
            tags: ["手動選択"]
        )
        
        Task {
            try? await StorageService.shared.savePalette(palette)
            showingCompletionAlert = true
            HapticManager.shared.success()
        }
    }
    
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
    
    private var cancellables = Set<AnyCancellable>()
}

// MARK: - Extensions
extension UIImage {
    func getPixelColor(at point: CGPoint) -> Color? {
        guard let cgImage = self.cgImage,
              let dataProvider = cgImage.dataProvider,
              let data = dataProvider.data,
              let bytes = CFDataGetBytePtr(data) else {
            return nil
        }
        
        let x = Int(point.x)
        let y = Int(point.y)
        
        guard x >= 0 && x < Int(size.width) && y >= 0 && y < Int(size.height) else {
            return nil
        }
        
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * Int(size.width)
        let byteIndex = (bytesPerRow * y) + (x * bytesPerPixel)
        
        let r = CGFloat(bytes[byteIndex]) / 255.0
        let g = CGFloat(bytes[byteIndex + 1]) / 255.0
        let b = CGFloat(bytes[byteIndex + 2]) / 255.0
        let a = CGFloat(bytes[byteIndex + 3]) / 255.0
        
        return Color(red: r, green: g, blue: b, opacity: a)
    }
}

// hexString extension は Color+Extensions.swift で定義済み

// MARK: - Preview
#Preview {
    NavigationView {
        ManualColorPickerView()
    }
}