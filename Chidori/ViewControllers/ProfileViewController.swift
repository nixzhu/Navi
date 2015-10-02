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

    @IBOutlet weak var avatarImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Profile"

        updateAvatarViewWithSize(avatarImageView.bounds.size)
    }

    private func updateAvatarViewWithSize(size: CGSize) {

        guard let user = user else {
            return
        }

        let avatarStyle: AvatarStyle = .Free(name: "NIX", transform: { image in

            guard let sourceCIImage = CIImage(image: image) else {
                return nil
            }

            let filter = blurWithRadius(3) +++ overlayWithColor(UIColor.redColor().colorWithAlphaComponent(0.5))

            let resultCIImage = filter(sourceCIImage)

            return UIImage(CIImage: resultCIImage)
        })

        let userAvatar = UserAvatar(user: user, avatarStyle: avatarStyle)

        avatarImageView.navi_setAvatar(userAvatar)
    }
}

