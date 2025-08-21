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
        .alert("エクスポートエラー", isPresented: $viewModel.showingExportErrorAlert) {
            Button("OK") {}
        } message: {
            Text(viewModel.exportErrorMessage)
        }
        .fileImporter(
            isPresented: $viewModel.showingImportPicker,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            viewModel.handleImportResult(result)
        }
    }
    
    // MARK: - App Info Section
    private var appInfoSection: some View {
        Section {
            NavigationLink(destination: AboutAppView()) {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.smartPink)
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
                        .foregroundColor(.smartPink)
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
                        .foregroundColor(.smartPink)
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
                        .foregroundColor(.smartPink)
                        .frame(width: 24, height: 24)
                    
                    Text("触覚フィードバック")
                        .smartText(.body)
                }
            }
            .tint(.smartPink)
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
                        .foregroundColor(.smartPink)
                        .frame(width: 24, height: 24)
                    
                    Text("パレットを自動保存")
                        .smartText(.body)
                }
            }
            .tint(.smartPink)
            
            Button(action: {
                viewModel.exportAllPalettes()
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up.on.square")
                        .foregroundColor(.smartPink)
                        .frame(width: 24, height: 24)
                    
                    Text("すべてのパレットをエクスポート")
                        .smartText(.body)
                    
                    Spacer()
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: {
                viewModel.showingImportPicker = true
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.down.on.square")
                        .foregroundColor(.smartPink)
                        .frame(width: 24, height: 24)
                    
                    Text("パレットをインポート")
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
                        .foregroundColor(.smartPink)
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
                        .foregroundColor(.smartPink)
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
                        .foregroundColor(.smartPink)
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
                        .foregroundColor(.smartPink)
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
                        .foregroundColor(.smartPink)
                        .frame(width: 24, height: 24)
                    
                    Text("プライバシーポリシー")
                        .smartText(.body)
                    
                    Spacer()
                }
            }
            
            NavigationLink(destination: TermsOfServiceView()) {
                HStack {
                    Image(systemName: "doc.text.fill")
                        .foregroundColor(.smartPink)
                        .frame(width: 24, height: 24)
                    
                    Text("利用規約")
                        .smartText(.body)
                    
                    Spacer()
                }
            }
            
            NavigationLink(destination: LicensesView()) {
                HStack {
                    Image(systemName: "scroll.fill")
                        .foregroundColor(.smartPink)
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
    @Published var showingExportErrorAlert = false
    @Published var showingImportPicker = false
    @Published var cacheSize = "計算中..."
    @Published var exportErrorMessage = ""
    
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
        Task {
            do {
                let allPalettes = await StorageService.shared.loadAllPalettes()
                
                guard !allPalettes.isEmpty else {
                    await MainActor.run {
                        self.showingExportErrorAlert = true
                        self.exportErrorMessage = "エクスポートするパレットがありません。"
                    }
                    return
                }
                
                let exportData = ExportData(
                    version: "1.0",
                    exportDate: Date(),
                    palettes: allPalettes,
                    totalCount: allPalettes.count
                )
                
                let jsonData = try JSONEncoder().encode(exportData)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
                let fileName = "推しパレ_エクスポート_\(dateFormatter.string(from: Date())).json"
                
                await MainActor.run {
                    self.shareExportData(jsonData, fileName: fileName)
                    HapticManager.shared.success()
                }
            } catch {
                await MainActor.run {
                    self.showingExportErrorAlert = true
                    self.exportErrorMessage = "エクスポートに失敗しました: \(error.localizedDescription)"
                    HapticManager.shared.error()
                }
            }
        }
    }
    
    private func shareExportData(_ data: Data, fileName: String) {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: tempURL)
            
            let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            activityVC.excludedActivityTypes = [.markupAsPDF]
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(activityVC, animated: true)
            }
        } catch {
            self.showingExportErrorAlert = true
            self.exportErrorMessage = "ファイルの保存に失敗しました。"
        }
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
    
    func handleImportResult(_ result: Result<[URL], Error>) {
        Task {
            do {
                let urls = try result.get()
                guard let url = urls.first else { return }
                
                let data = try Data(contentsOf: url)
                let exportData = try JSONDecoder().decode(ExportData.self, from: data)
                
                await StorageService.shared.importPalettes(exportData.palettes)
                
                await MainActor.run {
                    // インポート成功の通知
                    HapticManager.shared.success()
                }
            } catch {
                await MainActor.run {
                    self.showingExportErrorAlert = true
                    self.exportErrorMessage = "インポートに失敗しました: \(error.localizedDescription)"
                    HapticManager.shared.error()
                }
            }
        }
    }
}

// MARK: - Export Data Model
struct ExportData: Codable {
    let version: String
    let exportDate: Date
    let palettes: [ColorPalette]
    let totalCount: Int
}

// MARK: - Preview
#Preview {
    SettingsView()
}