//
//  LicensesView.swift
//  palette
//
//  Created by Claude on 2025/08/16.
//

import SwiftUI

// MARK: - ライセンス画面
struct LicensesView: View {
    
    // MARK: - State
    @State private var expandedLicenses: Set<Int> = []
    
    // MARK: - License Data
    private let licenses: [LicenseItem] = [
        LicenseItem(
            id: 0,
            name: "SwiftUI",
            author: "Apple Inc.",
            version: "iOS 16.0+",
            description: "SwiftUIフレームワーク",
            licenseType: "Apple Software License",
            licenseText: """
            SwiftUI framework provided by Apple Inc.
            
            Copyright (c) Apple Inc. All rights reserved.
            
            This software is provided by Apple Inc. and is subject to the Apple Software License Agreement included with the iOS SDK.
            
            SwiftUI is Apple's modern framework for building user interfaces across all Apple platforms with the power of Swift.
            """
        ),
        LicenseItem(
            id: 1,
            name: "PhotosUI",
            author: "Apple Inc.",
            version: "iOS 16.0+",
            description: "写真選択UIフレームワーク",
            licenseType: "Apple Software License",
            licenseText: """
            PhotosUI framework provided by Apple Inc.
            
            Copyright (c) Apple Inc. All rights reserved.
            
            This software is provided by Apple Inc. and is subject to the Apple Software License Agreement included with the iOS SDK.
            
            PhotosUI provides modern photo picking experiences for iOS applications.
            """
        ),
        LicenseItem(
            id: 2,
            name: "Foundation",
            author: "Apple Inc.",
            version: "iOS 16.0+",
            description: "基本的なデータ型とコレクション",
            licenseType: "Apple Software License",
            licenseText: """
            Foundation framework provided by Apple Inc.
            
            Copyright (c) Apple Inc. All rights reserved.
            
            This software is provided by Apple Inc. and is subject to the Apple Software License Agreement included with the iOS SDK.
            
            Foundation defines a base layer of functionality for apps and frameworks.
            """
        ),
        LicenseItem(
            id: 3,
            name: "UIKit",
            author: "Apple Inc.",
            version: "iOS 16.0+",
            description: "UIコンポーネントフレームワーク",
            licenseType: "Apple Software License",
            licenseText: """
            UIKit framework provided by Apple Inc.
            
            Copyright (c) Apple Inc. All rights reserved.
            
            This software is provided by Apple Inc. and is subject to the Apple Software License Agreement included with the iOS SDK.
            
            UIKit provides the core objects that you need to build apps for iOS and tvOS.
            """
        ),
        LicenseItem(
            id: 4,
            name: "Core Image",
            author: "Apple Inc.",
            version: "iOS 16.0+",
            description: "画像処理フレームワーク",
            licenseType: "Apple Software License",
            licenseText: """
            Core Image framework provided by Apple Inc.
            
            Copyright (c) Apple Inc. All rights reserved.
            
            This software is provided by Apple Inc. and is subject to the Apple Software License Agreement included with the iOS SDK.
            
            Core Image provides image processing capabilities for still and video images.
            """
        ),
        LicenseItem(
            id: 5,
            name: "Combine",
            author: "Apple Inc.",
            version: "iOS 16.0+",
            description: "リアクティブプログラミングフレームワーク",
            licenseType: "Apple Software License",
            licenseText: """
            Combine framework provided by Apple Inc.
            
            Copyright (c) Apple Inc. All rights reserved.
            
            This software is provided by Apple Inc. and is subject to the Apple Software License Agreement included with the iOS SDK.
            
            The Combine framework provides a declarative Swift API for processing values over time.
            """
        ),
        LicenseItem(
            id: 6,
            name: "StoreKit",
            author: "Apple Inc.",
            version: "iOS 16.0+",
            description: "App Storeサービスフレームワーク",
            licenseType: "Apple Software License",
            licenseText: """
            StoreKit framework provided by Apple Inc.
            
            Copyright (c) Apple Inc. All rights reserved.
            
            This software is provided by Apple Inc. and is subject to the Apple Software License Agreement included with the iOS SDK.
            
            StoreKit provides support for in-app purchases and App Store review requests.
            """
        ),
        LicenseItem(
            id: 7,
            name: "SF Symbols",
            author: "Apple Inc.",
            version: "iOS 16.0+",
            description: "システムアイコンライブラリ",
            licenseType: "Apple Software License",
            licenseText: """
            SF Symbols provided by Apple Inc.
            
            Copyright (c) Apple Inc. All rights reserved.
            
            SF Symbols provides a library of iconography designed to integrate seamlessly with San Francisco, the system font for Apple platforms.
            
            The symbols are provided for use in applications and may be subject to additional restrictions. Please refer to Apple's SF Symbols license agreement for complete terms.
            """
        )
    ]
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // ヘッダー情報
            headerSection
            
            // ライセンス一覧
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 16) {
                    ForEach(licenses) { license in
                        LicenseItemView(
                            license: license,
                            isExpanded: expandedLicenses.contains(license.id)
                        ) {
                            toggleExpansion(for: license.id)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .background(Color.backgroundPrimary)
        .navigationTitle("ライセンス")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Text("オープンソースライセンス")
                    .smartText(.subtitle)
                
                Text("推しパレで使用している主要なフレームワークとライブラリのライセンス情報です。これらの優れたソフトウェアの開発者の皆様に感謝いたします。")
                    .smartText(.body)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("総ライセンス数")
                        .smartText(.captionSecondary)
                    Text("\(licenses.count)")
                        .smartText(.subtitle)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("主要フレームワーク")
                        .smartText(.captionSecondary)
                    Text("Apple SDK")
                        .smartText(.subtitle)
                }
            }
        }
        .padding(20)
        .smartCard(elevation: .medium)
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }
    
    // MARK: - Helper Methods
    private func toggleExpansion(for id: Int) {
        withAnimation(.easeInOut(duration: 0.3)) {
            if expandedLicenses.contains(id) {
                expandedLicenses.remove(id)
            } else {
                expandedLicenses.insert(id)
            }
        }
        HapticManager.shared.selectionChanged()
    }
}

// MARK: - License Data Model
struct LicenseItem: Identifiable {
    let id: Int
    let name: String
    let author: String
    let version: String
    let description: String
    let licenseType: String
    let licenseText: String
}

// MARK: - License Item View
struct LicenseItemView: View {
    let license: LicenseItem
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // ライセンス情報ヘッダー
            Button(action: onTap) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(license.name)
                                .smartText(.subtitle)
                            
                            Text("by \(license.author)")
                                .smartText(.captionSecondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(license.version)
                                .smartText(.captionSecondary)
                            
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.iconSecondary)
                        }
                    }
                    
                    Text(license.description)
                        .smartText(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // ライセンスタイプ
                    HStack {
                        Text(license.licenseType)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.smartPink)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.smartPalePink)
                            .cornerRadius(SmartTheme.cornerRadiusSmall)
                        
                        Spacer()
                    }
                }
                .padding(20)
            }
            .buttonStyle(PlainButtonStyle())
            
            // ライセンステキスト
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Divider()
                        .background(Color.borderPrimary)
                    
                    Text("ライセンス全文")
                        .smartText(.subtitle)
                    
                    ScrollView(.vertical) {
                        Text(license.licenseText)
                            .smartText(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .background(Color.surfaceSecondary)
                            .cornerRadius(SmartTheme.cornerRadiusMedium)
                    }
                    .frame(maxHeight: 300)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .smartCard(elevation: .medium)
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        LicensesView()
    }
}