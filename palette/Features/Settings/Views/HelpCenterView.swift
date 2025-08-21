//
//  HelpCenterView.swift
//  palette
//
//  Created by Claude on 2025/08/16.
//

import SwiftUI

// MARK: - ヘルプセンター画面
struct HelpCenterView: View {
    
    // MARK: - State
    @State private var searchText = ""
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // 検索バー
            searchSection
            
            // ヘルプコンテンツ
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    // はじめに
                    gettingStartedSection
                    
                    // 基本的な使い方
                    basicUsageSection
                    
                    // よくあるトラブル
                    troubleshootingSection
                    
                    // ヒントとコツ
                    tipsSection
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .background(Color.backgroundPrimary)
        .navigationTitle("ヘルプセンター")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Search Section
    private var searchSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.iconSecondary)
                
                TextField("ヘルプを検索...", text: $searchText)
                    .smartText(.body)
                
                if !searchText.isEmpty {
                    Button("クリア") {
                        searchText = ""
                    }
                    .smartText(.captionSecondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.surfaceSecondary)
            .cornerRadius(SmartTheme.cornerRadiusMedium)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(Color.surfacePrimary)
        .shadow(color: SmartTheme.shadowColor, radius: 2, y: 1)
    }
    
    // MARK: - Getting Started Section
    private var gettingStartedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("はじめに")
                .smartText(.subtitle)
            
            VStack(spacing: 12) {
                HelpCard(
                    icon: "play.circle.fill",
                    title: "アプリの基本",
                    description: "推しパレの基本的な使い方を学びます",
                    content: "推しパレは写真から美しい色のパレットを作成するアプリです。写真を選択するだけで、その画像の主要な色を自動的に抽出できます。"
                )
                
                HelpCard(
                    icon: "photo.circle.fill",
                    title: "写真の選択",
                    description: "最適な写真の選び方",
                    content: "色が豊富で明度の高い写真を選ぶと、より美しいパレットが作成できます。コントラストがはっきりした画像がおすすめです。"
                )
                
                HelpCard(
                    icon: "paintpalette.fill",
                    title: "パレットの保存",
                    description: "作成したパレットを保存する方法",
                    content: "色の抽出が完了したら「パレット保存」ボタンをタップして名前を付けて保存します。ギャラリータブから後で確認できます。"
                )
            }
        }
        .padding(20)
        .smartCard(elevation: .medium)
    }
    
    // MARK: - Basic Usage Section
    private var basicUsageSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("基本的な使い方")
                .smartText(.subtitle)
            
            VStack(spacing: 12) {
                HelpCard(
                    icon: "1.circle.fill",
                    title: "自動色抽出",
                    description: "写真から自動で色を抽出する方法",
                    content: "ホームタブで「パレットを作成」→「自動抽出」を選択し、写真を選んで抽出する色数を設定してください。"
                )
                
                HelpCard(
                    icon: "2.circle.fill",
                    title: "手動パレット作成",
                    description: "カラーピッカーで自由に色を選ぶ方法",
                    content: "「手動で作成」を選択し、カラーピッカーで好きな色を選んで「この色を追加」をタップします。最大10色まで選択可能です。"
                )
                
                HelpCard(
                    icon: "3.circle.fill",
                    title: "パレット管理",
                    description: "保存したパレットの管理方法",
                    content: "ギャラリータブで保存したパレットを確認、編集、削除、共有できます。タップで詳細表示、長押しでオプションメニューが表示されます。"
                )
            }
        }
        .padding(20)
        .smartCard(elevation: .medium)
    }
    
    // MARK: - Troubleshooting Section
    private var troubleshootingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("よくあるトラブル")
                .smartText(.subtitle)
            
            VStack(spacing: 12) {
                HelpCard(
                    icon: "exclamationmark.triangle.fill",
                    title: "色抽出がうまくいかない",
                    description: "期待した色が抽出されない場合",
                    content: "画像の解像度が低すぎるか、色のバリエーションが少ない可能性があります。明度とコントラストの高い画像を試してください。"
                )
                
                HelpCard(
                    icon: "photo.badge.exclamationmark",
                    title: "写真が選択できない",
                    description: "写真ライブラリにアクセスできない場合",
                    content: "設定アプリ→プライバシーとセキュリティ→写真で、推しパレへのアクセスを許可してください。"
                )
                
                HelpCard(
                    icon: "icloud.and.arrow.down",
                    title: "パレットが保存されない",
                    description: "作成したパレットが保存できない場合",
                    content: "ストレージ容量が不足している可能性があります。設定からキャッシュをクリアするか、不要なファイルを削除してください。"
                )
            }
        }
        .padding(20)
        .smartCard(elevation: .medium)
    }
    
    // MARK: - Tips Section
    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("ヒントとコツ")
                .smartText(.subtitle)
            
            VStack(spacing: 12) {
                HelpCard(
                    icon: "lightbulb.fill",
                    title: "美しいパレットのコツ",
                    description: "より魅力的なパレット作成のために",
                    content: "自然の風景、アートワーク、ファッション写真など、プロが撮影した高品質な画像を使用すると美しいパレットが作成できます。"
                )
                
                HelpCard(
                    icon: "star.fill",
                    title: "色数の選択",
                    description: "最適な色数の決め方",
                    content: "3-5色：シンプルで洗練されたパレット\n6-8色：バランスの取れたパレット\n9-10色：詳細で豊富なパレット"
                )
                
                HelpCard(
                    icon: "square.and.arrow.up",
                    title: "パレットの活用",
                    description: "作成したパレットの使い道",
                    content: "デザインプロジェクト、絵画、インテリア、ファッションコーディネートなど、様々な創作活動でカラーリファレンスとして活用できます。"
                )
            }
        }
        .padding(20)
        .smartCard(elevation: .medium)
    }
}

// MARK: - Help Card
struct HelpCard: View {
    let icon: String
    let title: String
    let description: String
    let content: String
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
                HapticManager.shared.selectionChanged()
            }) {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(.smartPink)
                        .frame(width: 32, height: 32)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .smartText(.body)
                        
                        Text(description)
                            .smartText(.captionSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.iconSecondary)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                Text(content)
                    .smartText(.body)
                    .padding(.top, 8)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(16)
        .smartCard(elevation: .low)
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        HelpCenterView()
    }
}