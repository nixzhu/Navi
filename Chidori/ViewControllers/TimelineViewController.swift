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
import CoreData
import Navi

class TimelineViewController: UITableViewController {

    lazy var coreDataStack = CoreDataStack()

    lazy var fetchedResultsController: NSFetchedResultsController = {

        let fetchRequest = NSFetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "createdUnixTime", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchBatchSize = 20

        let context = self.coreDataStack.context

        let tweetEntityDescription = NSEntityDescription.entityForName("Tweet", inManagedObjectContext: context)!
        fetchRequest.entity = tweetEntityDescription

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)

        fetchedResultsController.delegate = self

        return fetchedResultsController
        }()

    lazy var accountStore = ACAccountStore()

    private lazy var dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
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
                        return
                }
                //print("tweetsData: \(tweetsData)")

                dispatch_async(dispatch_get_main_queue()) {

                    guard let context = self?.coreDataStack.context else {
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

                        var tweet: Tweet?

                        let tweetRequest = NSFetchRequest(entityName: "Tweet")
                        tweetRequest.predicate = NSPredicate(format: "tweetID = %@", tweetID)

                        do {
                            if let tweets = try context.executeFetchRequest(tweetRequest) as? [Tweet] {
                                if tweets.isEmpty {
                                    let tweetEntityDescription = NSEntityDescription.entityForName("Tweet", inManagedObjectContext: context)!
                                    let newTweet = NSManagedObject(entity: tweetEntityDescription, insertIntoManagedObjectContext: context) as! Tweet

                                    newTweet.tweetID = tweetID
                                    newTweet.createdUnixTime = self?.dateFormatter.dateFromString(tweetCreatedDateString)?.timeIntervalSince1970 ?? NSDate().timeIntervalSince1970
                                    newTweet.message = message

                                    tweet = newTweet

                                } else {
                                    tweet = tweets.first
                                }
                            }

                        } catch let error as NSError {
                            print(error)
                        }

                        var user: User?

                        let userRequest = NSFetchRequest(entityName: "User")
                        userRequest.predicate = NSPredicate(format: "userID = %@", userID)

                        do {
                            if let users = try context.executeFetchRequest(userRequest) as? [User] {
                                if users.isEmpty {
                                    let userEntityDescription = NSEntityDescription.entityForName("User", inManagedObjectContext: context)!
                                    let newUser = NSManagedObject(entity: userEntityDescription, insertIntoManagedObjectContext: context) as! User

                                    newUser.userID = userID
                                    newUser.createdUnixTime = self?.dateFormatter.dateFromString(userCreatedDateString)?.timeIntervalSince1970 ?? NSDate().timeIntervalSince1970

                                    user = newUser

                                } else {
                                    user = users.first
                                }

                                // update
                                user?.username = username
                                user?.avatarURLString = avatarURLString
                            }

                        } catch let error as NSError {
                            print(error)
                        }

                        tweet?.user = user
                    })

                    context.trySave()
                }
            }
        }
    }

    let tweetCellID = "TweetCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Timeline"

        tableView.registerNib(UINib(nibName: tweetCellID, bundle: nil), forCellReuseIdentifier: tweetCellID)
        tableView.tableFooterView = UIView()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80

        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("fetchedResultsController.performFetch: \(error)")
        }
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

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier(tweetCellID, forIndexPath: indexPath) as! TweetCell

        configureCell(cell, atIndexPath: indexPath)

        return cell
    }

    private func configureCell(cell: TweetCell, atIndexPath indexPath: NSIndexPath) {

        let tweet = fetchedResultsController.objectAtIndexPath(indexPath) as! Tweet

        cell.configureWithTweet(tweet)
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TimelineViewController: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(controller: NSFetchedResultsController) {

        tableView.beginUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {

        switch type {

        case .Insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
            }

        case .Delete:
            if let indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }

        case .Move:
            if let indexPath = indexPath, newIndexPath = newIndexPath {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
            }

        case .Update:
            if let indexPath = indexPath, cell = tableView.cellForRowAtIndexPath(indexPath) as? TweetCell {
                configureCell(cell, atIndexPath: indexPath)
            }
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {

        tableView.endUpdates()
    }
}

