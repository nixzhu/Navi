//
//  UserAvatar.swift
//  Chidori
//
//  Created by NIX on 15/9/27.
//  Copyright © 2015年 nixWork. All rights reserved.
//

import CoreData
import Navi

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

        if let data = user.avatar?.avatarData {
            return UIImage(data: data)
        }

        return nil
    }

    var localStyleImage: UIImage? {

        switch style {

        case .Rectangle:
            if let data = user.avatar?.miniAvatarData {
                //return UIImage(data: data)
                return UIImage(data: data, scale: 2)
            }

        case .RoundedRectangle:
            if let data = user.avatar?.nanoAvatarData {
                //return UIImage(data: data)
                return UIImage(data: data, scale: 2)
            }
        }

        return nil
    }

    func saveOriginalImage(image: UIImage, styleImage: UIImage) {

        guard let context = user.managedObjectContext else {
            return
        }

        if user.avatar == nil {

            let avatarEntityDescription = NSEntityDescription.entityForName("Avatar", inManagedObjectContext: context)!
            let avatar = NSManagedObject(entity: avatarEntityDescription, insertIntoManagedObjectContext: context) as! Avatar

            avatar.avatarURLString = URL.absoluteString
            avatar.avatarData = UIImageJPEGRepresentation(image, 1.0)

            user.avatar = avatar
        }

        if let avatar = user.avatar {

            switch style {

            case .Rectangle:
                if avatar.miniAvatarData == nil {
                    //avatar.miniAvatarData = UIImageJPEGRepresentation(styleImage, 1.0)
                    avatar.miniAvatarData = UIImagePNGRepresentation(styleImage)
                }

            case .RoundedRectangle:
                if avatar.nanoAvatarData == nil {
                    //avatar.nanoAvatarData = UIImageJPEGRepresentation(styleImage, 1.0)
                    avatar.miniAvatarData = UIImagePNGRepresentation(styleImage)
                }
            }
        }
        
        context.trySave()
    }
}

