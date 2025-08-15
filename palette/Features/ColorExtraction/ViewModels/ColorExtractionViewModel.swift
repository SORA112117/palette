//
//  ColorExtractionViewModel.swift
//  palette
//
//  Created by Claude on 2025/08/14.
//

import Foundation
import SwiftUI
import Combine

// MARK: - 色抽出画面ViewModel
@MainActor
class ColorExtractionViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var sourceImage: UIImage
    @Published var extractedColors: [ExtractedColor] = []
    @Published var selectedColorCount: Int = 5
    @Published var isExtracting = false
    @Published var extractionProgress: Double = 0.0
    @Published var errorMessage: String?
    @Published var paletteTitle: String = ""
    @Published var paletteTags: [String] = []
    @Published var showingSaveConfirmation = false
    @Published var savedPalette: ColorPalette?
    
    // MARK: - Extraction Settings
    @Published var extractionQuality: ColorExtractionQuality
    @Published var showColorDetails = true
    @Published var sortByPercentage = true
    
    // MARK: - Services
    private let colorExtractionService = ColorExtractionService()
    private let storageService = StorageService.shared
    private let hapticManager = HapticManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(sourceImage: UIImage) {
        self.sourceImage = sourceImage
        self.extractionQuality = storageService.colorExtractionQuality
        self.selectedColorCount = storageService.defaultColorCount
        
        // 初回自動抽出
        Task {
            await extractColors()
        }
    }
    
    // MARK: - Public Methods
    
    /// 色を抽出する
    func extractColors() async {
        isExtracting = true
        extractionProgress = 0.0
        errorMessage = nil
        
        // プログレス更新のシミュレーション
        let progressTask = Task {
            for i in 1...10 {
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1秒
                await MainActor.run {
                    self.extractionProgress = Double(i) / 10.0
                }
            }
        }
        
        do {
            let colors = try await colorExtractionService.extractColors(
                from: sourceImage,
                colorCount: selectedColorCount
            )
            
            extractedColors = sortByPercentage ? 
                colors.sorted { $0.percentage > $1.percentage } : colors
            
            hapticManager.success()
            
            // タイトルの自動生成
            if paletteTitle.isEmpty {
                generatePaletteTitle()
            }
            
        } catch {
            errorMessage = error.localizedDescription
            hapticManager.error()
        }
        
        progressTask.cancel()
        isExtracting = false
        extractionProgress = 1.0
    }
    
    /// 色数を変更して再抽出
    func changeColorCount(_ count: Int) {
        guard count != selectedColorCount else { return }
        selectedColorCount = count
        hapticManager.selectionChanged()
        
        Task {
            await extractColors()
        }
    }
    
    /// 色を削除
    func removeColor(_ color: ExtractedColor) {
        withAnimation(.easeInOut(duration: 0.3)) {
            extractedColors.removeAll { $0.id == color.id }
        }
        hapticManager.lightImpact()
        recalculatePercentages()
    }
    
    /// 色を追加（手動選択）
    func addColor(_ color: Color) {
        let rgbColor = color.rgbColor
        let newColor = ExtractedColor(
            hexCode: rgbColor.hexCode,
            rgb: rgbColor,
            hsl: rgbColor.hsl,
            percentage: 0.0 // 手動追加は0%
        )
        
        withAnimation(.easeInOut(duration: 0.3)) {
            extractedColors.append(newColor)
        }
        hapticManager.colorSelection()
    }
    
    /// 色の順序を入れ替え
    func moveColor(from source: IndexSet, to destination: Int) {
        extractedColors.move(fromOffsets: source, toOffset: destination)
        hapticManager.selectionChanged()
    }
    
    /// パレットを保存
    func savePalette() async {
        guard !extractedColors.isEmpty else { return }
        
        let palette = ColorPalette(
            sourceImageData: sourceImage.jpegData(compressionQuality: 0.8),
            colors: extractedColors,
            title: paletteTitle.isEmpty ? nil : paletteTitle,
            tags: paletteTags
        )
        
        do {
            try await storageService.savePalette(palette)
            savedPalette = palette
            showingSaveConfirmation = true
            hapticManager.paletteSaved()
        } catch {
            errorMessage = "保存に失敗しました: \(error.localizedDescription)"
            hapticManager.error()
        }
    }
    
    /// タグを追加
    func addTag(_ tag: String) {
        let trimmedTag = tag.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTag.isEmpty && !paletteTags.contains(trimmedTag) else { return }
        
        withAnimation {
            paletteTags.append(trimmedTag)
        }
        hapticManager.lightImpact()
    }
    
    /// タグを削除
    func removeTag(_ tag: String) {
        withAnimation {
            paletteTags.removeAll { $0 == tag }
        }
        hapticManager.lightImpact()
    }
    
    /// ソート順を切り替え
    func toggleSortOrder() {
        sortByPercentage.toggle()
        withAnimation(.easeInOut(duration: 0.3)) {
            if sortByPercentage {
                extractedColors.sort { $0.percentage > $1.percentage }
            } else {
                // 色相順でソート
                extractedColors.sort { $0.hsl.hue < $1.hsl.hue }
            }
        }
        hapticManager.selectionChanged()
    }
    
    // MARK: - Private Methods
    
    /// パーセンテージを再計算
    private func recalculatePercentages() {
        let total = 100.0
        let count = Double(extractedColors.count)
        guard count > 0 else { return }
        
        let equalPercentage = total / count
        
        for index in extractedColors.indices {
            extractedColors[index] = ExtractedColor(
                id: extractedColors[index].id,
                hexCode: extractedColors[index].hexCode,
                rgb: extractedColors[index].rgb,
                hsl: extractedColors[index].hsl,
                percentage: equalPercentage,
                name: extractedColors[index].name
            )
        }
    }
    
    /// パレットタイトルを自動生成
    private func generatePaletteTitle() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd HH:mm"
        
        // 主要色に基づいてタイトルを生成
        if let dominantColor = extractedColors.first {
            let hue = dominantColor.hsl.hue
            let colorName = getColorNameFromHue(hue)
            paletteTitle = "\(colorName)パレット - \(dateFormatter.string(from: Date()))"
        } else {
            paletteTitle = "新規パレット - \(dateFormatter.string(from: Date()))"
        }
    }
    
    /// 色相から色名を取得
    private func getColorNameFromHue(_ hue: Double) -> String {
        switch hue {
        case 0..<30, 330..<360:
            return "赤系"
        case 30..<60:
            return "オレンジ系"
        case 60..<90:
            return "黄色系"
        case 90..<150:
            return "緑系"
        case 150..<210:
            return "青緑系"
        case 210..<270:
            return "青系"
        case 270..<330:
            return "紫系"
        default:
            return "カラフル"
        }
    }
    
    /// 色をクリップボードにコピー
    func copyColorToClipboard(_ color: ExtractedColor) {
        UIPasteboard.general.string = color.hexCode
        hapticManager.lightImpact()
    }
    
    /// 色の詳細情報を取得
    func getColorInfo(_ color: ExtractedColor) -> ColorInfo {
        ColorInfo(
            hexCode: color.hexCode,
            rgb: "RGB(\(Int(color.rgb.red)), \(Int(color.rgb.green)), \(Int(color.rgb.blue)))",
            hsl: "HSL(\(Int(color.hsl.hue))°, \(Int(color.hsl.saturation))%, \(Int(color.hsl.lightness))%)",
            percentage: "\(color.percentage.formatted(.number.precision(.fractionLength(1))))%",
            name: color.name ?? getColorNameFromHue(color.hsl.hue)
        )
    }
}

// MARK: - Supporting Types

struct ColorInfo {
    let hexCode: String
    let rgb: String
    let hsl: String
    let percentage: String
    let name: String
}