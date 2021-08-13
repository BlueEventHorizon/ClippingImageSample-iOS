//
//  UIImageView+Copy.swift
//  ClippingImageSample
//
//  Created by Katsuhiko Terada on 2021/08/13.
//

import UIKit

extension UIImageView {
    
    /// 指定した領域の画像をコピーして返す
    /// - Parameter rect: コピーする領域。nilの場合は全領域をコピーする
    /// - Returns: コピーされた画像
    func copyImage(inRange rect: CGRect? = nil) -> UIImage? {
        
        guard let image = self.image else { return nil }
        
        let rectForView = rect ?? CGRect(origin: .zero, size: self.frame.size)
        
        let rectForImage = convertImageOrigin(from: rectForView)
        
        if let copiedCgImage = image.cgImage?.cropping(to: rectForImage) {
            return UIImage(cgImage: copiedCgImage)
        }

        return nil
    }

    /// UIImageView とその UIImage の size が異なるのでUIImageView の Rect から UIImage の Rect に変換する
    /// https://qiita.com/noby111/items/a7e72f95108711ebb8a3
    /// - Parameters:
    ///   - rect: UIImageView上の任意のRect
    /// - Returns: 与えられたrectに対応するUIImage上のRect
    func convertImageOrigin(from rect: CGRect) -> CGRect {

        guard let image = self.image else { return .zero }

        let imageOrientation = image.imageOrientation

        let scaleX = image.size.width / self.frame.size.width
        let scaleY = image.size.height / self.frame.size.height
        
        var transform: CGAffineTransform
        
        switch imageOrientation {
                case .left:
                    transform = CGAffineTransform(rotationAngle: .pi / 2).translatedBy(x: 0, y: -image.size.height)
                case .right:
                    transform = CGAffineTransform(rotationAngle: -.pi / 2).translatedBy(x: -image.size.width, y: 0)
                case .down:
                    transform = CGAffineTransform(rotationAngle: -.pi).translatedBy(x: -image.size.width, y: -image.size.height)
                default:
                    transform = .identity
        }
        
        transform = transform.scaledBy(x: scaleX, y: scaleY)

        return rect.applying(transform)
    }
}
