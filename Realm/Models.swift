//
//  Models.swift
//  Chidori
//
//  Created by NIX on 15/10/3.
//  Copyright © 2015年 nixWork. All rights reserved.
//

import Foundation
import RealmSwift

class User: Object {

    dynamic var userID: String = ""
    dynamic var createdUnixTime: NSTimeInterval = NSDate().timeIntervalSince1970
    dynamic var username: String = ""
    dynamic var avatarURLString: String = ""
    dynamic var avatar: Avatar?
    var tweets = List<Tweet>()

    class func getOrCreateWithUserID(userID: String, inRealm realm: Realm) -> (justCreated: Bool, User) {

        let predicate = NSPredicate(format: "userID = %@", userID)

        if let user = realm.objects(User).filter(predicate).first {
            return (justCreated: false, user)

        } else {
            let newUser = User()
            newUser.userID = userID

            let _ = try? realm.write {
                realm.add(newUser)
            }

            return (justCreated: true, newUser)
        }
    }
}

class Avatar: Object {

    dynamic var avatarURLString: String = ""
    dynamic var originalAvatarData: NSData = NSData()
    dynamic var miniRoundAvatarData: NSData = NSData()
    dynamic var miniSquareAvatarData: NSData = NSData()

    let owners = LinkingObjects(fromType: User.self, property: "avatar")
    var owner: User? {
        return owners.first
    }

    class func getOrCreateWithAvatarURLString(avatarURLString: String, inRealm realm: Realm) -> Avatar {

        let predicate = NSPredicate(format: "avatarURLString = %@", avatarURLString)

        if let avatar = realm.objects(Avatar).filter(predicate).first {
            return avatar

        } else {
            let newAvatar = Avatar()
            newAvatar.avatarURLString = avatarURLString

            let _ = try? realm.write {
                realm.add(newAvatar)
            }

            return newAvatar
        }
    }
}

class Tweet: Object {

    dynamic var tweetID: String = ""
    dynamic var createdUnixTime: NSTimeInterval = NSDate().timeIntervalSince1970
    dynamic var message: String = ""

    dynamic var creator: User?

    class func getOrCreateWithTweetID(tweetID: String, inRealm realm: Realm) -> (justCreated: Bool, Tweet) {

        let predicate = NSPredicate(format: "tweetID = %@", tweetID)

        if let tweet = realm.objects(Tweet).filter(predicate).first {
            return (justCreated: false, tweet)

        } else {
            let newTweet = Tweet()
            newTweet.tweetID = tweetID
            
            let _ = try? realm.write {
                realm.add(newTweet)
            }
            
            return (justCreated: true, newTweet)
        }
    }
}

