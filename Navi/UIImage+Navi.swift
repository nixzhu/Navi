//
//  UIImage+Navi.swift
//  Navi
//
//  Created by NIX on 15/9/27.
//  Copyright © 2015年 nixWork. All rights reserved.
//

import UIKit

// ref http://vocaro.com/trevor/blog/2009/10/12/resize-a-uiimage-the-right-way/
// but with better scale logic

private let screenScale = UIScreen.main.scale

// MARK: - API

public extension UIImage {

    public func navi_avatarImageWithStyle(_ avatarStyle: AvatarStyle) -> UIImage {

        var avatarImage: UIImage?

        switch avatarStyle {

        case .original:
            return self

        case .rectangle(let size):
            avatarImage = navi_centerCropWithSize(size)

        case .roundedRectangle(let size, let cornerRadius, let borderWidth):
            avatarImage = navi_centerCropWithSize(size)?.navi_roundWithCornerRadius(cornerRadius, borderWidth: borderWidth)

        case .freeform(_, let transform):
            avatarImage = transform(self)
        }

        return avatarImage ?? self
    }
}

// MARK: - Resize

public extension UIImage {

    public func navi_resizeToSize(_ size: CGSize, withTransform transform: CGAffineTransform, drawTransposed: Bool, interpolationQuality: CGInterpolationQuality) -> UIImage? {

        let pixelSize = CGSize(width: size.width * screenScale, height: size.height * screenScale)

        let newRect = CGRect(origin: CGPoint.zero, size: pixelSize).integral
        let transposedRect = CGRect(origin: CGPoint.zero, size: CGSize(width: pixelSize.height, height: pixelSize.width))

        guard let cgImage = cgImage else {
            return nil
        }
        guard let colorSpace = cgImage.colorSpace else {
            return nil
        }
        guard let bitmapContext = CGContext(data: nil, width: Int(newRect.width), height: Int(newRect.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: cgImage.bitmapInfo.rawValue) else {
            return nil
        }

        bitmapContext.concatenate(transform)

        bitmapContext.interpolationQuality = interpolationQuality

        bitmapContext.draw(cgImage, in: drawTransposed ? transposedRect : newRect)

        guard let newCGImage = bitmapContext.makeImage() else {
            return nil
        }

        let image = UIImage(cgImage: newCGImage, scale: screenScale, orientation: imageOrientation)
        return image
    }

    public func navi_transformForOrientationWithSize(_ size: CGSize) -> CGAffineTransform {

        var transform = CGAffineTransform.identity

        switch imageOrientation {

        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: .pi)

        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)

        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: .pi / -2)

        default:
            break
        }

        switch imageOrientation {

        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)

        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)

        default:
            break
        }

        return transform
    }

    public func navi_resizeToSize(_ size: CGSize, withInterpolationQuality interpolationQuality: CGInterpolationQuality) -> UIImage? {

        let drawTransposed: Bool

        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            drawTransposed = true
        default:
            drawTransposed = false
        }

        let image = navi_resizeToSize(size, withTransform: navi_transformForOrientationWithSize(size), drawTransposed: drawTransposed, interpolationQuality: interpolationQuality)
        return image
    }

    public func navi_cropWithBounds(_ bounds: CGRect) -> UIImage? {

        guard let cgImage = cgImage else {
            return nil
        }
        guard let newCGImage = cgImage.cropping(to: bounds) else {
            return nil

        }

        let image = UIImage(cgImage: newCGImage, scale: screenScale, orientation: imageOrientation)
        return image
    }

    public func navi_centerCropWithSize(_ size: CGSize) -> UIImage? {

        let pixelSize = CGSize(width: size.width * screenScale, height: size.height * screenScale)

        let horizontalRatio = pixelSize.width / self.size.width
        let verticalRatio = pixelSize.height / self.size.height

        let ratio: CGFloat

        let originalX: CGFloat
        let originalY: CGFloat

        if horizontalRatio > verticalRatio {
            ratio = horizontalRatio

            originalX = 0
            originalY = (self.size.height - pixelSize.height / ratio) / 2

        } else {
            ratio = verticalRatio

            originalX = (self.size.width - pixelSize.width / ratio) / 2
            originalY = 0
        }

        let bounds = CGRect(x: originalX, y: originalY, width: pixelSize.width / ratio, height: pixelSize.height / ratio)

        let image = navi_cropWithBounds(bounds)?.navi_resizeToSize(size, withInterpolationQuality: .default)
        return image
    }
}

