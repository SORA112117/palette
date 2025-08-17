//
//  MoreOptionsView.swift
//  palette
//
//  Created by Claude on 2025/08/15.
//

import SwiftUI

// MARK: - その他のオプション画面
struct MoreOptionsView: View {
    
    // MARK: - State
    @StateObject private var storageService = StorageService.shared
    @State private var showingAbout = false
    
    // MARK: - Body
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                // ヘッダー説明
                headerSection
                
                // 設定・カスタマイズ
                settingsSection
                
                // サポート・情報
                supportSection
                
                // アプリ情報
                appInfoSection
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(backgroundGradient)
        .navigationTitle("その他")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "gear.badge")
                .font(.system(size: 48))
                .foregroundColor(Color(red: 0.6, green: 0.8, blue: 0.4))
            
            VStack(spacing: 8) {
                Text("設定とサポート")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("アプリの設定やサポート情報")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Settings Section
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("設定・カスタマイズ")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                // アプリ設定
                MoreOptionCard(
                    title: "アプリ設定",
                    subtitle: "テーマ、通知、その他の設定",
                    icon: "gearshape.fill",
                    iconColor: Color(red: 0.5, green: 0.5, blue: 0.5),
                    action: {
                        NavigationRouter.shared.homePath.append(NavigationDestination.about) // TODO: 設定画面
                    }
                )
                
                // ハプティック設定
                MoreOptionCard(
                    title: "ハプティックフィードバック",
                    subtitle: storageService.hapticFeedbackEnabled ? "オン" : "オフ",
                    icon: "iphone.radiowaves.left.and.right",
                    iconColor: Color(red: 1.0, green: 0.6, blue: 0.0),
                    hasToggle: true,
                    toggleValue: storageService.hapticFeedbackEnabled,
                    toggleAction: {
                        storageService.hapticFeedbackEnabled.toggle()
                    }
                )
                
                // 色抽出品質
                MoreOptionCard(
                    title: "色抽出品質",
                    subtitle: storageService.colorExtractionQuality.displayName,
                    icon: "eye.fill",
                    iconColor: Color(red: 0.3, green: 0.8, blue: 0.9),
                    action: {
                        // TODO: 品質設定画面
                        NavigationRouter.shared.showAlert(AlertItem(
                            title: "品質設定",
                            message: "詳細設定画面は今後追加予定です"
                        ))
                    }
                )
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
            )
        }
    }
    
    // MARK: - Support Section
    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("サポート・ヘルプ")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                // ヘルプ・チュートリアル
                MoreOptionCard(
                    title: "ヘルプ・チュートリアル",
                    subtitle: "アプリの使い方を確認",
                    icon: "questionmark.circle.fill",
                    iconColor: Color(red: 0.2, green: 0.7, blue: 1.0),
                    action: {
                        // TODO: ヘルプ画面
                        NavigationRouter.shared.showAlert(AlertItem(
                            title: "ヘルプ",
                            message: "ヘルプ機能は今後追加予定です"
                        ))
                    }
                )
                
                // フィードバック
                MoreOptionCard(
                    title: "フィードバック送信",
                    subtitle: "改善提案やバグ報告",
                    icon: "envelope.fill",
                    iconColor: Color(red: 0.8, green: 0.3, blue: 0.9),
                    action: {
                        sendFeedback()
                    }
                )
                
                // レビュー
                MoreOptionCard(
                    title: "App Storeでレビュー",
                    subtitle: "アプリを評価してください",
                    icon: "star.fill",
                    iconColor: Color(red: 1.0, green: 0.8, blue: 0.0),
                    action: {
                        requestReview()
                    }
                )
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
            )
        }
    }
    
    // MARK: - App Info Section
    private var appInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("アプリ情報")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                // アプリについて
                MoreOptionCard(
                    title: "推しパレについて",
                    subtitle: "バージョン情報・開発者情報",
                    icon: "info.circle.fill",
                    iconColor: Color(red: 1.0, green: 0.4, blue: 0.6),
                    action: {
                        showingAbout = true
                    }
                )
                
                // プライバシーポリシー
                MoreOptionCard(
                    title: "プライバシーポリシー",
                    subtitle: "個人情報の取り扱いについて",
                    icon: "hand.raised.fill",
                    iconColor: Color(red: 0.5, green: 0.8, blue: 0.5),
                    action: {
                        NavigationRouter.shared.homePath.append(NavigationDestination.privacyPolicy)
                    }
                )
                
                // 利用規約
                MoreOptionCard(
                    title: "利用規約",
                    subtitle: "アプリの利用条件",
                    icon: "doc.text.fill",
                    iconColor: Color(red: 0.2, green: 0.7, blue: 1.0),
                    action: {
                        NavigationRouter.shared.homePath.append(NavigationDestination.terms)
                    }
                )
                
                // ライセンス
                MoreOptionCard(
                    title: "ライセンス情報",
                    subtitle: "オープンソースライセンス",
                    icon: "books.vertical.fill",
                    iconColor: Color(red: 0.8, green: 0.5, blue: 0.9),
                    action: {
                        NavigationRouter.shared.homePath.append(NavigationDestination.licenses)
                    }
                )
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
            )
        }
    }
    
    // MARK: - Background Gradient
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(.systemBackground),
                Color(red: 0.6, green: 0.8, blue: 0.4).opacity(0.05)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Helper Methods
    
    private func sendFeedback() {
        // TODO: フィードバック送信機能
        NavigationRouter.shared.showAlert(AlertItem(
            title: "フィードバック",
            message: "フィードバック機能は今後追加予定です"
        ))
    }
    
    private func requestReview() {
        // TODO: App Store レビュー要求
        NavigationRouter.shared.showAlert(AlertItem(
            title: "レビュー",
            message: "App Store レビュー機能は今後追加予定です"
        ))
    }
}

// MARK: - More Option Card
struct MoreOptionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let iconColor: Color
    let hasToggle: Bool
    let toggleValue: Bool
    let toggleAction: (() -> Void)?
    let action: (() -> Void)?
    
    init(
        title: String,
        subtitle: String,
        icon: String,
        iconColor: Color,
        hasToggle: Bool = false,
        toggleValue: Bool = false,
        toggleAction: (() -> Void)? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.iconColor = iconColor
        self.hasToggle = hasToggle
        self.toggleValue = toggleValue
        self.toggleAction = toggleAction
        self.action = action
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // アイコン
            Image(systemName: icon)
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(iconColor)
                .frame(width: 28, height: 28)
            
            // テキスト部分
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            // トグルまたは矢印
            if hasToggle {
                Toggle("", isOn: Binding<Bool>(
                    get: { toggleValue },
                    set: { _ in toggleAction?() }
                ))
                .labelsHidden()
                .tint(iconColor)
            } else {
                Button(action: {
                    action?()
                }) {
                    Image(systemName: "chevron.right")
                        .font(.subheadline)
                        .foregroundColor(.secondary.opacity(0.6))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            if !hasToggle {
                action?()
            }
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        MoreOptionsView()
    }
}