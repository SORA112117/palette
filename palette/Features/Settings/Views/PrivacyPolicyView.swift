//
//  PrivacyPolicyView.swift
//  palette
//
//  Created by Claude on 2025/08/16.
//

import SwiftUI

// MARK: - プライバシーポリシー画面
struct PrivacyPolicyView: View {
    
    // MARK: - Body
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                // ヘッダー
                headerSection
                
                // 概要
                overviewSection
                
                // 収集する情報
                dataCollectionSection
                
                // 情報の使用
                dataUsageSection
                
                // 情報の共有
                dataSharingSection
                
                // データの保存
                dataStorageSection
                
                // お客様の権利
                userRightsSection
                
                // セキュリティ
                securitySection
                
                // 変更について
                changesSection
                
                // お問い合わせ
                contactSection
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(Color.backgroundPrimary)
        .navigationTitle("プライバシーポリシー")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("プライバシーポリシー")
                .smartText(.header)
            
            Text("最終更新日：2025年8月16日")
                .smartText(.captionSecondary)
            
            Text("推しパレ（以下「本アプリ」）は、お客様のプライバシーを尊重し、個人情報の保護に努めています。本プライバシーポリシーでは、本アプリがどのような情報を収集し、どのように使用するかについて説明します。")
                .smartText(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .smartCard(elevation: .medium)
    }
    
    // MARK: - Overview Section
    private var overviewSection: some View {
        PrivacySection(
            title: "概要",
            icon: "eye.fill",
            content: [
                "本アプリは、お客様の写真から色のパレットを作成する機能を提供します。",
                "お客様の個人情報やプライバシーは最優先事項です。",
                "本アプリはローカルストレージを使用し、お客様のデータを外部サーバーに送信することはありません。",
                "収集される情報は、アプリの機能向上とユーザー体験の改善のためのみに使用されます。"
            ]
        )
    }
    
    // MARK: - Data Collection Section
    private var dataCollectionSection: some View {
        PrivacySection(
            title: "収集する情報",
            icon: "doc.text.fill",
            content: [
                "写真データ：お客様が選択した写真（デバイス内でのみ処理され、外部に送信されません）",
                "作成したパレット：色の情報とお客様が設定したパレット名",
                "アプリ使用状況：クラッシュレポートやパフォーマンスデータ（匿名化されます）",
                "デバイス情報：iOSバージョン、デバイス種別（アプリの最適化のため）"
            ]
        )
    }
    
    // MARK: - Data Usage Section
    private var dataUsageSection: some View {
        PrivacySection(
            title: "情報の使用目的",
            icon: "gear.circle.fill",
            content: [
                "色抽出機能：選択された写真から色のパレットを作成するため",
                "パレット管理：作成されたパレットの保存と管理のため",
                "アプリ改善：機能向上とバグ修正のため",
                "ユーザーサポート：お客様からのお問い合わせへの対応のため"
            ]
        )
    }
    
    // MARK: - Data Sharing Section
    private var dataSharingSection: some View {
        PrivacySection(
            title: "第三者との情報共有",
            icon: "person.2.fill",
            content: [
                "本アプリは、お客様の個人情報を第三者と共有することはありません。",
                "お客様がパレットを共有機能を使用して他の人と共有する場合を除きます。",
                "法的要請がある場合や、アプリの運営上必要な場合を除き、情報の開示は行いません。",
                "匿名化された使用統計データのみ、アプリ改善の目的で分析される場合があります。"
            ]
        )
    }
    
    // MARK: - Data Storage Section
    private var dataStorageSection: some View {
        PrivacySection(
            title: "データの保存",
            icon: "internaldrive.fill",
            content: [
                "すべてのパレットデータはお客様のデバイス内にローカル保存されます。",
                "写真データは処理後、アプリ内には保存されません（お客様が選択した場合を除く）。",
                "データは暗号化されてデバイス内に安全に保管されます。",
                "アプリを削除すると、保存されたすべてのデータも削除されます。"
            ]
        )
    }
    
    // MARK: - User Rights Section
    private var userRightsSection: some View {
        PrivacySection(
            title: "お客様の権利",
            icon: "hand.raised.fill",
            content: [
                "作成したパレットの表示、編集、削除をいつでも行えます。",
                "アプリの設定からすべてのデータを削除できます。",
                "写真へのアクセス許可は、iOSの設定からいつでも変更・取り消しできます。",
                "このプライバシーポリシーに関するご質問やご懸念がある場合は、お問い合わせください。"
            ]
        )
    }
    
    // MARK: - Security Section
    private var securitySection: some View {
        PrivacySection(
            title: "セキュリティ",
            icon: "lock.shield.fill",
            content: [
                "お客様のデータの保護のため、業界標準のセキュリティ対策を実施しています。",
                "データの暗号化とセキュアな保存方法を採用しています。",
                "定期的なセキュリティ評価と改善を行っています。",
                "不正アクセスやデータ漏洩を防ぐための技術的措置を講じています。"
            ]
        )
    }
    
    // MARK: - Changes Section
    private var changesSection: some View {
        PrivacySection(
            title: "プライバシーポリシーの変更",
            icon: "doc.badge.gearshape.fill",
            content: [
                "本プライバシーポリシーは、必要に応じて更新される場合があります。",
                "重要な変更がある場合は、アプリ内で通知いたします。",
                "変更後も本アプリを継続して使用される場合、新しいポリシーに同意したものとみなされます。",
                "最新版は常にアプリ内の設定画面から確認できます。"
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
                Text("プライバシーに関するご質問やご懸念がございましたら、以下の方法でお問い合わせください：")
                    .smartText(.body)
                    .fixedSize(horizontal: false, vertical: true)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("• アプリ内の「設定」→「お問い合わせ」")
                        .smartText(.body)
                    
                    Text("• 本プライバシーポリシーは日本の法律に準拠します")
                        .smartText(.body)
                }
                
                Text("お客様のプライバシーと個人情報の保護は私たちの最優先事項です。安心して本アプリをご利用ください。")
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

// MARK: - Privacy Section
struct PrivacySection: View {
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
                ForEach(content, id: \.self) { item in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .smartText(.body)
                            .foregroundColor(.smartMediumGray)
                        
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
        PrivacyPolicyView()
    }
}