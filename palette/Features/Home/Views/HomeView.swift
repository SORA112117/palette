//
//  HomeView.swift
//  palette
//
//  Created by Claude on 2025/08/14.
//

import SwiftUI
import PhotosUI

// MARK: - ホーム画面
struct HomeView: View {
    
    // MARK: - State
    @StateObject private var viewModel = HomeViewModel()
    @State private var showingAbout = false
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    headerSection
                    quickActionsSection
                    recentPalettesSection
                    featuredSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100) // タブバー分の余白
            }
            .background(backgroundGradient)
            .navigationBarHidden(true)
        }
        .photosPicker(
            isPresented: $viewModel.showingImagePicker,
            selection: $viewModel.selectedPhotoItem,
            matching: .images,
            photoLibrary: .shared()
        )
        .sheet(isPresented: $viewModel.showingColorExtraction) {
            if let image = viewModel.selectedImage {
                ColorExtractionView(sourceImage: image)
            }
        }
        .sheet(isPresented: $viewModel.showingGallery) {
            GalleryView()
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
        .loadingOverlay(isLoading: viewModel.isLoading)
        .errorAlert(error: Binding<Error?>(
            get: { viewModel.errorMessage.map { NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: $0]) } },
            set: { _ in viewModel.clearError() }
        ))
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("推しパレ")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("あなたの色を見つけよう")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: { showingAbout = true }) {
                    Image(systemName: "info.circle")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .bounceOnTap()
            }
            .padding(.top, 8)
            
            // 今日のインスピレーション
            inspirationCard
        }
    }
    
    // MARK: - Inspiration Card
    private var inspirationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.yellow)
                Text("今日のインスピレーション")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            HStack(spacing: 8) {
                ForEach(Color.sunsetGradient.indices, id: \.self) { index in
                    Circle()
                        .fill(Color.sunsetGradient[index])
                        .frame(width: 30, height: 30)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                                .shadow(color: .black.opacity(0.1), radius: 2)
                        )
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("サンセットグラデーション")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text("温かく優しい色合い")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding(20)
        .glassMorphism()
    }
    
    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("クイックアクション")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                QuickActionCard.photoExtraction {
                    viewModel.selectPhotoFromLibrary()
                }
                
                QuickActionCard.camera {
                    viewModel.takePhoto()
                }
                
                QuickActionCard.gallery {
                    viewModel.showGallery()
                }
                
                QuickActionCard.wallpaper {
                    // TODO: 壁紙作成画面への遷移
                }
            }
        }
    }
    
    // MARK: - Recent Palettes Section
    private var recentPalettesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("最近のパレット")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("すべて表示") {
                    viewModel.showGallery()
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            
            if viewModel.recentPalettes.isEmpty {
                emptyRecentPalettesView
            } else {
                ForEach(viewModel.recentPalettes) { palette in
                    RecentPaletteCard(palette: palette) {
                        viewModel.extractColorsFromPalette(palette)
                    }
                }
            }
        }
    }
    
    // MARK: - Empty Recent Palettes View
    private var emptyRecentPalettesView: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("まだパレットがありません")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("写真から色を抽出して、最初のパレットを作成しましょう")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("写真を選択") {
                viewModel.selectPhotoFromLibrary()
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.primaryPink)
            .cornerRadius(25)
            .bounceOnTap()
        }
        .padding(32)
        .cardStyle()
    }
    
    // MARK: - Featured Section
    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("おすすめ機能")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                QuickActionCard.trending {
                    // TODO: トレンド画面への遷移
                }
                
                QuickActionCard.randomPalette {
                    // TODO: ランダムパレット生成
                }
            }
        }
    }
    
    // MARK: - Background Gradient
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(.systemBackground),
                Color(.systemBackground).opacity(0.8),
                Color.primaryTurquoise.opacity(0.1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

// MARK: - About View (Placeholder)
struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "paintpalette")
                    .font(.system(size: 80))
                    .foregroundColor(.primaryPink)
                
                Text("推しパレ")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("あなたの推しの色を見つけて、美しいパレットを作成しましょう。")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                
                Text("Version 1.0.0")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .navigationTitle("アプリについて")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
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

// MARK: - Color Extraction View (Placeholder)
struct ColorExtractionView: View {
    let sourceImage: UIImage
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("色抽出画面")
                    .font(.title)
                
                Image(uiImage: sourceImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 300)
                    .cornerRadius(12)
                
                Text("この画面で色抽出処理を行います")
                    .font(.body)
                    .padding()
                
                Spacer()
            }
            .padding()
            .navigationTitle("色を抽出")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
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

// MARK: - Gallery View (Placeholder)
struct GalleryView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Text("ギャラリー画面")
                .font(.title)
                .navigationTitle("ギャラリー")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
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
    HomeView()
}