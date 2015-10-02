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

    var URL: NSURL {

        // try construct original URL from normal one

        if let URL = NSURL(string: user.avatarURLString!), lastPathComponent = URL.lastPathComponent, pathExtension = URL.pathExtension {

            let underscoreParts = lastPathComponent.componentsSeparatedByString("_normal")

            if underscoreParts.count == 2 {

                let name = underscoreParts[0]
                return URL.URLByDeletingLastPathComponent!.URLByAppendingPathComponent(name + "." + pathExtension)
            }
        }

        return NSURL(string: user.avatarURLString!)!
    }

    var style: AvatarStyle {
        return avatarStyle
    }

    var placeholderImage: UIImage? {

        switch style {

        case squareAvatarStyle:
            return UIImage(named: "square_avatar_placeholder")

        case roundAvatarStyle:
            return UIImage(named: "round_avatar_placeholder")

        default:
            return nil
        }
    }

    var localOriginalImage: UIImage? {

        if let data = user.avatar?.originalAvatarData {
            return UIImage(data: data)
        }

        return nil
    }

    var localStyledImage: UIImage? {

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

    func saveOriginalImage(originalImage: UIImage, styledImage: UIImage) {

        guard let context = user.managedObjectContext else {
            return
        }

        var isDirty = false

        if user.avatar == nil {

            let avatarEntityDescription = NSEntityDescription.entityForName("Avatar", inManagedObjectContext: context)!
            let avatar = NSManagedObject(entity: avatarEntityDescription, insertIntoManagedObjectContext: context) as! Avatar

            avatar.avatarURLString = URL.absoluteString
            avatar.originalAvatarData = UIImageJPEGRepresentation(originalImage, 1.0)

            user.avatar = avatar

            isDirty = true
        }

        if let avatar = user.avatar {

            switch style {

            case .Rectangle:

                if avatar.miniSquareAvatarData == nil {
                    avatar.miniSquareAvatarData = UIImageJPEGRepresentation(styledImage, 1.0)

                    isDirty = true
                }

            case .RoundedRectangle:

                if avatar.miniRoundAvatarData == nil {
                    avatar.miniRoundAvatarData = UIImagePNGRepresentation(styledImage)

                    isDirty = true
                }

            default:
                break
            }
        }

        if isDirty {
            context.trySave()
        }
    }
}

