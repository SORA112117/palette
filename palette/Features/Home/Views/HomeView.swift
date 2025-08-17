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
        NavigationView {
            VStack(spacing: 0) {
                // ヘッダー
                headerSection
                
                // メインコンテンツ
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 32) {
                        welcomeSection
                        mainOptionsSection
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 100) // タブバー分の余白
                }
                .background(Color.backgroundPrimary)
            }
            .navigationBarHidden(true)
        }
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
            VStack(alignment: .leading, spacing: 4) {
                Text("推しパレ")
                    .smartText(.header)
                
                Text("あなたの色を見つけよう")
                    .smartText(.bodySecondary)
            }
            
            Spacer()
            
            Button(action: { showingAbout = true }) {
                Image(systemName: "info.circle")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            .bounceOnTap()
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .background(Color(.systemBackground).opacity(0.95))
    }
    
    // MARK: - Welcome Section
    private var welcomeSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "paintpalette.fill")
                .font(.system(size: 64))
                .foregroundColor(.iconPrimary)
                .padding(.top, 20)
            
            VStack(spacing: 8) {
                Text("何をしたいですか？")
                    .smartText(.title)
                
                Text("下のオプションから選んでください")
                    .smartText(.bodySecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - Main Options Section
    private var mainOptionsSection: some View {
        VStack(spacing: 24) {
            // パレット作成
            MainOptionCard(
                title: "パレットを作成",
                subtitle: "写真から色を抽出・手動で作成",
                icon: "plus.circle.fill",
                iconColor: .smartBlack,
                action: {
                    NavigationRouter.shared.homePath.append(NavigationDestination.paletteCreationOptions)
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
        Button(action: action) {
            HStack(spacing: 20) {
                // アイコン
                Image(systemName: icon)
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(iconColor)
                    .frame(width: 60, height: 60)
                    .background(iconColor.opacity(0.1))
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