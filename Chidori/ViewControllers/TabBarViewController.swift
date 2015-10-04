//
//  TabBarViewController.swift
//  Chidori
//
//  Created by NIX on 15/10/4.
//  Copyright © 2015年 nixWork. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    var previousSelectedIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
    }
}

// MARK: - UITabBarControllerDelegate

extension TabBarViewController: UITabBarControllerDelegate {

    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {

        if selectedIndex == 0 && selectedIndex == previousSelectedIndex {
            if let topViewController = (viewController as? UINavigationController)?.topViewController {
                if let tableView = (topViewController as? TimelineViewController)?.tableView {
                    if tableView.numberOfRowsInSection(0) > 0 {
                        let topIndexPath = NSIndexPath(forRow: 0, inSection: 0)
                        tableView.scrollToRowAtIndexPath(topIndexPath, atScrollPosition: .Top, animated: true)
                    }
                }
            }
        }

        previousSelectedIndex = selectedIndex
    }
}

