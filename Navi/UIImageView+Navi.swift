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

    fileprivate var navi_avatarKey: String? {
        return objc_getAssociatedObject(self, &avatarKeyAssociatedObject) as? String
    }

    fileprivate func navi_setAvatarKey(_ avatarKey: String) {
        objc_setAssociatedObject(self, &avatarKeyAssociatedObject, avatarKey, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    public func navi_setAvatar(_ avatar: Avatar, withFadeTransitionDuration fadeTransitionDuration: TimeInterval = 0) {

        navi_setAvatarKey(avatar.key)

        AvatarPod.wakeAvatar(avatar) { [weak self] finished, image, cacheType in

            guard let strongSelf = self, let avatarKey = strongSelf.navi_avatarKey , avatarKey == avatar.key else {
                return
            }

            if finished && cacheType != .memory {
                UIView.transition(with: strongSelf, duration: fadeTransitionDuration, options: .transitionCrossDissolve, animations: {
                    self?.image = image
                }, completion: nil)

            } else {
                self?.image = image
            }
        }
    }
}

