//
//  UIImageView+Navi.swift
//  Navi
//
//  Created by NIX on 15/10/1.
//  Copyright © 2015年 nixWork. All rights reserved.
//

import UIKit

private var avatarKeyAssociatedObject: Void?

public extension UIImageView {

    private var navi_avatarKey: String? {
        return objc_getAssociatedObject(self, &avatarKeyAssociatedObject) as? String
    }

    private func navi_setAvatarKey(avatarKey: String) {
        objc_setAssociatedObject(self, &avatarKeyAssociatedObject, avatarKey, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    public func navi_setAvatar(avatar: Avatar) {

        print(avatar.URL)

        navi_setAvatarKey(avatar.key)

        AvatarPod.wakeAvatar(avatar) { [weak self] image in

            guard let avatarKey = self?.navi_avatarKey where avatarKey == avatar.key else {
                return
            }

            self?.image = image
        }
    }
}

