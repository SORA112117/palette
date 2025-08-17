//
//  ManualPaletteCreationView.swift
//  palette
//
//  Created by Claude on 2025/08/15.
//

import SwiftUI

// MARK: - 手動パレット作成画面
struct ManualPaletteCreationView: View {
    
    // MARK: - State
    @StateObject private var viewModel = ManualPaletteCreationViewModel()
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
                    instructionSection
                    colorSelectionSection
                    addedColorsSection
                }
                .padding(.horizontal, SmartTheme.spacingL)
                .padding(.bottom, SmartTheme.spacingXXL)
            }
            .background(Color.backgroundPrimary)
            
            // 保存ボタン
            if !viewModel.selectedColors.isEmpty {
                saveButtonSection
            }
        }
        .background(Color.backgroundPrimary)
        .navigationTitle("手動で作成")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("キャンセル") {
                    // NavigationStackコンテキストでは、NavigationPathから最後の要素を削除
                    if !diContainer.navigationRouter.homePath.isEmpty {
                        diContainer.navigationRouter.homePath.removeLast()
                    }
                }
                .smartText(.body)
            }
        }
        .alert("パレットを保存", isPresented: $viewModel.showingSaveDialog) {
            TextField("パレット名を入力", text: $viewModel.paletteName)
                .smartText(.body)
            
            Button("保存") {
                viewModel.savePalette()
            }
            Button("キャンセル", role: .cancel) {
                viewModel.paletteName = ""
            }
        } message: {
            Text("空白の場合は「手動作成パレット」として保存されます")
                .smartText(.caption)
        }
        .alert("保存完了", isPresented: $viewModel.showingSuccessAlert) {
            Button("ギャラリーで確認") {
                NavigationRouter.shared.navigateToGallery()
                // ギャラリーに移動するのでhomePathをクリア
                diContainer.navigationRouter.homePath = NavigationPath()
            }
            Button("続けて作成") {
                // 何もしない（アラートを閉じるだけ）
            }
        } message: {
            Text("パレットが正常に保存されました")
                .smartText(.caption)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: SmartTheme.spacingS) {
            Image(systemName: "paintpalette.fill")
                .font(.system(size: 48))
                .foregroundColor(.iconPrimary)
            
            Text("カラーピッカーで自由に選択")
                .smartText(.title)
            
            Text("好きな色を組み合わせて\\nオリジナルパレットを作成")
                .smartText(.bodySecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, SmartTheme.spacingL)
        .padding(.horizontal, SmartTheme.spacingL)
    }
    
    // MARK: - Instruction Section
    private var instructionSection: some View {
        VStack(spacing: SmartTheme.spacingM) {
            HStack {
                Text("色を選択")
                    .smartText(.subtitle)
                
                Spacer()
                
                Text("\(viewModel.selectedColors.count)/10色")
                    .smartText(.caption)
                    .padding(.horizontal, SmartTheme.spacingS)
                    .padding(.vertical, SmartTheme.spacingXS)
                    .background(Color.surfaceSecondary)
                    .cornerRadius(SmartTheme.cornerRadiusSmall)
            }
            
            Text("カラーピッカーから色を選んで、あなただけのパレットを作成しましょう。最大10色まで選択できます。")
                .smartText(.caption)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(SmartTheme.spacingM)
        .smartCard(elevation: .low)
    }
    
    // MARK: - Color Selection Section
    private var colorSelectionSection: some View {
        VStack(spacing: SmartTheme.spacingM) {
            HStack {
                Text("カラーピッカー")
                    .smartText(.subtitle)
                
                Spacer()
                
                Button("リセット") {
                    viewModel.resetColors()
                }
                .smartButton(style: .ghost)
                .padding(.horizontal, SmartTheme.spacingM)
                .padding(.vertical, SmartTheme.spacingS)
                .disabled(viewModel.selectedColors.isEmpty)
            }
            
            // カラーピッカー
            ColorPicker("", selection: $viewModel.currentColor, supportsOpacity: false)
                .labelsHidden()
                .scaleEffect(2.0)
                .frame(height: 100)
                .onChange(of: viewModel.currentColor) { _, newColor in
                    // 色が変更されたときの処理はViewModelで行う
                }
            
            Button("この色を追加") {
                viewModel.addCurrentColor()
            }
            .smartButton(style: .primary)
            .padding(.horizontal, SmartTheme.spacingL)
            .padding(.vertical, SmartTheme.spacingM)
            .disabled(viewModel.selectedColors.count >= 10)
            .disabled(viewModel.colorAlreadyExists)
            
            if viewModel.colorAlreadyExists {
                Text("この色は既に追加されています")
                    .smartText(.caption)
                    .foregroundColor(.smartError)
            }
        }
        .padding(SmartTheme.spacingM)
        .smartCard(elevation: .medium)
    }
    
    // MARK: - Added Colors Section
    private var addedColorsSection: some View {
        Group {
            if !viewModel.selectedColors.isEmpty {
                VStack(spacing: SmartTheme.spacingM) {
                    HStack {
                        Text("選択済みの色")
                            .smartText(.subtitle)
                        
                        Spacer()
                    }
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: SmartTheme.spacingM), count: 3), spacing: SmartTheme.spacingM) {
                        ForEach(Array(viewModel.selectedColors.enumerated()), id: \.offset) { index, color in
                            ColorSelectionCard(
                                color: color,
                                index: index,
                                onRemove: {
                                    viewModel.removeColor(at: index)
                                }
                            )
                        }
                    }
                }
                .padding(SmartTheme.spacingM)
                .smartCard(elevation: .low)
            }
        }
    }
    
    // MARK: - Save Button Section
    private var saveButtonSection: some View {
        VStack(spacing: SmartTheme.spacingM) {
            Divider()
                .background(Color.borderPrimary)
            
            HStack(spacing: SmartTheme.spacingM) {
                Button("すべてクリア") {
                    viewModel.resetColors()
                }
                .smartButton(style: .secondary)
                .padding(.horizontal, SmartTheme.spacingM)
                .padding(.vertical, SmartTheme.spacingS)
                
                Button("パレットを保存") {
                    viewModel.showingSaveDialog = true
                }
                .smartButton(style: .primary)
                .padding(.horizontal, SmartTheme.spacingL)
                .padding(.vertical, SmartTheme.spacingS)
                .disabled(viewModel.selectedColors.count < 2)
            }
            .padding(.horizontal, SmartTheme.spacingL)
            .padding(.bottom, SmartTheme.spacingM)
        }
        .background(Color.surfacePrimary)
        .shadow(color: SmartTheme.shadowColor, radius: SmartTheme.shadowRadius, x: 0, y: -SmartTheme.shadowOffset.height)
    }
}

