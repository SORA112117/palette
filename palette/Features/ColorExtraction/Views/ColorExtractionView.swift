//
//  ColorExtractionView.swift
//  palette
//
//  Created by Claude on 2025/08/14.
//

import SwiftUI

// MARK: - 色抽出画面
struct ColorExtractionView: View {
    
    // MARK: - Properties
    @StateObject private var viewModel: ColorExtractionViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingColorPicker = false
    @State private var showingTagEditor = false
    @State private var selectedColor: ExtractedColor?
    @State private var draggedColor: ExtractedColor?
    
    // MARK: - Initialization
    init(sourceImage: UIImage) {
        _viewModel = StateObject(wrappedValue: ColorExtractionViewModel(sourceImage: sourceImage))
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        imagePreviewSection
                        
                        if viewModel.isExtracting {
                            extractionProgressView
                        } else if !viewModel.extractedColors.isEmpty {
                            extractedColorsSection
                            colorCountSelector
                            paletteInfoSection
                            actionButtons
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("色を抽出")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !viewModel.extractedColors.isEmpty {
                        Menu {
                            Button(action: { viewModel.toggleSortOrder() }) {
                                Label(
                                    viewModel.sortByPercentage ? "色相順で並べ替え" : "占有率順で並べ替え",
                                    systemImage: "arrow.up.arrow.down"
                                )
                            }
                            
                            Button(action: { showingColorPicker = true }) {
                                Label("色を追加", systemImage: "plus.circle")
                            }
                            
                            Button(action: { sharepalette() }) {
                                Label("共有", systemImage: "square.and.arrow.up")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingColorPicker) {
            ColorPickerSheet { color in
                viewModel.addColor(color)
            }
        }
        .sheet(item: $selectedColor) { color in
            ColorDetailSheet(color: color, viewModel: viewModel)
        }
        .alert("保存完了", isPresented: $viewModel.showingSaveConfirmation) {
            Button("ギャラリーで見る") {
                dismiss()
                NavigationRouter.shared.navigateToGallery()
            }
            Button("閉じる") {
                dismiss()
            }
        } message: {
            Text("パレットが保存されました")
        }
        .errorAlert(error: Binding<Error?>(
            get: { viewModel.errorMessage.map { NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: $0]) } },
            set: { _ in viewModel.errorMessage = nil }
        ))
    }
    
    // MARK: - Sections
    
    /// 画像プレビューセクション
    private var imagePreviewSection: some View {
        VStack(spacing: 16) {
            Image(uiImage: viewModel.sourceImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 250)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
            
            if viewModel.extractedColors.isEmpty && !viewModel.isExtracting {
                Button(action: {
                    Task { await viewModel.extractColors() }
                }) {
                    Label("色を抽出", systemImage: "eyedropper")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.primaryPink)
                        .cornerRadius(25)
                }
                .bounceOnTap()
            }
        }
        .padding(.top, 16)
    }
    
    /// 抽出プログレスビュー
    private var extractionProgressView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle(tint: .primaryPink))
            
            Text("色を分析中...")
                .font(.headline)
                .foregroundColor(.secondary)
            
            ProgressView(value: viewModel.extractionProgress)
                .progressViewStyle(LinearProgressViewStyle(tint: .primaryPink))
                .frame(maxWidth: 200)
        }
        .padding(40)
        .cardStyle()
    }
    
    /// 抽出された色セクション
    private var extractedColorsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("抽出された色")
                .font(.title2)
                .fontWeight(.bold)
            
            // カラーパレット表示
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.extractedColors) { color in
                        ColorCard(
                            color: color,
                            showDetails: viewModel.showColorDetails,
                            onTap: {
                                selectedColor = color
                                HapticManager.shared.colorSelection()
                            },
                            onDelete: {
                                viewModel.removeColor(color)
                            }
                        )
                        .draggable(color) {
                            ColorCircle(color: color, size: 60)
                                .opacity(0.8)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            
            // グラデーションプレビュー
            GradientBackground(
                extractedColors: viewModel.extractedColors,
                gradientType: .linear,
                orientation: .horizontal
            )
            .frame(height: 60)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white, lineWidth: 2)
                    .shadow(color: .black.opacity(0.1), radius: 2)
            )
        }
    }
    
    /// 色数選択セクション
    private var colorCountSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("抽出する色数: \(viewModel.selectedColorCount)")
                .font(.headline)
            
            Picker("色数", selection: $viewModel.selectedColorCount) {
                ForEach([3, 4, 5, 6, 7, 8], id: \.self) { count in
                    Text("\(count)色").tag(count)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: viewModel.selectedColorCount) { newValue in
                viewModel.changeColorCount(newValue)
            }
        }
    }
    
    /// パレット情報セクション
    private var paletteInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // タイトル入力
            VStack(alignment: .leading, spacing: 8) {
                Text("パレット名")
                    .font(.headline)
                TextField("パレット名を入力", text: $viewModel.paletteTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            // タグ入力
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("タグ")
                        .font(.headline)
                    Spacer()
                    Button(action: { showingTagEditor = true }) {
                        Image(systemName: "plus.circle")
                            .foregroundColor(.primaryPink)
                    }
                }
                
                if !viewModel.paletteTags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(viewModel.paletteTags, id: \.self) { tag in
                                TagChip(tag: tag) {
                                    viewModel.removeTag(tag)
                                }
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingTagEditor) {
            TagEditorSheet(tags: viewModel.paletteTags) { newTag in
                viewModel.addTag(newTag)
            }
        }
    }
    
    /// アクションボタン
    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button(action: {
                Task { await viewModel.extractColors() }
            }) {
                Label("再抽出", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
            }
            
            Button(action: {
                Task { await viewModel.savePalette() }
            }) {
                Label("保存", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.primaryPink)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .bounceOnTap()
        }
    }
    
    /// 背景グラデーション
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(.systemBackground),
                Color.primaryTurquoise.opacity(0.05)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Methods
    
    private func sharepalette() {
        guard let palette = viewModel.savedPalette else { return }
        // TODO: SNS共有機能の実装
        NavigationRouter.shared.presentShareSheet(items: [palette.autoGeneratedTitle])
    }
}

// MARK: - Color Card Component
struct ColorCard: View {
    let color: ExtractedColor
    let showDetails: Bool
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .topTrailing) {
                ColorCircle(
                    color: color,
                    size: 80,
                    showPercentage: false,
                    showHexCode: false,
                    onTap: onTap
                )
                
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .background(Circle().fill(Color.black.opacity(0.5)))
                }
                .offset(x: 8, y: -8)
            }
            
            if showDetails {
                VStack(spacing: 4) {
                    Text(color.hexCode)
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    Text("\(color.percentage, specifier: "%.1f")%")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

// MARK: - Tag Chip Component
struct TagChip: View {
    let tag: String
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(tag)
                .font(.caption)
                .foregroundColor(.primary)
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.gray.opacity(0.15))
        .cornerRadius(20)
    }
}

// MARK: - Preview
#Preview {
    ColorExtractionView(sourceImage: UIImage(systemName: "photo")!)
}