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

            syncLatestTweetsWithTwitterAccount(twitterAccount)
        }
    }

    private func syncLatestTweetsWithTwitterAccount(twitterAccount: ACAccount) {

        let homeTimelineURL = NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")!

        let parameters = [
            "count": 20,
        ]

        let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET, URL: homeTimelineURL, parameters: parameters)
        request.account = twitterAccount

        request.performRequestWithHandler { [weak self] data, response, error in

            defer {
                self?.refreshControl?.endRefreshing()
            }

            guard let
                data = data,
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

                var newTweets = [Tweet]()
                var newUsers = [User]()

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

                    let (tweetJustCreated, tweet) = Tweet.getOrCreateWithTweetID(tweetID, inRealm: realm)

                    if tweetJustCreated {
                        newTweets.append(tweet)
                    }

                    let _ = try? realm.write {
                        if let unixTime = self?.dateFormatter.dateFromString(tweetCreatedDateString)?.timeIntervalSince1970 {
                            tweet.createdUnixTime = unixTime
                        }
                        tweet.message = message
                    }

                    let (userJustCreated, user) = User.getOrCreateWithUserID(userID, inRealm: realm)

                    if userJustCreated {
                        newUsers.append(user)
                    }

                    let _ = try? realm.write {
                        if let unixTime = self?.dateFormatter.dateFromString(userCreatedDateString)?.timeIntervalSince1970 {
                            user.createdUnixTime = unixTime
                        }
                        user.username = username
                        user.avatarURLString = avatarURLString
                    }

                    let _ = try? realm.write {
                        tweet.creator = user
                    }
                })

                let insertIndexPaths: [NSIndexPath] = newTweets.map({ [weak self] tweet in

                    if let row = self?.tweets.indexOf(tweet) {
                        let indexPath = NSIndexPath(forRow: row, inSection: 0)
                        return indexPath
                    }

                    return nil

                    }).flatMap({ $0 })

                if insertIndexPaths.count == newTweets.count {
                    self?.tableView.insertRowsAtIndexPaths(insertIndexPaths, withRowAnimation: .Automatic)

                } else {
                    self?.tableView.reloadData()
                }

                if !newUsers.isEmpty {
                    NSNotificationCenter.defaultCenter().postNotificationName(Config.Notification.newUsers, object: newUsers)
                }
            }
        }
    }

    var realm: Realm!

    lazy var tweets: Results<Tweet> = {
        return self.realm.objects(Tweet).sorted("createdUnixTime", ascending: false)
        }()

    let tweetCellID = "TweetCell"

    // MARK: Heights

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

    private var tweetMessageHeightHash = [String: CGFloat]()

    func heightOfMessageInTweet(tweet: Tweet) -> CGFloat {

        let key = tweet.tweetID

        if let height = tweetMessageHeightHash[key] {
            return height

        } else {
            let height = TweetCell.heightOfTweetMessage(tweet.message)

            if !key.isEmpty {
                tweetMessageHeightHash[key] = height
            }

            return height
        }
    }

    // MARK: Life Circle

    override func viewDidLoad() {
        super.viewDidLoad()

        realm = try! Realm()

        title = "Timeline"

        tableView.registerNib(UINib(nibName: tweetCellID, bundle: nil), forCellReuseIdentifier: tweetCellID)
        tableView.tableFooterView = UIView()

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "syncLatestTweets", forControlEvents: .ValueChanged)

        self.refreshControl = refreshControl

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

    // MARK: Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "showProfile" {

            let vc = segue.destinationViewController as! ProfileViewController
            vc.user = sender as? User
        }
    }

    // MARK: Actions

    func syncLatestTweets() {

        guard let twitterAccount = twitterAccount else {
            return
        }
        syncLatestTweetsWithTwitterAccount(twitterAccount)
    }

    @IBAction func composeTweet(sender: UIBarButtonItem) {

        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {

            let tweet = SLComposeViewController(forServiceType: SLServiceTypeTwitter)

            tweet.completionHandler = { [weak self] result in
                if result == .Done {
                    self?.syncLatestTweets()
                }
            }

            presentViewController(tweet, animated: true, completion: nil)
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

        return tableView.dequeueReusableCellWithIdentifier(tweetCellID, forIndexPath: indexPath) as! TweetCell
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {

        configureCell(cell as! TweetCell, atIndexPath: indexPath)
    }

    private func configureCell(cell: TweetCell, atIndexPath indexPath: NSIndexPath) {

        let tweet = tweets[indexPath.row]
        cell.configureWithTweet(tweet, messageHeight: heightOfMessageInTweet(tweet))

        cell.delegate = self

        cell.showProfile = { [weak self] user in
            self?.performSegueWithIdentifier("showProfile", sender: user)
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        let tweet = tweets[indexPath.row]
        return heightOfTweet(tweet)
    }
}

// MARK: - TweetCellDelegate

extension TimelineViewController: TweetCellDelegate {
}

