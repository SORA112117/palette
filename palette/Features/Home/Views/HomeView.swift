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
    
    // MARK: - Dependencies
    @Environment(\.diContainer) private var diContainer
    
    // MARK: - State
    @StateObject private var viewModel: HomeViewModel
    @State private var showingAbout = false
    
    // MARK: - Initialization
    init(viewModel: HomeViewModel? = nil) {
        if let viewModel = viewModel {
            self._viewModel = StateObject(wrappedValue: viewModel)
        } else {
            // フォールバック: DIContainerから作成
            self._viewModel = StateObject(wrappedValue: DIContainer.shared.makeHomeViewModel())
        }
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // ヘッダー
            headerSection
            
            // メインコンテンツ
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    mainOptionsSection
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 100) // タブバー分の余白
            }
            .background(Color.backgroundPrimary)
        }
        .navigationBarHidden(true)
        .photosPicker(
            isPresented: $viewModel.showingImagePicker,
            selection: $viewModel.selectedPhotoItem,
            matching: .images,
            photoLibrary: .shared()
        )
        .onChange(of: viewModel.selectedImage) { _, newImage in
            if let image = newImage {
                diContainer.navigationRouter.presentColorExtraction(image: image)
            }
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
        HStack {
            Text("ホーム")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.textPrimary)
            
            Spacer()
            
            Button(action: { showingAbout = true }) {
                Image(systemName: "info.circle")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            .bounceOnTap()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(Color(.systemBackground).opacity(0.95))
    }
    
    
    // MARK: - Main Options Section
    private var mainOptionsSection: some View {
        VStack(spacing: 16) {
            // 手動ピッカーで作成
            MainOptionCard(
                title: "手動ピッカーで作成",
                subtitle: "画像内の好きな場所から色を選択",
                icon: "eyedropper.halffull",
                iconColor: Color.smartPink,
                action: {
                    diContainer.navigationRouter.homePath.append(NavigationDestination.manualColorPicker)
                }
            )
            
            // 自動抽出で作成
            MainOptionCard(
                title: "自動抽出で作成",
                subtitle: "色数を指定して自動で抽出",
                icon: "wand.and.stars",
                iconColor: Color.smartPink.opacity(0.8),
                action: {
                    diContainer.navigationRouter.homePath.append(NavigationDestination.automaticExtraction)
                }
            )
            
            // 手動パレット作成
            MainOptionCard(
                title: "手動で作成",
                subtitle: "カラーピッカーで自由に選択",
                icon: "paintpalette.fill",
                iconColor: Color.smartPink.opacity(0.6),
                action: {
                    diContainer.navigationRouter.homePath.append(NavigationDestination.manualPaletteCreation)
                }
            )
        }
    }
}

// MARK: - Main Option Card
struct MainOptionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let iconColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticManager.shared.lightImpact()
            action()
        }) {
            HStack(spacing: 20) {
                // アイコン
                Image(systemName: icon)
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(iconColor)
                    .frame(width: 60, height: 60)
                    .background(Color.smartPalePink)
                    .clipShape(Circle())
                
                // テキスト
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .smartText(.subtitle)
                    
                    Text(subtitle)
                        .smartText(.bodySecondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // 矢印
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundColor(.iconSecondary)
            }
            .padding(SmartTheme.spacingL)
            .smartCard(elevation: .medium)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .bounceOnTap()
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
                    .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.6))
                
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

// MARK: - Preview
#Preview {
    HomeView()
}