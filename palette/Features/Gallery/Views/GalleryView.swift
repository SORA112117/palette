//
//  GalleryView.swift
//  palette
//
//  Created by Claude on 2025/08/14.
//

import SwiftUI

// MARK: - ギャラリー画面
struct GalleryView: View {
    
    // MARK: - State
    @StateObject private var viewModel = GalleryViewModel()
    @State private var showingSortMenu = false
    @State private var selectedPalette: ColorPalette?
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                
                VStack(spacing: 0) {
                    searchAndFilterSection
                    
                    if viewModel.isLoading {
                        loadingView
                    } else if viewModel.filteredPalettes.isEmpty {
                        emptyStateView
                    } else {
                        paletteGridView
                    }
                }
            }
            .navigationTitle("ギャラリー")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if viewModel.isSelectionMode {
                        selectionToolbarItems
                    } else {
                        standardToolbarItems
                    }
                }
            }
            .refreshable {
                viewModel.refreshPalettes()
            }
        }
        .sheet(item: $selectedPalette) { palette in
            PaletteDetailView(palette: palette)
        }
        .sheet(isPresented: $viewModel.showingTagFilter) {
            TagFilterSheet(
                availableTags: viewModel.availableTags,
                onTagSelected: viewModel.filterByTag
            )
        }
        .alert("削除確認", isPresented: $viewModel.showingDeleteConfirmation) {
            Button("削除", role: .destructive) {
                viewModel.deleteSelectedPalettes()
            }
            Button("キャンセル", role: .cancel) { }
        } message: {
            Text("\(viewModel.selectedPalettes.count)個のパレットを削除しますか？")
        }
    }
    
    // MARK: - Sections
    
    /// 検索・フィルターセクション
    private var searchAndFilterSection: some View {
        VStack(spacing: 12) {
            // 検索バー
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("パレットを検索", text: $viewModel.searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                if !viewModel.searchText.isEmpty {
                    Button("キャンセル") {
                        viewModel.searchText = ""
                    }
                    .foregroundColor(.primaryPink)
                }
            }
            
            // フィルター・ソートボタン
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    FilterChip(
                        title: "すべて",
                        isSelected: viewModel.selectedFilter == .all,
                        action: { viewModel.selectedFilter = .all }
                    )
                    
                    FilterChip(
                        title: "お気に入り",
                        isSelected: viewModel.selectedFilter == .favorites,
                        action: { viewModel.selectedFilter = .favorites }
                    )
                    
                    FilterChip(
                        title: "最近",
                        isSelected: viewModel.selectedFilter == .recent,
                        action: { viewModel.selectedFilter = .recent }
                    )
                    
                    Button(action: { viewModel.showingTagFilter = true }) {
                        HStack(spacing: 4) {
                            Image(systemName: "tag")
                            Text("タグ")
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.primaryPink.opacity(0.1))
                        .foregroundColor(.primaryPink)
                        .cornerRadius(16)
                    }
                    
                    Menu {
                        ForEach(PaletteSortOrder.allCases, id: \.self) { sortOrder in
                            Button(action: { viewModel.selectedSortOrder = sortOrder }) {
                                HStack {
                                    Text(sortOrder.displayName)
                                    if viewModel.selectedSortOrder == sortOrder {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.arrow.down")
                            Text("並び替え")
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.1))
                        .foregroundColor(.primary)
                        .cornerRadius(16)
                    }
                }
                .padding(.horizontal, 4)
            }
            
            // 検索候補
            if !viewModel.searchSuggestions.isEmpty && !viewModel.searchText.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.searchSuggestions, id: \.self) { suggestion in
                            Button(suggestion) {
                                viewModel.searchText = suggestion
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(16)
                            .font(.caption)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    /// パレットグリッドビュー
    private var paletteGridView: some View {
        ScrollView {
            LazyVGrid(columns: viewModel.gridColumns, spacing: 16) {
                ForEach(viewModel.filteredPalettes) { palette in
                    PaletteGridItem(
                        palette: palette,
                        isSelected: viewModel.selectedPalettes.contains(palette.id),
                        isFavorite: StorageService.shared.favoritesPalettes.contains { $0.id == palette.id },
                        isSelectionMode: viewModel.isSelectionMode,
                        isGridView: viewModel.isGridView,
                        onTap: {
                            if viewModel.isSelectionMode {
                                viewModel.togglePaletteSelection(palette)
                            } else {
                                selectedPalette = palette
                            }
                        },
                        onFavorite: {
                            viewModel.toggleFavorite(palette)
                        },
                        onDelete: {
                            viewModel.deletePalette(palette)
                        },
                        onDuplicate: {
                            viewModel.duplicatePalette(palette)
                        },
                        onShare: {
                            viewModel.sharePalette(palette)
                        }
                    )
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 100) // タブバー分の余白
        }
    }
    
    /// ローディングビュー
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("パレットを読み込み中...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    /// 空状態ビュー
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "rectangle.stack")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                Text(emptyStateTitle)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(emptyStateMessage)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            if viewModel.selectedFilter == .all && viewModel.searchText.isEmpty {
                Button(action: {
                    NavigationRouter.shared.navigateToHome()
                }) {
                    Text("最初のパレットを作成")
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, -50)
    }
    
    /// 背景グラデーション
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(.systemBackground),
                Color.primaryGreen.opacity(0.05)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Toolbar Items
    
    @ViewBuilder
    private var standardToolbarItems: some View {
        Button(action: viewModel.toggleViewStyle) {
            Image(systemName: viewModel.isGridView ? "list.bullet" : "square.grid.2x2")
        }
        
        Menu {
            Button(action: viewModel.toggleSelectionMode) {
                Label("選択", systemImage: "checkmark.circle")
            }
            
            if viewModel.statistics != nil {
                Button(action: { /* 統計表示 */ }) {
                    Label("統計情報", systemImage: "chart.bar")
                }
            }
            
            Button(action: { /* エクスポート */ }) {
                Label("エクスポート", systemImage: "square.and.arrow.up")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }
    
    @ViewBuilder
    private var selectionToolbarItems: some View {
        Button("すべて選択") {
            if viewModel.selectedPalettes.count == viewModel.filteredPalettes.count {
                viewModel.deselectAllPalettes()
            } else {
                viewModel.selectAllPalettes()
            }
        }
        
        Button("削除") {
            viewModel.showingDeleteConfirmation = true
        }
        .disabled(viewModel.selectedPalettes.isEmpty)
        
        Button("完了") {
            viewModel.toggleSelectionMode()
        }
    }
    
    // MARK: - Computed Properties
    
    private var emptyStateTitle: String {
        switch viewModel.selectedFilter {
        case .all:
            return viewModel.searchText.isEmpty ? "パレットがありません" : "該当するパレットがありません"
        case .favorites:
            return "お気に入りがありません"
        case .recent:
            return "最近のパレットがありません"
        case .byTag(let tag):
            return "\"\(tag)\"のパレットがありません"
        }
    }
    
    private var emptyStateMessage: String {
        switch viewModel.selectedFilter {
        case .all:
            return viewModel.searchText.isEmpty ? 
                "写真から色を抽出して、最初のパレットを作成しましょう" : 
                "検索条件を変更してお試しください"
        case .favorites:
            return "パレットをお気に入りに追加してください"
        case .recent:
            return "7日以内に作成されたパレットがありません"
        case .byTag:
            return "このタグのパレットがありません"
        }
    }
}

// MARK: - Supporting Views

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.primaryPink : Color.gray.opacity(0.1))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
        .bounceOnTap()
    }
}

struct TagFilterSheet: View {
    let availableTags: [String]
    let onTagSelected: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 120))
                ], spacing: 12) {
                    ForEach(availableTags, id: \.self) { tag in
                        Button(action: {
                            onTagSelected(tag)
                            dismiss()
                        }) {
                            Text(tag)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                                .background(Color.primaryPink.opacity(0.1))
                                .foregroundColor(.primaryPink)
                                .cornerRadius(12)
                        }
                        .bounceOnTap()
                    }
                }
                .padding()
            }
            .navigationTitle("タグで絞り込み")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    GalleryView()
}