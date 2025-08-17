//
//  HapticManager.swift
//  palette
//
//  Created by Claude on 2025/08/14.
//

import UIKit
import CoreHaptics

// MARK: - ハプティックフィードバック管理
@MainActor
class HapticManager: HapticProviding {
    
    // MARK: - Singleton
    static let shared = HapticManager()
    
    // MARK: - Properties
    private var engine: CHHapticEngine?
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let notificationFeedback = UINotificationFeedbackGenerator()
    
    // MARK: - Initialization
    private init() {
        prepareHaptics()
    }
    
    // MARK: - Setup
    
    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("ハプティックエンジンの初期化エラー: \(error)")
        }
        
        // フィードバックジェネレーターの準備
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        selectionFeedback.prepare()
        notificationFeedback.prepare()
    }
    
    // MARK: - Impact Feedback
    
    /// 軽いタップフィードバック
    func lightImpact() {
        Task { @MainActor in
            guard StorageService.shared.hapticFeedbackEnabled else { return }
            impactLight.impactOccurred()
        }
    }
    
    /// 中程度のタップフィードバック
    func mediumImpact() {
        Task { @MainActor in
            guard StorageService.shared.hapticFeedbackEnabled else { return }
            impactMedium.impactOccurred()
        }
    }
    
    /// 重いタップフィードバック
    func heavyImpact() {
        Task { @MainActor in
            guard StorageService.shared.hapticFeedbackEnabled else { return }
            impactHeavy.impactOccurred()
        }
    }
    
    // MARK: - Selection Feedback
    
    /// 選択変更フィードバック
    func selectionChanged() {
        Task { @MainActor in
            guard StorageService.shared.hapticFeedbackEnabled else { return }
            selectionFeedback.selectionChanged()
        }
    }
    
    // MARK: - Notification Feedback
    
    /// 成功フィードバック
    func success() {
        Task { @MainActor in
            guard StorageService.shared.hapticFeedbackEnabled else { return }
            notificationFeedback.notificationOccurred(.success)
        }
    }
    
    /// 警告フィードバック
    func warning() {
        Task { @MainActor in
            guard StorageService.shared.hapticFeedbackEnabled else { return }
            notificationFeedback.notificationOccurred(.warning)
        }
    }
    
    /// エラーフィードバック
    func error() {
        Task { @MainActor in
            guard StorageService.shared.hapticFeedbackEnabled else { return }
            notificationFeedback.notificationOccurred(.error)
        }
    }
    
    // MARK: - Custom Haptic Patterns
    
    /// 色選択時のカスタムパターン
    func colorSelection() {
        Task { @MainActor in
            guard StorageService.shared.hapticFeedbackEnabled else { return }
            
            Task {
                await playCustomPattern(
                    intensity: 0.8,
                    sharpness: 0.9,
                    duration: 0.1
                )
            }
        }
    }
    
    /// パレット保存時のカスタムパターン
    func paletteSaved() {
        Task { @MainActor in
            guard StorageService.shared.hapticFeedbackEnabled else { return }
            
            Task {
                // 短い振動を2回
                await playCustomPattern(intensity: 0.6, sharpness: 0.5, duration: 0.1)
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1秒待機
                await playCustomPattern(intensity: 0.8, sharpness: 0.7, duration: 0.15)
            }
        }
    }
    
    /// スワイプ削除時のカスタムパターン
    func swipeDelete() {
        Task { @MainActor in
            guard StorageService.shared.hapticFeedbackEnabled else { return }
            
            Task {
                await playCustomPattern(
                    intensity: 0.9,
                    sharpness: 0.3,
                    duration: 0.2
                )
            }
        }
    }
    
    /// 壁紙生成完了時のカスタムパターン
    func wallpaperGenerated() {
        Task { @MainActor in
            guard StorageService.shared.hapticFeedbackEnabled else { return }
            
            Task {
                // 徐々に強くなる振動
                for i in 1...3 {
                    await playCustomPattern(
                        intensity: Float(Double(i) * 0.3),
                        sharpness: 0.6,
                        duration: 0.1
                    )
                    try? await Task.sleep(nanoseconds: 50_000_000) // 0.05秒待機
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func playCustomPattern(intensity: Float, sharpness: Float, duration: TimeInterval) async {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics,
              let engine = engine else { return }
        
        do {
            let pattern = try createHapticPattern(
                intensity: intensity,
                sharpness: sharpness,
                duration: duration
            )
            
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("カスタムハプティックパターンエラー: \(error)")
        }
    }
    
    private func createHapticPattern(
        intensity: Float,
        sharpness: Float,
        duration: TimeInterval
    ) throws -> CHHapticPattern {
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
            ],
            relativeTime: 0,
            duration: duration
        )
        
        return try CHHapticPattern(events: [event], parameters: [])
    }
}

// MARK: - SwiftUI View Extension

import SwiftUI

extension View {
    /// タップ時にハプティックフィードバックを発生させる
    func hapticTap(_ style: HapticStyle = .light) -> some View {
        self.onTapGesture {
            switch style {
            case .light:
                HapticManager.shared.lightImpact()
            case .medium:
                HapticManager.shared.mediumImpact()
            case .heavy:
                HapticManager.shared.heavyImpact()
            case .selection:
                HapticManager.shared.selectionChanged()
            case .success:
                HapticManager.shared.success()
            case .warning:
                HapticManager.shared.warning()
            case .error:
                HapticManager.shared.error()
            }
        }
    }
}

// MARK: - Haptic Style

enum HapticStyle {
    case light
    case medium
    case heavy
    case selection
    case success
    case warning
    case error
}