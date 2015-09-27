//
//  Avatar.swift
//  Navi
//
//  Created by NIX on 15/9/26.
//  Copyright © 2015年 nixWork. All rights reserved.
//

import Foundation

public func ==(lhs: AvatarStyle, rhs: AvatarStyle) -> Bool {

    switch (lhs, rhs) {

    case (.Rectangle(let sizeA), .Rectangle(let sizeB)) where sizeA == sizeB:
        return true

    case (.RoundedRectangle(let sizeA, let cornerRadiusA, let borderWidthA), .RoundedRectangle(let sizeB, let cornerRadiusB, let borderWidthB)) where (sizeA == sizeB && cornerRadiusA == cornerRadiusB && borderWidthA == borderWidthB):
        return true

    default:
        return false
    }
}

public enum AvatarStyle: Equatable {

    case Rectangle(size: CGSize)
    case RoundedRectangle(size: CGSize, cornerRadius: CGFloat, borderWidth: CGFloat)

    var hashString: String {
        switch self {
        case .Rectangle(let size):
            return "Rectangle-\(size)-"
        case .RoundedRectangle(let size, let cornerRadius, let borderWidth):
            return "RoundedRectangle-\(size)-\(cornerRadius)-\(borderWidth)-"
        }
    }
}

public protocol Avatar {

    var name: String { get }
    var URL: NSURL { get }
    var style: AvatarStyle { get }
    var localOriginalImage: UIImage? { get }
    var localStyledImage: UIImage? { get }

    func saveOriginalImage(originalImage: UIImage, styledImage: UIImage)
}

