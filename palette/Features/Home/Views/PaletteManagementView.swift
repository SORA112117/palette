//
//  PaletteManagementView.swift
//  palette
//
//  Created by Claude on 2025/08/15.
//

import SwiftUI

// MARK: - パレット管理画面
struct PaletteManagementView: View {
    
    // MARK: - State
    @StateObject private var storageService = StorageService.shared
    @State private var showingStatistics = false
    
    // MARK: - Body
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                // ヘッダー説明
                headerSection
                
                // 統計情報
                if !storageService.savedPalettes.isEmpty {
                    statisticsSection
                }
                
                // 管理オプション
                managementOptionsSection
                
                // 最近のパレット（少しだけプレビュー）
                if !storageService.savedPalettes.isEmpty {
                    recentPalettesPreview
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(backgroundGradient)
        .navigationTitle("パレット管理")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingStatistics) {
            PaletteStatisticsSheet()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "folder.badge.gearshape")
                .font(.system(size: 48))
                .foregroundColor(Color(red: 0.3, green: 0.8, blue: 0.9))
            
            VStack(spacing: 8) {
                Text("パレットを管理")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("保存済みのパレットを整理・管理できます")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Statistics Section
    private var statisticsSection: some View {
        VStack(spacing: 12) {
            Text("パレット統計")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            let statistics = storageService.getPaletteStatistics()
            
            HStack(spacing: 20) {
                StatisticItem(
                    title: "総数",
                    value: "\(statistics.totalPalettes)",
                    color: Color(red: 1.0, green: 0.4, blue: 0.6)
                )
                
                StatisticItem(
                    title: "お気に入り",
                    value: "\(statistics.favoritePalettes)",
                    color: Color(red: 1.0, green: 0.6, blue: 0.0)
                )
                
                StatisticItem(
                    title: "総色数",
                    value: "\(statistics.totalColors)",
                    color: Color(red: 0.3, green: 0.8, blue: 0.9)
                )
            }
            
            Button("詳細統計を見る") {
                showingStatistics = true
            }
            .font(.subheadline)
            .foregroundColor(Color(red: 0.3, green: 0.8, blue: 0.9))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
        )
    }
    
    // MARK: - Management Options Section
    private var managementOptionsSection: some View {
        VStack(spacing: 16) {
            // すべてのパレット
            ManagementOptionCard(
                title: "すべてのパレット",
                subtitle: "保存済みパレット一覧",
                icon: "rectangle.stack.fill",
                iconColor: Color(red: 0.2, green: 0.7, blue: 1.0),
                badgeCount: storageService.savedPalettes.count,
                action: {
                    NavigationRouter.shared.navigateToGallery()
                }
            )
            
            // お気に入り
            ManagementOptionCard(
                title: "お気に入り",
                subtitle: "お気に入りのパレット",
                icon: "heart.fill",
                iconColor: Color(red: 1.0, green: 0.3, blue: 0.4),
                badgeCount: storageService.favoritesPalettes.count,
                action: {
                    NavigationRouter.shared.navigateToGallery()
                    // TODO: フィルターをお気に入りに設定
                }
            )
            
            // タグで整理
            ManagementOptionCard(
                title: "タグで整理",
                subtitle: "タグ別にパレットを表示",
                icon: "tag.fill",
                iconColor: Color(red: 0.8, green: 0.5, blue: 0.9),
                action: {
                    // TODO: タグ一覧画面
                    NavigationRouter.shared.showAlert(AlertItem(
                        title: "準備中",
                        message: "タグ整理機能は現在開発中です"
                    ))
                }
            )
            
            // エクスポート・インポート
            ManagementOptionCard(
                title: "エクスポート・インポート",
                subtitle: "パレットの共有・バックアップ",
                icon: "arrow.up.arrow.down.circle.fill",
                iconColor: Color(red: 0.5, green: 0.8, blue: 0.5),
                action: {
                    // TODO: エクスポート・インポート機能
                    NavigationRouter.shared.showAlert(AlertItem(
                        title: "準備中",
                        message: "エクスポート機能は今後追加予定です"
                    ))
                }
            )
        }
    }
    
    // MARK: - Recent Palettes Preview
    private var recentPalettesPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("最近のパレット")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("すべて表示") {
                    NavigationRouter.shared.navigateToGallery()
                }
                .font(.subheadline)
                .foregroundColor(Color(red: 0.3, green: 0.8, blue: 0.9))
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(storageService.savedPalettes.prefix(5))) { palette in
                        RecentPalettePreview(palette: palette) {
                            NavigationRouter.shared.navigateToPaletteDetail(palette)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
        )
    }
    
    // MARK: - Background Gradient
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(.systemBackground),
                Color(red: 0.3, green: 0.8, blue: 0.9).opacity(0.05)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

// MARK: - Supporting Views

struct StatisticItem: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ManagementOptionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let iconColor: Color
    let badgeCount: Int?
    let action: () -> Void
    
    init(title: String, subtitle: String, icon: String, iconColor: Color, badgeCount: Int? = nil, action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.iconColor = iconColor
        self.badgeCount = badgeCount
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // アイコン
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(iconColor)
                }
                
                // テキスト部分
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        if let count = badgeCount, count > 0 {
                            Text("\(count)")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(iconColor)
                                .cornerRadius(10)
                        }
                    }
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.subheadline)
                    .foregroundColor(.secondary.opacity(0.6))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.04), radius: 4, y: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .bounceOnTap()
    }
}

struct RecentPalettePreview: View {
    let palette: ColorPalette
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // パレット色表示
                HStack(spacing: 2) {
                    ForEach(Array(palette.colors.prefix(4))) { color in
                        Rectangle()
                            .fill(color.color)
                            .frame(width: 12, height: 40)
                    }
                }
                .cornerRadius(6)
                
                Text(palette.autoGeneratedTitle)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .bounceOnTap()
        .frame(width: 60)
    }
}

// パレット統計詳細画面
struct PaletteStatisticsSheet: View {
    @StateObject private var storageService = StorageService.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("詳細統計")
                    .font(.title)
                Text("統計詳細機能は今後追加予定です")
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding()
            .navigationTitle("統計詳細")
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
    NavigationView {
        PaletteManagementView()
    }
}