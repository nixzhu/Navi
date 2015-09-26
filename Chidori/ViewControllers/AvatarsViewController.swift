//
//  AvatarsViewController.swift
//  Chidori
//
//  Created by NIX on 15/9/26.
//  Copyright © 2015年 nixWork. All rights reserved.
//

import UIKit
import CoreData

class AvatarsViewController: UICollectionViewController {

    lazy var coreDataStack = CoreDataStack()

    lazy var users: [User] = {

        if let users = self.coreDataStack.users() {

            // first time dammy data

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
                        
                        self.coreDataStack.saveContext()
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

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

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

        cell.backgroundColor = UIColor.lightGrayColor()

        let user = users[indexPath.item % users.count]

        cell.avatarView.setAvatar(user)

        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
}

