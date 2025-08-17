//
//  ColorDetailSheet.swift
//  palette
//
//  Created by Claude on 2025/08/14.
//

import SwiftUI

// MARK: - 色詳細シート
struct ColorDetailSheet: View {
    
    // MARK: - Properties
    let color: ExtractedColor
    let viewModel: ColorExtractionViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingColorPicker = false
    @State private var selectedColorSpace: ColorSpace = .hex
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                colorPreview
                colorInformation
                colorActions
                harmonySection
                Spacer()
            }
            .padding(.horizontal, 20)
            .navigationTitle("色の詳細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Sections
    
    /// 色プレビューセクション
    private var colorPreview: some View {
        VStack(spacing: 16) {
            ColorCircle(color: color, size: 120)
            
            VStack(spacing: 8) {
                Text(color.name ?? "無名の色")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("占有率: \(color.percentage, specifier: "%.1f")%")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 20)
    }
    
    /// 色情報セクション
    private var colorInformation: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("色の情報")
                .font(.headline)
            
            // 色空間選択
            Picker("色空間", selection: $selectedColorSpace) {
                ForEach(ColorSpace.allCases, id: \.self) { space in
                    Text(space.displayName).tag(space)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            // 選択された色空間の値表示
            VStack(alignment: .leading, spacing: 12) {
                switch selectedColorSpace {
                case .hex:
                    ColorInfoRow(label: "HEX", value: color.hexCode, copyable: true)
                case .rgb:
                    let rgb = color.rgb
                    ColorInfoRow(label: "Red", value: "\(Int(rgb.red))")
                    ColorInfoRow(label: "Green", value: "\(Int(rgb.green))")
                    ColorInfoRow(label: "Blue", value: "\(Int(rgb.blue))")
                    ColorInfoRow(
                        label: "RGB",
                        value: "rgb(\(Int(rgb.red)), \(Int(rgb.green)), \(Int(rgb.blue)))",
                        copyable: true
                    )
                case .hsl:
                    let hsl = color.hsl
                    ColorInfoRow(label: "Hue", value: "\(Int(hsl.hue))°")
                    ColorInfoRow(label: "Saturation", value: "\(Int(hsl.saturation))%")
                    ColorInfoRow(label: "Lightness", value: "\(Int(hsl.lightness))%")
                    ColorInfoRow(
                        label: "HSL",
                        value: "hsl(\(Int(hsl.hue)), \(Int(hsl.saturation))%, \(Int(hsl.lightness))%)",
                        copyable: true
                    )
                }
            }
            .cardStyle()
        }
    }
    
    /// 色アクションセクション
    private var colorActions: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("アクション")
                .font(.headline)
            
            HStack(spacing: 12) {
                ColorActionButton(
                    title: "コピー",
                    icon: "doc.on.doc",
                    action: { viewModel.copyColorToClipboard(color) }
                )
                
                ColorActionButton(
                    title: "削除",
                    icon: "trash",
                    action: {
                        viewModel.removeColor(color)
                        dismiss()
                    }
                )
                
                ColorActionButton(
                    title: "編集",
                    icon: "slider.horizontal.3",
                    action: { showingColorPicker = true }
                )
            }
        }
    }
    
    /// 配色セクション
    private var harmonySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("関連配色")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    HarmonyColorSet(
                        title: "補色",
                        colors: [color.color, color.color.complementary]
                    )
                    
                    HarmonyColorSet(
                        title: "三色配色",
                        colors: color.color.triadic
                    )
                    
                    HarmonyColorSet(
                        title: "類似色",
                        colors: color.color.analogous
                    )
                    
                    HarmonyColorSet(
                        title: "分割補色",
                        colors: color.color.splitComplementary
                    )
                }
                .padding(.horizontal, 4)
            }
        }
        .sheet(isPresented: $showingColorPicker) {
            ColorAdjustmentView(originalColor: color) { adjustedColor in
                // TODO: 調整された色で置き換え
            }
        }
    }
}

// MARK: - Supporting Views

struct ColorInfoRow: View {
    let label: String
    let value: String
    let copyable: Bool
    
