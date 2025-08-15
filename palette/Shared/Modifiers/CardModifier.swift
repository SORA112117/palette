//
//  CardModifier.swift
//  palette
//
//  Created by Claude on 2025/08/14.
//

import SwiftUI

// MARK: - カードスタイルモディファイア
struct CardModifier: ViewModifier {
    let backgroundColor: Color
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat
    let shadowOpacity: Double
    let shadowOffset: CGSize
    
    init(
        backgroundColor: Color = Color(.systemBackground),
        cornerRadius: CGFloat = 16,
        shadowRadius: CGFloat = 8,
        shadowOpacity: Double = 0.1,
        shadowOffset: CGSize = CGSize(width: 0, height: 4)
    ) {
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
        self.shadowOpacity = shadowOpacity
        self.shadowOffset = shadowOffset
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
                    .shadow(
                        color: .black.opacity(shadowOpacity),
                        radius: shadowRadius,
                        x: shadowOffset.width,
                        y: shadowOffset.height
                    )
            )
    }
}

// MARK: - Glass Morphism Modifier
struct GlassMorphismModifier: ViewModifier {
    let backgroundColor: Color
    let opacity: Double
    let cornerRadius: CGFloat
    let blur: CGFloat
    
    init(
        backgroundColor: Color = .white,
        opacity: Double = 0.7,
        cornerRadius: CGFloat = 16,
        blur: CGFloat = 10
    ) {
        self.backgroundColor = backgroundColor
        self.opacity = opacity
        self.cornerRadius = cornerRadius
        self.blur = blur
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor.opacity(opacity))
                    .background(.ultraThinMaterial)
                    .blur(radius: blur * 0.1)
            )
    }
}

// MARK: - Neumorphism Modifier
struct NeumorphismModifier: ViewModifier {
    let backgroundColor: Color
    let cornerRadius: CGFloat
    let isPressed: Bool
    
    init(
        backgroundColor: Color = Color(.systemBackground),
        cornerRadius: CGFloat = 16,
        isPressed: Bool = false
    ) {
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.isPressed = isPressed
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
                    .shadow(
                        color: isPressed ? .clear : .black.opacity(0.2),
                        radius: isPressed ? 0 : 10,
                        x: isPressed ? 0 : -5,
                        y: isPressed ? 0 : -5
                    )
                    .shadow(
                        color: isPressed ? .clear : .white.opacity(0.7),
                        radius: isPressed ? 0 : 10,
                        x: isPressed ? 0 : 5,
                        y: isPressed ? 0 : 5
                    )
            )
    }
}

// MARK: - Floating Card Modifier
struct FloatingCardModifier: ViewModifier {
    @State private var offset: CGSize = .zero
    @State private var isDragging = false
    
    func body(content: Content) -> some View {
        content
            .offset(offset)
            .scaleEffect(isDragging ? 1.05 : 1.0)
            .rotationEffect(.degrees(Double(offset.width / 40)))
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if !isDragging {
                            isDragging = true
                        }
                        offset = value.translation
                    }
                    .onEnded { _ in
                        isDragging = false
                        withAnimation(.spring()) {
                            offset = .zero
                        }
                    }
            )
            .animation(.spring(), value: isDragging)
    }
}

// MARK: - View Extensions for Card Modifiers
extension View {
    func card(
        backgroundColor: Color = Color(.systemBackground),
        cornerRadius: CGFloat = 16,
        shadowRadius: CGFloat = 8,
        shadowOpacity: Double = 0.1
    ) -> some View {
        self.modifier(CardModifier(
            backgroundColor: backgroundColor,
            cornerRadius: cornerRadius,
            shadowRadius: shadowRadius,
            shadowOpacity: shadowOpacity
        ))
    }
    
    func glassMorphism(
        backgroundColor: Color = .white,
        opacity: Double = 0.7,
        cornerRadius: CGFloat = 16
    ) -> some View {
        self.modifier(GlassMorphismModifier(
            backgroundColor: backgroundColor,
            opacity: opacity,
            cornerRadius: cornerRadius
        ))
    }
    
    func neumorphism(
        backgroundColor: Color = Color(.systemBackground),
        cornerRadius: CGFloat = 16,
        isPressed: Bool = false
    ) -> some View {
        self.modifier(NeumorphismModifier(
            backgroundColor: backgroundColor,
            cornerRadius: cornerRadius,
            isPressed: isPressed
        ))
    }
    
    func floatingCard() -> some View {
        self.modifier(FloatingCardModifier())
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 30) {
        Text("Card Style")
            .padding()
            .card()
        
        Text("Glass Morphism")
            .padding()
            .glassMorphism()
        
        Text("Neumorphism")
            .padding()
            .neumorphism()
        
        Text("Floating Card")
            .padding()
            .card()
            .floatingCard()
    }
    .padding()
    .background(
        LinearGradient(
            colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
}