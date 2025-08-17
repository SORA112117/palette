//
//  ContactSupportView.swift
//  palette
//
//  Created by Claude on 2025/08/16.
//

import SwiftUI
import MessageUI

// MARK: - お問い合わせ画面
struct ContactSupportView: View {
    
    // MARK: - State
    @StateObject private var viewModel = ContactSupportViewModel()
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // ヘッダー情報
                headerSection
                
                // お問い合わせフォーム
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        contactFormSection
                        quickHelpSection
                        systemInfoSection
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("お問い合わせ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                    .smartText(.body)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("送信") {
                        viewModel.sendSupportEmail()
                    }
                    .smartText(.body)
                    .disabled(!viewModel.isFormValid)
                    .foregroundColor(viewModel.isFormValid ? .smartBlack : .smartMediumGray)
                }
            }
        }
        .sheet(isPresented: $viewModel.showingMailComposer) {
            if MFMailComposeViewController.canSendMail() {
                MailComposeView(
                    subject: viewModel.subject,
                    messageBody: viewModel.composedMessage,
                    onComplete: { result in
                        viewModel.handleMailResult(result)
                    }
                )
            } else {
                MailUnavailableView()
            }
        }
        .alert("送信完了", isPresented: $viewModel.showingSuccessAlert) {
            Button("閉じる") {
                dismiss()
            }
        } message: {
            Text("お問い合わせを送信しました。回答までお時間をいただく場合があります。")
        }
        .alert("エラー", isPresented: $viewModel.showingErrorAlert) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                Image(systemName: "envelope.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.smartBlack)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("サポートにお問い合わせ")
                        .smartText(.subtitle)
                    
                    Text("ご質問やご要望をお聞かせください")
                        .smartText(.bodySecondary)
                }
                
                Spacer()
            }
            
            Text("お困りのことがありましたら、下記フォームからお気軽にお問い合わせください。通常24時間以内に回答いたします。")
                .smartText(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .smartCard(elevation: .medium)
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }
    
    // MARK: - Contact Form Section
    private var contactFormSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("お問い合わせ内容")
                .smartText(.subtitle)
            
            // カテゴリー選択
            VStack(alignment: .leading, spacing: 12) {
                Text("カテゴリー")
                    .smartText(.body)
                
                Picker("カテゴリー", selection: $viewModel.selectedCategory) {
                    ForEach(ContactCategory.allCases, id: \.self) { category in
                        Text(category.displayName).tag(category)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.surfaceSecondary)
                .cornerRadius(SmartTheme.cornerRadiusMedium)
            }
            
            // 件名
            VStack(alignment: .leading, spacing: 12) {
                Text("件名")
                    .smartText(.body)
                
                TextField("問題の概要を入力してください", text: $viewModel.subject)
                    .smartText(.body)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.surfaceSecondary)
                    .cornerRadius(SmartTheme.cornerRadiusMedium)
            }
            
            // 詳細
            VStack(alignment: .leading, spacing: 12) {
                Text("詳細")
                    .smartText(.body)
                
                ZStack(alignment: .topLeading) {
                    if viewModel.message.isEmpty {
                        Text("問題の詳細や再現手順をできるだけ具体的に記述してください")
                            .smartText(.bodySecondary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                    }
                    
                    TextEditor(text: $viewModel.message)
                        .smartText(.body)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.surfaceSecondary)
                        .cornerRadius(SmartTheme.cornerRadiusMedium)
                        .frame(minHeight: 120)
                }
            }
            
            // 連絡先
            VStack(alignment: .leading, spacing: 12) {
                Text("連絡先（任意）")
                    .smartText(.body)
                
                TextField("回答が必要な場合はメールアドレスを入力", text: $viewModel.contactEmail)
                    .smartText(.body)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.surfaceSecondary)
                    .cornerRadius(SmartTheme.cornerRadiusMedium)
            }
        }
        .padding(20)
        .smartCard(elevation: .medium)
    }
    
    // MARK: - Quick Help Section
    private var quickHelpSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("よくある質問")
                .smartText(.subtitle)
            
            VStack(spacing: 12) {
                QuickHelpCard(
                    icon: "questionmark.circle.fill",
                    title: "色抽出がうまくいかない",
                    description: "画像の解像度や色のコントラストを確認してください",
                    action: {
                        viewModel.selectQuickHelp(category: .technicalIssue, subject: "色抽出の問題")
                    }
                )
                
                QuickHelpCard(
                    icon: "photo.badge.exclamationmark",
                    title: "写真にアクセスできない",
                    description: "設定でアプリの写真アクセス権限を確認してください",
                    action: {
                        viewModel.selectQuickHelp(category: .technicalIssue, subject: "写真アクセス権限の問題")
                    }
                )
                
                QuickHelpCard(
                    icon: "gear.badge.exclamationmark",
                    title: "アプリがクラッシュする",
                    description: "アプリの再起動や最新バージョンへの更新をお試しください",
                    action: {
                        viewModel.selectQuickHelp(category: .bug, subject: "アプリクラッシュの報告")
                    }
                )
            }
        }
        .padding(20)
        .smartCard(elevation: .medium)
    }
    
    // MARK: - System Info Section
    private var systemInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("システム情報")
                .smartText(.subtitle)
            
            VStack(spacing: 8) {
                SystemInfoRow(label: "アプリバージョン", value: viewModel.appVersion)
                SystemInfoRow(label: "ビルド番号", value: viewModel.buildNumber)
                SystemInfoRow(label: "iOSバージョン", value: viewModel.iosVersion)
                SystemInfoRow(label: "デバイス", value: viewModel.deviceModel)
            }
            
            Text("この情報は問題の解決に役立つため、お問い合わせに自動的に含まれます。")
                .smartText(.captionSecondary)
                .padding(.top, 8)
        }
        .padding(20)
        .smartCard(elevation: .low)
    }
}

