//
//  Tweet+CoreDataProperties.swift
//  Chidori
//
//  Created by NIX on 15/10/2.
//  Copyright © 2015年 nixWork. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Tweet {

    @NSManaged var message: String?
    @NSManaged var tweetID: String?
    @NSManaged var createdUnixTime: NSNumber?
    @NSManaged var user: User?

}
