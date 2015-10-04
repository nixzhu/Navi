//
//  UserAvatar.swift
//  Chidori
//
//  Created by NIX on 15/9/27.
//  Copyright © 2015年 nixWork. All rights reserved.
//

import RealmSwift
import Navi

private let screenScale = UIScreen.mainScreen().scale

struct UserAvatar {

    let userID: String
    let avatarStyle: AvatarStyle

    var user: User {
        let (_, user) = User.getOrCreateWithUserID(userID, inRealm: try! Realm())
        return user
    }
}

let squareAvatarStyle: AvatarStyle = .Rectangle(size: CGSize(width: 60, height: 60))
let roundAvatarStyle: AvatarStyle = .RoundedRectangle(size: CGSize(width: 60, height: 60), cornerRadius: 30, borderWidth: 0)

extension UserAvatar: Navi.Avatar {

    var URL: NSURL {

        // try construct original URL from normal one

        if let URL = NSURL(string: user.avatarURLString), lastPathComponent = URL.lastPathComponent, pathExtension = URL.pathExtension {

            let underscoreParts = lastPathComponent.componentsSeparatedByString("_normal")

            if underscoreParts.count == 2 {

                let name = underscoreParts[0]

                if pathExtension == "" {
                    return URL.URLByDeletingLastPathComponent!.URLByAppendingPathComponent(name)

                } else {
                    return URL.URLByDeletingLastPathComponent!.URLByAppendingPathComponent(name + "." + pathExtension)
                }
            }
        }

        return NSURL(string: user.avatarURLString)!
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

        guard let realm = user.realm else {
            return
        }

        if user.avatar == nil {

            let avatar = Avatar.getOrCreateWithAvatarURLString(user.avatarURLString, inRealm: realm)

            realm.write {
                self.user.avatar = avatar
            }
        }

        if let avatar = user.avatar {

            if avatar.originalAvatarData.length == 0, let data = UIImageJPEGRepresentation(originalImage, 1.0) {
                realm.write {
                    avatar.originalAvatarData = data
                }
            }

            switch style {

            case .Rectangle:

                if avatar.miniSquareAvatarData.length == 0, let data = UIImageJPEGRepresentation(styledImage, 1.0) {
                    realm.write {
                        avatar.miniSquareAvatarData = data
                    }
                }

            case .RoundedRectangle:

                if avatar.miniRoundAvatarData.length == 0, let data = UIImagePNGRepresentation(styledImage) {
                    realm.write {
                        avatar.miniRoundAvatarData = data
                    }
                }

            default:
                break
            }
        }
    }
}

