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

    func configureWithTweet(tweet: Tweet) {

        if let user = tweet.user {
            let userAvatar = UserAvatar(user: user, avatarStyle: roundAvatarStyle)
            avatarImageView.navi_setAvatar(userAvatar)
        } else {
            avatarImageView.image = nil
        }

        usernameLabel.text = tweet.user?.username
        messageLabel.text = tweet.message
    }
}

