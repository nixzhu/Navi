//
//  AvatarsViewController.swift
//  Chidori
//
//  Created by NIX on 15/9/26.
//  Copyright © 2015年 nixWork. All rights reserved.
//

import UIKit
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

    var localImage: UIImage? {

        switch style {

        case .Rectangle:
            if let data = user.avatar?.miniAvatarData {
                return UIImage(data: data)
            }

        case .RoundedRectangle:
            if let data = user.avatar?.nanoAvatarData {
                return UIImage(data: data)
            }
        }

        if let data = user.avatar?.avatarData {
            return UIImage(data: data)
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
                    avatar.miniAvatarData = UIImageJPEGRepresentation(styleImage, 1.0)
                }

            case .RoundedRectangle:
                if avatar.nanoAvatarData == nil {
                    avatar.nanoAvatarData = UIImageJPEGRepresentation(styleImage, 1.0)
                }
            }
        }

        context.trySave()
    }
}

class AvatarsViewController: UICollectionViewController {

    lazy var coreDataStack = CoreDataStack()

    lazy var users: [User] = {

        if let users = self.coreDataStack.users() {

            // first time dummy data

            if users.isEmpty {

                if let usersURL = NSBundle.mainBundle().URLForResource("users", withExtension: "plist") {

                    if let users = NSArray(contentsOfURL: usersURL) as? [NSDictionary] {

                        let context = self.coreDataStack.context

                        users.forEach { userInfo in

                            let userEntityDescription = NSEntityDescription.entityForName("User", inManagedObjectContext: context)!
                            let user = NSManagedObject(entity: userEntityDescription, insertIntoManagedObjectContext: context) as! User

                            user.username = userInfo["username"] as? String
                            user.avatarURLString = userInfo["avatarURLString"] as? String
                        }
                        
                        context.trySave()
                    }
                }

                if let users = self.coreDataStack.users() {
                    return users
                }
            }

            return users
        }

        return []
        }()

    private let avatarCellID = "AvatarCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView!.backgroundColor = UIColor.whiteColor()
        collectionView!.registerNib(UINib(nibName: avatarCellID, bundle: nil), forCellWithReuseIdentifier: avatarCellID)
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {

        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return users.count * 5
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(avatarCellID, forIndexPath: indexPath) as! AvatarCell

        cell.backgroundColor = UIColor.darkGrayColor()

        let user = users[indexPath.item % users.count]

        let avatarStyle: AvatarStyle
        if indexPath.item % 2 == 0 {
            avatarStyle = .RoundedRectangle(size: CGSize(width: 60, height: 60), cornerRadius: 21, borderWidth: 0)
        } else {
            avatarStyle = .Rectangle(size: CGSize(width: 60, height: 60))
        }

        let userAvatar = UserAvatar(user: user, avatarStyle: avatarStyle)

        cell.avatarView.setAvatar(userAvatar)

        return cell
    }
}

