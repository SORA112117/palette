//
//  AboutAppView.swift
//  palette
//
//  Created by Claude on 2025/08/16.
//

import SwiftUI

// MARK: - アプリ情報画面
struct AboutAppView: View {
    
    // MARK: - Body
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 32) {
                // アプリアイコンとタイトル
                appHeaderSection
                
                // アプリ説明
                appDescriptionSection
                
                // 主要機能
                featuresSection
                
                // バージョン情報
                versionInfoSection
                
                // 開発者情報
                developerSection
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(Color.backgroundPrimary)
        .navigationTitle("このアプリについて")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - App Header Section
    private var appHeaderSection: some View {
        VStack(spacing: 16) {
            // アプリアイコン
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color.smartBlack, Color.smartDarkGray],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 100, height: 100)
                .overlay(
                    Image(systemName: "paintpalette.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.white)
                )
                .shadow(color: SmartTheme.shadowColor, radius: 16, y: 8)
            
            VStack(spacing: 8) {
                Text("推しパレ")
                    .smartText(.header)
                
                Text("あなたの推しの色を見つけよう")
                    .smartText(.bodySecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - App Description Section
    private var appDescriptionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("アプリについて")
                .smartText(.subtitle)
            
            Text("推しパレは、お気に入りの写真から美しい色のパレットを作成するアプリです。写真を選ぶだけで、その画像の主要な色を自動的に抽出し、あなただけのカラーパレットを作成できます。")
                .smartText(.body)
                .fixedSize(horizontal: false, vertical: true)
            
            Text("作成したパレットは保存して後から確認でき、デザインやアートプロジェクトのインスピレーションとして活用できます。")
                .smartText(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .smartCard(elevation: .medium)
    }
    
    // MARK: - Features Section
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("主要機能")
                .smartText(.subtitle)
            
            VStack(spacing: 12) {
                FeatureRow(
                    icon: "wand.and.stars",
                    title: "自動色抽出",
                    description: "写真から主要な色を自動的に抽出"
                )
                
                FeatureRow(
                    icon: "paintpalette",
                    title: "手動パレット作成",
                    description: "カラーピッカーで自由に色を選択"
                )
                
                FeatureRow(
                    icon: "photo.on.rectangle",
                    title: "ギャラリー管理",
                    description: "作成したパレットを整理・管理"
                )
                
                FeatureRow(
                    icon: "square.and.arrow.up",
                    title: "パレット共有",
                    description: "作成したパレットを画像として共有"
                )
            }
        }
        .padding(20)
        .smartCard(elevation: .medium)
    }
    
    // MARK: - Version Info Section
    private var versionInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("バージョン情報")
                .smartText(.subtitle)
            
            VStack(spacing: 8) {
                HStack {
                    Text("アプリバージョン")
                        .smartText(.body)
                    Spacer()
                    Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0")
                        .smartText(.captionSecondary)
                }
                
                HStack {
                    Text("ビルド番号")
                        .smartText(.body)
                    Spacer()
                    Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1")
                        .smartText(.captionSecondary)
                }
                
                HStack {
                    Text("最終更新")
                        .smartText(.body)
                    Spacer()
                    Text("2025年8月")
                        .smartText(.captionSecondary)
                }
            }
        }
        .padding(20)
        .smartCard(elevation: .low)
    }
    
    // MARK: - Developer Section
    private var developerSection: some View {
        VStack(spacing: 12) {
            Text("Made with ❤️ by Claude")
                .smartText(.caption)
            
            Text("このアプリは色彩の美しさを大切にする全ての人のために作られました。")
                .smartText(.captionSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.smartBlack)
                .frame(width: 40, height: 40)
                .background(Color.smartBlack.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .smartText(.body)
                
                Text(description)
                    .smartText(.captionSecondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        AboutAppView()
    }
}