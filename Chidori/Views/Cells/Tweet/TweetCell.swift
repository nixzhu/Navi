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

    static let messageLabelMaxWidth: CGFloat = {
        return UIScreen.mainScreen().bounds.width - (8 + 60 + 8 + 8)
        }()

    static let messageAttributes: [String: NSObject] = [
        NSFontAttributeName: UIFont.tweetMessageFont(),
    ]

    class func heightOfTweetMessage(message: String) -> CGFloat {

        let rect = message.boundingRectWithSize(CGSize(width: messageLabelMaxWidth, height: CGFloat(FLT_MAX)), options: [.UsesLineFragmentOrigin, .UsesFontLeading], attributes: messageAttributes, context: nil)

        return ceil(rect.height)
    }

    class func heightOfTweet(tweet: Tweet) -> CGFloat {

        let tweetMessageHeight = heightOfTweetMessage(tweet.message)

        return 8 + max(21 + 8 + tweetMessageHeight, 60) + 8
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        messageLabel.font = UIFont.tweetMessageFont()
    }

    func configureWithTweet(tweet: Tweet) {

        if let user = tweet.creator {
            let userAvatar = UserAvatar(userID: user.userID, avatarStyle: roundAvatarStyle)
            avatarImageView.navi_setAvatar(userAvatar)
        } else {
            avatarImageView.image = nil
        }

        usernameLabel.text = tweet.creator?.username
        messageLabel.text = tweet.message

        messageLabel.frame.size.height = TweetCell.heightOfTweetMessage(tweet.message)
    }
}

