//
//  FAQView.swift
//  palette
//
//  Created by Claude on 2025/08/16.
//

import SwiftUI

// MARK: - FAQ画面
struct FAQView: View {
    
    // MARK: - State
    @State private var searchText = ""
    @State private var expandedItems: Set<Int> = []
    
    // MARK: - FAQ Data
    private let faqItems: [FAQItem] = [
        FAQItem(
            id: 0,
            category: "基本的な使い方",
            question: "推しパレとは何ですか？",
            answer: "推しパレは、お気に入りの写真から美しい色のパレットを作成するiOSアプリです。写真を選択するだけで、その画像の主要な色を自動的に抽出し、あなただけのカラーパレットを作成できます。デザインやアートプロジェクトでカラーリファレンスとして活用できます。"
        ),
        FAQItem(
            id: 1,
            category: "基本的な使い方",
            question: "パレットの作成方法を教えてください",
            answer: "パレット作成には2つの方法があります：\n\n1. 自動抽出：「パレットを作成」→「自動抽出」で写真を選択し、抽出する色数を設定して「色を抽出開始」をタップします。\n\n2. 手動作成：「手動で作成」でカラーピッカーから好きな色を選んで追加していきます。最大10色まで選択可能です。"
        ),
        FAQItem(
            id: 2,
            category: "基本的な使い方",
            question: "パレットはどこで確認できますか？",
            answer: "作成・保存したパレットは、アプリ下部の「ギャラリー」タブで確認できます。ここで全てのパレットを一覧表示し、詳細確認、編集、削除、共有などの操作が可能です。"
        ),
        FAQItem(
            id: 3,
            category: "機能について",
            question: "色の抽出はどのように行われますか？",
            answer: "推しパレは高度な色解析アルゴリズムを使用して、画像内の色を分析します。類似色をグループ化し、各色の使用頻度を計算して、最も代表的な色を選択します。抽出する色数は3〜10色の範囲で設定できます。"
        ),
        FAQItem(
            id: 4,
            category: "機能について",
            question: "どのような写真が色抽出に適していますか？",
            answer: "以下のような写真が色抽出に適しています：\n\n• 解像度が高く、鮮明な画像\n• 色のバリエーションが豊富な画像\n• コントラストがはっきりしている画像\n• 自然の風景、アートワーク、ファッション写真など\n\n暗すぎる画像や色の種類が少ない画像では、期待した結果が得られない場合があります。"
        ),
        FAQItem(
            id: 5,
            category: "機能について",
            question: "パレットに名前を付けることはできますか？",
            answer: "はい、パレット保存時に自由に名前を付けることができます。名前を入力しない場合は、自動的に「自動抽出パレット(5色)」や「手動作成パレット」などのデフォルト名が付けられます。"
        ),
        FAQItem(
            id: 6,
            category: "トラブルシューティング",
            question: "色抽出に失敗する場合はどうすればよいですか？",
            answer: "以下を確認してください：\n\n• 画像の解像度が十分か確認\n• より鮮明でコントラストの高い画像を試す\n• 抽出する色数を少なくしてみる\n• アプリを再起動してみる\n\nそれでも問題が解決しない場合は、設定の「お問い合わせ」からご連絡ください。"
        ),
        FAQItem(
            id: 7,
            category: "トラブルシューティング",
            question: "写真にアクセスできないというエラーが出ます",
            answer: "iOSの設定で写真へのアクセス許可が必要です：\n\n1. 設定アプリを開く\n2. 「プライバシーとセキュリティ」をタップ\n3. 「写真」をタップ\n4. 「推しパレ」を見つけて、「選択した写真」または「すべての写真」を選択\n\nアクセス許可を変更した後、アプリを再起動してください。"
        ),
        FAQItem(
            id: 8,
            category: "データ管理",
            question: "作成したパレットはどこに保存されますか？",
            answer: "パレットはお使いのデバイス内にローカル保存されます。iCloudには自動同期されませんが、安全にプライベートな状態で保管されます。アプリを削除すると、保存されたパレットも削除されるのでご注意ください。"
        ),
        FAQItem(
            id: 9,
            category: "データ管理",
            question: "パレットを他のデバイスと同期できますか？",
            answer: "現在のバージョンでは、デバイス間でのパレット同期機能は提供されていません。各デバイスでローカルに保存されます。パレットを他のデバイスに移したい場合は、共有機能を使って画像として保存し、他のデバイスに送信してください。"
        ),
        FAQItem(
            id: 10,
            category: "データ管理",
            question: "パレットを削除するには？",
            answer: "ギャラリータブでパレットを長押しすると、削除オプションが表示されます。また、パレットの詳細画面からも削除できます。削除したパレットは復元できないので、重要なパレットは事前に共有機能で保存することをおすすめします。"
        ),
        FAQItem(
            id: 11,
            category: "共有・エクスポート",
            question: "パレットを他の人と共有できますか？",
            answer: "はい、作成したパレットは画像として共有できます。パレットの詳細画面で共有ボタンをタップすると、メール、メッセージ、SNSなど様々な方法で共有可能です。色のコード情報も含まれるので、受け取った人もその色を再現できます。"
        ),
        FAQItem(
            id: 12,
            category: "共有・エクスポート",
            question: "パレットの色コードを確認できますか？",
            answer: "はい、パレットの詳細画面で各色をタップすると、HEXコード、RGB値、HSL値などの詳細な色情報を確認できます。これらの値をデザインソフトやWebデザインで直接使用できます。"
        )
    ]
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // 検索バー
            searchSection
            
