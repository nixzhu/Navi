//
//  Avatar.swift
//  Navi
//
//  Created by NIX on 15/9/26.
//  Copyright © 2015年 nixWork. All rights reserved.
//

import Foundation

public enum AvatarStyle {

    case original
    case rectangle(size: CGSize)
    case roundedRectangle(size: CGSize, cornerRadius: CGFloat, borderWidth: CGFloat)

    public typealias Transform = (UIImage) -> UIImage?
    case freeform(name: String, transform: Transform)
}

extension AvatarStyle {

    var hashString: String {

        switch self {

        case .original:
            return "Original-"

        case .rectangle(let size):
            return "Rectangle-\(size)-"

        case .roundedRectangle(let size, let cornerRadius, let borderWidth):
            return "RoundedRectangle-\(size)-\(cornerRadius)-\(borderWidth)-"

        case .freeform(let name, _):
            return "Freeform-\(name)-"
        }
    }
}

extension AvatarStyle: Equatable {

    public static func ==(lhs: AvatarStyle, rhs: AvatarStyle) -> Bool {

        switch (lhs, rhs) {

        case (.original, .original):
            return true

        case (.rectangle(let sizeA), .rectangle(let sizeB)) where sizeA == sizeB:
            return true

        case (.roundedRectangle(let sizeA, let cornerRadiusA, let borderWidthA), .roundedRectangle(let sizeB, let cornerRadiusB, let borderWidthB)) where (sizeA == sizeB && cornerRadiusA == cornerRadiusB && borderWidthA == borderWidthB):
            return true

        case (.freeform(let nameA, _), .freeform(let nameB, _)) where nameA == nameB:
            return true
            
        default:
            return false
        }
    }
}

public protocol Avatar {

    var url: URL? { get }
    var style: AvatarStyle { get }
    var placeholderImage: UIImage? { get }
    var localOriginalImage: UIImage? { get }
    var localStyledImage: UIImage? { get }

    func save(originalImage: UIImage, styledImage: UIImage)
}

public extension Avatar {

    public var key: String {
        return style.hashString + (url?.absoluteString ?? "")
    }
}

