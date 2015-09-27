//
//  Avatar.swift
//  Navi
//
//  Created by NIX on 15/9/26.
//  Copyright © 2015年 nixWork. All rights reserved.
//

import Foundation

public enum AvatarStyle {

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
    var localImage: UIImage? { get }

    func saveOriginalImage(image: UIImage, styleImage: UIImage)
}

