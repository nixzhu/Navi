//
//  UIImageView+Navi.swift
//  Navi
//
//  Created by NIX on 15/10/1.
//  Copyright © 2015年 nixWork. All rights reserved.
//

import UIKit

private var URLKey: Void?

public extension UIImageView {

    private var navi_avatarURL: NSURL? {
        return objc_getAssociatedObject(self, &URLKey) as? NSURL
    }

    private func navi_setAvatarURL(URL: NSURL) {
        objc_setAssociatedObject(self, &URLKey, URL, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    public func navi_setAvatar(avatar: Avatar) {

        navi_setAvatarURL(avatar.URL)

        AvatarCache.retrieveAvatar(avatar) { [weak self] image in

            if let URL = self?.navi_avatarURL where URL == avatar.URL {

                self?.image = image
            }
        }
    }
}

