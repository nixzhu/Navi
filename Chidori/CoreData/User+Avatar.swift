//
//  User+Avatar.swift
//  Chidori
//
//  Created by NIX on 15/9/26.
//  Copyright © 2015年 nixWork. All rights reserved.
//

import Navi

extension User: Navi.Avatar {

    var name: String {
        return username!
    }

    var URL: NSURL {
        return NSURL(string: avatarURLString!)!
    }

    var localImage: UIImage? {
        return nil
    }
}