//
//  TimelineViewController.swift
//  Chidori
//
//  Created by NIX on 15/10/2.
//  Copyright © 2015年 nixWork. All rights reserved.
//

import UIKit
import Accounts
import Social
import Navi

struct Feed {
    let username: String
    let avatarURLString: String
    let message: String
}

extension Feed: Navi.Avatar {

    var URL: NSURL {
        return NSURL(string: avatarURLString)!
    }

    var style: AvatarStyle {
        return .RoundedRectangle(size: CGSize(width: 60, height: 60), cornerRadius: 30, borderWidth: 0)
    }

    var placeholderImage: UIImage? {
        return UIImage(named: "round_avatar_placeholder")
    }

    var localOriginalImage: UIImage? {
        return nil
    }

    var localStyledImage: UIImage? {
        return nil
    }

    func saveOriginalImage(originalImage: UIImage, styledImage: UIImage) {
    }
}

class TimelineViewController: UITableViewController {

    lazy var accountStore = ACAccountStore()

    var feeds = [Feed]() {
        didSet {
            dispatch_async(dispatch_get_main_queue()) { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }

    var twitterAccount: ACAccount? {
        willSet {
            guard let twitterAccount = newValue else {
                return
            }

            let feedURL = NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")!

            let parameters = [
                "count": 15,
            ]

            let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET, URL: feedURL, parameters: parameters)
            request.account = twitterAccount

            request.performRequestWithHandler { [weak self] data, response, error in

                guard let
                    json = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)),
                    feedsData = json as? [[NSObject: AnyObject]] else {
                        return
                }
                //print("feedsData: \(feedsData)")

                self?.feeds = feedsData.map({ feedInfo in
                    guard let
                        userInfo = feedInfo["user"] as? [NSObject: AnyObject],
                        username = userInfo["screen_name"] as? String,
                        avatarURLString = userInfo["profile_image_url_https"] as? String,
                        message = feedInfo["text"] as? String else {
                            return nil
                    }

                    return Feed(username: username, avatarURLString: avatarURLString, message: message)
                }).flatMap({ $0 })
            }
        }
    }

    let tweetCellID = "TweetCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerNib(UINib(nibName: tweetCellID, bundle: nil), forCellReuseIdentifier: tweetCellID)
        tableView.tableFooterView = UIView()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        let twitterType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)

        accountStore.requestAccessToAccountsWithType(twitterType, options: nil) { [weak self] granted, error in

            if granted {

                guard let strongSelf = self else {
                    return
                }

                let twitterAccounts = strongSelf.accountStore.accountsWithAccountType(twitterType)

                strongSelf.twitterAccount = twitterAccounts.first as? ACAccount
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return feeds.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier(tweetCellID, forIndexPath: indexPath) as! TweetCell

        let feed = feeds[indexPath.row]
        cell.configureWithFeed(feed)

        return cell
    }
}

