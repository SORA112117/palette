//
//  TermsOfServiceView.swift
//  palette
//
//  Created by Claude on 2025/08/16.
//

import SwiftUI

// MARK: - 利用規約画面
struct TermsOfServiceView: View {
    
    // MARK: - Body
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                // ヘッダー
                headerSection
                
                // 利用規約の適用
                applicationSection
                
                // サービスの内容
                serviceContentSection
                
                // 利用条件
                usageConditionsSection
                
                // 禁止事項
                prohibitedActsSection
                
                // 知的財産権
                intellectualPropertySection
                
                // 免責事項
                disclaimerSection
                
                // サービスの変更・停止
                serviceChangesSection
                
                // 利用規約の変更
                termsChangesSection
                
                // 準拠法・管轄
                jurisdictionSection
                
                // お問い合わせ
                contactSection
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(Color.backgroundPrimary)
        .navigationTitle("利用規約")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("利用規約")
                .smartText(.header)
            
            Text("最終更新日：2025年8月16日")
                .smartText(.captionSecondary)
            
            Text("この利用規約（以下「本規約」）は、推しパレ（以下「本アプリ」）の利用に関する条件を定めるものです。本アプリをご利用いただく前に、必ず本規約をお読みください。")
                .smartText(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .smartCard(elevation: .medium)
    }
    
    // MARK: - Application Section
    private var applicationSection: some View {
        TermsSection(
            title: "第1条 利用規約の適用",
            icon: "doc.text.circle.fill",
            content: [
                "本規約は、お客様が本アプリを利用する際に適用されます。",
                "本アプリをダウンロード、インストール、または使用することにより、お客様は本規約に同意したものとみなされます。",
                "本規約に同意いただけない場合は、本アプリをご利用いただくことはできません。",
                "本規約は、関連するプライバシーポリシーと併せて適用されます。"
            ]
        )
    }
    
    // MARK: - Service Content Section
    private var serviceContentSection: some View {
        TermsSection(
            title: "第2条 サービスの内容",
            icon: "paintpalette.fill",
            content: [
                "本アプリは、お客様が選択した写真から色のパレットを作成する機能を提供します。",
                "自動色抽出機能：画像解析により主要な色を自動的に抽出します。",
                "手動パレット作成機能：カラーピッカーを使用してカスタムパレットを作成できます。",
                "パレット管理機能：作成したパレットの保存、編集、削除、共有が可能です。",
                "サービス内容は、アプリのアップデートにより変更される場合があります。"
            ]
        )
    }
    
    // MARK: - Usage Conditions Section
    private var usageConditionsSection: some View {
        TermsSection(
            title: "第3条 利用条件",
            icon: "checkmark.shield.fill",
            content: [
                "本アプリは、iOS 16.0以降を搭載したデバイスでご利用いただけます。",
                "写真へのアクセス権限の許可が必要です。",
                "お客様ご自身が撮影または正当な権利を有する写真のみをご使用ください。",
                "商用利用を含め、個人の創作活動での利用は自由です。",
                "アプリの機能を正常に使用する範囲での利用に限ります。"
            ]
        )
    }
    
    // MARK: - Prohibited Acts Section
    private var prohibitedActsSection: some View {
        TermsSection(
            title: "第4条 禁止事項",
            icon: "xmark.shield.fill",
            content: [
                "他者の著作権、肖像権、プライバシー権を侵害する行為",
                "本アプリのリバースエンジニアリング、逆コンパイル、逆アセンブル",
                "本アプリの機能を悪用したスパムやマルウェアの作成・配布",
                "他のユーザーや第三者に迷惑をかける行為",
                "法令に違反する行為や公序良俗に反する行為",
                "本アプリのサーバーやネットワークに過度な負荷をかける行為",
                "その他、当方が不適切と判断する行為"
            ]
        )
    }
    
