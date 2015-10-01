//
//  AvatarCell.swift
//  Chidori
//
//  Created by NIX on 15/9/26.
//  Copyright © 2015年 nixWork. All rights reserved.
//

import UIKit
import Navi

class AvatarCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        imageView.contentMode = .Center
    }

    func configureWithAvatar(avatar: Navi.Avatar) {

        imageView.navi_setAvatar(avatar)
    }
}

