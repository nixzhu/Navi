//
//  UIImage+Navi.swift
//  Navi
//
//  Created by NIX on 15/9/27.
//  Copyright © 2015年 nixWork. All rights reserved.
//

import UIKit

// ref http://vocaro.com/trevor/blog/2009/10/12/resize-a-uiimage-the-right-way/comment-page-1/

private let screenScale = UIScreen.mainScreen().scale

// MARK: - API

extension UIImage {

    func avatarImageWithStyle(avatarStyle: AvatarStyle) -> UIImage {

        var avatarImage: UIImage?

        switch avatarStyle {

        case .Rectangle(let size):
            avatarImage = centerCropWithSize(size)

        case .RoundedRectangle(let size, let cornerRadius, let borderWidth):
            avatarImage = centerCropWithSize(size)?.roundWithCornerRadius(cornerRadius, borderWidth: borderWidth)
        }

        return avatarImage ?? self
    }
}

// MARK: - Resize

extension UIImage {

    func resizeToSize(size: CGSize, withTransform transform: CGAffineTransform, drawTransposed: Bool, interpolationQuality: CGInterpolationQuality) -> UIImage? {

        let newRect = CGRectIntegral(CGRect(origin: CGPointZero, size: size))
        let transposedRect = CGRect(origin: CGPointZero, size: CGSize(width: size.height, height: size.width))

        let bitmapContext = CGBitmapContextCreate(nil, Int(newRect.width), Int(newRect.height), CGImageGetBitsPerComponent(CGImage), 0, CGImageGetColorSpace(CGImage), CGImageGetBitmapInfo(CGImage).rawValue)

        CGContextConcatCTM(bitmapContext, transform)

        CGContextSetInterpolationQuality(bitmapContext, interpolationQuality)

        CGContextDrawImage(bitmapContext, drawTransposed ? transposedRect : newRect, CGImage)

        if let newCGImage = CGBitmapContextCreateImage(bitmapContext) {
            return UIImage(CGImage: newCGImage, scale: screenScale, orientation: imageOrientation)
        }

        return nil
    }

    func transformForOrientationWithSize(size: CGSize) -> CGAffineTransform {
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

    func resizeToSize(size: CGSize, withInterpolationQuality interpolationQuality: CGInterpolationQuality) -> UIImage? {

        let drawTransposed: Bool

        switch imageOrientation {
        case .Left, .LeftMirrored, .Right, .RightMirrored:
            drawTransposed = true
        default:
            drawTransposed = false
        }

        return resizeToSize(size, withTransform: transformForOrientationWithSize(size), drawTransposed: drawTransposed, interpolationQuality: interpolationQuality)
    }

    func cropWithBounds(bounds: CGRect) -> UIImage? {

        if let newCGImage = CGImageCreateWithImageInRect(CGImage, bounds) {

            return UIImage(CGImage: newCGImage, scale: screenScale, orientation: imageOrientation)
        }

        return nil
    }

    func centerCropWithSize(size: CGSize) -> UIImage? {

        let size = CGSize(width: size.width * screenScale, height: size.height * screenScale)

        let horizontalRatio = size.width / self.size.width
        let verticalRatio = size.height / self.size.height

        let ratio: CGFloat

        let originalX: CGFloat
        let originalY: CGFloat

        if horizontalRatio > verticalRatio {
            ratio = horizontalRatio

            originalX = 0
            originalY = (self.size.height - size.height / ratio) / 2

        } else {
            ratio = verticalRatio

            originalX = (self.size.width - size.width / ratio) / 2
            originalY = 0
        }

        let bounds = CGRect(x: originalX, y: originalY, width: size.width / ratio, height: size.height / ratio)

        return cropWithBounds(bounds)?.resizeToSize(size, withInterpolationQuality: .Default)
    }
}

// MARK: - Round

extension UIImage {

    private func CGContextAddRoundedRect(context: CGContext, rect: CGRect, ovalWidth: CGFloat, ovalHeight: CGFloat) {

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

    func roundWithCornerRadius(cornerRadius: CGFloat, borderWidth: CGFloat) -> UIImage? {

        let image = imageWithAlpha()

        let cornerRadius = cornerRadius * screenScale

        guard let bitmapContext = CGBitmapContextCreate(nil, Int(image.size.width), Int(image.size.height), CGImageGetBitsPerComponent(image.CGImage), 0, CGImageGetColorSpace(image.CGImage), CGImageGetBitmapInfo(image.CGImage).rawValue) else {
            return nil
        }

        let size = CGSize(width: self.size.width * screenScale, height: self.size.height * screenScale)

        CGContextBeginPath(bitmapContext)

        let rect = CGRect(x: borderWidth, y: borderWidth, width: size.width - borderWidth * 2, height: size.height - borderWidth * 2)
        CGContextAddRoundedRect(bitmapContext, rect: rect, ovalWidth: cornerRadius, ovalHeight: cornerRadius)

        CGContextClosePath(bitmapContext)

        CGContextClip(bitmapContext)

        let imageRect = CGRect(origin: CGPointZero, size: size)
        CGContextDrawImage(bitmapContext, imageRect, image.CGImage)

        if let newCGImage = CGBitmapContextCreateImage(bitmapContext) {
            return UIImage(CGImage: newCGImage, scale: screenScale, orientation: .Up)
        }

        return nil
    }
}

// MARK: - Alpha

extension UIImage {

    func hasAlpha() -> Bool {

        let alpha = CGImageGetAlphaInfo(CGImage)

        switch alpha {

        case .First, .Last, .PremultipliedFirst, .PremultipliedLast:
            return true

        default:
            return false
        }
    }

    func imageWithAlpha() -> UIImage {

        if hasAlpha() {
            return self
        }

        let width = CGImageGetWidth(CGImage) * Int(screenScale)
        let height = CGImageGetHeight(CGImage) * Int(screenScale)

        let offscreenContext = CGBitmapContextCreate(nil, width, height, CGImageGetBitsPerComponent(CGImage), 0, CGImageGetColorSpace(CGImage), CGBitmapInfo(rawValue: CGBitmapInfo.ByteOrderDefault.rawValue | CGImageAlphaInfo.PremultipliedFirst.rawValue).rawValue)
        
        CGContextDrawImage(offscreenContext, CGRect(origin: CGPointZero, size: CGSize(width: width, height: height)), CGImage)
        
        if let alphaCGImage = CGBitmapContextCreateImage(offscreenContext) {
            return UIImage(CGImage: alphaCGImage, scale: screenScale, orientation: imageOrientation)
        } else {
            return self
        }
    }
}

