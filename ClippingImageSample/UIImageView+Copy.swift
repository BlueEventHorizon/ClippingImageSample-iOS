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
        let scale = min(scaleX, scaleY)
        
        var transform: CGAffineTransform

        switch imageOrientation {
                case .left:
                    transform = CGAffineTransform(rotationAngle: .pi / 2).translatedBy(x: 0, y: -image.size.height).scaledBy(x: scale, y: scale)
                case .right:
                    transform = CGAffineTransform(rotationAngle: -.pi / 2).translatedBy(x: -image.size.width, y: 0).scaledBy(x: scale, y: scale)
                case .down:
                    transform = CGAffineTransform(rotationAngle: -.pi).translatedBy(x: -image.size.width, y: -image.size.height).scaledBy(x: scale, y: scale)
                default:
                    transform = .identity
        }

        if scaleX > scaleY {
            // この場合、 imageView に対して image が横に長く、左右がcroppingされている
            // 左側でcroppingされているoffsetを求めて移動させる
            let offset = (image.size.width - self.frame.width * scale) / 2
            transform = transform.translatedBy(x: offset, y: 0)
            
        } else if scaleX < scaleY {
            // この場合、 imageView に対して image が縦に長く、上下がcroppingされている
            // 左側でcroppingされているoffsetを求めて移動させる
            let offset = (image.size.height - self.frame.height * scale) / 2
            transform = transform.translatedBy(x: 0, y: offset)
        } else {
            // 全画像がcroppingされずに表示されているはずなので、何もしない
        }

        transform = transform.scaledBy(x: scale, y: scale)

        return rect.applying(transform)
    }
}
