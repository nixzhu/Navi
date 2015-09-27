//
//  ProfileViewController.swift
//  Chidori
//
//  Created by NIX on 15/9/27.
//  Copyright © 2015年 nixWork. All rights reserved.
//

import UIKit
import Navi

class ProfileViewController: UIViewController {

    var user: User?

    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var avatarViewWidthConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Profile"

        updateAvatarViewWithSize(CGSize(width: 300, height: 300))
    }

    private func updateAvatarViewWithSize(size: CGSize) {

        avatarViewWidthConstraint.constant = size.width

        view.layoutIfNeeded()

        guard let user = user else {
            return
        }

        let avatarStyle: AvatarStyle = .Rectangle(size: size)
        let userAvatar = UserAvatar(user: user, avatarStyle: avatarStyle)

        avatarView.setAvatar(userAvatar)
    }
}

