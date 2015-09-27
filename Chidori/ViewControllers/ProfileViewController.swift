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

    var isShowingAvatar = false

    @IBOutlet weak var avatarView: AvatarView!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Profile"
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if !isShowingAvatar {

            guard let user = user else {
                return
            }

            let avatarStyle: AvatarStyle = .Rectangle(size: avatarView.bounds.size)
            let userAvatar = UserAvatar(user: user, avatarStyle: avatarStyle)

            avatarView.setAvatar(userAvatar)
            
            
            isShowingAvatar = true
        }
    }
}

