//
//  TweetCell.swift
//  Chidori
//
//  Created by NIX on 15/10/2.
//  Copyright © 2015年 nixWork. All rights reserved.
//

import UIKit
import SafariServices
import Navi

protocol TweetCellDelegate: NSObjectProtocol {

    func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?)
}

class TweetCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!

    weak var delegate: TweetCellDelegate?

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

        messageTextView.font = UIFont.tweetMessageFont()
        messageTextView.textContainerInset = UIEdgeInsetsZero
        messageTextView.textContainer.lineFragmentPadding = 0
        messageTextView.delegate = self
    }

    func configureWithTweet(tweet: Tweet, messageHeight: CGFloat) {

        if let user = tweet.creator {
            let userAvatar = UserAvatar(userID: user.userID, avatarStyle: roundAvatarStyle)
            avatarImageView.navi_setAvatar(userAvatar)

        } else {
            avatarImageView.image = nil
        }

        usernameLabel.text = "@" + (tweet.creator?.username ?? "")
        messageTextView.text = tweet.message

        messageTextView.frame.size.height = messageHeight
    }
}

// MARK: - UITextViewDelegate

extension TweetCell: UITextViewDelegate {

    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {

        if #available(iOS 9.0, *) {
            let vc = SFSafariViewController(URL: URL)
            delegate?.presentViewController(vc, animated: true, completion: nil)

            return false
        }

        return true
    }
}