// MARK: - Color Selection Card
struct ColorSelectionCard: View {
    let color: Color
    let index: Int
    let onRemove: () -> Void
    
    var body: some View {
        VStack(spacing: SmartTheme.spacingS) {
            ZStack {
                RoundedRectangle(cornerRadius: SmartTheme.cornerRadiusMedium)
                    .fill(color)
                    .frame(height: 60)
                    .overlay(
                        RoundedRectangle(cornerRadius: SmartTheme.cornerRadiusMedium)
                            .stroke(Color.borderPrimary, lineWidth: 1)
                    )
                
                VStack {
                    HStack {
                        Spacer()
                        Button(action: onRemove) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.smartWhite)
                                .background(
                                    Circle()
                                        .fill(Color.smartError)
                                        .frame(width: 20, height: 20)
                                )
                        }
                    }
                    Spacer()
                }
                .padding(SmartTheme.spacingXS)
            }
            
            VStack(spacing: 2) {
                Text("#\(index + 1)")
                    .smartText(.captionSecondary)
                
                Text(color.hexString)
                    .smartText(.captionSecondary)
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
            }
        }
    }
}

// MARK: - View Model
@MainActor
class ManualPaletteCreationViewModel: ObservableObject {
    @Published var currentColor: Color = .red
    @Published var selectedColors: [Color] = []
    @Published var showingSaveDialog = false
    @Published var showingSuccessAlert = false
    @Published var paletteName = ""
    
    var colorAlreadyExists: Bool {
        selectedColors.contains { existingColor in
            abs(currentColor.rgbColor.red - existingColor.rgbColor.red) < 0.01 &&
            abs(currentColor.rgbColor.green - existingColor.rgbColor.green) < 0.01 &&
            abs(currentColor.rgbColor.blue - existingColor.rgbColor.blue) < 0.01
        }
    }
    
    func addCurrentColor() {
        guard selectedColors.count < 10 && !colorAlreadyExists else { return }
        
        selectedColors.append(currentColor)
        HapticManager.shared.lightImpact()
        
        // 次の色をランダムに設定
        currentColor = generateRandomColor()
    }
    
    func removeColor(at index: Int) {
        guard index < selectedColors.count else { return }
        
        selectedColors.remove(at: index)
        HapticManager.shared.lightImpact()
    }
    
    func resetColors() {
        selectedColors.removeAll()
        currentColor = generateRandomColor()
        HapticManager.shared.mediumImpact()
    }
    
    func savePalette() {
        guard !selectedColors.isEmpty else { return }
        
        let finalName = paletteName.trimmingCharacters(in: .whitespacesAndNewlines)
        let paletteTitle = finalName.isEmpty ? "手動作成パレット" : finalName
        
        let extractedColors = selectedColors.enumerated().map { index, color in
            ExtractedColor(
                hexCode: color.hexString,
                rgb: color.rgbColor,
                hsl: color.hslColor,
                percentage: 100.0 / Double(selectedColors.count),
                name: "色\(index + 1)"
            )
        }
        
        let palette = ColorPalette(
            sourceImageData: nil,
            colors: extractedColors,
            title: paletteTitle,
            tags: ["手動作成", "カスタム"]
        )
        
        Task {
            do {
                try await StorageService.shared.savePalette(palette)
                showingSuccessAlert = true
                paletteName = ""
                HapticManager.shared.success()
            } catch {
                // エラーハンドリング
                print("パレット保存エラー: \(error)")
            }
        }
    }
    
    private func generateRandomColor() -> Color {
        Color(
            red: Double.random(in: 0...1),
            green: Double.random(in: 0...1),
            blue: Double.random(in: 0...1)
        )
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ManualPaletteCreationView()
            .withDependencies(DIContainer.shared)
    }
}