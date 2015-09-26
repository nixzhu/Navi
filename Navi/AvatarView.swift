//
//  AvatarView.swift
//  Navi
//
//  Created by NIX on 15/9/26.
//  Copyright © 2015年 nixWork. All rights reserved.
//

import UIKit

public class AvatarView: UIView {

    lazy var placeholderImageView = UIImageView()
    lazy var avatarImageView = UIImageView()

    public override func didMoveToSuperview() {
        super.didMoveToSuperview()

        backgroundColor = UIColor.clearColor()

        placeholderImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(placeholderImageView)
        addSubview(avatarImageView)

        let views = [
            "placeholderImageView": placeholderImageView,
            "avatarImageView": avatarImageView,
        ]

        let placeholderImageViewConstraintsH = NSLayoutConstraint.constraintsWithVisualFormat("H:|[placeholderImageView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        let placeholderImageViewConstraintsV = NSLayoutConstraint.constraintsWithVisualFormat("V:|[placeholderImageView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)

        NSLayoutConstraint.activateConstraints(placeholderImageViewConstraintsH)
        NSLayoutConstraint.activateConstraints(placeholderImageViewConstraintsV)

        let avatarImageViewConstraintsH = NSLayoutConstraint.constraintsWithVisualFormat("H:|[avatarImageView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        let avatarImageViewConstraintsV = NSLayoutConstraint.constraintsWithVisualFormat("V:|[avatarImageView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)

        NSLayoutConstraint.activateConstraints(avatarImageViewConstraintsH)
        NSLayoutConstraint.activateConstraints(avatarImageViewConstraintsV)
    }

    public func setAvatar(avatar: Avatar) {

        AvatarCache.retrieveAvatar(avatar) { [weak self] image in
            self?.avatarImageView.image = image
        }
    }
}

