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

class AvatarsViewController: UICollectionViewController {

    lazy var coreDataStack = CoreDataStack()

    lazy var users: [User] = {
        return self.coreDataStack.users() ?? []
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
        let userAvatar = UserAvatar(user: user, avatarStyle: squareAvatarStyle)

        cell.configureWithAvatar(userAvatar)

        return cell
    }

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        let user = users[indexPath.item % users.count]
        performSegueWithIdentifier("showProfile", sender: user)
    }
}

