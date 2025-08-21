//
//  SettingsView.swift
//  palette
//
//  Created by Claude on 2025/08/16.
//

import SwiftUI
import StoreKit

// MARK: - 設定画面
struct SettingsView: View {
    
    // MARK: - State
    @StateObject private var viewModel = SettingsViewModel()
    @AppStorage("appTheme") private var appTheme = "system"
    @AppStorage("hapticFeedback") private var hapticFeedback = true
    @AppStorage("autoSavePalettes") private var autoSavePalettes = true
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            List {
                // アプリ情報セクション
                appInfoSection
                
                // 外観設定セクション
                appearanceSection
                
                // データ管理セクション
                dataManagementSection
                
                // サポートセクション
                supportSection
                
                // 法的情報セクション
                legalSection
                
                // バージョン情報
                versionSection
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $viewModel.showingMailComposer) {
            // メール画面（実装は後で）
            ContactSupportView()
        }
        .alert("データをクリア", isPresented: $viewModel.showingClearDataAlert) {
            Button("すべて削除", role: .destructive) {
                viewModel.clearAllData()
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("すべてのパレットとデータが削除されます。この操作は取り消せません。")
        }
        .alert("キャッシュをクリア", isPresented: $viewModel.showingClearCacheAlert) {
            Button("クリア", role: .destructive) {
                viewModel.clearCache()
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("一時ファイルとキャッシュが削除されます。")
        }
    }
    
    // MARK: - App Info Section
    private var appInfoSection: some View {
        Section {
            NavigationLink(destination: AboutAppView()) {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.smartBlack)
                        .frame(width: 24, height: 24)
                    
                    Text("このアプリについて")
                        .smartText(.body)
                    
                    Spacer()
                }
            }
            
            Button(action: {
                viewModel.requestAppReview()
            }) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.smartBlack)
                        .frame(width: 24, height: 24)
                    
                    Text("アプリを評価する")
                        .smartText(.body)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.forward.square")
                        .foregroundColor(.smartMediumGray)
                        .font(.footnote)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: {
                viewModel.shareApp()
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.smartBlack)
                        .frame(width: 24, height: 24)
                    
                    Text("友達に共有")
                        .smartText(.body)
                    
