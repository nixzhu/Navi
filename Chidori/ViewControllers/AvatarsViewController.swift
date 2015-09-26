//
//  AvatarsViewController.swift
//  Chidori
//
//  Created by NIX on 15/9/26.
//  Copyright © 2015年 nixWork. All rights reserved.
//

import UIKit

class AvatarsViewController: UICollectionViewController {

    let users: [User] = [
        User(name: "NIX A", URL: NSURL(string: "https://raw.githubusercontent.com/onevcat/Kingfisher/master/images/kingfisher-1.jpg")!, localImage: nil),
        User(name: "NIX B", URL: NSURL(string: "https://raw.githubusercontent.com/onevcat/Kingfisher/master/images/kingfisher-2.jpg")!, localImage: nil),
        User(name: "NIX C", URL: NSURL(string: "https://raw.githubusercontent.com/onevcat/Kingfisher/master/images/kingfisher-3.jpg")!, localImage: nil),
        User(name: "NIX D", URL: NSURL(string: "https://raw.githubusercontent.com/onevcat/Kingfisher/master/images/kingfisher-4.jpg")!, localImage: nil),
        User(name: "NIX E", URL: NSURL(string: "https://raw.githubusercontent.com/onevcat/Kingfisher/master/images/kingfisher-5.jpg")!, localImage: nil),
        User(name: "NIX F", URL: NSURL(string: "https://raw.githubusercontent.com/onevcat/Kingfisher/master/images/kingfisher-6.jpg")!, localImage: nil),
        User(name: "NIX G", URL: NSURL(string: "https://raw.githubusercontent.com/onevcat/Kingfisher/master/images/kingfisher-7.jpg")!, localImage: nil),
        User(name: "NIX H", URL: NSURL(string: "https://raw.githubusercontent.com/onevcat/Kingfisher/master/images/kingfisher-8.jpg")!, localImage: nil),
        User(name: "NIX I", URL: NSURL(string: "https://raw.githubusercontent.com/onevcat/Kingfisher/master/images/kingfisher-9.jpg")!, localImage: nil),
        User(name: "NIX J", URL: NSURL(string: "https://raw.githubusercontent.com/onevcat/Kingfisher/master/images/kingfisher-10.jpg")!, localImage: nil),
    ]

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

