//
//  ContentView.swift
//  palette
//
//  Created by 山内壮良 on 2025/08/15.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var diContainer = DIContainer.shared
    @StateObject private var router = NavigationRouter.shared
    
    var body: some View {
        TabView(selection: $router.selectedTab) {
            // ホームタブ
            NavigationStack(path: $router.homePath) {
                HomeView()
                    .withDependencies(diContainer)
                    .navigationDestination(for: NavigationDestination.self) { destination in
                        destinationView(destination)
                    }
            }
            .tabItem {
                Image(systemName: AppTab.home.icon)
                Text(AppTab.home.title)
            }
            .tag(AppTab.home)
            
            // ギャラリータブ
            NavigationStack(path: $router.galleryPath) {
                GalleryView()
                    .withDependencies(diContainer)
                    .navigationDestination(for: NavigationDestination.self) { destination in
                        destinationView(destination)
                    }
            }
            .tabItem {
                Image(systemName: AppTab.gallery.icon)
                Text(AppTab.gallery.title)
            }
            .tag(AppTab.gallery)
            
            // 設定タブ
            NavigationStack(path: $router.settingsPath) {
                SettingsView()
                    .withDependencies(diContainer)
                    .navigationDestination(for: NavigationDestination.self) { destination in
                        destinationView(destination)
                    }
            }
            .tabItem {
                Image(systemName: AppTab.settings.icon)
                Text(AppTab.settings.title)
            }
            .tag(AppTab.settings)
        }
        .tint(Color(red: 1.0, green: 0.4, blue: 0.6))
        .sheet(item: $router.presentedSheet) { sheet in
            sheetView(sheet)
        }
        .fullScreenCover(item: $router.presentedFullScreenCover) { cover in
            fullScreenCoverView(cover)
        }
        .alert(item: $router.alertItem) { alertItem in
            if let secondaryButton = alertItem.secondaryButton {
                Alert(
                    title: Text(alertItem.title),
                    message: alertItem.message != nil ? Text(alertItem.message!) : nil,
                    primaryButton: alertItem.primaryButton,
                    secondaryButton: secondaryButton
                )
            } else {
                Alert(
                    title: Text(alertItem.title),
                    message: alertItem.message != nil ? Text(alertItem.message!) : nil,
                    dismissButton: alertItem.primaryButton
                )
            }
        }
    }
    
    // MARK: - Navigation Destinations
    
    @ViewBuilder
    private func destinationView(_ destination: NavigationDestination) -> some View {
        switch destination {
        case .paletteDetail(let palette):
            PaletteDetailView(palette: palette)
        case .taggedPalettes(let tag):
            // TODO: TaggedPalettesViewの実装
            VStack {
                Text("タグ「\(tag)」のパレット")
                    .font(.title2)
                    .padding()
                Text("タグ別パレット表示（開発中）")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("タグ: \(tag)")
            .navigationBarTitleDisplayMode(.inline)
        case .paletteCreationOptions:
            PaletteCreationOptionsView()
        case .paletteManagement:
            PaletteManagementView()
        case .moreOptions:
            MoreOptionsView()
        case .manualColorPicker:
            ManualColorPickerView()
        case .automaticExtraction:
            AutomaticExtractionView()
        case .manualPaletteCreation:
            ManualPaletteCreationView()
        case .about:
            AboutAppView()
        case .privacyPolicy:
            PrivacyPolicyView()
        case .terms:
            TermsOfServiceView()
        case .licenses:
            LicensesView()
        }
    }
    
    // MARK: - Sheet Views
    
    @ViewBuilder
    private func sheetView(_ sheet: SheetDestination) -> some View {
        switch sheet {
        case .paletteEditor(let palette):
            // TODO: PaletteEditSheetの実装
            PaletteDetailView(palette: palette)
        case .colorPicker(_):
            // TODO: ColorPickerSheetの実装
            Text("カラーピッカー（開発中）")
                .padding()
        case .tagEditor(_):
            // TODO: TagEditorSheetの実装
            Text("タグエディター（開発中）")
                .padding()
        case .share(let items):
            ShareSheet(items: items)
        case .imagePicker:
            // TODO: ImagePickerViewの実装
            Text("画像選択（開発中）")
                .padding()
        }
    }
    
    // MARK: - Full Screen Cover Views
    
    @ViewBuilder
    private func fullScreenCoverView(_ cover: FullScreenDestination) -> some View {
        switch cover {
        case .colorExtraction(let image):
            ColorExtractionView(sourceImage: image)
        case .wallpaperCreator(let palette):
            // TODO: WallpaperCreatorViewの実装
            NavigationView {
                VStack {
                    Text("壁紙作成（開発中）")
                        .font(.title2)
                        .padding()
                    
                    Button("閉じる") {
                        diContainer.navigationRouter.dismissAllModals()
                    }
                    .padding()
                }
                .navigationTitle("壁紙作成")
                .navigationBarTitleDisplayMode(.inline)
            }
        case .onboarding:
            // TODO: OnboardingViewの実装
            NavigationView {
                VStack {
                    Text("オンボーディング（開発中）")
                        .font(.title2)
                        .padding()
                    
                    Button("閉じる") {
                        diContainer.navigationRouter.dismissAllModals()
                    }
                    .padding()
                }
                .navigationTitle("ようこそ")
                .navigationBarTitleDisplayMode(.inline)
            }
        case .camera:
            // TODO: CameraViewの実装
            NavigationView {
                VStack {
                    Text("カメラ（開発中）")
                        .font(.title2)
                        .padding()
                    
                    Button("閉じる") {
                        diContainer.navigationRouter.dismissAllModals()
                    }
                    .padding()
                }
                .navigationTitle("カメラ")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

// MARK: - Placeholder Views

struct TaggedPalettesView: View {
    let tag: String
    
    var body: some View {
        VStack {
            Text("タグ「\(tag)」のパレット一覧")
                .font(.title2)
                .navigationTitle(tag)
        }
    }
}

// AboutView は HomeView.swift で定義されています

struct ImagePickerView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("画像選択")
                    .font(.title2)
            }
            .navigationTitle("画像を選択")
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

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Text("オンボーディング")
                .font(.title)
            
            Button("開始") {
                StorageService.shared.hasCompletedOnboarding = true
                dismiss()
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .background(Color(red: 1.0, green: 0.4, blue: 0.6))
            .cornerRadius(12)
        }
    }
}

struct CameraView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Text("カメラ")
                .font(.title)
            
            Button("閉じる") {
                dismiss()
            }
        }
    }
}

#Preview {
    ContentView()
}
