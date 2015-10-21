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

private let screenScale = UIScreen.mainScreen().scale

// MARK: - API

public extension UIImage {

    public func navi_avatarImageWithStyle(avatarStyle: AvatarStyle) -> UIImage {

        var avatarImage: UIImage?

        switch avatarStyle {

        case .Original:
            return self

        case .Rectangle(let size):
            avatarImage = navi_centerCropWithSize(size)

        case .RoundedRectangle(let size, let cornerRadius, let borderWidth):
            avatarImage = navi_centerCropWithSize(size)?.navi_roundWithCornerRadius(cornerRadius, borderWidth: borderWidth)

        case .Free(_, let transform):
            avatarImage = transform(self)
        }

        return avatarImage ?? self
    }
}

// MARK: - Resize

public extension UIImage {

    public func navi_resizeToSize(size: CGSize, withTransform transform: CGAffineTransform, drawTransposed: Bool, interpolationQuality: CGInterpolationQuality) -> UIImage? {

        let pixelSize = CGSize(width: size.width * screenScale, height: size.height * screenScale)

        let newRect = CGRectIntegral(CGRect(origin: CGPointZero, size: pixelSize))
        let transposedRect = CGRect(origin: CGPointZero, size: CGSize(width: pixelSize.height, height: pixelSize.width))

        let bitmapContext = CGBitmapContextCreate(nil, Int(newRect.width), Int(newRect.height), CGImageGetBitsPerComponent(CGImage), 0, CGImageGetColorSpace(CGImage), CGImageGetBitmapInfo(CGImage).rawValue)

        CGContextConcatCTM(bitmapContext, transform)

        CGContextSetInterpolationQuality(bitmapContext, interpolationQuality)

        CGContextDrawImage(bitmapContext, drawTransposed ? transposedRect : newRect, CGImage)

        if let newCGImage = CGBitmapContextCreateImage(bitmapContext) {
            let image = UIImage(CGImage: newCGImage, scale: screenScale, orientation: imageOrientation)
            return image
        }

        return nil
    }

    public func navi_transformForOrientationWithSize(size: CGSize) -> CGAffineTransform {

        var transform = CGAffineTransformIdentity

        switch imageOrientation {

        case .Down, .DownMirrored:
            transform = CGAffineTransformTranslate(transform, size.width, size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI))

        case .Left, .LeftMirrored:
            transform = CGAffineTransformTranslate(transform, size.width, 0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))

        case .Right, .RightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(-M_PI_2))

        default:
            break
        }

        switch imageOrientation {

        case .UpMirrored, .DownMirrored:
            transform = CGAffineTransformTranslate(transform, size.width, 0)
            transform = CGAffineTransformScale(transform, -1, 1)

        case .LeftMirrored, .RightMirrored:
            transform = CGAffineTransformTranslate(transform, size.height, 0)
            transform = CGAffineTransformScale(transform, -1, 1)

        default:
            break
        }

        return transform
    }

    public func navi_resizeToSize(size: CGSize, withInterpolationQuality interpolationQuality: CGInterpolationQuality) -> UIImage? {

        let drawTransposed: Bool

        switch imageOrientation {
        case .Left, .LeftMirrored, .Right, .RightMirrored:
            drawTransposed = true
        default:
            drawTransposed = false
        }

        let image = navi_resizeToSize(size, withTransform: navi_transformForOrientationWithSize(size), drawTransposed: drawTransposed, interpolationQuality: interpolationQuality)
        return image
    }

    public func navi_cropWithBounds(bounds: CGRect) -> UIImage? {

        if let newCGImage = CGImageCreateWithImageInRect(CGImage, bounds) {
            let image = UIImage(CGImage: newCGImage, scale: screenScale, orientation: imageOrientation)
            return image
        }

        return nil
    }

    public func navi_centerCropWithSize(size: CGSize) -> UIImage? {

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

        let image = navi_cropWithBounds(bounds)?.navi_resizeToSize(size, withInterpolationQuality: .Default)
        return image
    }
}

// MARK: - Round

public extension UIImage {

    private func navi_CGContextAddRoundedRect(context: CGContext, rect: CGRect, ovalWidth: CGFloat, ovalHeight: CGFloat) {

        if ovalWidth <= 0 || ovalHeight <= 0 {
            CGContextAddRect(context, rect)

        } else {
            CGContextSaveGState(context)

            CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect))

            CGContextScaleCTM(context, ovalWidth, ovalHeight)

            let fw = CGRectGetWidth(rect) / ovalWidth
            let fh = CGRectGetHeight(rect) / ovalHeight

            CGContextMoveToPoint(context, fw, fh/2)
            CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1)
            CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1)
            CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1)
            CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1)
            CGContextClosePath(context)

            CGContextRestoreGState(context)
        }
    }

    public func navi_roundWithCornerRadius(cornerRadius: CGFloat, borderWidth: CGFloat) -> UIImage? {

        let image = navi_imageWithAlpha()

        let cornerRadius = cornerRadius * screenScale
        let borderWidth = borderWidth * screenScale

        let pixelSize = CGSize(width: image.size.width * screenScale, height: image.size.height * screenScale)

        guard let bitmapContext = CGBitmapContextCreate(nil, Int(pixelSize.width), Int(pixelSize.height), CGImageGetBitsPerComponent(image.CGImage), 0, CGImageGetColorSpace(image.CGImage), CGImageGetBitmapInfo(image.CGImage).rawValue) else {
            return nil
        }

        CGContextBeginPath(bitmapContext)

        let rect = CGRect(x: borderWidth, y: borderWidth, width: pixelSize.width - borderWidth * 2, height: pixelSize.height - borderWidth * 2)
        navi_CGContextAddRoundedRect(bitmapContext, rect: rect, ovalWidth: cornerRadius, ovalHeight: cornerRadius)

        CGContextClosePath(bitmapContext)

        CGContextClip(bitmapContext)

        let imageRect = CGRect(origin: CGPointZero, size: pixelSize)
        CGContextDrawImage(bitmapContext, imageRect, image.CGImage)

        if let newCGImage = CGBitmapContextCreateImage(bitmapContext) {
            let image = UIImage(CGImage: newCGImage, scale: screenScale, orientation: imageOrientation)
            return image
        }

        return nil
    }
}

// MARK: - Alpha

public extension UIImage {

    public func navi_hasAlpha() -> Bool {

        let alpha = CGImageGetAlphaInfo(CGImage)

        switch alpha {

        case .First, .Last, .PremultipliedFirst, .PremultipliedLast:
            return true

        default:
            return false
        }
    }

    public func navi_imageWithAlpha() -> UIImage {

        if navi_hasAlpha() {
            return self
        }

        let pixelSize = CGSize(width: self.size.width * screenScale, height: self.size.height * screenScale)

        let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.ByteOrderDefault.rawValue | CGImageAlphaInfo.PremultipliedFirst.rawValue)

        let offscreenContext = CGBitmapContextCreate(nil, Int(pixelSize.width), Int(pixelSize.height), CGImageGetBitsPerComponent(CGImage), 0, CGColorSpaceCreateDeviceRGB(), bitmapInfo.rawValue)
        
        CGContextDrawImage(offscreenContext, CGRect(origin: CGPointZero, size: pixelSize), CGImage)
        
        if let alphaCGImage = CGBitmapContextCreateImage(offscreenContext) {
            let image = UIImage(CGImage: alphaCGImage, scale: screenScale, orientation: imageOrientation)
            return image

        } else {
            return self
        }
    }
}