            // FAQ リスト
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 16) {
                    ForEach(filteredFAQItems) { item in
                        FAQItemView(
                            item: item,
                            isExpanded: expandedItems.contains(item.id)
                        ) {
                            toggleExpansion(for: item.id)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .background(Color.backgroundPrimary)
        .navigationTitle("よくある質問")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Search Section
    private var searchSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.iconSecondary)
                
                TextField("質問を検索...", text: $searchText)
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
            
            // カテゴリータグ
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(categories, id: \.self) { category in
                        CategoryTag(
                            title: category,
                            isSelected: false
                        ) {
                            // カテゴリーフィルタリング機能（今回は省略）
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(Color.surfacePrimary)
        .shadow(color: SmartTheme.shadowColor, radius: 2, y: 1)
    }
    
    // MARK: - Helper Properties
    private var filteredFAQItems: [FAQItem] {
        if searchText.isEmpty {
            return faqItems
        } else {
            return faqItems.filter {
                $0.question.localizedCaseInsensitiveContains(searchText) ||
                $0.answer.localizedCaseInsensitiveContains(searchText) ||
                $0.category.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private var categories: [String] {
        Array(Set(faqItems.map { $0.category })).sorted()
    }
    
    // MARK: - Helper Methods
    private func toggleExpansion(for id: Int) {
        withAnimation(.easeInOut(duration: 0.3)) {
            if expandedItems.contains(id) {
                expandedItems.remove(id)
            } else {
                expandedItems.insert(id)
            }
        }
        HapticManager.shared.selectionChanged()
    }
}

// MARK: - FAQ Data Model
struct FAQItem: Identifiable {
    let id: Int
    let category: String
    let question: String
    let answer: String
}

// MARK: - FAQ Item View
struct FAQItemView: View {
    let item: FAQItem
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // カテゴリータグ
            HStack {
                Text(item.category)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.smartPink)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.smartPalePink)
                    .cornerRadius(SmartTheme.cornerRadiusSmall)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // 質問
            Button(action: onTap) {
                HStack(spacing: 16) {
                    Text(item.question)
                        .smartText(.body)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.iconSecondary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .buttonStyle(PlainButtonStyle())
            
            // 回答
            if isExpanded {
                Text(item.answer)
                    .smartText(.body)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .smartCard(elevation: .medium)
    }
}

// MARK: - Category Tag
struct CategoryTag: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .textSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isSelected ? Color.smartPink : Color.surfaceSecondary
                )
                .cornerRadius(SmartTheme.cornerRadiusMedium)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        FAQView()
    }
}