// MARK: - Round

public extension UIImage {

    fileprivate func navi_cgContextAddRoundedRect(_ context: CGContext, rect: CGRect, ovalWidth: CGFloat, ovalHeight: CGFloat) {

        if ovalWidth <= 0 || ovalHeight <= 0 {
            context.addRect(rect)

        } else {
            context.saveGState()

            context.translateBy(x: rect.minX, y: rect.minY)

            context.scaleBy(x: ovalWidth, y: ovalHeight)

            let fw = rect.width / ovalWidth
            let fh = rect.height / ovalHeight

            context.move(to: CGPoint(x: fw, y: fh/2))
            context.addArc(tangent1End: CGPoint(x: fw, y: fh), tangent2End: CGPoint(x: fw/2, y: fh), radius: 1)
            context.addArc(tangent1End: CGPoint(x: 0, y: fh), tangent2End: CGPoint(x: 0, y: fh/2), radius: 1)
            context.addArc(tangent1End: CGPoint(x: 0, y: 0), tangent2End: CGPoint(x: fw/2, y: 0), radius: 1)
            context.addArc(tangent1End: CGPoint(x: fw, y: 0), tangent2End: CGPoint(x: fw, y: fh/2), radius: 1)
            context.closePath()

            context.restoreGState()
        }
    }

    public func navi_roundWithCornerRadius(_ cornerRadius: CGFloat, borderWidth: CGFloat) -> UIImage? {

        let image = navi_imageWithAlpha()

        let cornerRadius = cornerRadius * screenScale
        let borderWidth = borderWidth * screenScale

        let pixelSize = CGSize(width: image.size.width * screenScale, height: image.size.height * screenScale)

        guard let cgImage = image.cgImage else {
            return nil
        }
        guard let colorSpace = cgImage.colorSpace else {
            return nil
        }
        guard let bitmapContext = CGContext(data: nil, width: Int(pixelSize.width), height: Int(pixelSize.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: cgImage.bitmapInfo.rawValue) else {
            return nil
        }

        bitmapContext.beginPath()

        let rect = CGRect(x: borderWidth, y: borderWidth, width: pixelSize.width - borderWidth * 2, height: pixelSize.height - borderWidth * 2)
        navi_cgContextAddRoundedRect(bitmapContext, rect: rect, ovalWidth: cornerRadius, ovalHeight: cornerRadius)

        bitmapContext.closePath()

        bitmapContext.clip()

        let imageRect = CGRect(origin: CGPoint.zero, size: pixelSize)
        bitmapContext.draw(cgImage, in: imageRect)

        if let newCGImage = bitmapContext.makeImage() {
            let image = UIImage(cgImage: newCGImage, scale: screenScale, orientation: imageOrientation)
            return image
        }

        return nil
    }
}

// MARK: - Alpha

public extension UIImage {

    public func navi_hasAlpha() -> Bool {

        guard let cgImage = cgImage else {
            return false
        }

        let alpha = cgImage.alphaInfo

        switch alpha {

        case .first, .last, .premultipliedFirst, .premultipliedLast:
            return true

        default:
            return false
        }
    }

    public func navi_imageWithAlpha() -> UIImage {

        if navi_hasAlpha() {
            return self
        }

        guard let cgImage = cgImage else {
            return self
        }

        let pixelSize = CGSize(width: self.size.width * screenScale, height: self.size.height * screenScale)

        let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo().rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)

        guard let offscreenContext = CGContext(data: nil, width: Int(pixelSize.width), height: Int(pixelSize.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: bitmapInfo.rawValue) else {
            return self
        }
        
        offscreenContext.draw(cgImage, in: CGRect(origin: CGPoint.zero, size: pixelSize))
        
        if let alphaCGImage = offscreenContext.makeImage() {
            let image = UIImage(cgImage: alphaCGImage, scale: screenScale, orientation: imageOrientation)
            return image

        } else {
            return self
        }
    }
}