// MARK: - Quick Help Card
struct QuickHelpCard: View {
    let icon: String
    let title: String
    let description: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.smartBlack)
                    .frame(width: 32, height: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .smartText(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(description)
                        .smartText(.captionSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.iconSecondary)
            }
            .padding(16)
            .smartCard(elevation: .low)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - System Info Row
struct SystemInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .smartText(.body)
            Spacer()
            Text(value)
                .smartText(.captionSecondary)
        }
    }
}

// MARK: - Contact Category
enum ContactCategory: CaseIterable {
    case general
    case technicalIssue
    case featureRequest
    case bug
    case other
    
    var displayName: String {
        switch self {
        case .general:
            return "一般的な質問"
        case .technicalIssue:
            return "技術的な問題"
        case .featureRequest:
            return "機能のご要望"
        case .bug:
            return "バグ報告"
        case .other:
            return "その他"
        }
    }
}

// MARK: - Contact Support View Model
@MainActor
class ContactSupportViewModel: ObservableObject {
    @Published var selectedCategory: ContactCategory = .general
    @Published var subject = ""
    @Published var message = ""
    @Published var contactEmail = ""
    @Published var showingMailComposer = false
    @Published var showingSuccessAlert = false
    @Published var showingErrorAlert = false
    @Published var errorMessage: String?
    
    var isFormValid: Bool {
        !subject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
    }
    
    var buildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    }
    
    var iosVersion: String {
        UIDevice.current.systemVersion
    }
    
    var deviceModel: String {
        UIDevice.current.model
    }
    
    var composedMessage: String {
        var fullMessage = message
        fullMessage += "\n\n---\n"
        fullMessage += "カテゴリー: \(selectedCategory.displayName)\n"
        fullMessage += "アプリバージョン: \(appVersion) (\(buildNumber))\n"
        fullMessage += "iOSバージョン: \(iosVersion)\n"
        fullMessage += "デバイス: \(deviceModel)\n"
        
        if !contactEmail.isEmpty {
            fullMessage += "連絡先: \(contactEmail)\n"
        }
        
        return fullMessage
    }
    
    func selectQuickHelp(category: ContactCategory, subject: String) {
        selectedCategory = category
        self.subject = subject
        HapticManager.shared.selectionChanged()
    }
    
    func sendSupportEmail() {
        if MFMailComposeViewController.canSendMail() {
            showingMailComposer = true
        } else {
            errorMessage = "メールアプリが設定されていません。設定アプリでメールアカウントを設定してください。"
            showingErrorAlert = true
        }
    }
    
    func handleMailResult(_ result: MFMailComposeResult) {
        switch result {
        case .sent:
            showingSuccessAlert = true
            HapticManager.shared.success()
        case .cancelled:
            // 何もしない
            break
        case .failed:
            errorMessage = "メールの送信に失敗しました。しばらく後に再度お試しください。"
            showingErrorAlert = true
            HapticManager.shared.error()
        case .saved:
            // メールが下書きに保存された
            break
        @unknown default:
            break
        }
    }
}

// MARK: - Mail Compose View
struct MailComposeView: UIViewControllerRepresentable {
    let subject: String
    let messageBody: String
    let onComplete: (MFMailComposeResult) -> Void
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        composer.setToRecipients(["support@oshipa-app.example.com"]) // 実際のサポートメールアドレスに変更
        composer.setSubject(subject)
        composer.setMessageBody(messageBody, isHTML: false)
        return composer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onComplete: onComplete)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let onComplete: (MFMailComposeResult) -> Void
        
        init(onComplete: @escaping (MFMailComposeResult) -> Void) {
            self.onComplete = onComplete
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true)
            onComplete(result)
        }
    }
}

// MARK: - Mail Unavailable View
struct MailUnavailableView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "envelope.badge.exclamationmark")
                .font(.system(size: 64))
                .foregroundColor(.smartError)
            
            VStack(spacing: 16) {
                Text("メールが利用できません")
                    .smartText(.title)
                
                Text("メールアプリが設定されていないため、お問い合わせを送信できません。設定アプリでメールアカウントを設定してから再度お試しください。")
                    .smartText(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            
            Button("閉じる") {
                dismiss()
            }
            .smartButton(style: .primary)
            .padding(.horizontal, 32)
        }
        .padding(32)
    }
}

// MARK: - Preview
#Preview {
    ContactSupportView()
}