//
//  ContentView.swift
//  palette
//
//  Created by 山内壮良 on 2025/08/15.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var router = NavigationRouter.shared
    
    var body: some View {
        TabView(selection: $router.selectedTab) {
            // ホームタブ
            NavigationStack(path: $router.homePath) {
                HomeView()
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
        .tint(.primaryPink)
        .sheet(item: $router.presentedSheet) { sheet in
            sheetView(sheet)
        }
        .fullScreenCover(item: $router.presentedFullScreenCover) { cover in
            fullScreenCoverView(cover)
        }
        .alert(item: $router.alertItem) { alertItem in
            Alert(
                title: Text(alertItem.title),
                message: alertItem.message.map(Text.init),
                primaryButton: alertItem.primaryButton,
                secondaryButton: alertItem.secondaryButton
            )
        }
    }
    
    // MARK: - Navigation Destinations
    
    @ViewBuilder
    private func destinationView(_ destination: NavigationDestination) -> some View {
        switch destination {
        case .paletteDetail(let palette):
            PaletteDetailView(palette: palette)
        case .taggedPalettes(let tag):
            TaggedPalettesView(tag: tag)
        case .about:
            AboutView()
        case .privacyPolicy:
            PrivacyPolicyView()
        case .terms:
            TermsView()
        case .licenses:
            LicensesView()
        }
    }
    
    // MARK: - Sheet Views
    
    @ViewBuilder
    private func sheetView(_ sheet: SheetDestination) -> some View {
        switch sheet {
        case .paletteEditor(let palette):
            PaletteEditSheet(palette: palette) { updatedPalette in
                Task {
                    try? await StorageService.shared.savePalette(updatedPalette)
                }
            }
        case .colorPicker(let colorBinding):
            ColorPickerSheet { color in
                colorBinding.wrappedValue = color
            }
        case .tagEditor(let tags):
            TagEditorSheet(tags: tags) { _ in }
        case .share(let items):
            ShareSheet(items: items)
        case .imagePicker:
            ImagePickerView()
        }
    }
    
    // MARK: - Full Screen Cover Views
    
    @ViewBuilder
    private func fullScreenCoverView(_ cover: FullScreenDestination) -> some View {
        switch cover {
        case .colorExtraction(let image):
            ColorExtractionView(sourceImage: image)
        case .wallpaperCreator(let palette):
            WallpaperCreatorView(palette: palette)
        case .onboarding:
            OnboardingView()
        case .camera:
            CameraView()
        }
    }
}

// MARK: - Placeholder Views

struct SettingsView: View {
    var body: some View {
        VStack {
            Text("設定画面")
                .font(.title)
                .navigationTitle("設定")
        }
    }
}

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

struct AboutView: View {
    var body: some View {
        VStack {
            Text("アプリについて")
                .font(.title2)
                .navigationTitle("About")
        }
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        VStack {
            Text("プライバシーポリシー")
                .font(.title2)
                .navigationTitle("プライバシーポリシー")
        }
    }
}

struct TermsView: View {
    var body: some View {
        VStack {
            Text("利用規約")
                .font(.title2)
                .navigationTitle("利用規約")
        }
    }
}

struct LicensesView: View {
    var body: some View {
        VStack {
            Text("ライセンス")
                .font(.title2)
                .navigationTitle("ライセンス")
        }
    }
}

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
            .background(Color.primaryPink)
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
