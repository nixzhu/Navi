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

let squareAvatarStyle: AvatarStyle = .Rectangle(size: CGSize(width: 60, height: 60))
let roundAvatarStyle: AvatarStyle = .RoundedRectangle(size: CGSize(width: 60, height: 60), cornerRadius: 30, borderWidth: 0)

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

        title = "Avatars"

        collectionView!.backgroundColor = UIColor.whiteColor()
        collectionView!.registerNib(UINib(nibName: avatarCellID, bundle: nil), forCellWithReuseIdentifier: avatarCellID)
    }

    // MARK: 

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "showProfile" {

            let vc = segue.destinationViewController as! ProfileViewController
            vc.user = sender as? User
        }
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

        let user = users[indexPath.item % users.count]
        let avatarStyle = (indexPath.item % 2 == 0) ? squareAvatarStyle : roundAvatarStyle
        let userAvatar = UserAvatar(user: user, avatarStyle: avatarStyle)

        cell.configureWithAvatar(userAvatar)

        return cell
    }

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        let user = users[indexPath.item % users.count]
        performSegueWithIdentifier("showProfile", sender: user)
    }
}