                    Spacer()
                }
            }
            .buttonStyle(PlainButtonStyle())
        } header: {
            Text("アプリ情報")
                .smartText(.caption)
        }
    }
    
    // MARK: - Appearance Section
    private var appearanceSection: some View {
        Section {
            HStack {
                Image(systemName: "moon.circle.fill")
                    .foregroundColor(.smartBlack)
                    .frame(width: 24, height: 24)
                
                Text("外観モード")
                    .smartText(.body)
                
                Spacer()
                
                Picker("", selection: $appTheme) {
                    Text("システム").tag("system")
                    Text("ライト").tag("light")
                    Text("ダーク").tag("dark")
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 180)
            }
            
            Toggle(isOn: $hapticFeedback) {
                HStack {
                    Image(systemName: "waveform")
                        .foregroundColor(.smartBlack)
                        .frame(width: 24, height: 24)
                    
                    Text("触覚フィードバック")
                        .smartText(.body)
                }
            }
            .tint(.smartBlack)
        } header: {
            Text("外観")
                .smartText(.caption)
        }
    }
    
    // MARK: - Data Management Section
    private var dataManagementSection: some View {
        Section {
            Toggle(isOn: $autoSavePalettes) {
                HStack {
                    Image(systemName: "externaldrive.fill")
                        .foregroundColor(.smartBlack)
                        .frame(width: 24, height: 24)
                    
                    Text("パレットを自動保存")
                        .smartText(.body)
                }
            }
            .tint(.smartBlack)
            
            Button(action: {
                viewModel.exportAllPalettes()
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up.on.square")
                        .foregroundColor(.smartBlack)
                        .frame(width: 24, height: 24)
                    
                    Text("すべてのパレットをエクスポート")
                        .smartText(.body)
                    
                    Spacer()
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: {
                viewModel.showingClearCacheAlert = true
            }) {
                HStack {
                    Image(systemName: "trash")
                        .foregroundColor(.smartBlack)
                        .frame(width: 24, height: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("キャッシュをクリア")
                            .smartText(.body)
                        
                        Text("使用中: \(viewModel.cacheSize)")
                            .smartText(.caption)
                    }
                    
                    Spacer()
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: {
                viewModel.showingClearDataAlert = true
            }) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.smartError)
                        .frame(width: 24, height: 24)
                    
                    Text("すべてのデータを削除")
                        .foregroundColor(.smartError)
                        .smartText(.body)
                    
                    Spacer()
                }
            }
            .buttonStyle(PlainButtonStyle())
        } header: {
            Text("データ管理")
                .smartText(.caption)
        }
    }
    
    // MARK: - Support Section
    private var supportSection: some View {
        Section {
            NavigationLink(destination: HelpCenterView()) {
                HStack {
                    Image(systemName: "questionmark.circle.fill")
                        .foregroundColor(.smartBlack)
                        .frame(width: 24, height: 24)
                    
                    Text("ヘルプセンター")
                        .smartText(.body)
                    
                    Spacer()
                }
            }
            
            Button(action: {
                viewModel.showingMailComposer = true
            }) {
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.smartBlack)
                        .frame(width: 24, height: 24)
                    
                    Text("お問い合わせ")
                        .smartText(.body)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.forward.square")
                        .foregroundColor(.smartMediumGray)
                        .font(.footnote)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            NavigationLink(destination: FAQView()) {
                HStack {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .foregroundColor(.smartBlack)
                        .frame(width: 24, height: 24)
                    
                    Text("よくある質問")
                        .smartText(.body)
                    
                    Spacer()
                }
            }
        } header: {
            Text("サポート")
                .smartText(.caption)
        }
    }
    
    // MARK: - Legal Section
    private var legalSection: some View {
        Section {
            NavigationLink(destination: PrivacyPolicyView()) {
                HStack {
                    Image(systemName: "hand.raised.fill")
                        .foregroundColor(.smartBlack)
                        .frame(width: 24, height: 24)
                    
                    Text("プライバシーポリシー")
                        .smartText(.body)
                    
                    Spacer()
                }
            }
            
            NavigationLink(destination: TermsOfServiceView()) {
                HStack {
                    Image(systemName: "doc.text.fill")
                        .foregroundColor(.smartBlack)
                        .frame(width: 24, height: 24)
                    
                    Text("利用規約")
                        .smartText(.body)
                    
                    Spacer()
                }
            }
            
            NavigationLink(destination: LicensesView()) {
                HStack {
                    Image(systemName: "scroll.fill")
                        .foregroundColor(.smartBlack)
                        .frame(width: 24, height: 24)
                    
                    Text("ライセンス")
                        .smartText(.body)
                    
                    Spacer()
                }
            }
        } header: {
            Text("法的情報")
                .smartText(.caption)
        }
    }
    
    // MARK: - Version Section
    private var versionSection: some View {
        Section {
            HStack {
                Text("バージョン")
                    .smartText(.body)
                
                Spacer()
                
                Text(viewModel.appVersion)
                    .smartText(.caption)
            }
            
            HStack {
                Text("ビルド")
                    .smartText(.body)
                
                Spacer()
                
                Text(viewModel.buildNumber)
                    .smartText(.caption)
            }
        }
    }
}

// MARK: - Settings View Model
@MainActor
class SettingsViewModel: ObservableObject {
    @Published var showingClearDataAlert = false
    @Published var showingClearCacheAlert = false
    @Published var showingMailComposer = false
    @Published var cacheSize = "計算中..."
    
    var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
    }
    
    var buildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    }
    
    init() {
        calculateCacheSize()
    }
    
    func calculateCacheSize() {
        Task {
            let size = await StorageService.shared.getCacheSize()
            let formatter = ByteCountFormatter()
            formatter.countStyle = .binary
            cacheSize = formatter.string(fromByteCount: Int64(size))
        }
    }
    
    func clearAllData() {
        Task {
            await StorageService.shared.clearAllData()
            HapticManager.shared.success()
        }
    }
    
    func clearCache() {
        Task {
            await StorageService.shared.clearCache()
            calculateCacheSize()
            HapticManager.shared.success()
        }
    }
    
    func exportAllPalettes() {
        // 実装予定
        HapticManager.shared.lightImpact()
    }
    
    func requestAppReview() {
        if #available(iOS 18.0, *) {
            // iOS 18以降の新しいAPI
            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                AppStore.requestReview(in: scene)
            }
        } else {
            // iOS 18未満の従来のAPI
            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
    }
    
    func shareApp() {
        let appURL = URL(string: "https://apps.apple.com/app/id123456789")! // 実際のApp Store URLに置き換え
        let activityVC = UIActivityViewController(activityItems: [appURL], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
    }
}

// MARK: - Preview
#Preview {
    SettingsView()
}