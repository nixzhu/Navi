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
import RealmSwift
import Navi

class TimelineViewController: UITableViewController {

    lazy var accountStore = ACAccountStore()

    private lazy var dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.dateStyle = .LongStyle
        formatter.formatterBehavior = .Behavior10_4
        formatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        return formatter
        }()

    var twitterAccount: ACAccount? {
        willSet {
            guard let twitterAccount = newValue else {
                return
            }

            let homeTimelineURL = NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")!

            let parameters = [
                "count": 50,
            ]

            let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET, URL: homeTimelineURL, parameters: parameters)
            request.account = twitterAccount

            request.performRequestWithHandler { [weak self] data, response, error in

                guard let
                    json = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)),
                    tweetsData = json as? [[NSObject: AnyObject]] else {
                        print("can not get tweets!")
                        return
                }
                //print("tweetsData: \(tweetsData)")

                dispatch_async(dispatch_get_main_queue()) {

                    guard let realm = try? Realm() else {
                        return
                    }

                    tweetsData.forEach({ tweetInfo in

                        guard let
                            tweetID = tweetInfo["id_str"] as? String,
                            tweetCreatedDateString = tweetInfo["created_at"] as? String,
                            message = tweetInfo["text"] as? String,
                            userInfo = tweetInfo["user"] as? [NSObject: AnyObject],
                            userID = userInfo["id_str"] as? String,
                            userCreatedDateString = userInfo["created_at"] as? String,
                            username = userInfo["screen_name"] as? String,
                            avatarURLString = userInfo["profile_image_url_https"] as? String else {
                                return
                        }

                        let tweet = Tweet.getOrCreateWithTweetID(tweetID, inRealm: realm)

                        realm.write {
                            if let unixTime = self?.dateFormatter.dateFromString(tweetCreatedDateString)?.timeIntervalSince1970 {
                                tweet.createdUnixTime = unixTime
                            }
                            tweet.message = message
                        }

                        let user = User.getOrCreateWithUserID(userID, inRealm: realm)

                        realm.write {
                            if let unixTime = self?.dateFormatter.dateFromString(userCreatedDateString)?.timeIntervalSince1970 {
                                user.createdUnixTime = unixTime
                            }
                            user.username = username
                            user.avatarURLString = avatarURLString
                        }

                        realm.write {
                            tweet.creator = user
                        }
                    })

                    self?.tableView.reloadData()
                }
            }
        }
    }

    var realm: Realm!

    lazy var tweets: Results<Tweet> = {
        return self.realm.objects(Tweet).sorted("createdUnixTime", ascending: false)
        }()

    let tweetCellID = "TweetCell"

    private var tweetHeightHash = [String: CGFloat]()

    func heightOfTweet(tweet: Tweet) -> CGFloat {

        let key = tweet.tweetID

        if let height = tweetHeightHash[key] {
            return height

        } else {
            let height = TweetCell.heightOfTweet(tweet)

            if !key.isEmpty {
                tweetHeightHash[key] = height
            }

            return height
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        realm = try! Realm()

        title = "Timeline"

        tableView.registerNib(UINib(nibName: tweetCellID, bundle: nil), forCellReuseIdentifier: tweetCellID)
        tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

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

    // MARK: - TableView

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return tweets.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier(tweetCellID, forIndexPath: indexPath) as! TweetCell

        return cell
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {

        configureCell(cell as! TweetCell, atIndexPath: indexPath)
    }

    private func configureCell(cell: TweetCell, atIndexPath indexPath: NSIndexPath) {

        let tweet = tweets[indexPath.row]
        cell.configureWithTweet(tweet)
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        let tweet = tweets[indexPath.row]
        return heightOfTweet(tweet)
    }
}