    init(label: String, value: String, copyable: Bool = false) {
        self.label = label
        self.value = value
        self.copyable = copyable
    }
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(.system(.subheadline, design: .monospaced))
                .fontWeight(.medium)
            
            Spacer()
            
            if copyable {
                Button(action: {
                    UIPasteboard.general.string = value
                    HapticManager.shared.lightImpact()
                }) {
                    Image(systemName: "doc.on.doc")
                        .font(.caption)
                        .foregroundColor(.primaryPink)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct ColorActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.6))
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .bounceOnTap()
    }
}

struct HarmonyColorSet: View {
    let title: String
    let colors: [Color]
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
            
            HStack(spacing: 4) {
                ForEach(colors.indices, id: \.self) { index in
                    Circle()
                        .fill(colors[index])
                        .frame(width: 32, height: 32)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 1)
                                .shadow(color: .black.opacity(0.1), radius: 1)
                        )
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Color Space Enum
enum ColorSpace: CaseIterable {
    case hex
    case rgb
    case hsl
    
    var displayName: String {
        switch self {
        case .hex: return "HEX"
        case .rgb: return "RGB"
        case .hsl: return "HSL"
        }
    }
}

// MARK: - Color Picker Sheet
struct ColorPickerSheet: View {
    let onColorSelected: (Color) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selectedColor = Color.red
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                ColorPicker("色を選択", selection: $selectedColor, supportsOpacity: false)
                    .labelsHidden()
                    .padding()
                
                Button("色を追加") {
                    onColorSelected(selectedColor)
                    dismiss()
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 12)
                .background(Color.primaryPink)
                .cornerRadius(25)
                
                Spacer()
            }
            .padding()
            .navigationTitle("色を選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Tag Editor Sheet
struct TagEditorSheet: View {
    let tags: [String]
    let onTagAdded: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var newTagText = ""
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("新しいタグを追加")
                    .font(.headline)
                
                HStack {
                    TextField("タグを入力", text: $newTagText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("追加") {
                        if !newTagText.isEmpty {
                            onTagAdded(newTagText)
                            newTagText = ""
                        }
                    }
                    .disabled(newTagText.isEmpty)
                }
                
                Text("提案タグ")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                let suggestedTags = ["自然", "鮮やか", "パステル", "モノトーン", "レトロ", "モダン"]
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 100))
                ], spacing: 8) {
                    ForEach(suggestedTags.filter { !tags.contains($0) }, id: \.self) { tag in
                        Button(tag) {
                            onTagAdded(tag)
                            dismiss()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.primaryPink.opacity(0.1))
                        .foregroundColor(.primaryPink)
                        .cornerRadius(16)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("タグ追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Color Adjustment View
struct ColorAdjustmentView: View {
    let originalColor: ExtractedColor
    let onAdjustmentComplete: (Color) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var adjustedColor: Color
    
    init(originalColor: ExtractedColor, onAdjustmentComplete: @escaping (Color) -> Void) {
        self.originalColor = originalColor
        self.onAdjustmentComplete = onAdjustmentComplete
        _adjustedColor = State(initialValue: originalColor.color)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                HStack(spacing: 20) {
                    VStack {
                        Text("元の色")
                            .font(.caption)
                        Circle()
                            .fill(originalColor.color)
                            .frame(width: 80, height: 80)
                    }
                    
                    Image(systemName: "arrow.right")
                        .foregroundColor(.secondary)
                    
                    VStack {
                        Text("調整後")
                            .font(.caption)
                        Circle()
                            .fill(adjustedColor)
                            .frame(width: 80, height: 80)
                    }
                }
                
                ColorPicker("色を調整", selection: $adjustedColor, supportsOpacity: false)
                    .labelsHidden()
                    .padding()
                
                Button("適用") {
                    onAdjustmentComplete(adjustedColor)
                    dismiss()
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 12)
                .background(Color.primaryPink)
                .cornerRadius(25)
                
                Spacer()
            }
            .padding()
            .navigationTitle("色を調整")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ColorDetailSheet(
        color: ExtractedColor.sampleColors[0],
        viewModel: ColorExtractionViewModel(sourceImage: UIImage(systemName: "photo")!)
    )
}