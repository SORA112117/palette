//
//  ColorExtractionService.swift
//  palette
//
//  Created by Claude on 2025/08/14.
//

import Foundation
import UIKit
import CoreImage
import Accelerate

// MARK: - 色抽出サービス
class ColorExtractionService: ColorExtractionProviding, ObservableObject {
    
    // MARK: - Properties
    private let context = CIContext()
    private let maxImageSize: CGFloat = 512 // 処理効率化のための最大サイズ
    
    // MARK: - Public Methods
    
    /// 画像から主要な色を抽出する
    /// - Parameters:
    ///   - image: 処理対象の画像
    ///   - colorCount: 抽出する色の数（デフォルト: 5）
    /// - Returns: 抽出された色の配列
    func extractColors(from image: UIImage, colorCount: Int = 5) async throws -> [ExtractedColor] {
        return try await withCheckedThrowingContinuation { continuation in
            Task {
                do {
                    let colors = try await performColorExtraction(image: image, colorCount: colorCount)
                    continuation.resume(returning: colors)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// 色抽出処理の実行
    private func performColorExtraction(image: UIImage, colorCount: Int) async throws -> [ExtractedColor] {
        // 1. 画像の前処理（リサイズ）
        guard let resizedImage = resizeImage(image, maxSize: maxImageSize) else {
            throw ColorExtractionError.imageProcessingFailed
        }
        
        // 2. ピクセルデータの取得
        guard let pixelData = getPixelData(from: resizedImage) else {
            throw ColorExtractionError.pixelDataExtractionFailed
        }
        
        // 3. K-meansクラスタリングによる色抽出
        let clusters = try await performKMeansClustering(pixelData: pixelData, k: colorCount)
        
        // 4. 結果の変換
        let extractedColors = clusters.map { cluster in
            let rgb = RGBColor(red: cluster.color.red, green: cluster.color.green, blue: cluster.color.blue)
            let hsl = rgb.hsl
            return ExtractedColor(
                hexCode: rgb.hexCode,
                rgb: rgb,
                hsl: hsl,
                percentage: cluster.percentage
            )
        }
        
        // 5. 占有率順でソート
        return extractedColors.sorted { $0.percentage > $1.percentage }
    }
    
    /// 画像のリサイズ
    private func resizeImage(_ image: UIImage, maxSize: CGFloat) -> UIImage? {
        let size = image.size
        let ratio = min(maxSize / size.width, maxSize / size.height)
        
        if ratio >= 1.0 {
            return image
        }
        
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
    
    /// ピクセルデータの取得
    private func getPixelData(from image: UIImage) -> [PixelColor]? {
        guard let cgImage = image.cgImage else { return nil }
        
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let totalBytes = height * bytesPerRow
        
        var pixelData = [UInt8](repeating: 0, count: totalBytes)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
        
        guard let cgContext = context else { return nil }
        
        cgContext.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        var pixels: [PixelColor] = []
        
        for y in 0..<height {
            for x in 0..<width {
                let index = (y * width + x) * bytesPerPixel
                let red = pixelData[index]
                let green = pixelData[index + 1]
                let blue = pixelData[index + 2]
                let alpha = pixelData[index + 3]
                
                // アルファ値が十分な場合のみ追加
                if alpha > 128 {
                    pixels.append(PixelColor(
                        red: Double(red),
                        green: Double(green),
                        blue: Double(blue)
                    ))
                }
            }
        }
        
        return pixels
    }
    
    /// K-meansクラスタリング
    private func performKMeansClustering(pixelData: [PixelColor], k: Int) async throws -> [ColorCluster] {
        let maxIterations = 50
        let tolerance = 1.0
        
        // 初期センター点をランダムに選択
        var centers = selectInitialCenters(from: pixelData, count: k)
        
        for _ in 0..<maxIterations {
            // 各ピクセルを最も近いセンターに割り当て
            let assignments = assignPixelsToCenters(pixels: pixelData, centers: centers)
            
            // 新しいセンターを計算
            let newCenters = calculateNewCenters(pixels: pixelData, assignments: assignments, k: k)
            
            // 収束判定
            let maxMovement = zip(centers, newCenters).map { (old, new) in
                distance(old, new)
            }.max() ?? 0
            
            centers = newCenters
            
            if maxMovement < tolerance {
                break
            }
        }
        
        // クラスター情報を作成
        let assignments = assignPixelsToCenters(pixels: pixelData, centers: centers)
        return createClusters(centers: centers, assignments: assignments, totalPixels: pixelData.count)
    }
    
    /// 初期センター点の選択
    private func selectInitialCenters(from pixels: [PixelColor], count: Int) -> [PixelColor] {
        var centers: [PixelColor] = []
        let sampleCount = min(pixels.count, count * 10)
        let sampleStep = max(1, pixels.count / sampleCount)
        
        for i in 0..<count {
            let index = min(i * sampleStep, pixels.count - 1)
            centers.append(pixels[index])
        }
        
        return centers
    }
    
    /// ピクセルのセンターへの割り当て
    private func assignPixelsToCenters(pixels: [PixelColor], centers: [PixelColor]) -> [Int] {
        return pixels.map { pixel in
            var minDistance = Double.infinity
            var closestCenter = 0
            
            for (index, center) in centers.enumerated() {
                let dist = distance(pixel, center)
                if dist < minDistance {
                    minDistance = dist
                    closestCenter = index
                }
            }
            
            return closestCenter
        }
    }
    
    /// 新しいセンターの計算
    private func calculateNewCenters(pixels: [PixelColor], assignments: [Int], k: Int) -> [PixelColor] {
        var newCenters: [PixelColor] = []
        
        for centerIndex in 0..<k {
            let assignedPixels = zip(pixels, assignments).compactMap { pixel, assignment in
                assignment == centerIndex ? pixel : nil
            }
            
            if assignedPixels.isEmpty {
                // 割り当てられたピクセルがない場合は元のセンターを維持
                newCenters.append(pixels.randomElement() ?? PixelColor(red: 0, green: 0, blue: 0))
            } else {
                let avgRed = assignedPixels.reduce(0) { $0 + $1.red } / Double(assignedPixels.count)
                let avgGreen = assignedPixels.reduce(0) { $0 + $1.green } / Double(assignedPixels.count)
                let avgBlue = assignedPixels.reduce(0) { $0 + $1.blue } / Double(assignedPixels.count)
                
                newCenters.append(PixelColor(red: avgRed, green: avgGreen, blue: avgBlue))
            }
        }
        
        return newCenters
    }
    
    /// クラスター情報の作成
    private func createClusters(centers: [PixelColor], assignments: [Int], totalPixels: Int) -> [ColorCluster] {
        var clusters: [ColorCluster] = []
        
        for (index, center) in centers.enumerated() {
            let count = assignments.filter { $0 == index }.count
            let percentage = Double(count) / Double(totalPixels) * 100.0
            
            clusters.append(ColorCluster(
                color: center,
                percentage: percentage
            ))
        }
        
        return clusters.filter { $0.percentage > 0.1 } // 占有率0.1%未満は除外
    }
    
    /// 二つの色の距離計算（ユークリッド距離）
    private func distance(_ color1: PixelColor, _ color2: PixelColor) -> Double {
        let dr = color1.red - color2.red
        let dg = color1.green - color2.green
        let db = color1.blue - color2.blue
        return sqrt(dr * dr + dg * dg + db * db)
    }
}

// MARK: - Supporting Types

/// ピクセル色情報
struct PixelColor {
    let red: Double
    let green: Double
    let blue: Double
}

/// 色クラスター
struct ColorCluster {
    let color: PixelColor
    let percentage: Double
}

/// 色抽出エラー
enum ColorExtractionError: LocalizedError {
    case imageProcessingFailed
    case pixelDataExtractionFailed
    case clusteringFailed
    
    var errorDescription: String? {
        switch self {
        case .imageProcessingFailed:
            return "画像の処理に失敗しました"
        case .pixelDataExtractionFailed:
            return "ピクセルデータの取得に失敗しました"
        case .clusteringFailed:
            return "色の分析に失敗しました"
        }
    }
}