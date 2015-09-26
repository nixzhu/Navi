//
//  User.swift
//  Chidori
//
//  Created by NIX on 15/9/26.
//  Copyright © 2015年 nixWork. All rights reserved.
//

import Foundation
import Navi

class User: Avatar {

    var name: String
    var URL: NSURL
    var localImage: UIImage?

    init(name: String, URL: NSURL, localImage: UIImage?) {
        self.name = name
        self.URL = URL
        self.localImage = localImage
    }
}

