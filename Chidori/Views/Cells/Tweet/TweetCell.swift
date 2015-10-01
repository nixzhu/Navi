//
//  TweetCell.swift
//  Chidori
//
//  Created by NIX on 15/10/2.
//  Copyright © 2015年 nixWork. All rights reserved.
//

import UIKit
import Navi

class TweetCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!

    func configureWithFeed(feed: Feed) {

        avatarImageView.backgroundColor = UIColor.lightGrayColor()
        avatarImageView.navi_setAvatar(feed as Navi.Avatar)
        usernameLabel.text = feed.username
        messageLabel.text = feed.message
    }
}

