//
//  View+Extensions.swift
//  palette
//
//  Created by Claude on 2025/08/14.
//

import SwiftUI

// MARK: - View Extensions
extension View {
    
    // MARK: - Card Styling
    
    /// カード風のスタイリングを適用
    func cardStyle(
        backgroundColor: Color = Color(.systemBackground),
        cornerRadius: CGFloat = 16,
        shadowRadius: CGFloat = 8,
        shadowOpacity: Double = 0.1
    ) -> some View {
        self
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .shadow(color: .black.opacity(shadowOpacity), radius: shadowRadius, x: 0, y: 4)
    }
    
    /// グラスモーフィズム効果を適用
    func glassMorphism(
        backgroundColor: Color = .white,
        opacity: Double = 0.7,
        blur: CGFloat = 10,
        cornerRadius: CGFloat = 16
    ) -> some View {
        self
            .background(
                Rectangle()
                    .fill(backgroundColor.opacity(opacity))
                    .background(.ultraThinMaterial)
                    .cornerRadius(cornerRadius)
            )
    }
    
    // MARK: - Animation Extensions
    
    /// スプリングアニメーションを適用
    func springAnimation(
        response: Double = 0.5,
        dampingFraction: Double = 0.8,
        blendDuration: Double = 0
    ) -> some View {
        self.animation(
            .spring(response: response, dampingFraction: dampingFraction, blendDuration: blendDuration),
            value: UUID()
        )
    }
    
    /// バウンス効果付きのタップアニメーション
    func bounceOnTap() -> some View {
        self.modifier(BounceModifier())
    }
    
    /// シマー（ローディング）効果を適用
    func shimmer(active: Bool = true) -> some View {
        self.modifier(ShimmerModifier(active: active))
    }
    
    /// パララックス効果を適用
    func parallax(magnitude: CGFloat = 10) -> some View {
        self.modifier(ParallaxModifier(magnitude: magnitude))
    }
    
    // MARK: - Layout Extensions
    
    /// 条件付きでモディファイアを適用
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    /// オプション値に基づいてモディファイアを適用
    @ViewBuilder
    func ifLet<Value, Content: View>(_ value: Value?, transform: (Self, Value) -> Content) -> some View {
        if let value = value {
            transform(self, value)
        } else {
            self
        }
    }
    
    /// デバイスサイズに応じてスタイリングを変更
    func adaptiveSize() -> some View {
        self.modifier(AdaptiveSizeModifier())
    }
    
    // MARK: - Navigation Extensions
    
    /// ナビゲーションバーを隠す
    func hideNavigationBar() -> some View {
        self
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
    }
    
    /// カスタムナビゲーションバーを追加
    func customNavigationBar<Content: View>(
        title: String = "",
        @ViewBuilder content: () -> Content = { EmptyView() }
    ) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                content()
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .background(.ultraThinMaterial)
            
            self
        }
    }
    
    // MARK: - Error Handling
    
    /// エラー状態を表示
    func errorAlert(
        error: Binding<Error?>,
        title: String = "エラー"
    ) -> some View {
        self.alert(
            title,
            isPresented: .constant(error.wrappedValue != nil),
            actions: {
                Button("OK") {
                    error.wrappedValue = nil
                }
            },
            message: {
                if let error = error.wrappedValue {
                    Text(error.localizedDescription)
                }
            }
        )
    }
    
    // MARK: - Loading States
    
    /// ローディング状態のオーバーレイ
    func loadingOverlay(isLoading: Bool) -> some View {
        self.overlay(
            Group {
                if isLoading {
                    LoadingOverlay()
                }
            }
        )
    }
    
    // MARK: - Share Extensions
    
    /// シェア機能を追加
    func shareSheet(items: [Any], isPresented: Binding<Bool>) -> some View {
        self.sheet(isPresented: isPresented) {
            ShareSheet(items: items)
        }
    }
    
    // MARK: - Haptic Feedback
    
    /// タップ時にハプティックフィードバックを発生
    func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) -> some View {
        self.onTapGesture {
            UIImpactFeedbackGenerator(style: style).impactOccurred()
        }
    }
    
    // MARK: - Accessibility
    
    /// アクセシビリティ要素を設定
    func accessibilityElement(
        label: String,
        hint: String? = nil,
        value: String? = nil,
        traits: AccessibilityTraits = []
    ) -> some View {
        self
            .accessibilityLabel(label)
            .if(hint != nil) { view in
                view.accessibilityHint(hint!)
            }
            .if(value != nil) { view in
                view.accessibilityValue(value!)
            }
            .accessibilityAddTraits(traits)
    }
    
    // MARK: - Safe Area
    
    /// セーフエリアを無視
    func ignoreSafeArea(_ regions: SafeAreaRegions = .all) -> some View {
        self.ignoresSafeArea(regions)
    }
    
    /// セーフエリアに基づくパディングを追加
    func safeAreaPadding(_ edges: Edge.Set = .all) -> some View {
        self.padding(edges, getSafeAreaInsets(for: edges))
    }
    
    private func getSafeAreaInsets(for edges: Edge.Set) -> CGFloat {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return 0
        }
        
        let safeAreaInsets = window.safeAreaInsets
        
        if edges.contains(.top) {
            return safeAreaInsets.top
        } else if edges.contains(.bottom) {
            return safeAreaInsets.bottom
        } else if edges.contains(.leading) {
            return safeAreaInsets.left
        } else if edges.contains(.trailing) {
            return safeAreaInsets.right
        }
        
        return 0
    }
}

// MARK: - Custom Modifiers

/// バウンス効果モディファイア
struct BounceModifier: ViewModifier {
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) { isPressing in
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = isPressing
                }
            } perform: {}
    }
}

/// アダプティブサイズモディファイア
struct AdaptiveSizeModifier: ViewModifier {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    func body(content: Content) -> some View {
        content
            .padding(horizontalSizeClass == .compact ? 16 : 24)
    }
}

/// ローディングオーバーレイ
struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                
                Text("処理中...")
                    .foregroundColor(.white)
                    .font(.headline)
            }
            .padding(24)
            .background(.ultraThinMaterial)
            .cornerRadius(16)
        }
    }
}

/// シェアシート
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        Text("Card Style Example")
            .padding()
            .cardStyle()
        
        Text("Glass Morphism Example")
            .padding()
            .glassMorphism()
        
        Text("Bounce on Tap")
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .bounceOnTap()
        
        Text("Shimmer Effect")
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
            .shimmer()
    }
    .padding()
    .background(
        LinearGradient(
            colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
}