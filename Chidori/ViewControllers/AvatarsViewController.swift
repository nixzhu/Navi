//
//  AvatarsViewController.swift
//  Chidori
//
//  Created by NIX on 15/9/26.
//  Copyright © 2015年 nixWork. All rights reserved.
//

import UIKit
import RealmSwift
import Navi

struct YepAvatar {

    let avatarURL: NSURL
}

extension YepAvatar: Navi.Avatar {

    var URL: NSURL? {
        return avatarURL
    }
    var style: AvatarStyle {
        return roundAvatarStyle
    }
    var placeholderImage: UIImage? {
        return UIImage(named: "round_avatar_placeholder")
    }
    var localOriginalImage: UIImage? {
        return nil
    }
    var localStyledImage: UIImage? {
        return nil
    }

    func saveOriginalImage(originalImage: UIImage, styledImage: UIImage) {
    }
}

class AvatarsViewController: UICollectionViewController {

    var realm: Realm!

    lazy var users: Results<User> = {
        return self.realm.objects(User).sorted("createdUnixTime", ascending: false)
        }()

    let yepAvatarURLStrings = [
        "https://yep-avatars.s3.cn-north-1.amazonaws.com.cn/84c9a0a9-c6eb-4495-9b50-0d551749956a",
        "https://yep-avatars.s3.cn-north-1.amazonaws.com.cn/7cf09c38-355b-4daa-b733-5fede0181e5f",
        "https://yep-avatars.s3.cn-north-1.amazonaws.com.cn/76daf547-a38f-410f-88fb-c7aece4fb1c8",
        "https://yep-avatars.s3.cn-north-1.amazonaws.com.cn/0e47196b-1656-4b79-8953-457afaca6f7b",
        "https://yep-avatars.s3.cn-north-1.amazonaws.com.cn/e2b84ebe-533d-4845-a842-774de98c8504",
        "https://yep-avatars.s3.cn-north-1.amazonaws.com.cn/e24117db-d360-4c0b-8159-c908bf216e38",
        "https://yep-avatars.s3.cn-north-1.amazonaws.com.cn/0738b75f-b223-4e34-a61c-add693f99f74",
        "https://yep-avatars.s3.cn-north-1.amazonaws.com.cn/d88b7c3d-7252-41d5-a7bd-068980257eff",
        "https://yep-avatars.s3.cn-north-1.amazonaws.com.cn/134f80a5-d273-4e7c-b490-f0de862c4ac4",
        "https://yep-avatars.s3.cn-north-1.amazonaws.com.cn/d0c29846-e064-4b4c-b4aa-bd0bd2d8d435",
        "https://yep-avatars.s3.cn-north-1.amazonaws.com.cn/d124dcfe-07ec-4ac6-aaf3-5ba6afd131ad",
        "https://yep-avatars.s3.cn-north-1.amazonaws.com.cn/70f6f156-7707-471d-8c98-fcb7d2a6edb1",
        "https://yep-avatars.s3.cn-north-1.amazonaws.com.cn/24795538-fc57-428b-843e-211e6b89a00c",
        "https://yep-avatars.s3.cn-north-1.amazonaws.com.cn/70a3d702-7769-4616-8410-0a7f5d39d883",
        "https://yep-avatars.s3.cn-north-1.amazonaws.com.cn/14902752-2e43-45a1-901b-3a534b1d32b4",
        "https://yep-avatars.s3.cn-north-1.amazonaws.com.cn/db49a8c6-dd2f-464d-8d06-03e7268c7fb4",
        "https://yep-avatars.s3.cn-north-1.amazonaws.com.cn/4c59a970-2e3d-452a-aa2b-00f46ac0512f",
    ]

    let alphaAvatarURLStrings = [
        "http://7xkdk4.com2.z0.glb.qiniucdn.com/pics/avatars/u5561381442825024.jpg?imageView2/1/w/128/h/128",
        "http://7xkszy.com2.z0.glb.qiniucdn.com/pics/avatars/u8516711441533445.jpg?imageView2/1/w/128/h/128",
    ]

    private let avatarCellID = "AvatarCell"

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        realm = try! Realm()

        title = "Avatars"

        collectionView!.backgroundColor = UIColor.whiteColor()
        collectionView!.registerNib(UINib(nibName: avatarCellID, bundle: nil), forCellWithReuseIdentifier: avatarCellID)
        collectionView!.alwaysBounceVertical = true

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateCollectionView:", name: Config.Notification.newUsers, object: nil)
    }

    // MARK: Actions

    func updateCollectionView(notification: NSNotification) {
        collectionView?.reloadData()
    }

    // MARK: Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "showProfile" {

            let vc = segue.destinationViewController as! ProfileViewController
            vc.user = sender as? User
        }
    }

    // MARK: - UICollectionView

    enum Section: Int {
        case User
        case Yep
        case Alpha
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {

        return 3
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        switch section {

        case Section.User.rawValue:
            return users.count

        case Section.Yep.rawValue:
            return yepAvatarURLStrings.count

        case Section.Alpha.rawValue:
            return alphaAvatarURLStrings.count

        default:
            return 0
        }
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(avatarCellID, forIndexPath: indexPath) as! AvatarCell

        return cell
    }

    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {

        configureCell(cell as! AvatarCell, atIndexPath: indexPath)
    }

    private func configureCell(cell: AvatarCell, atIndexPath indexPath: NSIndexPath) {

        switch indexPath.section {

        case Section.User.rawValue:
            let user = users[indexPath.item]
            let userAvatar = UserAvatar(userID: user.userID, avatarStyle: squareAvatarStyle)
            cell.configureWithAvatar(userAvatar)

        case Section.Yep.rawValue:
            let avatarURLString = yepAvatarURLStrings[indexPath.item]
            let yepAvatar = YepAvatar(avatarURL: NSURL(string: avatarURLString)!)
            cell.configureWithAvatar(yepAvatar)

        case Section.Alpha.rawValue:
            let avatarURLString = alphaAvatarURLStrings[indexPath.item]
            let yepAvatar = YepAvatar(avatarURL: NSURL(string: avatarURLString)!)
            cell.configureWithAvatar(yepAvatar)

        default:
            break
        }
    }

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        switch indexPath.section {

        case Section.User.rawValue:
            let user = users[indexPath.item]
            performSegueWithIdentifier("showProfile", sender: user)

        default:
            break
        }
    }
}

