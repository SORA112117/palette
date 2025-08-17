//
//  PaletteCreationOptionsView.swift
//  palette
//
//  Created by Claude on 2025/08/15.
//

import SwiftUI
import PhotosUI

// MARK: - パレット作成方法選択画面
struct PaletteCreationOptionsView: View {
    
    // MARK: - Dependencies
    @Environment(\.diContainer) private var diContainer
    
    // MARK: - State
    @StateObject private var homeViewModel: HomeViewModel
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Initialization
    init() {
        self._homeViewModel = StateObject(wrappedValue: DIContainer.shared.makeHomeViewModel())
    }
    
    // MARK: - Body
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                // ヘッダー説明
                headerSection
                
                // 作成方法オプション
                creationOptionsSection
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color.backgroundPrimary)
        .navigationTitle("パレット作成")
        .navigationBarTitleDisplayMode(.inline)
        .photosPicker(
            isPresented: $homeViewModel.showingImagePicker,
            selection: $homeViewModel.selectedPhotoItem,
            matching: .images,
            photoLibrary: .shared()
        )
        .onChange(of: homeViewModel.selectedImage) { _, newImage in
            if let image = newImage {
                diContainer.navigationRouter.presentColorExtraction(image: image)
            }
        }
        .loadingOverlay(isLoading: homeViewModel.isLoading)
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "paintbrush.pointed.fill")
                .font(.system(size: 48))
                .foregroundColor(.iconPrimary)
            
            VStack(spacing: 8) {
                Text("パレットの作成方法を選択")
                    .smartText(.title)
                
                Text("どの方法でパレットを作成しますか？")
                    .smartText(.bodySecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Creation Options Section
    private var creationOptionsSection: some View {
        VStack(spacing: 16) {
            // 手動ピッカーで作成
            CreationOptionCard(
                title: "手動ピッカーで作成",
                subtitle: "画像内の好きな場所から色を選択",
                icon: "eyedropper.halffull",
                iconColor: Color.smartBlack,
                action: {
                    NavigationRouter.shared.homePath.append(NavigationDestination.manualColorPicker)
                }
            )
            
            // 自動抽出で作成
            CreationOptionCard(
                title: "自動抽出で作成",
                subtitle: "色数を指定して自動で抽出",
                icon: "wand.and.stars",
                iconColor: Color.smartDarkGray,
                action: {
                    NavigationRouter.shared.homePath.append(NavigationDestination.automaticExtraction)
                }
            )
            
            // 手動パレット作成
            CreationOptionCard(
                title: "手動で作成",
                subtitle: "カラーピッカーで自由に選択",
                icon: "paintpalette.fill",
                iconColor: Color.smartMediumGray,
                action: {
                    NavigationRouter.shared.homePath.append(NavigationDestination.manualPaletteCreation)
                }
            )
        }
    }
    
}

// MARK: - Creation Option Card
struct CreationOptionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let iconColor: Color
    let isRecommended: Bool
    let action: () -> Void
    
    init(title: String, subtitle: String, icon: String, iconColor: Color, isRecommended: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.iconColor = iconColor
        self.isRecommended = isRecommended
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // アイコン
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(iconColor)
                }
                
                // テキスト部分
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .smartText(.subtitle)
                    
                    Text(subtitle)
                        .smartText(.bodySecondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // 矢印
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title2)
                    .foregroundColor(iconColor)
            }
            .padding(SmartTheme.spacingL)
            .smartCard(elevation: .medium)
        }
        .buttonStyle(PlainButtonStyle())
        .bounceOnTap()
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        PaletteCreationOptionsView()
    }
}