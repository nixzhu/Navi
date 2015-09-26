//
//  Avatar.swift
//  Navi
//
//  Created by NIX on 15/9/26.
//  Copyright © 2015年 nixWork. All rights reserved.
//

public protocol Avatar {

    var name: String { get }
    var URL: NSURL { get }
    var localImage: UIImage? { get }

    func saveImage(image: UIImage)
}