    // MARK: - Intellectual Property Section
    private var intellectualPropertySection: some View {
        TermsSection(
            title: "第5条 知的財産権",
            icon: "c.circle.fill",
            content: [
                "本アプリに関するすべての知的財産権は当方に帰属します。",
                "お客様が作成したパレットの権利はお客様に帰属します。",
                "お客様が使用する写真の著作権等の権利は、元の権利者に帰属します。",
                "本アプリの商標、ロゴ、デザインの無断使用は禁止されています。"
            ]
        )
    }
    
    // MARK: - Disclaimer Section
    private var disclaimerSection: some View {
        TermsSection(
            title: "第6条 免責事項",
            icon: "exclamationmark.triangle.fill",
            content: [
                "本アプリは「現状有姿」で提供され、明示または黙示の保証はありません。",
                "色抽出の精度や結果について保証するものではありません。",
                "本アプリの利用により生じた損害について、当方は一切の責任を負いません。",
                "デバイスの故障、データの損失等について当方は責任を負いません。",
                "第三者のサービスとの連携部分について、当方は責任を負いません。"
            ]
        )
    }
    
    // MARK: - Service Changes Section
    private var serviceChangesSection: some View {
        TermsSection(
            title: "第7条 サービスの変更・停止",
            icon: "gear.circle.fill",
            content: [
                "当方は、事前の通知なくサービス内容を変更することがあります。",
                "メンテナンス、障害、その他やむを得ない事由により、一時的にサービスを停止する場合があります。",
                "サービスの提供を永続的に停止する場合は、可能な限り事前に通知いたします。",
                "サービスの変更・停止により生じた損害について、当方は責任を負いません。"
            ]
        )
    }
    
    // MARK: - Terms Changes Section
    private var termsChangesSection: some View {
        TermsSection(
            title: "第8条 利用規約の変更",
            icon: "arrow.clockwise.circle.fill",
            content: [
                "当方は、必要に応じて本規約を変更することがあります。",
                "重要な変更の場合は、アプリ内で通知いたします。",
                "変更後の規約は、アプリ内での掲載をもって効力を生じます。",
                "変更後も本アプリを継続してご利用いただく場合、新しい規約に同意したものとみなされます。"
            ]
        )
    }
    
    // MARK: - Jurisdiction Section
    private var jurisdictionSection: some View {
        TermsSection(
            title: "第9条 準拠法・管轄",
            icon: "building.columns.fill",
            content: [
                "本規約は日本法に準拠し、日本法により解釈されます。",
                "本アプリに関する一切の紛争は、東京地方裁判所を第一審の専属的合意管轄裁判所とします。",
                "国際的な紛争については、日本国内の法的手続きに従います。"
            ]
        )
    }
    
    // MARK: - Contact Section
    private var contactSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "envelope.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.smartPink)
                
                Text("お問い合わせ")
                    .smartText(.subtitle)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("本規約に関するご質問やご不明な点がございましたら、以下の方法でお問い合わせください：")
                    .smartText(.body)
                    .fixedSize(horizontal: false, vertical: true)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("• アプリ内の「設定」→「お問い合わせ」")
                        .smartText(.body)
                    
                    Text("• 回答には数日お時間をいただく場合があります")
                        .smartText(.captionSecondary)
                }
                
                Text("快適に本アプリをご利用いただくため、本規約をご理解いただき、適切にご利用ください。")
                    .smartText(.body)
                    .foregroundColor(.smartPink)
                    .padding(.top, 8)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(20)
        .smartCard(elevation: .medium)
    }
}

// MARK: - Terms Section
struct TermsSection: View {
    let title: String
    let icon: String
    let content: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.smartPink)
                
                Text(title)
                    .smartText(.subtitle)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(content.enumerated()), id: \.offset) { index, item in
                    HStack(alignment: .top, spacing: 8) {
                        Text("\(index + 1).")
                            .smartText(.body)
                            .foregroundColor(.smartMediumGray)
                            .frame(width: 20, alignment: .leading)
                        
                        Text(item)
                            .smartText(.body)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(20)
        .smartCard(elevation: .medium)
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        TermsOfServiceView()
    }
}