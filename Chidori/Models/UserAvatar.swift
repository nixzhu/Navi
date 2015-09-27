//
//  UserAvatar.swift
//  Chidori
//
//  Created by NIX on 15/9/27.
//  Copyright © 2015年 nixWork. All rights reserved.
//

import CoreData
import Navi

private let screenScale = UIScreen.mainScreen().scale

class UserAvatar {

    let user: User
    let avatarStyle: AvatarStyle

    init(user: User, avatarStyle: AvatarStyle) {
        self.user = user
        self.avatarStyle = avatarStyle
    }
}

extension UserAvatar: Navi.Avatar {

    var name: String {
        return user.username!
    }

    var URL: NSURL {
        return NSURL(string: user.avatarURLString!)!
    }

    var style: AvatarStyle {
        return avatarStyle
    }

    var localOriginalImage: UIImage? {

        if let data = user.avatar?.originalAvatarData {
            return UIImage(data: data)
        }

        return nil
    }

    var localStyleImage: UIImage? {

        switch style {

        case squareAvatarStyle:
            if let data = user.avatar?.miniSquareAvatarData {
                return UIImage(data: data, scale: screenScale)
            }

        case roundAvatarStyle:
            if let data = user.avatar?.miniRoundAvatarData {
                return UIImage(data: data, scale: screenScale)
            }

        default:
            break
        }

        return nil
    }

    func saveOriginalImage(image: UIImage, styleImage: UIImage) {

        guard let context = user.managedObjectContext else {
            return
        }

        var isDirty = false

        if user.avatar == nil {

            let avatarEntityDescription = NSEntityDescription.entityForName("Avatar", inManagedObjectContext: context)!
            let avatar = NSManagedObject(entity: avatarEntityDescription, insertIntoManagedObjectContext: context) as! Avatar

            avatar.avatarURLString = URL.absoluteString
            avatar.originalAvatarData = UIImageJPEGRepresentation(image, 1.0)

            user.avatar = avatar

            isDirty = true
        }

        if let avatar = user.avatar {

            switch style {

            case .Rectangle:
                if avatar.miniSquareAvatarData == nil {
                    avatar.miniSquareAvatarData = UIImagePNGRepresentation(styleImage)

                    isDirty = true
                }

            case .RoundedRectangle:
                if avatar.miniRoundAvatarData == nil {
                    avatar.miniRoundAvatarData = UIImagePNGRepresentation(styleImage)

                    isDirty = true
                }
            }
        }

        if isDirty {
            context.trySave()
        }
    }
}

